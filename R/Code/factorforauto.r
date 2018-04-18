setwd("C:/Documents and Settings/YChen/My Documents/R")

library(zoo)            # Load the zoo package

# Read the CSV files into data frames
#
rawdata = read.csv("input_price.csv", stringsAsFactors=F)
dimr=dim(rawdata)[1]
dimc=dim(rawdata)[2]/2


d1=rawdata[,1:2]
ind1=0
for (i in 1:dimr){
    if (is.na(d1[i,2])==TRUE) ind1=ind1+1}
data1=d1[1:(dimr-ind1),]

d2=rawdata[,3:4]
ind2=0
for (i in 1:dimr){
    if (is.na(d2[i,2])==TRUE) ind2=ind2+1}
data2=d2[1:(dimr-ind2),]

d3=rawdata[,5:6]
ind3=0
for (i in 1:dimr){
    if (is.na(d3[i,2])==TRUE) ind3=ind3+1}
data3=d3[1:(dimr-ind3),]

d4=rawdata[,7:8]
ind4=0
for (i in 1:dimr){
    if (is.na(d4[i,2])==TRUE) ind4=ind4+1}
data4=d4[1:(dimr-ind4),]

d5=rawdata[,9:10]
ind5=0
for (i in 1:dimr){
    if (is.na(d5[i,2])==TRUE) ind5=ind5+1}
data5=d5[1:(dimr-ind5),]

d6=rawdata[,11:12]
ind6=0
for (i in 1:dimr){
    if (is.na(d6[i,2])==TRUE) ind6=ind6+1}
data6=d6[1:(dimr-ind6),]

d7=rawdata[,13:14]
ind7=0
for (i in 1:dimr){
    if (is.na(d7[i,2])==TRUE) ind7=ind7+1}
data7=d7[1:(dimr-ind7),]

d8=rawdata[,15:16]
ind8=0
for (i in 1:dimr){
    if (is.na(d8[i,2])==TRUE) ind8=ind8+1}
data8=d8[1:(dimr-ind8),]

d9=rawdata[,17:18]
ind9=0
for (i in 1:dimr){
    if (is.na(d9[i,2])==TRUE) ind9=ind9+1}
data9=d9[1:(dimr-ind9),]

d10=rawdata[,19:20]
ind10=0
for (i in 1:dimr){
    if (is.na(d10[i,2])==TRUE) ind10=ind10+1}
data10=d10[1:(dimr-ind10),]

d11=rawdata[,21:22]
ind11=0
for (i in 1:dimr){
    if (is.na(d11[i,2])==TRUE) ind11=ind11+1}
data11=d11[1:(dimr-ind11),]

d12=rawdata[,23:24]
ind12=0
for (i in 1:dimr){
    if (is.na(d12[i,2])==TRUE) ind12=ind12+1}
data12=d12[1:(dimr-ind12),]

d13=rawdata[,25:26]
ind13=0
for (i in 1:dimr){
    if (is.na(d13[i,2])==TRUE) ind13=ind13+1}
data13=d13[1:(dimr-ind13),]

d14=rawdata[,27:28]
ind14=0
for (i in 1:dimr){
    if (is.na(d14[i,2])==TRUE) ind14=ind14+1}
data14=d14[1:(dimr-ind14),]

d15=rawdata[,29:30]
ind15=0
for (i in 1:dimr){
    if (is.na(d15[i,2])==TRUE) ind15=ind15+1}
data15=d15[1:(dimr-ind15),]

d16=rawdata[,31:32]
ind16=0
for (i in 1:dimr){
    if (is.na(d16[i,2])==TRUE) ind16=ind16+1}
data16=d16[1:(dimr-ind16),]

d17=rawdata[,33:34]
ind17=0
for (i in 1:dimr){
    if (is.na(d17[i,2])==TRUE) ind17=ind17+1}
data17=d17[1:(dimr-ind17),]


