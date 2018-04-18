
# You can specify that a row be returned for all dates in the requested period, even when markets or
# closed or otherwise no data is available, by specifying include.non.trading.days=TRUE. If you request
# multiple securities, this is automatically set to TRUE. You can use na.omit or na.exclude to remove
# these rows

library(Rbbg)
conn=blpConnect()
fields=c("CHG_PCT_1D")
securities=c("2600 HK Equity","AA Equity","AWC AU Equity","486 HK Equity", "HNDL IN Equity")
start_date="2010-01-29"
end_date="2017-10-04"
#end_date=Sys.Date()
start.date = as.POSIXct(start_date)
end.date = as.POSIXct(end_date)
x_h=bdh(conn,securities,fields,start.date,end.date,
        option_names = c("nonTradingDayFillOption", "nonTradingDayFillMethod"), 
        option_values = c("ALL_CALENDAR_DAYS", "PREVIOUS_VALUE"),always.display.tickers = TRUE)

#the following need to be exlpored more, because diff col have diff #of NA values
#could assign this to siyuan
#nona_xh=na.omit(x_h)
#list_ret=unstack(nona_xh,CHG_PCT_1D~ticker)
#list_date=unstack(nona_xh,date~ticker)
list_ret=unstack(x_h,CHG_PCT_1D~ticker)
list_date=unstack(x_h,date~ticker)
df.ret=as.data.frame(list_ret)
df.date=as.data.frame(list_date[1])
mtx.date=as.matrix(df.date)
date.date=as.Date(mtx.date)
library(zoo)            # Load the zoo package
library(xts)             # Load the xts package
rtn.xts=xts(df.ret,date.date)
pathname="C:/users/ychen/documents/git/working_dir/R/Data/"
outfile="alum_factor_rtn.csv"
file_dir_out=paste(pathname,outfile,sep="")
write.csv(rtn.xts,file_dir_out)