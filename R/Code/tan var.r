setwd("C:/Documents and Settings/YChen/My Documents/R")
# set output options
options(width = 70, digits=4)

# load required packages
library(ellipse)
library(fEcofin)                # various data sets
library(PerformanceAnalytics)   # performance and risk analysis functions
library(zoo)

# load Data
raw_price=read.csv("JP_health.csv", stringsAsFactors=F)
num_obs=dim(raw_price)[1]
num_dim=dim(raw_price)[2]/2
name="tan US"

raw_factor=read.csv("factor_input.csv", stringsAsFactors=F)
num_obs_f=dim(raw_factor)[1]
num_dim_f=dim(raw_factor)[2]/2

f1=raw_factor[,9:10]
f_ind1=0
for (i in 1:num_obs_f){
    if (is.na(f1[i,2])==TRUE) f_ind1=f_ind1+1}
factor1=f1[1:(num_obs_f-f_ind1),]

f2=raw_factor[,11:12]
f_ind2=0
for (i in 1:num_obs_f){
    if (is.na(f2[i,2])==TRUE) f_ind2=f_ind2+1}
factor2=f2[1:(num_obs_f-f_ind2),]
N2=dim(factor1)[1]
N3=dim(factor2)[1]

factor1.n=(factor1[,2]-mean(factor1[,2]))/sd(factor1[,2])
factor2.n=(factor2[,2]-mean(factor2[,2]))/sd(factor2[,2])

factor1.d <- as.Date(factor1[2:N2,1],"%m/%d/%Y")
factor2.d <- as.Date(factor2[2:N3,1],"%m/%d/%Y")

factor1.zoo=zoo(factor1.n,factor1.d)
factor2.zoo=zoo(factor2.n,factor2.d)
tmp.zoo<-merge(factor1.zoo,factor2.zoo,all=FALSE)
tmp1.zoo<-tmp.zoo$factor1.zoo-tmp.zoo$factor2.zoo

for (j in 1:36){
p1=raw_price[,(2*j-1):(2*j)]
ind1=0
for (i in 1:num_obs){
    if (is.na(p1[i,2])==TRUE) ind1=ind1+1}
price1=p1[1:(num_obs-ind1),]

ind1_p=0
for(i in 1:(num_obs-ind1)){
    if(price1[i,2]=="") ind1_p=ind1_p+1}
price1=price1[1:(num_obs-ind1-ind1_p),]

N1=dim(price1)[1]


# Normalize the time series
price1.n=(price1[,2]-mean(price1[,2]))/sd(price1[,2])


#price1.n=log(price1[,2],base=exp(1))
#factor1.n=log(factor1[,2],base=exp(1))
#factor2.n=log(factor2[,2],base=exp(1))

# differentiate the time series
#price1.n=diff(price1[,2])
#factor1.n=diff(factor1[,2])
#factor2.n=diff(factor2[,2])

#price1.n=(price1.n-mean(price1.n))/sd(price1.n)
#factor1.n=(factor1.n-mean(factor1.n))/sd(factor1.n)
#factor2.n=(factor2.n-mean(factor2.n))/sd(factor2.n)


# The first column contains dates.  The as.Date
# function can convert strings into Date objects.
#
price1.d <- as.Date(price1[2:N1,1],"%m/%d/%Y")
price1.zoo=zoo(price1.n,price1.d)



# The merge function can combine two zoo objects,
# computing either their intersection (all=FALSE)
# or union (all=TRUE).
#


t.zoo<-merge(price1.zoo, tmp1.zoo, all=FALSE)

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
colnames(t.now)=c("now.price1","now.factor")
library(vars)
lags=VARselect(t.his, lag.max = 10, type = "both")
#plot(t.zoo)
bestlag=lags$selection[1]
var1=VAR(t.his,p=bestlag,type="both")
coeff=coef(var1)

result=matrix(0,ncol=bestlag,nrow=1)
for (i in 1:bestlag){
result[i]=coeff$price1.zoo[(2*bestlag+2)*3+2*i]
}

write.table(result, file="JP-health-P.csv", sep=",", append=TRUE, col.names=FALSE)

#summary(var1)
}