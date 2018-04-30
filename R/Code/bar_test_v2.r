#pathname="C:/Users/YChen/Documents/git/working_dir/R/Data/"
home = path.expand("~") #which is "C:/Users/YChen/Documents"
pathname=paste(home,"/git/working_dir/R/Data/",sep="")

library(Rblpapi)
con=blpConnect()
tz = "America/New_York"
##don't use "EST", "EST" in R means somewhere in Eastern Canada
Sys.setenv(TZ = tz)

security="SPY Equity"

current.date=Sys.Date()
lookback.window=200
char.start.date=as.character(current.date-lookback.window,"%m/%d/%Y")
char.start.time=paste(char.start.date,"09:30:00")
char.end.date=as.character(current.date-1,"%m/%d/%Y")
char.end.time=paste(char.end.date,"16:15:00")

#char.start.time="03/25/2017 09:30:00"
#char.end.time="03/28/2018 16:15:00"
start.time=as.POSIXct(char.start.time,format='%m/%d/%Y %H:%M:%S')
end.time=as.POSIXct(char.end.time,format='%m/%d/%Y %H:%M:%S')

##functions from Rblpapi package will not work after library Rbbg is used.
##have to close R and reopen it
x_bar= getBars(security, eventType = "TRADE", barInterval = 1,
        startTime = start.time, endTime = end.time,con= defaultConnection())

df.date=as.data.frame(as.Date(x_bar$times))
u.date=unique(df.date)
num.udays=dim(u.date)[1]
rownames(u.date)=1:num.udays
colnames(u.date)="u.date"

v.time=format(x_bar$times,'%H:%M:%S')
df.price=as.data.frame(x_bar$close)


newdf=cbind(df.date,df.price)
colnames(newdf)=c("date","price")
list.bar = split(newdf,f = newdf$date)

##############user-defined function####################
fun_abs_sum <- function(x) {
  sum = 0
  num.rows=length(x)
  for (i in 2:num.rows) {
    sum = sum + abs(x[i]-x[i-1])
  }
  return(sum)
}

intraday.1= sapply(list.bar, function(x) fun_abs_sum( x$price ))
#intrada.1 is a named numeric, use head(names(intraday.1)) could see the names, not colnames, not rownames
df.intraday.1 = as.data.frame(intraday.1)
#####################################

###interday mov
start.date=u.date[1,1]
end.date=u.date[num.udays,1]
d.fields=c("CHG_NET_1D","LAST_PRICE")
df.day.data=bdh(security,d.fields,start.date,end.date)

interday.1=abs(df.day.data$CHG_NET_1D)
df.interday.1=as.data.frame(interday.1)
security.1 = df.day.data$LAST_PRICE

par(mar = c(5,7,5,5)) #margin in lines on bottom, left, top and right, every line is 0.2 inch
#plot(u.date,intraday.1,type="l",col="red",xlab="Date")
##it will give errors if try to plot(u.date,df.intrady.1), have to specify the name of the column even if there is only one column
##if don't specify ylab, it will default to df.intraday.1$intraday.1
##if don't specify xlab, it will default to x1
##Set las to 1 to change the label positions so that they are horizontal.
#plot(u.date,df.intraday.1$intraday.1,type="l",col="red",xlab="Date",ylab="intraday.1")
plot(u.date,df.intraday.1$intraday.1,type="l",col="red",xlab="Date",ylab=NA,las = 1)
mtext(side = 2, line = 2, 'intraday.1') # 2 lines from the left axis
par(new = T)
#plot(u.date, interday.1,type="l", axes=F, xlab=NA, ylab=NA,col="blue")
plot(u.date, df.interday.1$interday.1,type="l", axes=F, xlab=NA, ylab=NA,col="blue")
axis(side = 4,las = 1) #on the right
mtext(side = 4, line = 2, 'interday.1') # 3 lines from the right axis
par(new = T)
##use lwd for line width
plot(u.date, security.1,type="l", axes=F, xlab=NA, ylab=NA, lwd=2)
axis(side = 2,line = 4,las = 1) #on the left
mtext(side = 2, line = 6, 'security.1')# 5 lines from the left axis

legend("topleft",
       legend=c("intraday.1", "interday.1", "security.1"),
       lty=c(1,1,1), col=c("red", "blue","black"), cex = 0.8, bty = "n")


###############5day cumulative##################
n.movdays=5
f5= rep(1/n.movdays, n.movdays)
intraday.5 = n.movdays*filter(intraday.1, f5, sides=1)
interday.5 = n.movdays*filter(interday.1, f5, sides=1)
security.5 = n.movdays*filter(security.1, f5, sides=1)

plot.new()
par(mar = c(5,5,2,5))
plot(u.date,intraday.5,type="l",col="red",xlab="Date")
par(new = T)
plot(u.date, interday.5,type="l", axes=F, xlab=NA, ylab=NA, cex=1.2,col="blue")
axis(side = 4) #on the right
mtext(side = 4, line = 3, 'interday.5')
par(new = T)
plot(u.date, security.5,type="l", axes=F, xlab=NA, ylab=NA, lwd=2)

legend("topleft",
       legend=c("intraday.5", "interday.5", "security.5"),
       lty=c(1,1,1), col=c("red", "blue","black"), cex = 0.8, bty = "n")



out.df.rownames = rownames(df.intraday.1)

df.intraday.5 = as.data.frame(intraday.5)
df.interday.5=as.data.frame(interday.5)
colnames(df.intraday.5)="intraday.5"
colnames(df.interday.5)="interday.5"
df.security.1 = as.data.frame(security.1)
df.security.5=as.data.frame(security.5)
colnames(df.security.5)="security.5"
out.df=cbind(df.intraday.1,df.interday.1,df.security.1,df.intraday.5,df.interday.5,df.security.5)



str_current_date=format(current.date,'%m%d%Y')

file_name1=paste("bardata_",str_current_date,".csv",sep="")
file_dir1=paste(pathname,file_name1,sep="")
write.csv(x_bar, file_dir1)

file_name2=paste("bardata_output_",str_current_date,".csv",sep="")
file_dir2=paste(pathname,file_name2,sep="")
write.csv(out.df, file_dir2)