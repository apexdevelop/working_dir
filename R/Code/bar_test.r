library(Rblpapi)
con=blpConnect()
tz = "America/New_York"
##don't use "EST", "EST" in R means somewhere in Eastern Canada
Sys.setenv(TZ = tz)

security="SPY Equity"
char.start.time="03/25/2017 09:30:00"
char.end.time="03/28/2018 16:15:00"

start.time=as.POSIXct(char.start.time,format='%m/%d/%Y %H:%M:%S')
end.time=as.POSIXct(char.end.time,format='%m/%d/%Y %H:%M:%S')

x_bar= getBars(security, eventType = "TRADE", barInterval = 1,
        startTime = start.time, endTime = end.time)

df.date=as.data.frame(as.Date(x_bar$times))
u.date=unique(df.date)

v.time=format(x_bar$times,'%H:%M:%S')
df.price=as.data.frame(x_bar$close)

num.udays=dim(u.date)[1]
abs.mov=matrix(data=0, nrow=num.udays)
abs.mov2=matrix(data=0, nrow=num.udays)

newdf=cbind(df.date,df.price)
colnames(newdf)=c("date","price")
list.bar = split(newdf,f = newdf$date)

##############testing user-defined function and sapply####################
fun_abs_sum <- function(x) {
  sum = 0
  num.rows=length(x)
  for (i in 2:num.rows) {
    sum = sum + abs(x[i]-x[i-1])
  }
  return(sum)
}

abs.mov2= sapply( list.bar , function(x) fun_abs_sum( x$price ) )
#test.result= sapply( list.bar , function(x) mean( x$price ) )
#####################################

###interday mov
start.date=u.date[1,1]
end.date=u.date[num.udays,1]
x_h=bdh(security,'CHG_NET_1D',start.date=start.date,end.date=end.date)

abs.interday.mov=abs(x_h$CHG_NET_1D)

par(mfrow=c(2,1))

plot(1:num.udays,abs.mov2,type="l",col="red")
lines(1:num.udays,abs.interday.mov,col="green")

n.movdays=5
f5= rep(1/n.movdays, n.movdays)
intraday.5 = 5*filter(abs.mov2, f5, sides=1)
interday.5 = 5*filter(abs.interday.mov, f5, sides=1)

plot(1:num.udays,intra.lag,type="l",col="red")
lines(1:num.udays,inter.lag,col="green")

par(mar = c(5,5,2,5))
plot(1:num.udays,intraday.5,type="l",col="red")
par(new = T)
plot(1:num.udays, interday.5,type="l", axes=F, xlab=NA, ylab=NA, cex=1.2)
axis(side = 4)
mtext(side = 4, line = 3, 'interday.5')
legend("topleft",
       legend=c("intraday.5", "interday.5"),
       lty=c(1,1), col=c("red", "black"))

intraday.1 = abs.mov2
interday.1 = abs.interday.mov
par(mar = c(5,5,2,5))
plot(1:num.udays,intraday.1,type="l",col="red")
par(new = T)
plot(1:num.udays, interday.1,type="l", axes=F, xlab=NA, ylab=NA, cex=1.2)
axis(side = 4)
mtext(side = 4, line = 3, 'interday.1')
legend("topleft",
       legend=c("intraday.1", "interday.1"),
       lty=c(1,1), col=c("red", "black"))
###############brute force method to calculate sum of absolute mov
ob.perday=matrix(data=0, nrow=num.udays)
num.ob=dim(df.date)[1]
parsed.days = 0
for (i in 1:num.udays) {
  for (j in (ob.perday[i]+1):num.ob) {
    if (df.date[j,1]==u.date[i,1]) {
      ob.perday[i] = ob.perday[i] + 1
      if (ob.perday[i]>1) {
        abs.mov[i] = abs.mov[i] + abs(df.price[j,1]-df.price[j-1,1])
      }
    }
  }
  parsed.days = parsed.days + ob.perday[i]
}
#################################################################

pathname="C:/Users/YChen/Documents/git/working_dir/R/Data/"
file_name3="test_bardata_output.csv"
file_dir3=paste(pathname,file_name3,sep="")
write.csv(x_bar, file_dir3)