library(zoo)            # Load the zoo package
library(xts)             # Load the xts package
#install.packages("PerformanceAnalytics")
library(PerformanceAnalytics)

# Read the CSV files
pathname="Z:/Proj/Trading/Amie Ma/project3/perf_data/input/"
list.universe=c("em","asia","mn","allhf")
u.option=1 #choose universe
u.name=list.universe[u.option]

#input the files
infile=paste(u.name,"_incep_ret.csv",sep="")#first, build the name of file
file.dir=paste(pathname,infile,sep="")#second, get the direction of file
raw.securities=read.csv(file.dir,header = FALSE, stringsAsFactors=F)#the data
setwd("Z:/Proj/Trading/Amie Ma/project3/perf_data/input")
date=read.csv("date_ret_incep.csv",header = FALSE, stringsAsFactors=F)

########get fund data

list.ret=as.matrix(raw.securities)
list.date=as.matrix(date[2:63,2])
n.sec=dim(list.ret)[1]
n.col=dim(list.ret)[2]
name.list=as.matrix(raw.securities[1,2:n.col])

bench=read.csv("bench_incep_ret.csv",header = FALSE, stringsAsFactors=F)
## the following line need to change, when you read in data from line 26, don't include the names
bench.xts=cbind(as.numeric(bench[2:n.sec,2]),as.numeric(bench[2:n.sec,3]))

######Calculating
ann.rfrate=0.005
mon.rfrate=(1+ann.rfrate)^(1/12)-1

df.metrics.5=NULL  #calculated manually
df.metrics.incep=NULL


for (i in 11:11) { 
  df.ret=matrix(data=NA)
  df.date=matrix(data=NA)

  df.ret=as.numeric(list.ret[2:n.sec,i])/100
  df.date=list.date#list.date here only has one col
  
  df.clean.ret=df.ret[!is.na(df.ret)]
  df.clean.date=as.Date(df.date[!is.na(df.ret)],format = "%m/%d/%Y")
  f.ret.zoo=zoo(df.clean.ret,df.clean.date)
  
  fund.xts=as.matrix(df.clean.ret)
  nrows=dim(fund.xts)[1]
  
  bench.hf=bench.xts[,1]
  bench.clean.hf=bench.xts[!is.na(bench.hf),1]
  bench.clean.hf.date=as.Date(df.date[!is.na(bench.hf)],format = "%m/%d/%Y")
  
  bhf.ret.zoo=zoo(bench.clean.hf,bench.clean.hf.date)
  fnbhf.ret.zoo=merge(f.ret.zoo,bhf.ret.zoo,all=FALSE)
  colnames(fnbhf.ret.zoo)=c("f","bhf")
  
  bench.idx=bench.xts[,2]
  bench.clean.idx=bench.xts[!is.na(bench.idx),2]
  bench.clean.idx.date=as.Date(df.date[!is.na(bench.idx)],format = "%m/%d/%Y")
  
  bidx.ret.zoo=zoo(bench.clean.idx,bench.clean.idx.date)
  fnbidx.ret.zoo=merge(f.ret.zoo,bidx.ret.zoo,all=FALSE)
  colnames(fnbidx.ret.zoo)=c("f","bidx")
  
  
  ##############################################
  
  if (nrows>=60){
    ####calculate absolute analytics(no benchmark involved)##########
    n.periods=60
    trailing60.rows=(nrows-n.periods+1):nrows
    ret.60=fund.xts[trailing60.rows]
    date.60=df.clean.date[trailing60.rows]
    
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
    
    omega.5=Omega(ret.60)
    wl.5=length(which(ret.60>0))/n.periods
    skewness.5=skewness(ret.60)
    kurtosis.5=kurtosis(ret.60)
    
    ####calculate relative analytics(benchmark involved)##########<----
    
    ####calculate info ratio##########<----
    nfit.hf.row=dim(fnbhf.ret.zoo)[1]
    if (nfit.hf.row>=60){
      trailing60.fit=(nfit.hf.row-n.periods+1):nfit.hf.row
      
      excess.bhf.5=fnbhf.ret.zoo[trailing60.fit,1]-fnbhf.ret.zoo[trailing60.fit,2]
      totalret.excess.5=prod(excess.bhf.5+1)-1
      ann.excessret.5=(totalret.excess.5+1)^(12/n.periods)-1
      ann.excessstd.5=sd(excess.bhf.5)*sqrt(12)
      inforatio.5=ann.excessret.5/ann.excessstd.5
    
    ####calculate correlation############## <-----------
      corr.bhf.5=cor(fnbhf.ret.zoo[trailing60.fit,1],fnbhf.ret.zoo[trailing60.fit,2])
    } else {
      inforatio.5=NA
      corr.bhf.5=NA
    }
    ####calculate beta and alpha
    nfit.idx.row=dim(fnbidx.ret.zoo)[1]
    if (nfit.idx.row>=60){
      fit=lm(f~bidx,data=fnbidx.ret.zoo)
      alpha.5=coef(fit)[1]
      beta.5=coef(fit)[2]
      corr.bidx.5=cor(fnbidx.ret.zoo[,1],fnbidx.ret.zoo[,2])
    } else {
      alpha.5=NA
      beta.5=NA
      corr.bidx.5=NA
    }

    fund.name=name.list[i]
    
    
    omega.5=as.numeric(omega.5)
    temp.metrics.5=as.data.frame(cbind(ann.ret.5,ann.std.5,downrisk.5,drawdown.5
                                        ,sharpe.5,sortino.5,inforatio.5,alpha.5
                                        ,beta.5,corr.bhf.5,corr.bidx.5,omega.5
                                        ,wl.5,skewness.5,kurtosis.5),row.names=fund.name)
    df.metrics.5=rbind(df.metrics.5,temp.metrics.5)
    
  }
}

outfile=paste(u.name,"_rcustom_output2.csv",sep="")
file.dir.out=paste(pathname,outfile,sep="")
#paste the name together to become whole name
write.csv(df.metrics.5, file.dir.out)
