setwd("C:/Documents and Settings/YChen/My Documents/R")
# set output options
options(width = 70, digits=4)

# load required packages
library(ellipse)
library(fEcofin)                # various data sets
library(PerformanceAnalytics)   # performance and risk analysis functions
library(zoo)

# load Data
raw_price=read.csv("japan_input_price.csv", stringsAsFactors=F)
num_obs=dim(raw_price)[1]
num_dim=dim(raw_price)[2]/2
name="HOYA CORP"


#y=cbind(p1,p2)

p1=raw_price[,9:10]
ind1=0
for (i in 1:num_obs){
    if (is.na(p1[i,2])==TRUE) ind1=ind1+1}
price1=p1[1:(num_obs-ind1),]

raw_factor=read.csv("factor_input.csv", stringsAsFactors=F)
num_obs_f=dim(raw_factor)[1]
num_dim_f=dim(raw_factor)[2]/2

f1=raw_factor[,1:2]
f_ind1=0
for (i in 1:num_obs_f){
    if (is.na(f1[i,2])==TRUE) f_ind1=f_ind1+1}
factor1=f1[1:(num_obs_f-f_ind1),]

f2=raw_factor[,3:4]
f_ind2=0
for (i in 1:num_obs_f){
    if (is.na(f2[i,2])==TRUE) f_ind2=f_ind2+1}
factor2=f2[1:(num_obs_f-f_ind2),]


N1=dim(price1)[1]
N2=dim(factor1)[1]
N3=dim(factor2)[1]

# Normalize the time series
price1.n=(price1[,2]-mean(price1[,2]))/sd(price1[,2])
factor1.n=(factor1[,2]-mean(factor1[,2]))/sd(factor1[,2])
factor2.n=(factor2[,2]-mean(factor2[,2]))/sd(factor2[,2])

# differentiate the time series
#price1.r=diff(price1.n)/price1.n[1:N1-1]
#factor1.r=diff(factor1.n)/factor1.n[1:(N2-1)]
#factor2.r=diff(factor2.n)/factor2.n[1:(N3-1)]


# The first column contains dates.  The as.Date
# function can convert strings into Date objects.
#
price1.d <- as.Date(price1[,1],"%m/%d/%Y")
factor1.d <- as.Date(factor1[,1],"%m/%d/%Y")
factor2.d <- as.Date(factor1[,1],"%m/%d/%Y")

price1.zoo=zoo(price1.n,price1.d[1:(N1-1)])
factor1.zoo=zoo(factor1.n,factor1.d[1:(N2-1)])
factor2.zoo=zoo(factor2.n,factor2.d[1:(N2-1)])

# The merge function can combine two zoo objects,
# computing either their intersection (all=FALSE)
# or union (all=TRUE).
#
tmp.zoo <- merge(factor1.zoo, factor2.zoo, all=FALSE)
t.zoo<-merge(tmp.zoo, price1.zoo, all=FALSE)

# create data frame
#
t=as.data.frame(t.zoo)

#choose the exogenous variable


#par(mfrow=c(2,1))
#plot(date,t(d1.df[1]),type="l",ylab="",main="1st difference of citcrp",col="blue")
#plot(date,t(m1.df),type="l",main="difference between citcrp and coned",col="blue")

#Estimate VAR Parameters
#Pick previous days to estimate from
pred.window=30
history=dim(t)[1]-pred.window
t.his=t[1:history,]
t.now=t[(history+1):dim(t)[1],]
colnames(t.now)=c("now.price1","now.factor1","now.factor2")
library(vars)
VARselect(t.his, lag.max = 8, type = "const")

var1=VAR(t.his,p=2,type="const")
summary(var1)

##################Prediction###################
var1.pred=predict(var1,n.ahead=pred.window,ci=0.95)
plot(var1.pred)
plot(var1.pred,names="price1.zoo")
#fanchart(var1.pred,names="price1.zoo")


predict.price1=as.matrix(var1.pred$fcst$price1.zoo[,1])
#predict.factor1=as.matrix(var1.pred$fcst$factor1.zoo[,1])
#predict.factor2=as.matrix(var1.pred$fcst$factor2.zoo[,1])

his.price1=as.matrix(t.his[,3])
mix.price1=rbind(his.price1,predict.price1)

#his.factor1=as.matrix(t.his[,1])
#mix.factor1=rbind(his.factor1,predict.factor1)

date=as.Date(row.names(t))

#############Comparion between observed and predicted price
plot(date,mix.price1,type="l",col="blue",lwd=2,ylim=range(t[,2]),main=name)
lines(date,t[,3],col="red")
grid()
legend("topleft",c('"predicted"','"observed"'),col=c("blue","red"),lty=c(1,1))

#########################################################################