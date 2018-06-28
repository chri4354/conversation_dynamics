# jonashaslbeck@gmail.com; June 2018

# ------------------------------------------------------------------------------
# ---------- Load All Chain Data + Predictions ---------------------------------
# ------------------------------------------------------------------------------

dataDir <- "/Volumes/Macintosh HD 2/Dropbox/MyData/_PhD/__projects/conversation_dynamics/target_conversations/output/"
files <- list.files(dataDir)
n_files <- length(files)

l_data <- list()
for(i in 1:n_files) l_data[[i]] <- read.table(paste0(dataDir, files[i]), sep="\t")


read.table(file = paste0(dataDir, files[i]), 
           header = TRUE,
           sep = "\t")

?read.table


# ------------------------------------------------------------------------------
# ---------- Load All Chain Data + Predictions ---------------------------------
# ------------------------------------------------------------------------------


