# jonashaslbeck@gmail.com; June 2018

library(qgraph)
library(igraph)
library(readr)

# ------------------------------------------------------------------------------
# ---------- Load Data ---------------------------------------------------------
# ------------------------------------------------------------------------------

## CMV Data
dataDir <- "/Volumes/Macintosh HD 2/Dropbox/MyData/_PhD/__projects/CD_data/"
mainDir <- "/Volumes/Macintosh HD 2/Dropbox/MyData/_PhD/__projects/conversation_dynamics/target_conversations/"
figDir <- "/Volumes/Macintosh HD 2/Dropbox/MyData/_PhD/__projects/conversation_dynamics/target_conversations/figures/"
D <- read_tsv(paste0(dataDir, "cmv2017.txt"))

# ------------------------------------------------------------------------------
# ---------- Make Recursive Child Finder ---------------------------------------
# ------------------------------------------------------------------------------

ChildFinder <- function(inlist) {
  
  # browser()
  
  # get from list
  m_ids <- inlist$m_ids
  graph <- inlist$graph
  id_parent <- inlist$id_parent
  v_ids_out <- inlist$v_ids_out
  v_author <- inlist$v_author
  v_author <- inlist$v_author
  orig_rows <- inlist$orig_rows 
  
  # get child of master node
  child_i <- which(m_ids[, 2] == id_parent)
  n_child_n <- length(child_i)
  
  row_parent <- which(v_ids_out == id_parent)
  starter <- 1 + sum(graph[row_parent, ])
  
  # only loop of there are children left
  if(!(starter > n_child_n)) {
    
    # loop over children
    for(i in starter:n_child_n) {
      
      ## add child to graph
      graph2 <- matrix(0, ncol(graph)+1, ncol(graph)+1)
      graph2[1:ncol(graph), 1:ncol(graph)] <- graph
      graph2[row_parent, ncol(graph)+1] <- 1
      graph <- graph2
      v_ids_out <- c(v_ids_out, m_ids[child_i[i], 1])
      v_author <- c(v_author, D$author[child_i[i]])
      orig_rows <- c(orig_rows, child_i[i])
      
      
      inlist <- list("m_ids" = m_ids,
                     "graph" = graph,
                     "id_parent" = m_ids[child_i[i], 1], 
                     "v_ids_out" = v_ids_out,
                     "v_author" = v_author, 
                     "orig_rows" = orig_rows)
      
      child_of_child <-  which(m_ids[, 2] == m_ids[child_i[i], 1])
      # if child has children, go deeper
      if(length(child_of_child) > 0) {
        
        return(ChildFinder(inlist))
        
      } # end if: are there children?
      
    } # end for: loop over children
    
  } # end if: do we still have children at this level?
  
  
  # get parent of parent
  # if(ncol(graph) == 5) browser()
  id_parent_parent <- which(graph[, row_parent] == 1)
  if(length(id_parent_parent)==0) return(inlist)
  
  inlist <- list("m_ids" = m_ids,
                 "graph" = graph,
                 "id_parent" = v_ids_out[id_parent_parent], # go one parent up
                 "v_ids_out" = v_ids_out,
                 "v_author" = v_author, 
                 "orig_rows" = orig_rows) 
  
  return(ChildFinder(inlist))  
  
} # EoF


# ------------------------------------------------------------------------------
# ---------- Global Settings ---------------------------------------------------
# ------------------------------------------------------------------------------

## Select Threads
df_simon <- read_csv(paste0(mainDir, "CMV_TopAbortionThread.csv"))
target_cmvs <- df_simon$url[1:10]
n_cmv <- length(target_cmvs)

## k longest chains?
k <- 10


# ------------------------------------------------------------------------------
# ---------- Loop over CMVs: Create tree ---------------------------------------
# ------------------------------------------------------------------------------


for(j in (1:n_cmv)[-7]) {
  
  # ---------- 1) Compute Tree ----------------------------------------
  
  # Select cmv
  target_cmv <- target_cmvs[j]
  
  # Create input list
  id_which <- which(D$url == target_cmv)
  m_ids <- cbind(D$id, D$parent_id)
  id_parent <- D$id[id_which]
  graph <- matrix(0, 1, 1)
  v_author <- D$author[id_which]
  orig_rows <- id_which
  
  inlist <- list("m_ids" = m_ids,
                 "graph" = graph,
                 "id_parent" = id_parent, 
                 "v_ids_out" = id_parent,
                 "v_author" = v_author, 
                 "orig_rows" = orig_rows)
  
  # Call the function
  out <- ChildFinder(inlist)
  
  # map authors to colors
  un_authors <- unique(out$v_author)
  un_authors <- cbind(un_authors, 1:length(un_authors))
  authors_num <- out$v_author
  for(i in 1:length(un_authors)) authors_num[authors_num == un_authors[i]] <- i
  authors_num <- as.numeric(authors_num)
  
  
  # ---------- 2) Visualize Tree ----------------------------------------
  
  pdf(paste0(figDir, "cmv", j,".pdf"), width = 10, height = 7)
  qgraph(out$graph, 
         # labels = out$v_ids_out, 
         labels = out$v_author, 
         color = colors()[1:length(colors())][authors_num])
  mtext(target_cmv, 3, cex=1, line=3)
  dev.off()
  
  # Save Graph
  saveRDS(out, file=paste0(mainDir, "files/cmv_", j, "_graph.RDS"))
  
  # progress:
  print(j)
  
  
} # end for: cmv




