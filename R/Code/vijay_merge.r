library(dplyr)
library(plyr)
factors <- c('S_','OP_','EPS_')
library(doBy)

#remove(period_stats)
#df_mydata  <- data.frame(mydata)
#remove(junk)

junk = sapply(factors, function(x){
  t  <- paste('^', x, '.+?F', sep="")
  tmp  <-  paste(grep(t, names(mydata), value=TRUE), collapse=" + ")
  tmp  <- paste("I(", tmp, ")", sep = "")
  tmp  <-  as.formula(paste(tmp, "Ticker", sep = " ~ "))
  stats = summaryBy(tmp, data=mydata,FUN=c(mean), na.rm=TRUE, var.names=paste(x, "mean", sep=""))
})
