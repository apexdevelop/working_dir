library(zoo)            # Load the zoo package
library(xts)             # Load the xts package
library(PerformanceAnalytics)
# Read the CSV files
pathname="C:/Users/YChen/Documents/git/working_dir/R/Data/"
list.universe=c("em","asia","mn","allhf")
u.option=4#choose universe
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
#n.sec=dim(securities)[1]

library(Rbbg)
conn=blpConnect()
fields=c("CHG_PCT_1D")

start_date="2004-04-01"
#end_date="2017-06-30"
end_date=Sys.Date()
start.date = as.POSIXct(start_date)
end.date = as.POSIXct(end_date)

########get fund data
x.h=bdh(conn,securities,fields,start.date,end.date,option_names = "periodicitySelection", option_values = "MONTHLY",always.display.tickers = TRUE)
list.ret=unstack(x.h,CHG_PCT_1D~ticker)
list.date=unstack(x.h,date~ticker)
name.list=as.matrix(names(list.ret))
n.sec=dim(name.list)[1]

#######get benchmark data
benchmark=c("HFRIFWI Index","MXWO Index")
bench.h=bdh(conn,benchmark,fields,start.date,end.date,option_names = "periodicitySelection", option_values = "MONTHLY",always.display.tickers = TRUE)
list.b.ret=unstack(bench.h,CHG_PCT_1D~ticker)
list.b.date=unstack(bench.h,date~ticker)
df.b.ret=as.data.frame(list.b.ret/100)
df.b.date=as.data.frame(list.b.date[1])
mtx.b.date=as.matrix(df.b.date)
date.b.date=as.Date(mtx.b.date)
bench.xts=xts(df.b.ret,date.b.date)
nrows.b=dim(bench.xts)[1]

######Calculating
ann.rfrate=0.005
mon.rfrate=(1+ann.rfrate)^(1/12)-1

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
  
  if (nrows>=1){
    n.periods=nrows
    incep.rows=1:nrows
    ret.incep=fund.xts[incep.rows]
    date.incep=date.date[incep.rows]
    ret.bhf.incep=bench.clean.xts[incep.rows,1]
    ret.bidx.incep=bench.clean.xts[incep.rows,2]
    #manually calculate
    totalret.incep=prod(ret.incep+1)-1
    ann.ret.incep=(totalret.incep+1)^(12/n.periods)-1
    ann.std.incep=sd(ret.incep)*sqrt(12)
    downrisk.incep=sd(ret.incep[(ret.incep<0)])*sqrt(12)
    v.cumret.incep=matrix(1,nrow=n.periods+1,ncol=1)
    v.maxdd.incep=matrix(0,nrow=n.periods,ncol=1)
    for (j in 2:(n.periods+1)){
      v.cumret.incep[j]=v.cumret.incep[j-1]*(ret.incep[j-1]+1)
      v.maxdd.incep[j-1]=v.cumret.incep[j]/max(v.cumret.incep[1:j])-1
    }
    drawdown.incep=min(v.maxdd.incep)
    sharpe.incep=(ann.ret.incep-ann.rfrate)/ann.std.incep
    sortino.incep=(ann.ret.incep-ann.rfrate)/downrisk.incep
    
    ####calculate info ratio
    excess.bhf.incep=ret.incep-ret.bhf.incep
    totalret.excess.incep=prod(excess.bhf.incep+1)-1
    ann.excessret.incep=(totalret.excess.incep+1)^(12/n.periods)-1
    ann.excessstd.incep=sd(excess.bhf.incep)*sqrt(12)
    inforatio.incep=ann.excessret.incep/ann.excessstd.incep
    ####calculate beta and alpha
    f.ret.zoo=zoo(ret.incep,date.incep)
    bidx.ret.zoo=zoo(ret.bidx.incep,date.incep)
    fnbidx.ret.zoo=merge(f.ret.zoo,bidx.ret.zoo,all=FALSE)
    colnames(fnbidx.ret.zoo)=c("f","b")
    
    bhf.ret.zoo=zoo(ret.bhf.incep,date.incep)
    fnbhf.ret.zoo=merge(f.ret.zoo,bhf.ret.zoo,all=FALSE)
    colnames(fnbhf.ret.zoo)=c("f","b")
    
    fit=lm(f~b,data=fnbidx.ret.zoo)
    alpha.incep=coef(fit)[1]
    beta.incep=coef(fit)[2]
    ####calculate correlation
    corr.bhf.incep=cor(fnbhf.ret.zoo[,1],fnbhf.ret.zoo[,2])
    corr.bidx.incep=cor(fnbidx.ret.zoo[,1],fnbidx.ret.zoo[,2])
    
    omega.incep=Omega(ret.incep)
    wl.incep=length(which(ret.incep>0))/n.periods
    skewness.incep=skewness(ret.incep)
    kurtosis.incep=kurtosis(ret.incep)
    
    
    fund.name=colnames(ret.incep)
    
    
    omega.incep=as.numeric(omega.incep)
    #corr.bhf.incep=as.numeric(corr.bhf.incep)
    #corr.bidx.incep=as.numeric(corr.bidx.incep)
    temp.metrics.incep=as.data.frame(cbind(ann.ret.incep,ann.std.incep,downrisk.incep,drawdown.incep
                                        ,sharpe.incep,sortino.incep,inforatio.incep,alpha.incep
                                        ,beta.incep,corr.bhf.incep,corr.bidx.incep,omega.incep
                                        ,wl.incep,skewness.incep,kurtosis.incep),row.names=fund.name)
    df.metrics.incep=rbind(df.metrics.incep,temp.metrics.incep)
    
  }
}

outfile=paste(u.name,"_10yr_output.csv",sep="")
file.dir.out=paste(pathname,outfile,sep="")
write.csv(df.metrics.incep, file.dir.out)
#library(xlsx)
#outfile="output_r_analysis.xlsx"
#file.dir.out=paste(pathname,outfile,sep="")
#sheet.name=paste(u.name,"_10yr",sep="")
#write.xlsx(df.metrics.incep,file.dir.out,sheetName = sheet.name)
#write.csv(bench.xts, file.dir.bret)
fret.file=paste(u.name,"_10yr_ret.csv",sep="");
file.dir.fret=paste(pathname,fret.file,sep="")
write.csv(list.ret, file.dir.fret)
#write.csv(df.date, file.dir.date)