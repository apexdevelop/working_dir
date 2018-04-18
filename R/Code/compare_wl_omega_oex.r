library(zoo)            # Load the zoo package
library(xts)             # Load the xts package
library(PerformanceAnalytics)
# Read the CSV files
pathname="Y:/working_directory/R/Data/"
infile="shsz_list.csv"
outfile="wl_omega_output_shsz.csv"

file_dir=paste(pathname,infile,sep="")
file_dir_out=paste(pathname,outfile,sep="")
# file_dir_out_2=paste(pathname,outfile2,sep="")


raw_securities = read.csv(file_dir,header = FALSE, stringsAsFactors=F)
#raw_securities = read.csv(file_dir,header = FALSE)
securities=as.matrix(raw_securities)
securities=as.matrix(sort(securities))
n_sec=dim(securities)[1]

library(Rbbg)
conn=blpConnect()
fields=c("CHG_PCT_1D")

start_date="2010-07-01"
#end_date="2017-06-30"
end_date=Sys.Date()
start.date = as.POSIXct(start_date)
end.date = as.POSIXct(end_date)

########get security data
x_h=bdh(conn,securities,fields,start.date,end.date,option_names = "periodicitySelection", option_values = "WEEKLY",always.display.tickers = TRUE)
list_ret=unstack(x_h,CHG_PCT_1D~ticker)
list_date=unstack(x_h,date~ticker)
name_list=as.matrix(names(list_ret))
n_sec=dim(name_list)[1]

df.metrics.incep=NULL

for (i in 1:n_sec) {
  df.ret=as.data.frame(list_ret[i]/100)
  df.date=as.data.frame(list_date[i])
  df.clean.ret=as.data.frame(df.ret[!is.na(df.ret)])
  colnames(df.clean.ret)=colnames(df.ret)
  df.clean.date=as.data.frame(df.date[!is.na(df.ret)])
  colnames(df.clean.date)=colnames(df.ret)
  mtx.date=as.matrix(df.clean.date)
  date.date=as.Date(mtx.date)
  fund.xts=xts(df.clean.ret,date.date)
  nrows=dim(fund.xts)[1]
  
  incep.rows=1:nrows
  ret.incep=fund.xts[incep.rows]
  ann.ret.incep=Return.annualized(ret.incep)
  ann.std.incep=StdDev.annualized(ret.incep)
  downrisk.incep=DownsideDeviation(ret.incep)
  drawdown.incep=maxDrawdown(ret.incep,invert=FALSE)
  sharpe.incep=SharpeRatio(ret.incep, Rf = 0.005, FUN="StdDev")
  sortino.incep=SortinoRatio(ret.incep)
  omega.incep=Omega(ret.incep)
  wl.incep=UpsideFrequency(ret.incep,MAR=0)
  skewness.incep=skewness(ret.incep)
  kurtosis.incep=kurtosis(ret.incep)
  
  fund.name=colnames(ann.ret.incep)
  ann.ret.incep=as.numeric(ann.ret.incep)
  ann.std.incep=as.numeric(ann.std.incep)
  sharpe.incep=as.numeric(sharpe.incep)
  sortino.incep=as.numeric(sortino.incep)
  omega.incep=as.numeric(omega.incep)
  omega.incep=1/(1+1/omega.incep) #convert to 0 to 1
  
  
  temp.metrics.incep=as.data.frame(cbind(ann.ret.incep,ann.std.incep,downrisk.incep,
                      drawdown.incep,sharpe.incep,sortino.incep,
                      omega.incep,wl.incep,
                      skewness.incep,kurtosis.incep),row.names=fund.name)
  df.metrics.incep=rbind(df.metrics.incep,temp.metrics.incep)
}


write.csv(df.metrics.incep, file_dir_out)
