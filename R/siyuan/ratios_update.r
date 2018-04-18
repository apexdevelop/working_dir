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
Information_Ratio=NULL
for (i in 2:(noc-1)){
    for (j in 1:nor){
    data[j,i]=mydata[j,i]-mydata[j,7]
  }
}
for (a in 1:(noc-2)){
  ret[a]=avg[a]-avg[6]
  IR[a]=ret[a]/sd(data[,(a+1)])
}
IR=c(IR,"benchmark")

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
  dr[c]=sd(mydata[which(mydata[,c]<0),c])
  Sortino[c]=(avg[c-1]-0.005)/dr[c]
}
Sortino=Sortino[!is.na(Sortino)]

dates=as.Date(mydata[,1], "%m/%d/%Y")
years=format(dates, "%Y")
car=NULL
Sterling=NULL
maxd=NULL
rtn=NULL
for (d in 2:noc){
  maxd[d]=mean(tapply(mydata[,d], years, min))
  rtn=mydata[,d]+1
  car[d]=((prod(rtn[d])^(12/nor)))-1 
  #here starts mydata[2,], because R doesn't count automatically the lable
  #car is the compound annual ratio
  Sterling[d]=car[d]/abs(maxd[d]-0.1)
}
Sterling=Sterling[!is.na(Sterling)]

beta=NULL
Treynor=NULL
car2=NULL
for (e in 1:(noc-1)){
  beta[e]=cor(mydata[,(e+1)],mydata[,7])*(sd(mydata[,(e+1)])/sd(mydata[,7]))
  Treynor[e]=(car[(e+1)]-0.004)/beta[e]
}

dataframe <- data.frame(market,IR,Omega,Sortino,Sterling,Treynor)
write.csv(dataframe,"ratios_update.csv",row.names = F,quote = F )





# beta=cor(mydata[,3],mydata[,7])*(sd(mydata[,3])/sd(mydata[,7]))
# rtn3=mydata[,3]+1
# car3=((prod(rtn3[3])^(12/nor)))-1
# Treynor=(car3-0.005)/beta
