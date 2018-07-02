# jonashaslbeck@gmail.com; June 2018

# ------------------------------------------------------------------------------
# ---------- Load All Chain Data + Predictions ---------------------------------
# ------------------------------------------------------------------------------

dataDir <- "/Volumes/Macintosh HD 2/Dropbox/MyData/_PhD/__projects/conversation_dynamics_local/target_conversations/output_chains/"
files <- list.files(dataDir)
ind_withscores <- grepl("score", files)
files <- files[ind_withscores] 
n_files <- length(files)

l_data <- list()
for(i in 1:n_files) l_data[[i]] <- read.table(paste0(dataDir, files[i]), sep="\t")

read.table(file = paste0(dataDir, files[i]))
out_score <- read.csv(file = paste0(dataDir, "cmv1_chain1_scoreXX.csv"))


# ------------------------------------------------------------------------------
# ---------- Load All Chain Data + Predictions ---------------------------------
# ------------------------------------------------------------------------------


