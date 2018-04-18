# Load Systematic Investor Toolbox (SIT)
# https://systematicinvestor.wordpress.com/systematic-investor-toolbox/
###############################################################################
con = gzcon(url('http://www.systematicportfolio.com/sit.gz', 'rb'))
source(con)
close(con)

#*****************************************************************
# Load historical data
#****************************************************************** 
load.packages('quantmod')   


library(Rbbg)
conn=blpConnect()
fields=c("PX_LAST")
tickers = "SPY Equity"
start_date="1990-09-01"
end_date=Sys.Date()
start.date = as.POSIXct(start_date)
end.date = as.POSIXct(end_date)
x_h=bdh(conn,tickers,fields,start.date,end.date,option_names = "periodicitySelection", option_values = "DAILY",always.display.tickers = TRUE)

px=unstack(x_h,PX_LAST~ticker)
date=unstack(x_h,date~ticker)
mtx.date=as.matrix(date)
date.date=as.Date(mtx.date)
px.xts=xts(px,date.date)
data=px.xts
#*****************************************************************
# Euclidean distance, one to one mapping
#****************************************************************** 
obj = bt.matching.find(data, normalize.fn = normalize.mean, dist.fn = 'dist.euclidean', plot=T)

matches = bt.matching.overlay(obj, plot.index=1:90, plot=T)

layout(1:2)
matches = bt.matching.overlay(obj, plot=T, layout=T)
bt.matching.overlay.table(obj, matches, plot=T, layout=T)