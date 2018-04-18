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
n.data1=(data1[,2]-mean(data1[,2]))/sd(data1[,2])

d2=rawdata[,3:4]
ind2=0
for (i in 1:dimr){
    if (is.na(d2[i,2])==TRUE) ind2=ind2+1}
data2=d2[1:(dimr-ind2),]
n.data2=(data2[,2]-mean(data2[,2]))/sd(data2[,2])


d3=rawdata[,5:6]
ind3=0
for (i in 1:dimr){
    if (is.na(d3[i,2])==TRUE) ind3=ind3+1}
data3=d3[1:(dimr-ind3),]
n.data3=(data3[,2]-mean(data3[,2]))/sd(data3[,2])

d4=rawdata[,7:8]
ind4=0
for (i in 1:dimr){
    if (is.na(d4[i,2])==TRUE) ind4=ind4+1}
data4=d4[1:(dimr-ind4),]
n.data4=(data4[,2]-mean(data4[,2]))/sd(data4[,2])

d5=rawdata[,9:10]
ind5=0
for (i in 1:dimr){
    if (is.na(d5[i,2])==TRUE) ind5=ind5+1}
data5=d5[1:(dimr-ind5),]
n.data5=(data5[,2]-mean(data5[,2]))/sd(data5[,2])

d6=rawdata[,11:12]
ind6=0
for (i in 1:dimr){
    if (is.na(d6[i,2])==TRUE) ind6=ind6+1}
data6=d6[1:(dimr-ind6),]
n.data6=(data6[,2]-mean(data6[,2]))/sd(data6[,2])

d7=rawdata[,13:14]
ind7=0
for (i in 1:dimr){
    if (is.na(d7[i,2])==TRUE) ind7=ind7+1}
data7=d7[1:(dimr-ind7),]
n.data7=(data7[,2]-mean(data7[,2]))/sd(data7[,2])


d8=rawdata[,15:16]
ind8=0
for (i in 1:dimr){
    if (is.na(d8[i,2])==TRUE) ind8=ind8+1}
data8=d8[1:(dimr-ind8),]
n.data8=(data8[,2]-mean(data8[,2]))/sd(data8[,2])

d9=rawdata[,17:18]
ind9=0
for (i in 1:dimr){
    if (is.na(d9[i,2])==TRUE) ind9=ind9+1}
data9=d9[1:(dimr-ind9),]
n.data9=(data9[,2]-mean(data9[,2]))/sd(data9[,2])

d10=rawdata[,19:20]
ind10=0
for (i in 1:dimr){
    if (is.na(d10[i,2])==TRUE) ind10=ind10+1}
data10=d10[1:(dimr-ind10),]
n.data10=(data10[,2]-mean(data10[,2]))/sd(data10[,2])

d11=rawdata[,21:22]
ind11=0
for (i in 1:dimr){
    if (is.na(d11[i,2])==TRUE) ind11=ind11+1}
data11=d11[1:(dimr-ind11),]
n.data11=(data11[,2]-mean(data11[,2]))/sd(data11[,2])

d12=rawdata[,23:24]
ind12=0
for (i in 1:dimr){
    if (is.na(d12[i,2])==TRUE) ind12=ind12+1}
data12=d12[1:(dimr-ind12),]
n.data12=(data12[,2]-mean(data12[,2]))/sd(data12[,2])

d13=rawdata[,25:26]
ind13=0
for (i in 1:dimr){
    if (is.na(d13[i,2])==TRUE) ind13=ind13+1}
data13=d13[1:(dimr-ind13),]
n.data13=(data13[,2]-mean(data13[,2]))/sd(data13[,2])

d14=rawdata[,27:28]
ind14=0
for (i in 1:dimr){
    if (is.na(d14[i,2])==TRUE) ind14=ind14+1}
data14=d14[1:(dimr-ind14),]
n.data14=(data14[,2]-mean(data14[,2]))/sd(data14[,2])

d15=rawdata[,29:30]
ind15=0
for (i in 1:dimr){
    if (is.na(d15[i,2])==TRUE) ind15=ind15+1}
data15=d15[1:(dimr-ind15),]
n.data15=(data15[,2]-mean(data15[,2]))/sd(data15[,2])

d16=rawdata[,31:32]
ind16=0
for (i in 1:dimr){
    if (is.na(d16[i,2])==TRUE) ind16=ind16+1}
data16=d16[1:(dimr-ind16),]
n.data16=(data16[,2]-mean(data16[,2]))/sd(data16[,2])

d17=rawdata[,33:34]
ind17=0
for (i in 1:dimr){
    if (is.na(d17[i,2])==TRUE) ind17=ind17+1}
data17=d17[1:(dimr-ind17),]
n.data17=(data17[,2]-mean(data17[,2]))/sd(data17[,2])


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

