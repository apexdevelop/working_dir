library(zoo)            # Load the zoo package
library(xts)             # Load the xts package
library(PerformanceAnalytics)
# Read the CSV files
pathname="C:/Users/YChen/Documents/git/working_dir/R/Data/"
list.universe=c("em","asia","mn","allhf")
u.option=3#choose universe
u.name=list.universe[u.option]

infile=paste(u.name,"_list.csv",sep="")


file.dir=paste(pathname,infile,sep="")


#bret.file="bench_incep_ret.csv"
#file.dir.bret=paste(pathname,bret.file,sep="")

#date.file="date_ret_incep.csv"
#file.dir.date=paste(pathname,date.file,sep="")

raw.securities = read.csv(file.dir,header = FALSE, stringsAsFactors=F)
#raw_securities ="PACAPRV KY Equity"
securities=as.matrix(raw.securities)
securities=as.matrix(sort(securities))
n.sec=dim(securities)[1]

library(Rbbg)
conn=blpConnect()
fields=c("CHG_PCT_1D")

start_date="2012-09-01"
#end_date="2017-06-30"
end_date=Sys.Date()
start.date = as.POSIXct(start_date)
end.date = as.POSIXct(end_date)

########get fund data
x.h=bdh(conn,securities,fields,start.date,end.date,option_names = "periodicitySelection", option_values = "MONTHLY",always.display.tickers = TRUE)
list.ret=unstack(x.h,CHG_PCT_1D~ticker)
list.date=unstack(x.h,date~ticker)
name.list=as.matrix(names(list.ret))
# n.sec=dim(name.list)[1]

#######get benchmark data
benchmark=c("HFRIFWI Index","MXWO Index")
bench.h=bdh(conn,benchmark,fields,start.date,end.date,option_names = "periodicitySelection", option_values = "MONTHLY",always.display.tickers = TRUE)
list.b.ret=unstack(bench.h,CHG_PCT_1D~ticker)
list.b.date=unstack(bench.h,date~ticker)
df.b.ret=as.data.frame(list.b.ret/100)####### <----
df.b.date=as.data.frame(list.b.date[1])
mtx.b.date=as.matrix(df.b.date)
date.b.date=as.Date(mtx.b.date)
bench.xts=xts(df.b.ret,date.b.date)
nrows.b=dim(bench.xts)[1]

######Calculating
ann.rfrate=0.005
mon.rfrate=(1+ann.rfrate)^(1/12)-1

df.metrics.5=NULL  #calculated manually
df.metrics.incep=NULL

for (i in 1:n.sec) {
  df.ret=as.data.frame(list.ret[i]/100)
  df.date=as.data.frame(list.date[i])
  #df.ret=as.data.frame(list_ret["DERNMOF.US.Equity"]/100)
  #df.date=as.data.frame(list_date["DERNMOF.US.Equity"])
  df.clean.ret=as.data.frame(df.ret[!is.na(df.ret)])
  colnames(df.clean.ret)=colnames(df.ret)
  df.clean.date=as.data.frame(df.date[!is.na(df.ret)])
  colnames(df.clean.date)=colnames(df.ret)
  mtx.date=as.matrix(df.clean.date)
  date.date=as.Date(mtx.date)
  fund.xts=xts(df.clean.ret,date.date)
  nrows=dim(fund.xts)[1]
  
  bench.clean.xts=bench.xts[!is.na(df.ret)]
  
  if (nrows>=60){
    n.periods=60
    trailing60.rows=(nrows-n.periods+1):nrows
    ret.60=fund.xts[trailing60.rows]
    date.60=date.date[trailing60.rows]
    ret.bhf.60=bench.clean.xts[trailing60.rows,1]
    ret.bidx.60=bench.clean.xts[trailing60.rows,2]
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
    
    
    fund.name=colnames(ret.60)
    
    
    omega.5=as.numeric(omega.5)
    #corr.bhf.5=as.numeric(corr.bhf.5)
    #corr.bidx.5=as.numeric(corr.bidx.5)
    temp.metrics.5=as.data.frame(cbind(ann.ret.5,ann.std.5,downrisk.5,drawdown.5
                                        ,sharpe.5,sortino.5,inforatio.5,alpha.5
                                        ,beta.5,corr.bhf.5,corr.bidx.5,omega.5
                                        ,wl.5,skewness.5,kurtosis.5),row.names=fund.name)
    df.metrics.5=rbind(df.metrics.5,temp.metrics.5)
    
  }
}

outfile=paste(u.name,"_rcustom_output.csv",sep="")
file.dir.out=paste(pathname,outfile,sep="")
write.csv(df.metrics.5, file.dir.out)
#write.csv(bench.xts, file.dir.bret)
fret.file=paste(u.name,"_incep_ret.csv",sep="");
file.dir.fret=paste(pathname,fret.file,sep="")
write.csv(list.ret, file.dir.fret)
#write.csv(df.date, file.dir.date)