setwd("Z:/Proj/Trading/Amie Ma")
mydata = read.csv("project2_realign.csv", stringsAsFactors=F)
data_J=mydata[,2]
data_N=mydata[,3]
nob=dim(mydata)[1]

rt_1=NULL
rt_2=NULL
rt_1=matrix(0,nrow=1,ncol=1)
rt_2=matrix(0,nrow=1,ncol=1)

for (a in 2:nob){
  r_J=(data_J[a+1]-data_J[a])/data_J[a]
  rt_1=rbind(rt_1,r_J)
}
for (a in 2:nob){
  r_N=(data_N[a+1]-data_N[a])/data_N[a]
  rt_2=rbind(rt_2,r_N)
}
rt_J=as.vector(rt_1)
rt_N=as.vector(rt_2)

#zscore
zscore1=NULL
zscore1=scale(data_J[1:999],center=T,scale=T)
for (j in 1:3335){
  avr1=mean(rt_J[j:(1000+j)])
  sd1=sd(rt_J[j:(1000+j)])
  zs1=(rt_J[j]-avr1)/sd1
  zscore1=rbind(zscore1,zs1)
}
zscoreJ=as.vector(zscore1)

zscore2=NULL
zscore2=scale(data_N[1:999],center=T,scale=T)
for (t in 1:3335){
  avr2=mean(rt_N[t:(1000+t)])
  sd2=sd(rt_N[t:(1000+t)])
  zs2=(rt_N[t]-avr2)/sd2
  zscore2=rbind(zscore2,zs2)
}
zscoreN=as.vector(zscore2)

#correlation
corr=NULL
corr=matrix(1,nrow=259,ncol=1)
for (i in 1:4075){
  corl = cor(rt_J[i:(260+i)],rt_N[i:(260+i)])
  corr=rbind(corr,corl)
}
correlation=as.vector(corr)

#Granger Causaility
#install.packages("vars")
library(vars)
rt_J[is.na(rt_J)] <- 0
rt_N[is.na(rt_N)] <- 0
#hypothesis is that JPY doesn't Granger cause NYK
gc1=NULL
gc1=matrix(0,nrow=260,ncol=1)
rtj=NULL
rtn=NULL
for (i in 2:(nob-259)){
  for (j in 0:259){
    # rt=matrix()
    rtj[j+1]=rt_J[i+j]
    rtn[j+1]=rt_N[i+j]
  }
  
  var2.fit=VAR(cbind(rtj,rtn),p=2)
  v.cov=vcov(var2.fit)
  R=matrix(c(0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0),nrow=2,ncol=10,byrow=TRUE)
  avar=R%*%v.cov%*%t(R)
  
  temp.coef1=coef(var2.fit)$rtj
  new.coef1=rbind(temp.coef1[5,1],as.matrix(temp.coef1[1:4,1]))
  temp.coef2=coef(var2.fit)$rtn
  new.coef2=rbind(temp.coef2[5,1],as.matrix(temp.coef2[1:4,1]))
  vecPi=rbind(new.coef1,new.coef2)
  
  wald=t(R%*%vecPi)%*%solve(avar)%*%(R%*%vecPi)
  granger.causality=1-pchisq(wald,2)
  gc1=rbind(gc1,granger.causality)
  
}

#hypothesis is that NYK doesn't Granger cause JPY
gc2=NULL
gc2=matrix(0,nrow=260,ncol=1)

for (i in 2:(nob-259)){
  for (j in 0:259){
    # rt=matrix()
    rtj[j+1]=rt_J[i+j]
    rtn[j+1]=rt_N[i+j]
  }
  
  var2.fit=VAR(cbind(rtj,rtn),p=2)
  v.cov=vcov(var2.fit)
  R=matrix(c(0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0),nrow=2,ncol=10,byrow=TRUE)
  avar=R%*%v.cov%*%t(R)
  
  temp.coef1=coef(var2.fit)$rtj
  new.coef1=rbind(temp.coef1[5,1],as.matrix(temp.coef1[1:4,1]))
  temp.coef2=coef(var2.fit)$rtn
  new.coef2=rbind(temp.coef2[5,1],as.matrix(temp.coef2[1:4,1]))
  vecPi=rbind(new.coef1,new.coef2)
  
  wald=t(R%*%vecPi)%*%solve(avar)%*%(R%*%vecPi)
  granger.causality=1-pchisq(wald,2)
  gc2=rbind(gc2,granger.causality)
  
}

dataframe <- data.frame(mydata,rt_J,rt_N,correlation,zscoreJ,zscoreN,gc1,gc2)
dataframe[is.na(dataframe)] <- 0
write.csv(dataframe, "project2.csv")
