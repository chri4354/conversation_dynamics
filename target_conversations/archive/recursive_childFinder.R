# jonashaslbeck@gmail.com; June 2018

# ------------------------------------------------------------------------------
# ---------- Make artificial directed chain graph ------------------------------
# ------------------------------------------------------------------------------

# Synthetic data
n <- 10
m_ids <- matrix(0, nrow=n, ncol=2)
m_ids[, 1] <- 1:n

m_ids[2, 2] <- 1
m_ids[3:4, 2] <- 2
m_ids[5, 2] <- 1
m_ids[6:7, 2] <- 5
m_ids[8:9, 2] <- 7
m_ids[10, 2] <- 9

colnames(m_ids) <- c("id", "parent_id")

# Input
id_parent <- m_ids[1, 1]
graph <- matrix(0, 1, 1)

inlist <- list("m_ids" = m_ids,
               "graph" = graph,
               "id_parent" = id_parent)


# ------------------------------------------------------------------------------
# ---------- Make Recursive Child Finder ---------------------------------------
# ------------------------------------------------------------------------------

ChildFinder <- function(inlist) {
  
  # browser()
  
  m_ids <- inlist$m_ids
  graph <- inlist$graph
  id_parent <- inlist$id_parent
  
  # get child of master node
  child_i <- which(m_ids[, 2] == id_parent)
  n_child_n <- length(child_i)
  
  starter <- 1 + sum(graph[id_parent, ])
  
  # end condition
  # if(id_parent == 1 & starter > n_child_n) return(inlist)
  
  if(!(starter > n_child_n)) {
    
    for(i in starter:n_child_n) {
      
      ## add child to graph
      graph2 <- matrix(0, ncol(graph)+1, ncol(graph)+1)
      graph2[1:ncol(graph), 1:ncol(graph)] <- graph
      graph2[id_parent, ncol(graph)+1] <- 1
      graph <- graph2
      
      inlist <- list("m_ids" = m_ids,
                     "graph" = graph,
                     "id_parent" = child_i[i])
      
      child_of_child <-  which(m_ids[, 2] == child_i[i])
      # if child has children, go deeper
      if(length(child_of_child) > 0) {
        
        return(ChildFinder(inlist))
        
      } # end if: are there children?
      
    } # end for: loop over children
    
  }# end if: do we still have children at this level?
  
  
  # get parent of parent
  # if(ncol(graph) == 5) browser()
  id_parent_parent <- which(graph[, id_parent] == 1)
  if(length(id_parent_parent)==0) return(inlist)
  
    inlist <- list("m_ids" = m_ids,
                   "graph" = graph,
                   "id_parent" = id_parent_parent) # fill in NEXT parent here
    
    return(ChildFinder(inlist))  

} # EoF


# ------------------------------------------------------------------------------
# ---------- Testing -----------------------------------------------------------
# ------------------------------------------------------------------------------


inlist <- list("m_ids" = m_ids,
               "graph" = graph,
               "id_parent" = id_parent)

out <- ChildFinder(inlist)
qgraph(out$graph)


# ------------------------------------------------------------------------------
# ---------- Visualization -----------------------------------------------------
# ------------------------------------------------------------------------------

library(qgraph)
qgraph(out$graph)





