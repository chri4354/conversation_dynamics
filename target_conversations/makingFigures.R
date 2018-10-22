# jonashaslbeck@gmail.com; June 2018

require(data.table)
library(qgraph)

mainDir <- "/Volumes/Macintosh HD 2/Dropbox/MyData/_PhD/__projects/conversation_dynamics/target_conversations/"
figDir <- "/Volumes/Macintosh HD 2/Dropbox/MyData/_PhD/__projects/conversation_dynamics/target_conversations/figures/"

# ------------------------------------------------------------------------------
# ---------- Load All Chain Data + Predictions ---------------------------------
# ------------------------------------------------------------------------------



# ------------------------------------------------------------------------------
# ---------- Pictures of individual Chains -------------------------------------
# ------------------------------------------------------------------------------


# -------- Load Data for Chains ------------------------------------------------

dataDir <- "/Volumes/Macintosh HD 2/Dropbox/MyData/_PhD/__projects/conversation_dynamics/target_conversations/output_chains/"


# -------- Plotting ------------------------------------------------------------


library(plotrix)
library(RColorBrewer)

# Settings
node_radius <- .015
arrow_size <- .05
chain_counter <- 1
l_allChains <- list()

for(cmv in (1:10)[-7]) {
  for(chain in 1:10) {
    
    # ----- Prep Data -----
    
    # Load Chain
    D <- fread(paste0(dataDir, "cmv", cmv, "_chain", chain, "_score.tsv"))
    n <- length(D$median_scores)
    
    # Select colors for authors
    unique_authors <- unique(D$author)
    authors_fac <- as.numeric(as.factor(D$author))
    authors_fac_unique <- unique(authors_fac)
    n_authors <- length(unique(authors_fac))
    cols <- brewer.pal(n_authors, "Paired")
    
    # compute changing opinions
    m_opinion <- m_dp <- matrix(NA, ncol=n_authors, nrow = n)
    for(a in 1:n_authors) {
      for(i in 1:n) {
        if(D$author[i] == unique_authors[a]) {
          m_opinion[i, a] <- D$median_scores[i]
          m_dp[i, a] <- 1
        } else {
          if(i!=1) m_opinion[i, a] <- m_opinion[i-1, a]
        }
      }
    }
    
    
    # ----- Plotting -----
    
    pdf(paste0(figDir, "plot_cmv", cmv, "_chain", chain, ".pdf"), width = 6, height = 3)
    
    # define layout
    lmat <- matrix(1:4, nrow=2)
    lo <- layout(lmat, heights = c(.2, .8), widths = c(.1, .9))
    # layout.show(lo)
    
    # empty
    par(mar=rep(0,4))
    plot.new()
    plot.window(xlim=c(0,1), ylim=c(0,1))
    
    # legend left side
    par(mar=rep(0,4))
    plot.new()
    plot.window(xlim=c(0,1), ylim=c(0,1))
    arrows(x0 = .75, 
           y0 = 0, 
           x1 = .75, 
           y1 = 1, 
           code = 3, length=.15)
    text(x = .3, 
         y = 1-.15, 
         labels = "Pro Choice", 
         srt=90)
    text(x = .3, 
         y = 0+.15, 
         labels = "Pro Life", 
         srt=90)
    
    # chain graph plot 
    par(mar=rep(0,4))
    plot.new()
    plot.window(xlim=c(0,1), ylim=c(0,1))
    x_points <- seq(0, 1, length=n)
    
    # deltas <- D$deltas
    # deltas[is.na(deltas)] <- 0
    # deltas <- deltas / max(deltas)
    # cols_deltas <- rep("black", n)
    # cols_deltas[deltas!=0] <- "gold"
    
    for(i in 1:n) draw.circle(x = x_points[i],
                              y = .5, 
                              radius = node_radius, 
                              col = cols[authors_fac[i]])
    # border = cols_deltas[i],
    # lwd = 1+deltas[i])
    for(i in 1:(n-1)) arrows(x0 = x_points[i]+node_radius, 
                             y0 = .5,
                             x1 = x_points[i+1]-node_radius, 
                             y1 = .5, 
                             length = arrow_size)
    
    ## Opinion plot
    par(mar=rep(0,4))
    plot.new()
    plot.window(xlim=c(0,1), ylim=c(0,1))
    abline(h=c(0, .5, 1), lty=2, col="grey")
    
    for(a in 1:n_authors)  {
      lines(seq(0, 1, length=n), m_opinion[, a], col=cols[authors_fac_unique[a]], lwd=2)
      
      # only point when there is an actual data point
      points(seq(0, 1, length=n)[!is.na(m_dp[, a])], 
             m_opinion[!is.na(m_dp[, a]), a], 
             col=cols[authors_fac_unique[a]], 
             pch=20, 
             cex = 1.5)
    }
    
    
    dev.off()
    
    print(paste0("cmv: ", cmv, " chain: ", chain))
    
    # Save for statistial analysis
    l_allChains[[chain_counter]] <- m_opinion
    chain_counter <- chain_counter + 1
    
    
  } # end for: chain
} # end for: cmv


