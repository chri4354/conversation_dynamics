# jonashaslbeck@gmail.com; July 2018


# ------------------------------------------------------------------------------
# ---------- Load Data ---------------------------------------------------------
# ------------------------------------------------------------------------------

mainDir <- "/Volumes/Macintosh HD 2/Dropbox/MyData/_PhD/__projects/conversation_dynamics/target_conversations/"

l_allChains <- readRDS(paste0(mainDir, "files/ChainSummary.RDS"))


# ------------------------------------------------------------------------------
# ---------- Statistical Analysis: Convergence? --------------------------------
# ------------------------------------------------------------------------------

# For each chain: predict sd(opinions across authors) by time (corrected for number of authors)

# Aux vars
n_chains <- length(l_allChains)
l_slopes <- list()

# Loop over chains
for(i in 1:n_chains) {
  
  chain <- l_allChains[[i]]
  chain_length <- nrow(chain)
  if(chain_length > 3) { 
    
    # get variances across time
    sds <- apply(chain, 1, function(x) sd(x, na.rm = TRUE))[-1]
    
    # number of authors
    n_auth <- apply(chain, 1, function(x) sum(!is.na(x)) )[-1]
    
    # regression
    time <- 1:(chain_length-1)
    linmod <- lm(sds ~ time + n_auth)
    
    # save
    l_slopes[[i]] <- linmod$coefficients[2]
    
  } else {
    l_slopes[[i]] <- NULL
  }
  
}

v_slopes <- unlist(l_slopes)
length(v_slopes)

pdf(paste0(figDir, "hist_slopes.pdf"), width = 5, height = 4)
hist(v_slopes, main="slope: SD(opinion) predicted by time", xlab="slope value")
dev.off()

t.test(v_slopes)

