library(fExtremes)
z.vals=seq(-5,5,length=200)
#cdfs
cdf.f=ifelse((z.vals>-2),pgev(z.vals,xi=0.5),0)
cdf.w=ifelse((z.vals<2),pgev(z.vals,xi=-0.5),1)
cdf.g=exp(-exp(-z.vals))
plot(z.vals,cdf.w,type="l",xlab="z",ylab="H(z)")
lines(z.vals,cdf.f,type="l",lty=2)
lines(z.vals,cdf.g,type="l",lty=3)
legend(-5,1,legend=c("Weibull H(-0.5,0,1)","Frechet H(0.5,0,1)","Gumbel H(0,0,1)"),lty=1:3)

#pdfs
pdf.f=ifelse((z.vals>-2),dgev(z.vals,xi=0.5),0)
pdf.w=ifelse((z.vals<2),dgev(z.vals,xi=-0.5),0)
pdf.g=exp(-exp(-z.vals))*exp(-z.vals)
plot(z.vals,pdf.w,type="l",xlab="z",ylab="h(z)")
lines(z.vals,pdf.f,type="l",lty=2)
lines(z.vals,pdf.g,type="l",lty=3)
legend(-5.25,0.4,legend=c("Weibull H(-0.5,0,1)","Frechet H(0.5,0,1)",
                          "Gumbel H(0,0,1)"),lty=1:3)

#no sp.raw dataset in timeSeries in r
#library(timeSeries)
#spto87=getReturns(sp.raw,type="discrete",percentage=T)

library(Rbbg)
conn=blpConnect()
fields=c("CHG_PCT_1D")
securities=c("SPX Index")
start_date="1960-01-05"
end_date="1987-10-16"
#end_date=Sys.Date()
start.date = as.POSIXct(start_date)
end.date = as.POSIXct(end_date)
x_h=bdh(conn,securities,fields,start.date,end.date,
        option_names = "periodicitySelection", 
        option_values = "DAILY",always.display.tickers = TRUE)
list_ret=unstack(x_h,CHG_PCT_1D~ticker)
list_date=unstack(x_h,date~ticker)
df.ret=as.data.frame(list_ret)
df.date=as.data.frame(list_date)
mtx.date=as.matrix(df.date)
date.date=as.Date(mtx.date)
library(zoo)            # Load the zoo package
library(xts)             # Load the xts package
sp.xts=xts(df.ret,date.date)
plot(sp.xts,main="Daily Percentage Returns")

qqline(sp.xts,main="Daily returns on S&P 500",
       xlab="Quantiles of standard normal",
       ylab="Quantiles of S&P 500")
#neg.sp.xts=-sp.xts
#apply.yearly could be replaced by aggregate on timeSeries object, but not so easy xts object
#annualMax.sp.xts = apply.yearly(-sp.xts,max)
sp.timeseries=as.timeSeries.xts(sp.xts)
sp.by=timeSequence(from = start(sp.timeseries),  to = end(sp.timeseries), by = "year")
annualMax.sp.timeSeries = aggregate(-sp.timeseries,sp.by,FUN=max)
max.rownames=rownames(annualMax.sp.timeSeries)
max.rownames=strptime(as.character(max.rownames),"%Y-%m-%d")
max.rownames=format(max.rownames,"%Y")
rownames(annualMax.sp.timeSeries)=max.rownames
#'seriesData' is deprecated.Use 'series' instead.
Xn=sort(series(annualMax.sp.timeSeries))
#par(mfrow=c(2,2))
plot(annualMax.sp.timeSeries)
hist(series(annualMax.sp.timeSeries),xlab="Annual maximum")
plot(Xn,-log(-log(ppoints(Xn))),xlab="Annual maximum")
