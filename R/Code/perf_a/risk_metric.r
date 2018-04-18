library(zoo)            # Load the zoo package
library(xts)             # Load the xts package
library(PerformanceAnalytics)
# Read the CSV files
pathname="C:/users/ychen/documents/git/working_dir/R/Data/"
#infile="em_list.csv"
#outfile="omega_output_em.csv"
#outfile_ret="ret_em.csv"
#infile="asia_list.csv"
#outfile="omega_output_asia.csv"
#outfile_ret="ret_asia.csv"
infile="mn_list.csv"
outfile="omega_output_mn.csv"
outfile_ret="ret_mn.csv"
#infile="allhf_list.csv"
#outfile="omega_output_allhf.csv"
#outfile_ret="ret_allhf.csv"
#infile="growth_list.csv"
#outfile="omega_output_growth.csv"
#outfile2="inforatio_output_growth.csv"

file_dir=paste(pathname,infile,sep="")
file_dir_out=paste(pathname,outfile,sep="")
file_dir_out_ret=paste(pathname,outfile_ret,sep="")
#file_dir_out_2=paste(pathname,outfile2,sep="")


raw_securities = read.csv(file_dir,header = FALSE, stringsAsFactors=F)
#raw_securities = read.csv(file_dir,header = FALSE)
securities=as.matrix(raw_securities)
securities=as.matrix(sort(securities))
n_sec=dim(securities)[1]

library(Rbbg)
conn=blpConnect()
fields=c("CHG_PCT_1D")

#start_date="2004-04-01"
start_date="2012-09-01"
#end_date="2017-06-30"
end_date=Sys.Date()
start.date = as.POSIXct(start_date)
end.date = as.POSIXct(end_date)

x_h=bdh(conn,securities,fields,start.date,end.date,option_names = "periodicitySelection", option_values = "MONTHLY",always.display.tickers = TRUE)
list_ret=unstack(x_h,CHG_PCT_1D~ticker)
list_date=unstack(x_h,date~ticker)
name_list=as.matrix(names(list_ret))
n_sec=dim(name_list)[1]

df_date1=as.data.frame(list_date[1])
mtx_date1=as.matrix(df_date1)
date1=as.Date(mtx_date1)
ret1=as.data.frame(list_ret)
ret.xts=xts(ret1,date1)
num.xts=ret.xts/100

#omit_na_x_h=na.omit(x_h)

#manager.col=11
#peers.cols=12:13
#indexes.cols
#Rf.col
nrows=dim(ret.xts)[1]
trailing12.rows=(nrows-11):nrows
trailing36.rows=(nrows-35):nrows
trailing60.rows=(nrows-59):nrows
incep.rows=1:nrows

ret.12=num.xts[trailing12.rows,1:n_sec]
ret.36=num.xts[trailing36.rows,1:n_sec]
ret.60=num.xts[trailing60.rows,1:n_sec]
ret.incep=num.xts[incep.rows,1:n_sec]

ret.12.multiple=ret.12+1
ret.36.multiple=ret.36+1
ret.60.multiple=ret.60+1
ret.incep.multiple=ret.incep+1

#mrtn.table=t(table.CalendarReturns(test_data))
#stats.table=t(table.Stats(test_data))
#ann.ret.12=Return.annualized(ret.12)
#Error in periodicity(R) : can not calculate periodicity of 1 observation

omega.12=Omega(ret.12)
omega.36=Omega(ret.36)
omega.60=Omega(ret.60)
omega.incep=Omega(ret.incep)
omega.12=t(omega.12)
omega.36=t(omega.36)
omega.60=t(omega.60)
omega.incep=t(omega.incep)
wl.12=UpsideFrequency(ret.12,MAR=0)

#omega_ratio=Omega(num.xts)
#omega_ratio=t(omega_ratio)
#setwd("./Data")
omega_ratio=cbind(omega.12,omega.36,omega.60,omega.incep)

#write.csv(omega_ratio, file_dir_out)
#write.csv(ret.incep, file_dir_out_ret)

# benchmark="HFRIFWI Index"
# bench_h=bdh(conn,benchmark,fields,start.date,end.date,option_names = "periodicitySelection", option_values = "MONTHLY",always.display.tickers = TRUE)
# ret_bench=as.data.frame(bench_h[,3]/100)
# 
# df.date.bench=as.data.frame(bench_h[,2])
# mtx.date.bench=as.matrix(df.date.bench)
# date.bench=as.Date(mtx.date.bench)
# 
# bench.xts=xts(ret_bench,date.bench)
# nrows_bench=dim(bench.xts)[1]
# trailing36.rows.bench=(nrows_bench-35):nrows_bench
# bench.36=bench.xts[trailing36.rows.bench]
# info_ratio=InformationRatio(ret.36,bench.36,12)
# info.ratio.36=t(info_ratio)
# write.csv(info.ratio.36, file_dir_out_2)