dates1 <- as.Date(data1[,1],"%m/%d/%Y")
dates2 <- as.Date(data2[,1],"%m/%d/%Y")
dates3 <- as.Date(data3[,1],"%m/%d/%Y")
dates4 <- as.Date(data4[,1],"%m/%d/%Y")
dates5 <- as.Date(data5[,1],"%m/%d/%Y")
dates6 <- as.Date(data6[,1],"%m/%d/%Y")
dates7 <- as.Date(data7[,1],"%m/%d/%Y")
dates8 <- as.Date(data8[,1],"%m/%d/%Y")
dates9 <- as.Date(data9[,1],"%m/%d/%Y")
dates10 <- as.Date(data10[,1],"%m/%d/%Y")
dates11 <- as.Date(data11[,1],"%m/%d/%Y")
dates12 <- as.Date(data12[,1],"%m/%d/%Y")
dates13 <- as.Date(data13[,1],"%m/%d/%Y")
dates14 <- as.Date(data14[,1],"%m/%d/%Y")
dates15 <- as.Date(data15[,1],"%m/%d/%Y")
dates16 <- as.Date(data16[,1],"%m/%d/%Y")
dates17 <- as.Date(data17[,1],"%m/%d/%Y")

z1=zoo(data1[,2],dates1)
z2=zoo(data2[,2],dates2)
z3=zoo(data3[,2],dates1)
z4=zoo(data4[,2],dates1)
z5=zoo(data5[,2],dates1)
z6=zoo(data6[,2],dates1)
z7=zoo(data7[,2],dates1)
z8=zoo(data8[,2],dates1)
z9=zoo(data9[,2],dates1)
z10=zoo(data10[,2],dates1)
z11=zoo(data11[,2],dates1)
z12=zoo(data12[,2],dates1)
z13=zoo(data13[,2],dates1)
z14=zoo(data14[,2],dates1)
z15=zoo(data15[,2],dates1)
z16=zoo(data16[,2],dates1)
z17=zoo(data17[,2],dates1)

zoo.m1 <- merge(z1, z2, all=FALSE)
zoo.m2 <- merge(zoo.m1, z3, all=FALSE)
zoo.m3 <- merge(zoo.m2, z4, all=FALSE)
zoo.m4 <- merge(zoo.m3, z5, all=FALSE)
zoo.m5 <- merge(zoo.m4, z6, all=FALSE)
zoo.m6 <- merge(zoo.m5, z7, all=FALSE)
zoo.m7 <- merge(zoo.m6, z8, all=FALSE)
zoo.m8 <- merge(zoo.m7, z9, all=FALSE)
zoo.m9 <- merge(zoo.m8, z10, all=FALSE)
zoo.m10 <- merge(zoo.m9, z11, all=FALSE)
zoo.m11 <- merge(zoo.m10, z12, all=FALSE)
zoo.m12 <- merge(zoo.m11, z13, all=FALSE)
zoo.m13 <- merge(zoo.m12, z14, all=FALSE)
zoo.m14 <- merge(zoo.m13, z15, all=FALSE)
zoo.m15 <- merge(zoo.m14, z16, all=FALSE)
zoo.m16 <- merge(zoo.m15, z17, all=FALSE)
t <- as.data.frame(zoo.m16)
t.mat=as.matrix(t)
t.mean=apply(t.mat,1,mean)

write.csv(t.mean,"sectormean.csv")


p = read.csv("7201jp.csv", stringsAsFactors=F)
c = read.csv("JPY.csv", stringsAsFactors=F)
m = read.csv("NKY.csv", stringsAsFactors=F)
s = read.csv("sector.csv", stringsAsFactors=F)

p.n=(p[,2]-mean(p[,2]))/sd(p[,2])
c.n=(c[,2]-mean(c[,2]))/sd(c[,2])
m.n=(m[,2]-mean(m[,2]))/sd(m[,2])
s.n=(s[,2]-mean(s[,2]))/sd(s[,2])

