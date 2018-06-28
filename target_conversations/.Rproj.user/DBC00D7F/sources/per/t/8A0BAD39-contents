# jonashaslbeck@gmail.com; June 2018

# ----------------------------------------------------------------------------
# --------- Select Target Thread ---------------------------------------------
# ----------------------------------------------------------------------------

library(qgraph)
library(readr)
fileDir <- "/Volumes/Macintosh HD 2/Dropbox/MyData/_PhD/__projects/conversation_dynamics/target_conversations/"

D <- read_tsv(paste0(fileDir, "cmv2017.txt"))
dim(D)
class(D)
head(D)
class(D)

id_which <- which(D$url == "https://www.reddit.com/r/changemyview/comments/5ut6o3/cmv_abortion_is_wrong/")


# ----------------------------------------------------------------------------
# --------- Do all at once ---------------------------------------------------
# ----------------------------------------------------------------------------

# create whole graph by looping over all rows
# then break out the sub-graph we need; but: probably way too big ...



# ----------------------------------------------------------------------------
# --------- Extract Tree ---------------------------------------------
# ----------------------------------------------------------------------------

## Setup storage
n <- 1000 # from website: should be 107

m_tree <- matrix(0, n, n) # directed tree; clumn points to row
l_body <- list() # save the body
v_time <- rep(NA, n) # time
v_id <- rep(NA, n) # unique identifier

# Start with parent node
id_master <- v_id[1] <- D[id_which, ]$id

# find children
ind_child1 <- which(D$parent_id == id_master)
n_child1 <- length(ind_child1)

# fill in info of children
count_id <- sum(!is.na(v_id))
ids_last_tier <- D$id[ind_child1]
v_id[(count_id+1):(count_id+n_child1)] <- ids_last_tier

# Fill graph
filled_rows <- sum(apply(m_tree, 1, function(x) any(x==1)))
m_tree[(filled_rows+2):(filled_rows+n_child1+1), which(v_id == id_master)] <- 1

for(i in 1:n_child1) {
  
  master_i <- ids_last_tier[i]
  children_i <- which(D$parent_id == master_i) # get children
  
  if(length(children_i) > 0) {
    
    ids_tier_i <- D$id[children_i]
    count_id <- sum(!is.na(v_id))
    
    # adding new ids to v_id
    n_children_i <- length(ids_tier_i)
    v_id[(count_id+1):(count_id+1+n_children_i-1)] <- ids_tier_i
    
    # adding new children to network
    filled_rows <- sum(apply(m_tree, 1, function(x) any(x==1)))
    m_tree[(filled_rows+2):(filled_rows+n_children_i+1), which(v_id == master_i)] <- 1
    
  } # end if: any children?
  
} # end for: loop i; level 1


any(m_tree[26, 1:5] == 1)
sum(apply(m_tree, 1, function(x) any(x==1)))


# ----------------------------------------------------------------------------
# --------- Visualize --------------------------------------------------------
# ----------------------------------------------------------------------------

limit <- sum(!is.na(v_id))

library(qgraph)
pdf(paste0(fileDir, "networkplot_1.pdf"), 7, 7)
qgraph(m_tree[1:limit, 1:limit],
       labels = v_id[1:limit])
dev.off()



# ----------------------------------------------------------------------------
# --------- Try with data.tree ---------------------------------------------
# ----------------------------------------------------------------------------

install.packages("data.tree")
library(data.tree)









