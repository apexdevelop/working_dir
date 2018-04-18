setwd("C:/Users/ychen/Documents/R")
# set output options
options(width = 70, digits=4)

# load required packages
library(ellipse)
#library(fEcofin)                # various data sets
library(PerformanceAnalytics)   # performance and risk analysis functions
library(zoo)

# load Data
ndf = read.csv("NDF.csv", stringsAsFactors=F)
index = read.csv("INDEX.csv", stringsAsFactors=F)

N1=dim(ndf)[1]
N2=dim(index)[1]

# Inverse the ndf series
#
ndf.inverse=1/ndf[,2]

# Normalize the time series
ndf.n=(ndf.inverse-mean(ndf.inverse))/sd(ndf.inverse)
index.n=(index[,2]-mean(index[,2]))/sd(index[,2])

# differentiate the time series
#ndf.r=diff(ndf.inverse/ndf.inverse[1:N1-1]
#index.r=diff(index[,2])/index[1:(N2-1),2]

# The first column contains dates.  The as.Date
# function can convert strings into Date objects.
#
ndf.d <- as.Date(ndf[,1],"%m/%d/%Y")
index.d <- as.Date(index[,1],"%m/%d/%Y")

ndf.zoo=zoo(ndf.n,ndf.d[1:(N1-1)])
index.zoo=zoo(index.n,index.d[1:(N2-1)])
# The merge function can combine two zoo objects,
# computing either their intersection (all=FALSE)
# or union (all=TRUE).
#
t.zoo <- merge(ndf.zoo, index.zoo, all=FALSE)

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
colnames(t.now)=c("now.ndf","now.index")
library(vars)
VARselect(t.his, lag.max = 8, type = "const")

var1=VAR(t.his,p=3,type="const")
summary(var1)


################Serial Test#######################################
##testing serial correlation
args(serial.test)
##Portmanteau-Test
var1.serial=serial.test(var1,lags.pt=16,type="PT.asymptotic")
var1.serial
plot(var1.serial,names="ndf.zoo")
plot(var1.serial,names="index.zoo")
## testing  heteroscedasticity
args(arch.test)
var1.arch<-arch.test(var1,lags.multi=5,multivariate.only=TRUE)
var1.arch
## t e s t i n g for normality
args(normality.test)
var1.norm=normality.test(var1,multivariate.only=TRUE)
var1.norm
#class and methods for diganostic tests
class(var1.serial)
class(var1.arch)
class(var1.norm)
methods(class="varcheck")
##Plot of objuests"varchek"
args(vars:::plot.varcheck)

##Causality tests
##Granger and instantaneous causality
var1.causal1=causality(var1,cause="ndf.zoo")
var1.causal2=causality(var1,cause="index.zoo")


##################Prediction###################
var1.pred=predict(var1,n.ahead=pred.window,ci=0.95)
plot(var1.pred)
plot(var1.pred,names="ndf.zoo")
fanchart(var1.pred,names="index.zoo")


predict.ndf=as.matrix(var1.pred$fcst$ndf.zoo[,1])
predict.index=as.matrix(var1.pred$fcst$index.zoo[,1])

his.ndf=as.matrix(t.his[,1])
mix.ndf=rbind(his.ndf,predict.ndf)

his.index=as.matrix(t.his[,2])
mix.index=rbind(his.index,predict.index)

date=as.Date(row.names(t))

#############Comparion between observed and predicted index
plot(date,mix.index,type="l",col="blue",lwd=2,ylim=range(t[,2]),main="HSCCI Index")
lines(date,t[,2],col="red")
grid()
legend("topleft",c('"predicted"','"observed"'),col=c("blue","red"),lty=c(1,1))

#############Comparion between observed and predicted ndf
plot(date,mix.ndf,type="l",col="blue",lwd=2,ylim=range(t[,1]),main="NDF Curncy")
lines(date,t[,1],col="red")
grid()
legend("topleft",c('"predicted"','"observed"'),col=c("blue","red"),lty=c(1,1))


#compare.ndf=cbind(t.now[,1],predict.ndf)
compare.ndf=t.now
compare.ndf[,2]=predict.ndf
colnames(compare.ndf)=c("now.ndf","predict.ndf")
par(mfrow=c(3,1))
#plot(date,t[,1],type="l",col="blue")
#plot(date,t[,2],type="l",col="red")
#plot(date,mix.index,type="l",col="green")

##################################impulse response analysis
irf.ndf=irf(var1,impulse="ndf.zoo",response="index.zoo",n.ahead=10,ortho=FALSE,cumulative=FALSE,boot=FALSE,seed=12345)
args(vars:::plot.varirf)
plot(irf.ndf)

irf.index=irf(var1,impulse="index.zoo",response="ndf.zoo",n.ahead=10,ortho=TRUE,cumulative=TRUE,boot=FALSE,seed=12345)
args(vars:::plot.varirf)
plot(irf.index)



#########################################################################

uni_his=index.n[1:history]
factor_his=ndf.n[1:history]
uni_now=index.n[(history+1):dim(t)[1]]
factor_now=ndf.n[(history+1):dim(t)[1]]

armafit=arima(uni_his,order=c(3,0,2),xreg=factor_his)
armafit.pred=predict(armafit,n.ahead=30,newxreg=factor_now)
date_now=date[(history+1):dim(t)[1]]

plot(date_now,armafit.pred$pred,type="l",col="blue",lwd=2,ylim=range(uni_now))
lines(date_now,uni_now,col="red")
grid()

#########################################################################
library(fastVAR)
data(Canada)
fastVAR(Canada,3)$model$coefficient


#summary(Canada)
#plot(Canada, nc = 2, xlab = "")
adf1 <- summary(ur.df(Canada[, "prod"], type = "trend", lags = 2))
#lm(formula = z.diff ~ z.lag.1 + 1 + tt + z.diff.lag)

adf2 <- summary(ur.df(diff(Canada[, "prod"]), type = "drift",lags = 1))
#lm(formula = z.diff ~ z.lag.1 + 1 + z.diff.lag)

VARselect(Canada, lag.max = 8, type = "both")
Canada <- Canada[, c("prod", "e", "U", "rw")]
p1ct <- VAR(Canada, p = 1, type = "both")
summary(p1ct, equation = "e")
plot(p1ct, names = "e")