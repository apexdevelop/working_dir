setwd("C:/Documents and Settings/YChen/My Documents/R")
# set output options
options(width = 70, digits=4)

# load required packages
library(ellipse)
library(fEcofin)                # various data sets
library(PerformanceAnalytics)   # performance and risk analysis functions
library(zoo)

# load Data
raw_price=read.csv("Japan_transport_index.csv", stringsAsFactors=F)
num_obs=dim(raw_price)[1]
num_dim=dim(raw_price)[2]/2
name="TPTRAN Index"

raw_factor=read.csv("japan_multifactor_monthly.csv", stringsAsFactors=F)
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

f3=raw_factor[,5:6]
f_ind3=0
for (i in 1:num_obs_f){
    if (is.na(f3[i,2])==TRUE) f_ind3=f_ind3+1}
factor3=f3[1:(num_obs_f-f_ind3),]

f4=raw_factor[,7:8]
f_ind4=0
for (i in 1:num_obs_f){
    if (is.na(f4[i,2])==TRUE) f_ind4=f_ind4+1}
factor4=f4[1:(num_obs_f-f_ind4),]

f5=raw_factor[,9:10]
f_ind5=0
for (i in 1:num_obs_f){
    if (is.na(f5[i,2])==TRUE) f_ind5=f_ind5+1}
factor5=f5[1:(num_obs_f-f_ind5),]

f6=raw_factor[,11:12]
f_ind6=0
for (i in 1:num_obs_f){
    if (is.na(f6[i,2])==TRUE) f_ind6=f_ind6+1}
factor6=f6[1:(num_obs_f-f_ind6),]

f7=raw_factor[,13:14]
f_ind7=0
for (i in 1:num_obs_f){
    if (is.na(f7[i,2])==TRUE) f_ind7=f_ind7+1}
factor7=f7[1:(num_obs_f-f_ind7),]

f8=raw_factor[,15:16]
f_ind8=0
for (i in 1:num_obs_f){
    if (is.na(f8[i,2])==TRUE) f_ind8=f_ind8+1}
factor8=f8[1:(num_obs_f-f_ind8),]

f9=raw_factor[,17:18]
f_ind9=0
for (i in 1:num_obs_f){
    if (is.na(f9[i,2])==TRUE) f_ind9=f_ind9+1}
factor9=f9[1:(num_obs_f-f_ind9),]

f10=raw_factor[,19:20]
f_ind10=0
for (i in 1:num_obs_f){
    if (is.na(f10[i,2])==TRUE) f_ind10=f_ind10+1}
factor10=f10[1:(num_obs_f-f_ind10),]

f11=raw_factor[,21:22]
f_ind11=0
for (i in 1:num_obs_f){
    if (is.na(f11[i,2])==TRUE) f_ind11=f_ind11+1}
factor11=f11[1:222,]



N2=dim(factor1)[1]
N3=dim(factor2)[1]
N4=dim(factor3)[1]
N5=dim(factor4)[1]
N6=dim(factor5)[1]
N7=dim(factor6)[1]
N8=dim(factor7)[1]
N9=dim(factor8)[1]
N10=dim(factor9)[1]
N11=dim(factor10)[1]
N12=dim(factor11)[1]


factor1.n=(factor1[,2]-mean(factor1[,2]))/sd(factor1[,2])
factor2.n=(factor2[,2]-mean(factor2[,2]))/sd(factor2[,2])
factor3.n=(factor3[,2]-mean(factor3[,2]))/sd(factor3[,2])
factor4.n=(factor4[,2]-mean(factor4[,2]))/sd(factor4[,2])
factor5.n=(factor5[,2]-mean(factor5[,2]))/sd(factor5[,2])
factor6.n=(factor6[,2]-mean(factor6[,2]))/sd(factor6[,2])
factor7.n=(factor7[,2]-mean(factor7[,2]))/sd(factor7[,2])
factor8.n=(factor8[,2]-mean(factor8[,2]))/sd(factor8[,2])
factor9.n=(factor9[,2]-mean(factor9[,2]))/sd(factor9[,2])
factor10.n=(factor10[,2]-mean(factor10[,2]))/sd(factor10[,2])
factor11.n=(factor11[,2]-mean(factor11[,2]))/sd(factor11[,2])

