library(zoo)            # Load the zoo package
library(xts)             # Load the xts package
library(PerformanceAnalytics)
# Read the CSV files
pathname="Y:/working_directory/R/Data/"
#infile="em_list.csv"
#outfile="omega_output_em.csv"
#infile="asia_list.csv"
#outfile="omega_output_asia.csv"
infile="mn_list.csv"
#outfile="omega_output_mn.csv"
#infile="allhf_list.csv"
#outfile="omega_output_allhf.csv"
# infile="growth_list.csv"
# outfile="omega_output_growth.csv"
# outfile2="inforatio_output_growth.csv"


file_dir=paste(pathname,infile,sep="")
#file_dir_out=paste(pathname,outfile,sep="")
#file_dir_out_2=paste(pathname,outfile2,sep="")


raw_securities = read.csv(file_dir,header = FALSE, stringsAsFactors=F)
#raw_securities = read.csv(file_dir,header = FALSE)
securities=as.matrix(raw_securities)
securities=as.matrix(sort(securities))
n_sec=dim(securities)[1]

library(Rbbg)
conn=blpConnect()
fields=c("CHG_PCT_1D")

start_date="2004-04-01"
#end_date="2017-06-30"
end_date=Sys.Date()
start.date = as.POSIXct(start_date)
end.date = as.POSIXct(end_date)

#######get benchmark data
benchmark="HFRIFWI Index"
bench_h=bdh(conn,benchmark,fields,start.date,end.date,option_names = "periodicitySelection", option_values = "MONTHLY",always.display.tickers = TRUE)
ret_bench=as.data.frame(bench_h[,3]/100)

df.date.bench=as.data.frame(bench_h[,2])
mtx.date.bench=as.matrix(df.date.bench)
date.bench=as.Date(mtx.date.bench)

bench.xts=xts(ret_bench,date.bench)
nrows.bench=dim(bench.xts)[1]
if (nrows.bench>=12){
  trailing12.rows.bench=(nrows.bench-11):nrows.bench
  bench.12=bench.xts[trailing12.rows.bench]
  #info_ratio.12=InformationRatio(ret.12,bench.12,12)
}

if (nrows.bench>=36){
  trailing36.rows.bench=(nrows.bench-35):nrows.bench
  bench.36=bench.xts[trailing36.rows.bench]
  #info_ratio.36=InformationRatio(ret.36,bench.36,12)
}

if (nrows.bench>=60){
  trailing60.rows.bench=(nrows.bench-59):nrows.bench
  bench.60=bench.xts[trailing60.rows.bench]
  #info_ratio.60=InformationRatio(ret.60,bench.60,12)
}


incep.rows.bench=1:nrows.bench
bench.incep=bench.xts[incep.rows.bench]
#info_ratio.incep=InformationRatio(ret.incep,bench.incep,12)


########get fund data
x_h=bdh(conn,securities,fields,start.date,end.date,option_names = "periodicitySelection", option_values = "MONTHLY",always.display.tickers = TRUE)
list_ret=unstack(x_h,CHG_PCT_1D~ticker)
list_date=unstack(x_h,date~ticker)
name_list=as.matrix(names(list_ret))
n_sec=dim(name_list)[1]