# ------------------------------------------------------------------------------
# ---------- Loop over CMVs: Extract Chains/Full trees/InitialAuthor -----------
# ------------------------------------------------------------------------------

for(j in (1:n_cmv)[-7]) {  
  
  # Load Tree data
  out <- readRDS(file=paste0(mainDir, "files/cmv_", j, "_graph.RDS"))
  
  # ---------- 3) Export data of whole Tree ----------------------------------------
  
  # ----- 3.1) Whole Tree ----
  
  # Subset Data
  D_ss <- data.frame(matrix(NA, nrow=ncol(out$graph), ncol=13))
  for(s in 1:ncol(out$graph)) D_ss[s, ] <- D[D$id == out$v_ids_out[s], ]
  colnames(D_ss) <- colnames(D)
  
  deltas <- as.numeric(gsub("([0-9]+).*$", "\\1", D_ss$author_flair_text))
  D_ss_out <- cbind(D_ss$id, D_ss$author, deltas, D_ss$body)
  D_ss_out[1, 4] <-  D_ss$selftext[1]
  colnames(D_ss_out) <- c("id", "author", "deltas", "body")
  
  # Save 
  write.table(D_ss_out, 
              file = paste0(mainDir, "output_trees/cmv" ,j ,"_fulltree.tsv"), 
              sep = "\t", 
              row.names=FALSE)
  
  
  # ----- 3.2) Initial Author Data ----
  
  author <- out$v_author[1]
  author_n <- sum(D_ss$author == author)
  
  D_author <- data.frame(matrix(NA, nrow=author_n, ncol=13))
  ind_author <- which(D_ss$author == author)
  for(s in 1:author_n) D_author[s, ] <- D_ss[ind_author[s], ]
  colnames(D_author) <- colnames(D_ss)
  
  deltas <- as.numeric(gsub("([0-9]+).*$", "\\1", D_author$author_flair_text))
  D_author_out <- cbind(D_author$id, D_author$author, deltas, D_author$body)
  D_author_out[1, 4] <-  D_author$selftext[1]
  colnames(D_author_out) <- c("id", "author", "deltas", "body")
  
  # Save 
  write.table(D_author_out, 
              file = paste0(mainDir, "output_initialauthors/cmv", j, "_initialauthor.tsv"), 
              sep = "\t", 
              row.names=FALSE)
  
  
  
  # ---------- 4) Export k longest Chains ----------------------------------------
  
  # Get all Chains
  n <- ncol(out$graph)
  graph_cut <- out$graph
  id_cut <- out$v_ids_out
  k_chains <- list()
  
  for(ki in 1:k) {
    
    # make igraph object
    graph_cut_igraph <- graph_from_adjacency_matrix(graph_cut)
    n_cut <- ncol(graph_cut)
    
    # extract longest chain
    l_chains <- list()
    for(i in 2:n_cut) {
      chain <- all_simple_paths(graph_cut_igraph, 1, i)
      if(length(chain)>0) {
        l_chains[[i]] <- as.numeric(chain[[1]]) 
      } else {
        l_chains[[i]] <- NULL
      }
    } 
    chain_dist <- unlist(lapply(l_chains, length))
    ind_ord <- order(chain_dist, decreasing = TRUE)
    k_chains[[ki]] <- id_cut[l_chains[[ind_ord[1]]]] # save longest chain
    
    # cut longest chain from graph & update graph
    cut <- l_chains[[ind_ord[1]]][-1]
    graph_cut <- graph_cut[-cut, -cut]
    id_cut <- id_cut[-cut]
    
  }
  
  # Export k chains
  for(i in 1:k) {
    
    # Subset Data
    D_ss <- data.frame(matrix(NA, nrow=length(k_chains[[i]]), ncol=13))
    for(s in 1:length(k_chains[[i]])) D_ss[s, ] <- D[D$id == k_chains[[i]][s], ]
    colnames(D_ss) <- colnames(D)
    
    deltas <- as.numeric(gsub("([0-9]+).*$", "\\1", D_ss$author_flair_text))
    D_ss_out <- cbind(D_ss$id, D_ss$author, deltas, D_ss$body)
    D_ss_out[1, 4] <-  D_ss$selftext[1]
    colnames(D_ss_out) <- c("id", "author", "deltas", "body")
    
    write.table(D_ss_out, file = paste0(mainDir, "output_chains/cmv" ,j ,"_chain" ,i ,".tsv"), 
                sep = "\t", row.names=FALSE)
    
  } # end for: chains
  
  # progress:
  print(j)
  
} # end for: loop over cmvs