# Export opinion changes; used in ConvergenceAnalysis.R
saveRDS(l_allChains, file=paste0(mainDir, "files/ChainSummary.RDS"))


# ------------------------------------------------------------------------------
# ---------- Pictures of whole trees -------------------------------------------
# ------------------------------------------------------------------------------

# -------- Load Data for Trees ------------------------------------------------

dataDir <- "/Volumes/Macintosh HD 2/Dropbox/MyData/_PhD/__projects/conversation_dynamics/target_conversations/output_trees/"


# -------- Plotting ------------------------------------------------------------

# Find color scheme
library(grDevices)
colfunc <- colorRampPalette(c("red", "blue"))
cols <- colfunc(100)

# Loop over CMVs

for(cmv in (1:10)[-7]) {
  
  # Load Tree data
  D <- fread(paste0(mainDir, "output_trees/cmv", cmv, "_fulltree_score.tsv"))
  n <- length(D$median_scores)
  
  # Load Tree structure
  out <- readRDS(paste0(mainDir, "files/cmv_", cmv, "_graph.RDS"))
  
  # Define color vector
  col <- round(D$median_scores*100)
  colors <- cols[col]
  colors[is.na(colors)] <- "white"
  
  # plot graph
  pdf(paste0(figDir, "cmv_", cmv, "_OpinionAsColor.pdf"), width = 10, height = 7)
  
  layout(matrix(1:2,ncol=2), width = c(4,1), height = c(1,1))
  colfunc <- colorRampPalette(c("red", "blue"))
  
  qgraph(out$graph, 
         color = colors, 
         labels = out$v_author)
  
  legend_image <- as.raster(matrix(cols, ncol=1))
  par(mar = c(2, 0, 2, 0))
  plot.new()
  plot.window(xlim=c(-1,2), ylim=c(0,1))
  text(x=0.5, y = c(0, 1), labels = c("Pro Life", "Pro Choice"))
  rasterImage(legend_image, .1, .1, .9, .9)
  
  dev.off()
  
  print(cmv)
  
} # end for: cmv


# ------------------------------------------------------------------------------
# ---------- Pictures of CMV Author opinions -----------------------------------
# ------------------------------------------------------------------------------

# -------- Load Data for Initial Authors ---------------------------------------

dataDir <- "/Volumes/Macintosh HD 2/Dropbox/MyData/_PhD/__projects/conversation_dynamics/target_conversations/output_initialauthors/"


# -------- Plotting ------------------------------------------------------------

plot.new()

l_authors <- list()
counter_a <- 1

# Load Tree data
for(cmv in (1:10)[-7]) {
  
  D <- fread(paste0(mainDir, "output_initialauthors/cmv", cmv, "_initialauthor_score.tsv"))
  l_authors[[counter_a]] <- D
  counter_a <- counter_a + 1
  
} #end for: cmv

max_length <- max(unlist(lapply(l_authors, nrow)))

pdf(paste0(figDir, "InitialAuthor_All_Trajectories.pdf"), width = 10, height = 4)

# Setup layout
par(mar=c(2,3,1,1))
plot.new()
plot.window(xlim=c(1, max_length), ylim=c(0,1))
axis(2, c(0, .5, 1), las=2)
abline(h=c(0, .5, 1), lty=2, col="grey")
axis(1, c(1, 10, 20, 30, 41))

# Select colors
cols <- brewer.pal(9, "Paired")

# Plot lines
for(i in 1:9) {
  lines(l_authors[[i]]$median_scores, col = cols[i], lwd=2)
}

dev.off()

# --------- Plot seperately -------

# Plot lines
for(i in 1:9) {
  
  cmv <- (1:10)[-7]
  
  pdf(paste0(figDir, "InitialAuthor_cmv", cmv[i], "_Trajectory.pdf"), width = 10, height = 4)
  
  # Setup layout
  par(mar=c(2,3,1,1))
  plot.new()
  plot.window(xlim=c(1, max_length), ylim=c(0,1))
  axis(2, c(0, .5, 1), las=2)
  abline(h=c(0, .5, 1), lty=2, col="grey")
  axis(1, c(1, 10, 20, 30, 41))
  
  # Select colors
  cols <- brewer.pal(9, "Paired")
  
  lines(l_authors[[i]]$median_scores, col = cols[i], lwd=2)
  dev.off()
  
}