msnad.8725=zoo(n.data1,dates1)
kobsteel.5406=zoo(n.data2,dates2)
asahiglass.5201=zoo(n.data3,dates1)
sony.6758=zoo(n.data4,dates1)
panasonic.6752=zoo(n.data5,dates1)
fujielectric.6504=zoo(n.data6,dates1)
sumitomoheavy.6302=zoo(n.data7,dates1)
toshiba.6502=zoo(n.data8,dates1)
kawasaki.9107=zoo(n.data9,dates1)
rohm.6963=zoo(n.data10,dates1)
murata.6981=zoo(n.data11,dates1)
nintendo.7974=zoo(n.data12,dates1)
brother.6448=zoo(n.data13,dates1)
sevenni.3382=zoo(n.data14,dates1)
mitsubishi.8058=zoo(n.data15,dates1)
sharp.6753=zoo(n.data16,dates1)
canon.7751=zoo(n.data17,dates1)

zoo.m1 <- merge(msnad.8725, kobsteel.5406, all=FALSE)
zoo.m2 <- merge(zoo.m1, asahiglass.5201, all=FALSE)
zoo.m3 <- merge(zoo.m2, sony.6758, all=FALSE)
zoo.m4 <- merge(zoo.m3, panasonic.6752, all=FALSE)
zoo.m5 <- merge(zoo.m4, fujielectric.6504, all=FALSE)
zoo.m6 <- merge(zoo.m5, sumitomoheavy.6302, all=FALSE)
zoo.m7 <- merge(zoo.m6, toshiba.6502, all=FALSE)
zoo.m8 <- merge(zoo.m7, kawasaki.9107, all=FALSE)
zoo.m9 <- merge(zoo.m8, rohm.6963, all=FALSE)
zoo.m10 <- merge(zoo.m9, murata.6981, all=FALSE)
zoo.m11 <- merge(zoo.m10, nintendo.7974, all=FALSE)
zoo.m12 <- merge(zoo.m11, brother.6448, all=FALSE)
zoo.m13 <- merge(zoo.m12, sevenni.3382, all=FALSE)
zoo.m14 <- merge(zoo.m13, mitsubishi.8058, all=FALSE)
zoo.m15 <- merge(zoo.m14, sharp.6753, all=FALSE)
zoo.m16 <- merge(zoo.m15, canon.7751, all=FALSE)
t <- as.data.frame(zoo.m16)
t.mat=as.matrix(t)
#t.mean=apply(t.mat,1,mean)

#write.csv(t.mean,"sectormean.csv")



c = read.csv("JPY.csv", stringsAsFactors=F)
m = read.csv("TPX.csv", stringsAsFactors=F)
#s = read.csv("sector.csv", stringsAsFactors=F)

c.n=(c[,2]-mean(c[,2]))/sd(c[,2])
m.n=(m[,2]-mean(m[,2]))/sd(m[,2])
#s.n=(s[,2]-mean(s[,2]))/sd(s[,2])

c_dates=as.Date(c[,1],"%m/%d/%Y")
m_dates=as.Date(m[,1],"%m/%d/%Y")
#s_dates=as.Date(s[,1],"%m/%d/%Y")

c.zoo=zoo(c.n,c_dates)
m.zoo=zoo(m.n,m_dates)
#s.zoo=zoo(s.n,s_dates)

factor.zoo=merge(c.zoo,m.zoo,all=FALSE)
#m2.zoo=merge(m.zoo,s.zoo,all=FALSE)
#m3.zoo=merge(m1.zoo,m2.zoo,all=FALSE)
m3.zoo=merge(zoo.m16,factor.zoo,all=FALSE)

totdim=dim(m3.zoo)
tot.t=as.data.frame(m3.zoo)

library(vars)
VARselect(tot.t[,18:19], lag.max = 8, type = "const")

var1=VAR(tot.t[,18:19],p=4,type="const")
summary(var1)
factor.surprise=as.matrix(residuals(var1))
n.obs=dim(tot.t)[1]-4

X.mat=cbind(rep(1,n.obs),factor.surprise)
returns=as.matrix(tot.t[5:(n.obs+4),1:17])
G.hat=qr.solve(X.mat,returns)
beta.hat=t(G.hat[2:3,])
E.hat=returns-X.mat%*%G.hat
diagD.hat=diag(crossprod(E.hat)/(n.obs-3))
#r.sq=1-diag(var(E.hat))/diag(var(returns))
write.csv(beta.hat,"japanbeta.csv")
par=(mfrow=c(3,1))
barplot(beta.hat[,1],names=names(beta.hat),horiz=T,main="Beta values for JPY Surprise")
barplot(beta.hat[,2],names=names(beta.hat),horiz=T,main="Beta values for TPX Surprise")
barplot(r.sq,names=names(r.sq),horiz=T,main="R-square values")

plot(factor.surprise[,1],type="l")




