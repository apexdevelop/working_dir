setwd("C:/Users/ychen/Documents/R/Data")
# set output options
options(width = 70, digits=4)

# load required packages
library(ellipse)

library(PerformanceAnalytics)   # performance and risk analysis functions
library(zoo)

# load Data
raw_price=read.csv("vec_ret_1yr_0120.csv", stringsAsFactors=F)
num_obs=dim(raw_price)[1]
num_dim=dim(raw_price)[2]/2
name="6301 JP"


r1=raw_price[,1:2]
ind1=0
for (i in 1:num_obs){
    if (is.na(r1[i,2])==TRUE) ind1=ind1+1}
return1=r1[1:(num_obs-ind1),]

#raw_factor=read.csv("factor_input.csv", stringsAsFactors=F)
#num_obs_f=dim(raw_factor)[1]
#num_dim_f=dim(raw_factor)[2]/2

rf1=raw_price[,3:4]
f_ind1=0
for (i in 1:num_obs){
    if (is.na(rf1[i,2])==TRUE) f_ind1=f_ind1+1}
rfactor1=rf1[1:(num_obs-f_ind1),]

rf2=raw_price[,5:6]
f_ind2=0
for (i in 1:num_obs){
    if (is.na(rf2[i,2])==TRUE) f_ind2=f_ind2+1}
rfactor2=rf2[1:(num_obs-f_ind2),]

N1=dim(return1)[1]
N2=dim(rfactor1)[1]
N3=dim(rfactor2)[1]

# Normalize the time series

return1.n=return1[,2]
rfactor1.n=rfactor1[,2]
rfactor2.n=rfactor2[,2]

# differentiate the time series
#price1.r=diff(price1.n)/price1.n[1:N1-1]
#factor1.r=diff(factor1.n)/factor1.n[1:(N2-1)]
#factor2.r=diff(factor2.n)/factor2.n[1:(N3-1)]


# The first column contains dates.  The as.Date
# function can convert strings into Date objects.
#
return1.d <- as.Date(return1[,1],"%m/%d/%Y")
rfactor1.d <- as.Date(rfactor1[,1],"%m/%d/%Y")
rfactor2.d <- as.Date(rfactor1[,1],"%m/%d/%Y")

return1.zoo=zoo(return1.n,return1.d[1:N1])
rfactor1.zoo=zoo(rfactor1.n,rfactor1.d[1:N2])
rfactor2.zoo=zoo(rfactor2.n,rfactor2.d[1:N2])

# The merge function can combine two zoo objects,
# computing either their intersection (all=FALSE)
# or union (all=TRUE).
#
tmp.zoo <- merge(rfactor1.zoo, rfactor2.zoo, all=FALSE)
#t.zoo <- merge(return1.zoo,rfactor2.zoo, all=FALSE)
t.zoo <- merge(return1.zoo,tmp.zoo, all=FALSE)


# create data frame
#
t=as.data.frame(t.zoo)

#choose the exogenous variable


#Estimate VAR Parameters
#Pick previous days to estimate from
pred.window=0
history=dim(t)[1]-pred.window
t.his=t[1:history,]
t.now=t[(history+1):dim(t)[1],]
#colnames(t.now)=c("now.price1","now.factor1","now.factor2")
colnames(t.now)=c("now.return1","now.factor1")
library(vars)
VARselect(t.his, lag.max = 8, type = "const")

var1=VAR(t.his,p=2,type="const")

causality(var1,cause="rfactor2.zoo")

#summary(var1)
var1.coef=Bcoef(var1)
vecPi=as.vector(var1.coef)

var1.fit=fitted(var1)
R=matrix(c(0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0),4,21,byrow=T)

##vcovHC(var1)Heteroskedasticity-consistent estimation of the covariance matrix of the coef?cient estimates in
##regression models.


avar=R%*%vcovHC(var1)%*%t(R)
wald=t(R%*%vecPi)%*%solve(avar)%*%(R%*%vecPi)
p.value=1-pchisq(wald,2)
##################Prediction###################
var1.pred=predict(var1,n.ahead=pred.window,ci=0.95)
plot(var1.pred)
plot(var1.pred,names="price1.zoo")
#fanchart(var1.pred,names="price1.zoo")


predict.price1=as.matrix(var1.pred$fcst$price1.zoo[,1])
#predict.factor1=as.matrix(var1.pred$fcst$factor1.zoo[,1])
#predict.factor2=as.matrix(var1.pred$fcst$factor2.zoo[,1])

his.price1=as.matrix(t.his[,1])
mix.price1=rbind(his.price1,predict.price1)

#his.factor1=as.matrix(t.his[,1])
#mix.factor1=rbind(his.factor1,predict.factor1)

date=as.Date(row.names(t))

#############Comparion between observed and predicted price
plot(date,mix.price1,type="l",col="blue",lwd=2,ylim=range(t[,2]),main=name)
lines(date,t[,1],col="red")
grid()
legend("topleft",c('"predicted"','"observed"'),col=c("blue","red"),lty=c(1,1))

#########################################################################