df.metrics.12=NULL
df.metrics.36=NULL
df.metrics.60=NULL
df.metrics.incep=NULL
#i=2
for (i in 1:n_sec) {
  df.ret=as.data.frame(list_ret[i]/100)
  #df.ret=as.data.frame(list_ret["DERNMOF.US.Equity"]/100)
  df.date=as.data.frame(list_date[i])
  #df.date=as.data.frame(list_date["DERNMOF.US.Equity"])
  df.clean.ret=as.data.frame(df.ret[!is.na(df.ret)])
  colnames(df.clean.ret)=colnames(df.ret)
  df.clean.date=as.data.frame(df.date[!is.na(df.ret)])
  colnames(df.clean.date)=colnames(df.ret)
  mtx.date=as.matrix(df.clean.date)
  date.date=as.Date(mtx.date)
  fund.xts=xts(df.clean.ret,date.date)
  nrows=dim(fund.xts)[1]
  if (nrows>=12){
    trailing12.rows=(nrows-11):nrows
    ret.12=fund.xts[trailing12.rows]
    ann.ret.12=Return.annualized(ret.12)
    ann.std.12=StdDev.annualized(ret.12)
    #r = subset(ret.12, ret.12 < 0)
    downrisk.12=DownsideDeviation(ret.12)
    drawdown.12=maxDrawdown(ret.12,invert=FALSE)
    sharpe.12=SharpeRatio(ret.12, Rf = 0.005, FUN="StdDev")
    sortino.12=SortinoRatio(ret.12)
    info_ratio.12=InformationRatio(ret.12,bench.12,12)
    omega.12=Omega(ret.12)
    wl.12=UpsideFrequency(ret.12,MAR=0)
    skewness.12=skewness(ret.12)
    kurtosis.12=kurtosis(ret.12)
    
    ####method1 convert all matric to numeric, add fundname as rowname
    #add colnames by force
    fund.name=colnames(ann.ret.12)
    ann.ret.12=as.numeric(ann.ret.12)
    ann.std.12=as.numeric(ann.std.12)
    sharpe.12=as.numeric(sharpe.12)
    sortino.12=as.numeric(sortino.12)
    omega.12=as.numeric(omega.12)
    
    temp.metrics.12=as.data.frame(cbind(ann.ret.12,ann.std.12,downrisk.12,drawdown.12
                     ,sharpe.12,sortino.12,info_ratio.12,omega.12
                     ,wl.12,skewness.12,kurtosis.12),row.names=fund.name)
    df.metrics.12=rbind(df.metrics.12,temp.metrics.12)
    ###method 2 transpose rownames and colnames of matrix
    # old.colnames=colnames(ann.ret.12)
    # 
    # old.rownames=rownames(ann.ret.12)
    # rownames(ann.ret.12)=old.colnames
    # colnames(ann.ret.12)=old.rownames
    # 
    # old.rownames=rownames(ann.std.12)
    # rownames(ann.std.12)=old.colnames
    # colnames(ann.std.12)=old.rownames
    # 
    # old.rownames=rownames(sharpe.12)
    # rownames(sharpe.12)=old.colnames
    # colnames(sharpe.12)=old.rownames
    # 
    # old.rownames=rownames(sortino.12)
    # rownames(sortino.12)=old.colnames
    # colnames(sortino.12)=old.rownames
    # 
    # old.rownames=rownames(omega.12)
    # rownames(omega.12)=old.colnames
    # colnames(omega.12)=old.rownames
    # 
    # mx.metrics.12=cbind(ann.ret.12,ann.std.12,downrisk.12,drawdown.12
    #                  ,sharpe.12,sortino.12,info_ratio.12,omega.12
    #                  ,wl.12,skewness.12,kurtosis.12)
  }
  if (nrows>=36){
    trailing36.rows=(nrows-35):nrows
    ret.36=fund.xts[trailing36.rows]
    ann.ret.36=Return.annualized(ret.36)
    ann.std.36=StdDev.annualized(ret.36)
    downrisk.36=DownsideDeviation(ret.36)
    drawdown.36=maxDrawdown(ret.36,invert=FALSE)
    sharpe.36=SharpeRatio(ret.36, Rf = 0.005, FUN="StdDev")
    sortino.36=SortinoRatio(ret.36)
    info_ratio.36=InformationRatio(ret.36,bench.36,12)
    omega.36=Omega(ret.36)
    wl.36=UpsideFrequency(ret.36,MAR=0)
    skewness.36=skewness(ret.36)
    kurtosis.36=kurtosis(ret.36)
    
    fund.name=colnames(ann.ret.36)
    ann.ret.36=as.numeric(ann.ret.36)
    ann.std.36=as.numeric(ann.std.36)
    sharpe.36=as.numeric(sharpe.36)
    sortino.36=as.numeric(sortino.36)
    omega.36=as.numeric(omega.36)
    
    temp.metrics.36=as.data.frame(cbind(ann.ret.36,ann.std.36,downrisk.36,drawdown.36
                     ,sharpe.36,sortino.36,info_ratio.36,omega.36
                     ,wl.36,skewness.36,kurtosis.36),row.names=fund.name)
    df.metrics.36=rbind(df.metrics.36,temp.metrics.36)
  }
  if (nrows>=60){
    trailing60.rows=(nrows-59):nrows
    ret.60=fund.xts[trailing60.rows]
    ann.ret.60=Return.annualized(ret.60)
    ann.std.60=StdDev.annualized(ret.60)
    downrisk.60=DownsideDeviation(ret.60)
    drawdown.60=maxDrawdown(ret.60,invert=FALSE)
    sharpe.60=SharpeRatio(ret.60, Rf = 0.005, FUN="StdDev")
    sortino.60=SortinoRatio(ret.60)
    info_ratio.60=InformationRatio(ret.60,bench.60,12)
    omega.60=Omega(ret.60)
    wl.60=UpsideFrequency(ret.60,MAR=0)
    skewness.60=skewness(ret.60)
    kurtosis.60=kurtosis(ret.60)
    
    fund.name=colnames(ann.ret.60)
    ann.ret.60=as.numeric(ann.ret.60)
    ann.std.60=as.numeric(ann.std.60)
    sharpe.60=as.numeric(sharpe.60)
    sortino.60=as.numeric(sortino.60)
    omega.60=as.numeric(omega.60)
    
    temp.metrics.60=as.data.frame(cbind(ann.ret.60,ann.std.60,downrisk.60,drawdown.60
                     ,sharpe.60,sortino.60,info_ratio.60,omega.60
                     ,wl.60,skewness.60,kurtosis.60),row.names=fund.name)
    df.metrics.60=rbind(df.metrics.60,temp.metrics.60)
  }
  incep.rows=1:nrows
  ret.incep=fund.xts[incep.rows]
  ann.ret.incep=Return.annualized(ret.incep)
  ann.std.incep=StdDev.annualized(ret.incep)
  downrisk.incep=DownsideDeviation(ret.incep)
  drawdown.incep=maxDrawdown(ret.incep,invert=FALSE)
  sharpe.incep=SharpeRatio(ret.incep, Rf = 0.005, FUN="StdDev")
  sortino.incep=SortinoRatio(ret.incep)
  info_ratio.incep=InformationRatio(ret.incep,bench.incep,12)
  #drawdown.table=table.DrawdownsRatio(ret.incep)
  omega.incep=Omega(ret.incep)
  wl.incep=UpsideFrequency(ret.incep,MAR=0)
  #mrtn.table=t(table.CalendarReturns(ret.incep))
  #stats.table=t(table.Stats(ret.incep))
  skewness.incep=skewness(ret.incep)
  kurtosis.incep=kurtosis(ret.incep)
  
  fund.name=colnames(ann.ret.incep)
  ann.ret.incep=as.numeric(ann.ret.incep)
  ann.std.incep=as.numeric(ann.std.incep)
  sharpe.incep=as.numeric(sharpe.incep)
  sortino.incep=as.numeric(sortino.incep)
  omega.incep=as.numeric(omega.incep)
  
  
  
  temp.metrics.incep=as.data.frame(cbind(ann.ret.incep,ann.std.incep,downrisk.incep,
                      drawdown.incep,sharpe.incep,sortino.incep,
                      info_ratio.incep,omega.incep,wl.incep,
                      skewness.incep,kurtosis.incep),row.names=fund.name)
  df.metrics.incep=rbind(df.metrics.incep,temp.metrics.incep)
}


#manager.col=11
#peers.cols=12:13
#indexes.cols
#Rf.col


outfile.test1="m12.csv"
file_dir_out_test1=paste(pathname,outfile.test1,sep="")
write.csv(df.metrics.12, file_dir_out_test1)

outfile.test2="m36.csv"
file_dir_out_test2=paste(pathname,outfile.test2,sep="")
write.csv(df.metrics.36, file_dir_out_test2)

outfile.test3="m60.csv"
file_dir_out_test3=paste(pathname,outfile.test3,sep="")
write.csv(df.metrics.60, file_dir_out_test3)