p_dates=as.Date(p[,1],"%m/%d/%Y")
c_dates=as.Date(c[,1],"%m/%d/%Y")
m_dates=as.Date(m[,1],"%m/%d/%Y")
s_dates=as.Date(s[,1],"%m/%d/%Y")

p.zoo=zoo(p.n,p_dates)
c.zoo=zoo(c.n,c_dates)
m.zoo=zoo(m.n,m_dates)
s.zoo=zoo(s.n,s_dates)

m1.zoo=merge(p.zoo,c.zoo,all=FALSE)
m2.zoo=merge(m.zoo,s.zoo,all=FALSE)
m3.zoo=merge(m1.zoo,m2.zoo,all=FALSE)

tf=as.data.frame(m3.zoo)


pred.window=30
history=dim(tf)[1]-pred.window
tf.his=tf[1:history,]
tf.now=tf[(history+1):dim(tf)[1],]
colnames(tf.now)=c("now.p","now.c","now.m","now.s")
library(vars)
VARselect(tf.his, lag.max = 8, type = "const")

var1=VAR(tf.his,p=2,type="const")
summary(var1)

################Serial Test#######################################
##testing serial correlation
args(serial.test)
##Portmanteau-Test
var1.serial=serial.test(var1,lags.pt=16,type="PT.asymptotic")
var1.serial
plot(var1.serial,names="p.zoo")
plot(var1.serial,names="c.zoo")
plot(var1.serial,names="m.zoo")
plot(var1.serial,names="s.zoo")
## testing  heteroscedasticity
args(arch.test)
var1.arch<-arch.test(var1,lags.multi=7,multivariate.only=TRUE)
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
var1.causal1=causality(var1,cause="p.zoo")
var1.causal2=causality(var1,cause="c.zoo")

##################Prediction###################
var1.pred=predict(var1,n.ahead=pred.window,ci=0.95)
plot(var1.pred)
plot(var1.pred,names="ndf.zoo")
fanchart(var1.pred,names="index.zoo")


predict.p=as.matrix(var1.pred$fcst$p.zoo[,1])
predict.c=as.matrix(var1.pred$fcst$c.zoo[,1])

var1.fit=as.data.frame(fitted(var1))

his.p=as.matrix(tf.his[1:2,1])
fit.p=rbind(his.p,as.matrix(var1.fit[,1]))
mix.p=rbind(fit.p,predict.p)

his.c=as.matrix(tf.his[,2])
mix.c=rbind(his.c,predict.c)

date=as.Date(row.names(t))

#############Comparion between observed and predicted index
plot(date,mix.p,type="l",col="blue",lwd=2,ylim=range(tf[,1]),main="7201 jp price")
lines(date,tf[,1],col="red",lwd=1)
grid()
legend("topleft",c('"predicted"','"observed"'),col=c("blue","red"),lty=c(1,1))

#############Comparion between observed and predicted ndf
plot(date,mix.c,type="l",col="blue",lwd=2,ylim=range(tf[,2]),main="JPY Curncy")
lines(date,tf[,2],col="red")
grid()
legend("topleft",c('"predicted"','"observed"'),col=c("blue","red"),lty=c(1,1))

##############################autocorrelation#############
mod<-ar(data1[,2],order.max=20)
mod.pred=predict(mod,n.ahead=25)
plot(mod$aic+.0001,type='b',log='y')
mod.sum=summary(mod)
roots<-polyroot(c(rev(-mod$ar),1))
plot(roots,xlim=c(-1.2,1.2),ylim=c(-1.2,1.2))
lines(complex(arg=seq(0,2*pi,len=300)))
resid<-mod$resid[(mod$order+1):length(mod$resid)]
ar.sim<-arima.sim(model=list(ar),n=677)+mod$x.mean 
plot(data1[,2],type="l",col="blue")
lines(ar.sim,col="red")
predict(mod,n.head=25)