factor1.d <- as.Date(factor1[1:N2,1],"%m/%d/%Y")
factor2.d <- as.Date(factor2[1:N3,1],"%m/%d/%Y")
factor3.d <- as.Date(factor3[1:N4,1],"%m/%d/%Y")
factor4.d <- as.Date(factor4[1:N5,1],"%m/%d/%Y")
factor5.d <- as.Date(factor5[1:N6,1],"%m/%d/%Y")
factor6.d <- as.Date(factor6[1:N7,1],"%m/%d/%Y")
factor7.d <- as.Date(factor7[1:N8,1],"%m/%d/%Y")
factor8.d <- as.Date(factor8[1:N9,1],"%m/%d/%Y")
factor9.d <- as.Date(factor9[1:N10,1],"%m/%d/%Y")
factor10.d <- as.Date(factor10[1:N11,1],"%m/%d/%Y")
factor11.d <- as.Date(factor11[1:N12,1],"%m/%d/%Y")

factor1.zoo=zoo(factor1.n,factor1.d)
factor2.zoo=zoo(factor2.n,factor2.d)
factor3.zoo=zoo(factor3.n,factor3.d)
factor4.zoo=zoo(factor4.n,factor4.d)
factor5.zoo=zoo(factor5.n,factor5.d)
factor6.zoo=zoo(factor6.n,factor6.d)
factor7.zoo=zoo(factor7.n,factor7.d)
factor8.zoo=zoo(factor8.n,factor8.d)
factor9.zoo=zoo(factor9.n,factor9.d)
factor10.zoo=zoo(factor10.n,factor10.d)
factor11.zoo=zoo(factor11.n,factor11.d)

tmp1.zoo<-merge(factor1.zoo,factor2.zoo,all=FALSE)
m1.zoo=tmp1.zoo$factor5.zoo-tmp1.zoo$factor1.zoo

tmp2.zoo<-merge(factor3.zoo,factor4.zoo,all=FALSE)
m2.zoo=tmp2.zoo$factor3.zoo-tmp2.zoo$factor4.zoo
tmp3.zoo<-merge(factor5.zoo,factor6.zoo,all=FALSE)
m3.zoo=tmp3.zoo$factor5.zoo-tmp3.zoo$factor6.zoo
tmp4.zoo<-merge(factor7.zoo,factor8.zoo,all=FALSE)
m4.zoo=tmp4.zoo$factor7.zoo-tmp4.zoo$factor8.zoo
tmp5.zoo<-merge(factor9.zoo,factor10.zoo,all=FALSE)
m5.zoo=tmp5.zoo$factor9.zoo-tmp5.zoo$factor10.zoo
tmp6.zoo<-merge(tmp1.zoo,tmp2.zoo,all=FALSE)
tmp7.zoo<-merge(tmp3.zoo,tmp4.zoo,all=FALSE)
tmp8.zoo<-merge(tmp5.zoo,factor11.zoo,all=FALSE)
tmp9.zoo<-merge(tmp6.zoo,tmp7.zoo,all=FALSE)
tmp10.zoo<-merge(tmp8.zoo,tmp9.zoo,all=FALSE)

p1=raw_price[,1:2]
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
#price1.n=price1[,2]


price1.d <- as.Date(price1[1:N1,1],"%m/%d/%Y")
price1.zoo=zoo(price1.n,price1.d)



# The merge function can combine two zoo objects,
# computing either their intersection (all=FALSE)
# or union (all=TRUE).
#


t.zoo<-merge(price1.zoo, factor11.zoo, all=FALSE)

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
#var1=VAR(t.his,p=1,type="both")

var1=VAR(t.his,p=bestlag,type="both")
coeff=coef(var1)

result=matrix(0,ncol=bestlag,nrow=1)
for (i in 1:bestlag){
result[i]=coeff$price1.zoo[(2*bestlag+2)*3+2*i]
}

#write.table(result, file="Japan-Test-1.csv", sep=",", append=TRUE, col.names=FALSE)

summary(var1)
