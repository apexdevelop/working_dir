library(Rbbg)
conn=blpConnect()
conn=blpConnect(blpapi.jar.file="C:\\blp\\JavaAPI\\v3.8.8.2\\bin")
bdp(conn,"AMZN US Equity","NAME")

add.equity.label=function(ticker){
  paste(ticker,"Equity")
}

conn=blpConnect(jvm.params=c("-Xmx256m","-Xloggc:rbbg.gc","-XX:PrintGCDetails"))

tickers=bds(conn,"UKX Index","INDX_MEMBERS")[,1]
tickers=add.equity.label(tickers)
x=bdp(conn,tickers,"PX_LAST")
  
blpConnect(iface="COM", timeout=12000, show.days="week",
na.action="na", periodicity="daily")

blpConnect(iface = "Java", log.level = "warning", blpapi.jar.file = NULL, 
    throw.ticker.errors = TRUE, jvm.params = NULL, verbose = TRUE, 
    cache.responses = FALSE) 

blpDisconnect(conn)


# 3.1 reference data
securities=c("7203 JP EQUITY","857 HK EQUITY","015760 KS EQUITY")
fields=c("NAME","PX_LAST","LT_DEBT_TO_COM_EQY")
override_fields=c("EQY_FUND_DT")
overrides=c("20051231")
x=bdp(conn,securities,fields,override_fields,overrides)

bdp(conn,"/SEDOL1/2292612 EQUITY","NAME")

#3.2 bulk data
conn=blpConnect(log.level="finest")
security=c("105560 KS Equity")
field=c("DVD_HIST")
x_b=bds(conn,security,field)

#3.3 Historical data
# always.display.tickers=TRUE
#dates.as.row.names=(length(securities)==1)

Sys.setenv(TZ="")
# start.date=as.POSIXct("2015-09-21")
# end.date=as.POSIXct("2015-12-28")
start.date=c("20150921")
end.date=c("20151228")
x_h=bdh(conn,securities,"BEST_ANALYST_RATING",start.date,end.date)


library(zoo)
x_h=bdh(conn,securities,"PX_LAST",Sys.Date()-10)
xh.zoo=zoo(x_h,order.by=rownames(x_h))

x_h=bdh(conn,securities,c("PX_LAST","BID"),Sys.Date()-366,
        option_names="periodicitySelection",option_values="MONTHLY")
na.omit(x_h)

x_h=bdh(conn,securities,c("PX_LAST","BID"),Sys.Date()-366,
        option_names="periodicitySelection",option_values="MONTHLY"
        ,dates.as.row.names=FALSE)

#we should get NULL back when there's no data
bdh(conn,"/SEDOL1/2292612 EQUITY","PX_LAST","20090405","20090405")
#to return rows for all requested dates, even when they have no data
bdh(conn,"/SEDOL1/2292612 EQUITY","PX_LAST","20090405","20090405"
    ,include.non.trading.days=TRUE)

bdh(conn,"/SEDOL1/2292612 EQUITY","PX_LAST","20090405","20090405"
    ,option_names=c("nonTradingDayFillOption","nonTradingDayFillMethod"),
    option_values=c("ALL_CALENDAR_DAYS","PREVIOUS_VALUE"))

t=unstack(x_h,BEST_ANALYST_RATING~ticker)
rownames(t)=unique(x_h$date)

reshape(x_h,direction="wide",timevar="date",idvar="ticker")