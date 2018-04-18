library(zoo)            # Load the zoo package
library(xts)             # Load the xts package
#install.packages("PerformanceAnalytics")
#library(PerformanceAnalytics)

# Read the CSV files
pathname="E:/Apex/project3/project3/perf_data/input/"
list.universe=c("em","asia","mn","allhf")
u.option=4 #choose universe
u.name=list.universe[u.option]

#input the files
infile=paste(u.name,"_incep_ret.csv",sep="")#first, build the name of file
file.dir=paste(pathname,infile,sep="")#second, get the direction of file
raw.securities=read.csv(file.dir,header = FALSE, stringsAsFactors=F)#the data
setwd("E:/Apex/project3/project3/perf_data/input")
date=read.csv("date_ret_incep.csv",header = FALSE, stringsAsFactors=F)

########get fund data
nor=dim(raw.securities)[1]
ncol=dim(raw.securities)[2]
name.list=as.matrix(raw.securities[1,2:ncol])

bench=read.csv("bench_incep_ret.csv",header = FALSE, stringsAsFactors=F)
## the following line need to change, when you read in data from line 26, don't include the names
bench=cbind(as.numeric(bench[2:nor,2])/100,as.numeric(bench[2:nor,3])/100)

######Calculating
ann.rfrate=0.005
mon.rfrate=(1+ann.rfrate)^(1/12)-1

df.metrics.5=NULL  #calculated manually
df.metrics.incep=NULL

for (i in 2:ncol) { 
  
  df.ret=matrix(data=NA)
  df.date=matrix(data=NA)
  df.ret=as.numeric(raw.securities[2:nor,i])/100
  df.date=date[,2]

  #############benchmark remove NAs
  bench.cl.1=cbind(bench[!is.na(bench[,1]),1],bench[!is.na(bench[,1]),2])
  bench.cl=cbind(bench.cl.1[!is.na(bench.cl.1[,2]),1],bench.cl.1[!is.na(bench.cl.1[,2]),2])
  
  df.cl.ret1=df.ret[!is.na(bench[,1])]
  df.cl.ret=df.cl.ret1[!is.na(bench.cl.1[,2])]
  df.cl.date1=df.date[!is.na(bench[,1])]
  df.cl.date=df.cl.date1[!is.na(bench.cl.1[,2])]
  
  ##############returns remove NAs
  df.clean.ret=df.cl.ret[!is.na(df.cl.ret)]
  df.clean.date=df.cl.date[!is.na(df.cl.ret)]
  name.ret=name.list[i-1]
  mtx.date=as.matrix(df.clean.date)
  date.date=as.Date(mtx.date,format = "%m/%d/%Y")
  
  fund=as.matrix(df.clean.ret)
  nrows=dim(fund)[1]
  
  ######?????
  bench.cl.g1=bench.cl[,1]
  bench.cl.g2=bench.cl[,2]
  bench.clean=cbind(bench.cl.g1[!is.na(df.cl.ret)],bench.cl.g2[!is.na(df.cl.ret)])
##bench.clean=cbind(bench.xts[!is.na(df.ret),1],bench.xts[!is.na(df.ret),2])
  
  if (nrows>=55){
    
    n.periods=55
    trailing60.rows=(nrows-n.periods+1):nrows
    ret.60=fund[trailing60.rows]
    date.60=date.date[trailing60.rows]
    ret.bhf.60=bench.clean[trailing60.rows,1]
    ret.bidx.60=bench.clean[trailing60.rows,2]
    
    #manually calculate
    totalret.5=prod(ret.60+1)-1
    ann.ret.5=(totalret.5+1)^(12/n.periods)-1
    ann.std.5=sd(ret.60)*sqrt(12)
    downrisk.5=sd(ret.60[(ret.60<0)])*sqrt(12)
    v.cumret.5=matrix(1,nrow=n.periods+1,ncol=1)
    v.maxdd.5=matrix(0,nrow=n.periods,ncol=1)
    

    for (j in 2:(n.periods+1)){
      v.cumret.5[j]=v.cumret.5[j-1]*(ret.60[j-1]+1)
      v.maxdd.5[j-1]=v.cumret.5[j]/max(v.cumret.5[1:j])-1
    }
    drawdown.5=min(v.maxdd.5)
    sharpe.5=(ann.ret.5-ann.rfrate)/ann.std.5
    sortino.5=(ann.ret.5-ann.rfrate)/downrisk.5
  
    ####calculate info ratio
    excess.bhf.5=ret.60-ret.bhf.60
    totalret.excess.5=prod(excess.bhf.5+1)-1
    ann.excessret.5=(totalret.excess.5+1)^(12/n.periods)-1
    ann.excessstd.5=sd(excess.bhf.5)*sqrt(12)
    inforatio.5=ann.excessret.5/ann.excessstd.5
    
    ####calculate beta and alpha
    f.ret.zoo=zoo(ret.60,date.60)
    bidx.ret.zoo=zoo(ret.bidx.60,date.60)
    fnbidx.ret.zoo=merge(f.ret.zoo,bidx.ret.zoo,all=FALSE)
    colnames(fnbidx.ret.zoo)=c("f","b")

    bhf.ret.zoo=zoo(ret.bhf.60,date.60)
    fnbhf.ret.zoo=merge(f.ret.zoo,bhf.ret.zoo,all=FALSE)
    colnames(fnbhf.ret.zoo)=c("f","b")

    fit=lm(f~b,data=fnbidx.ret.zoo)
    alpha.5=coef(fit)[1]
    beta.5=coef(fit)[2]
    
    ####calculate correlation
    corr.bhf.5=cor(fnbhf.ret.zoo[,1],fnbhf.ret.zoo[,2])
    corr.bidx.5=cor(fnbidx.ret.zoo[,1],fnbidx.ret.zoo[,2])
    
    omega.5=Omega(ret.60)
    wl.5=length(which(ret.60>0))/n.periods
    skewness.5=skewness(ret.60)
    kurtosis.5=kurtosis(ret.60)
    
    omega.5=as.numeric(omega.5)
    #corr.bhf.5=as.numeric(corr.bhf.5)
    #corr.bidx.5=as.numeric(corr.bidx.5)
    temp.metrics.5=cbind(name.ret,ann.ret.5,ann.std.5,downrisk.5,drawdown.5
                                        ,sharpe.5,sortino.5,inforatio.5,alpha.5
                                        ,beta.5,corr.bhf.5,corr.bidx.5,omega.5
                                        ,wl.5,skewness.5,kurtosis.5)
    df.metrics.5=rbind(df.metrics.5,temp.metrics.5)
    
  }
}

outfile=paste(u.name,"_rcustom_output2.csv",sep="")
file.dir.out=paste(pathname,outfile,sep="")
#paste the name together to become whole name
write.csv(df.metrics.5, file.dir.out,row.names = F,quote = F )
