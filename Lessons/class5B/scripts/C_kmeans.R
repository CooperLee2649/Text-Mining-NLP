#' Title: K Means
#' Purpose: apply k means clustering to text


# Wd
setwd("~/Desktop/hult_NLP_student/lessons/class6/data")

# Libs
library(tm)
library(clue)
library(cluster)
library(fst)
library(wordcloud)

# This is an orphaned lib which gives us plotcluster:
#https://www.rdocumentation.org/packages/fpc/versions/2.1-11.2
#library(fpc)

# Bring in our supporting functions
source('~/Desktop/hult_NLP_student/lessons/Z_otherScripts/ZZZ_plotCluster.R')
source('~/Desktop/hult_NLP_student/lessons/Z_otherScripts/ZZZ_supportingFunctions.R')

# Options & Functions
options(stringsAsFactors = FALSE)
Sys.setlocale('LC_ALL','C')

# Stopwords
stops  <- c(stopwords('SMART'), 'work')

# Read & Preprocess
txtMat <- cleanMatrix(pth = 'basicResumes.csv', 
                      columnName  = 'text', # text column name
                      collapse = F, 
                      customStopwords = stops, 
                      type = 'DTM', 
                      wgt = 'weightTfIdf') #weightTf or weightTfIdf

txtMat    <- scale(txtMat) #subtract mean  & divide by stDev
txtKMeans <- kmeans(txtMat, 3)
txtKMeans$size
barplot(txtKMeans$size, main = 'k-means')

plotcluster(cmdscale(dist(txtMat)),txtKMeans$cluster)

dissimilarityMat <- dist(txtMat)
silPlot          <- silhouette(txtKMeans$cluster, dissimilarityMat)
plot(silPlot, col=1:max(txtKMeans$cluster), border=NA)


#calculate indices of closest document to each centroid
idx <- vector()
for (i in 1:max(txtKMeans$cluster)){
  
  # Calculate the absolute distance between doc & cluster center
  absDist <- abs(txtMat[which(txtKMeans$cluster==i),] -  txtKMeans$centers[i,])
  
  # Check for single doc clusters
  if(is.null(nrow(absDist))==F){
    absDist <- rowSums(absDist)
    minDist <- subset(absDist, absDist==min(absDist))
  } else {
    minDist <- txtKMeans$cluster[txtKMeans$cluster==i]
  }
  idx[i] <- as.numeric(names(minDist))
}

# Notification of closest doc to centroid
cat(paste('cluster',1:max(txtKMeans$cluster),': centroid doc is ', idx,'\n'))

# End
