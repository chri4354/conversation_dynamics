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
D <- read_tsv(paste0(dataDir, "cmv2017.txt"))
dim(D)

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
# ---------- Loop over CMVs: Create graph & Extract Chains ---------------------
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
  
  pdf(paste0(mainDir, "/output_trees/cmv", j,".pdf"), width = 10, height = 7)
  qgraph(out$graph, 
         # labels = out$v_ids_out, 
         labels = out$v_author, 
         color = colors()[1:length(colors())][authors_num])
  mtext(target_cmv, 3, cex=1, line=3)
  dev.off()
  
  
  
  # ---------- 3) Export k longest Chains ----------------------------------------

  # Get all Chains
  n <- ncol(out$graph)
  l_chains <- list()
  out_igraph <- graph_from_adjacency_matrix(out$graph)
  
  for(i in 2:n) {
    l_chains[[i]] <- as.numeric(all_simple_paths(out_igraph, 1, i)[[1]])
    # print(i)
  }
  
  # Check out distribution of chain lengths
  chain_dist <- unlist(lapply(l_chains, length))
  hist(chain_dist)
  
  ind_ord <- order(chain_dist, decreasing = TRUE)
  chain_dist_order <- chain_dist[ind_ord]

  # Select longest 10 chains
  longest_k <- ind_ord[1:k]
  
  
  # Export k chains
  for(i in 1:k) {
    
    D_ss <- D[out$orig_rows[l_chains[[longest_k[i]]]] , ]
    D_ss_out <- cbind(D_ss$author, D_ss$score, D_ss$body)
    D_ss_out[1, 3] <- D_ss$selftext[1]
    
    colnames(D_ss_out) <- c("author", "score", "body")
    
    write.table(D_ss_out, file = paste0(mainDir, "output_chains/cmv" ,j ,"_chain" ,i ,".tsv"), 
                sep = "\t", row.names=FALSE)
     
  } # end for: chains
  
  
  # progress:
  print(j)
  
} # end for: loop over cmvs




# ------------------------------------------------------------------------------
# ---------- Visualization -----------------------------------------------------
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# ---------- Get chains --------------------------------------------------------
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# ---------- Export Given Chain ------------------------------------------------
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# ---------- Troubleshooting ---------------------------------------------------
# ------------------------------------------------------------------------------

# D_debug <- D[out$orig_rows, ]
# 
# write.table(D_debug, file = paste0(fileDir, "output/Debug_all274.csv"), 
#             sep = ",", row.names=FALSE)




