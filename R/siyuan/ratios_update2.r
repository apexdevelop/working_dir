setwd("C:/users/ychen/documents/git/working_dir/R/siyuan")
mydata = read.csv("perf_data.csv", stringsAsFactors=F)
nor=dim(mydata)[1]
noc=dim(mydata)[2]
market=rbind('APEXGCE','HFRIEM','HFRIAWJ','HFRIEMNI','HFRIFWI','MXAP')
avg=as.matrix(as.vector(sapply(mydata[,2:7],mean)))
sdt=as.matrix(as.vector(sapply(mydata[,2:7],sd)))
data=matrix(data=NA, nrow=nor, ncol=noc-1)
ret=NULL
IR=NULL
car=NULL
for (i in 2:(noc-1)){
    for (j in 1:nor){
    data[j,i]=mydata[j,i]-mydata[j,7]
    }
  ret[i]=(prod(mydata[,i]+1)^(12/nor))-1
}
ret[7]=(prod(mydata[,7]+1)^(12/nor))-1
for (a in 1:(noc-2)){
  IR[a]=(ret[(a+1)]-ret[7])/(sd(data[,(a+1)])*sqrt(12))
}
IR=c(IR,'benchmark')

pos=NULL
neg=NULL
Omega=NULL
for (b in 2:noc){
  pos[b]=sum(mydata[which(mydata[,b]>0),b])
  neg[b]=sum(mydata[which(mydata[,b]<=0),b])
  Omega[b]=pos[b]/abs(neg[b])
}
Omega=Omega[!is.na(Omega)]

dr=NULL
Sortino=NULL
for (c in 2:noc){
  dr[c]=sd(mydata[which(mydata[,c]<0),c])*sqrt(12)
  Sortino[c]=(ret[c]-0.005)/dr[c]
}
Sortino=Sortino[!is.na(Sortino)]


dates=as.Date(mydata[,1], "%m/%d/%Y")
years=format(dates, "%Y")
Sterling=NULL
maxd=NULL
for (d in 1:(noc-1)){
  maxd[d]=mean(tapply(mydata[,(d+1)], years, min))
  Sterling[d]=ret[(d+1)]/abs(maxd[d]-0.1)
}

beta=NULL
Treynor=NULL
for (e in 1:(noc-1)){
  beta[e]=cor(mydata[,(e+1)],mydata[,7])*(sd(mydata[,(e+1)])/sd(mydata[,7]))
  Treynor[e]=(ret[(e+1)]-0.004)/beta[e]
}

dataframe <- data.frame(market,IR,Omega,Sortino,Sterling,Treynor)
write.csv(dataframe,"ratios_update.csv",row.names = F,quote = F )