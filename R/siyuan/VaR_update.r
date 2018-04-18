setwd("C:/users/ychen/documents/git/working_dir/R/siyuan")
mydata = read.csv("perf_data.csv", stringsAsFactors=F)
nor=dim(mydata)[1]
noc=dim(mydata)[2]

WMat=matrix(c(0.1,0.1,0.2,0.2,0.2,0.2),nrow=1,ncol=6)
Cov1=as.vector(cov(mydata[,2:7],mydata[,2:7]))
CovMat1=matrix(Cov1, nrow = 6, ncol = 6, byrow = TRUE)
volatility1=WMat%*%CovMat1%*%t(WMat)
Z_alpha=qnorm(0.99,0,1)
#one value of VaR
VaR1=NULL
for (i in 2:7){
  VaR1[i]=(mean(mydata[,i])-volatility1*Z_alpha)*100
}
VaR1=VaR1[!is.na(VaR1)]

#Start to 10th
Cov=matrix(data=NA)
CovMat=matrix(data=NA, nrow=6, ncol=6)
volatility=NULL
avg_r=matrix(data=NA)
avg=matrix(data=NA)
for (i in 1:(nor-10)){
  Cov=as.vector(cov(mydata[i:(i+10),2:7],mydata[i:(i+10),2:7]))
  CovMat=matrix(Cov, nrow = 6, ncol = 6, byrow = TRUE)
  vol=WMat%*%CovMat%*%t(WMat)
  volatility=rbind(volatility,vol)
}
VaR=matrix(data=NA,nrow = 50, ncol = 6, byrow = TRUE)
for (j in 2:noc){
  for (t in 1:(nor-10)){
    VaR[t,(j-1)]=(mean(mydata[t:(t+10),j])-volatility[t]*Z_alpha)*100
  }
}
VaR=cbind((mydata[11:60,1]),VaR)
colnames(VaR) <- c('date','APEXGCE','HFRIEM','HFRIAWJ','HFRIEMNI','HFRIFWI','MXAP')
write.csv(VaR,"VaR_update.csv",row.names = F,quote = F )


