setwd("C:/Documents and Settings/YChen/My Documents/Yan/R")
# set output options
options(width = 70, digits=4)

# load required packages
library(ellipse)
library(fEcofin)                # various data sets
library(PerformanceAnalytics)   # performance and risk analysis functions
library(zoo)

# load Berndt Data
data(berndtInvest)
#str(berndtInvest)

# create data frame with dates as rownames
berndt.df = berndtInvest[, -1]
rownames(berndt.df) = as.character(berndtInvest[, 1])

d1=diff(as.matrix(berndt.df[,1, drop=F]))
m1=as.matrix(berndt.df[,1, drop=F])-as.matrix(berndt.df[,2, drop=F])
len_m1=length(m1)

#choose the exogenous variable
e1=diff(as.matrix(berndt.df[,10,drop=F]))

berndt.ts=cbind(d1,m1[2:len_m1,])
colnames(berndt.ts) = c("d-citcrp","citcrp-coned")

d1.df=data.frame(d1)
date=as.Date(row.names(d1.df))

m1.df=data.frame(m1[2:len_m1,])


par(mfrow=c(2,1))
plot(date,t(d1.df[1]),type="l",ylab="",main="1st difference of citcrp",col="blue")
plot(date,t(m1.df),type="l",main="difference between citcrp and coned",col="blue")
library(vars)
var1=VAR(berndt.ts,p=2,type="none",exogen=e1)
summary(var1)


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