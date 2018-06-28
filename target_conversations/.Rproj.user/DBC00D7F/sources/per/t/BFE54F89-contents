# jonashaslbeck@gmail.com; June 2018

# ------------------------------------------------------------------------------
# ---------- Load Data ------------------------------
# ------------------------------------------------------------------------------

## CMV Data
library(qgraph)
library(readr)
fileDir <- "/Volumes/Macintosh HD 2/Dropbox/MyData/_PhD/__projects/conversation_dynamics/target_conversations/"
D <- read_tsv(paste0(fileDir, "cmv2017.txt"))
dim(D)

D$author


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
# ---------- Apply -----------------------------------------------------------
# ------------------------------------------------------------------------------

# Select thread
# target_cmv <- "https://www.reddit.com/r/changemyview/comments/5ut6o3/cmv_abortion_is_wrong/"
target_cmv <- "https://www.reddit.com/r/changemyview/comments/5shhx3/cmv_i_am_not_prolife_nor_am_i_prochoice_i_am/"

id_which <- which(D$url == target_cmv)

# Create input list
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

# checks
dim(out$graph)
out$v_ids_out
length(un_authors)

# map authors to colors
un_authors <- unique(out$v_author)
un_authors <- cbind(un_authors, 1:length(un_authors))
authors_num <- out$v_author
for(i in 1:length(un_authors)) authors_num[authors_num == un_authors[i]] <- i
authors_num <- as.numeric(authors_num)


# ------------------------------------------------------------------------------
# ---------- Visualization -----------------------------------------------------
# ------------------------------------------------------------------------------

library(qgraph)

# pdf(paste0(fileDir, "cmv_abortion_is_wrong.pdf"), width = 10, height = 7)
pdf(paste0(fileDir, "cmv_i_am_not_a_pro-life.pdf"), width = 10, height = 7)
qgraph(out$graph, 
       # labels = out$v_ids_out, 
       labels = out$v_author, 
       color = colors()[367:length(colors())][authors_num])
mtext(target_cmv, 3, cex=1, line=3)
dev.off()



# ------------------------------------------------------------------------------
# ---------- Get chains --------------------------------------------------------
# ------------------------------------------------------------------------------

library(igraph)

# Get all Chains
n <- ncol(out$graph)
l_chains <- list()
out_igraph <- graph_from_adjacency_matrix(out$graph)

for(i in 2:n) {
  l_chains[[i]] <- as.numeric(all_simple_paths(out_igraph, 1, i)[[1]])
  print(i)
}

# Check out distribution of chain lengths
chain_dist <- unlist(lapply(l_chains, length))
hist(chain_dist)

ind_ord <- order(chain_dist, decreasing = TRUE)
chain_dist_order <- chain_dist[ind_ord]
head(chain_dist_order)

# Select longest chain



longest_10 <- ind_ord[1:10]


# ------------------------------------------------------------------------------
# ---------- Export Given Chain ------------------------------------------------
# ------------------------------------------------------------------------------


for(i in 1:10) {
  
  D_ss <- D[out$orig_rows[l_chains[[longest_10[i]]]] , ]
  D_ss_out <- cbind(D_ss$author, D_ss$body)
  D_ss_out[1, 2] <- D_ss$selftext[1]
  
  colnames(D_ss_out) <- c("author", "body")
  
  write.table(D_ss_out, file = paste0(fileDir, "output/cmv1_chain",i,".csv"), 
              sep = ",", row.names=FALSE)
  
}

# ------------------------------------------------------------------------------
# ---------- Troubleshooting ---------------------------------------------------
# ------------------------------------------------------------------------------

D_debug <- D[out$orig_rows, ]

write.table(D_debug, file = paste0(fileDir, "output/Debug_all274.csv"), 
            sep = ",", row.names=FALSE)




