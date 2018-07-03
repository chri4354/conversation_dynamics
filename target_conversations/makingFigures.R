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

library(RColorBrewer)


for(cmv in (1:10)[-7]) {
  
  # Load Tree data
  D <- fread(paste0(dataDir, "cmv", cmv, "_fulltree_score.tsv"))
  n <- length(D$median_scores)
  
  # Load Tree structure
  
  
  # Construct color scheme
  
  
  # plot graph
  qgraph()
  
  
  
}


####### DEVVVV

library(grDevices)

layout(matrix(1:2,ncol=2), width = c(2,1),height = c(1,1))
plot(1:20, 1:20, pch = 19, cex=2, col = colfunc(20))

legend_image <- as.raster(matrix(colfunc(20), ncol=1))
plot(c(0,2),c(0,1),type = 'n', axes = F,xlab = '', ylab = '', main = 'legend title')
text(x=1.5, y = seq(0,1,l=5), labels = seq(0,1,l=5))
rasterImage(legend_image, 0, 0, 1,1)



# ------------------------------------------------------------------------------
# ---------- Pictures of CMV Author opinions -----------------------------------
# ------------------------------------------------------------------------------

# -------- Load Data for Initial Authors ---------------------------------------

dataDir <- "/Volumes/Macintosh HD 2/Dropbox/MyData/_PhD/__projects/conversation_dynamics/target_conversations/output_initialauthors/"


# -------- Plotting ------------------------------------------------------------








