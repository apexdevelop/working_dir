#https://faculty.washington.edu/ezivot/econ589/econ589riskMeasures.r
# econ589riskMeasures.r
#
# R examples for lectures on estimating risk measures
#
# Eric Zivot
# April 2nd, 2012
# update history
# April 23rd, 2013
#   Fixed reversal of axis labels in scatterplot
# April 17th, 2012
#   Added risk analysis from multivariate distribution examples
# April 16th, 2012
#   Added multivariate distribution examples

# load libraries
library(PerformanceAnalytics)
library(quantmod)
library(MASS)
library(mvtnorm)
library(mnormt) 

options(digits=4)
#
# Example: Normal VaR
#

mu = 10
sigma = 100
alpha = 0.95
VaR.alpha = qnorm(alpha, mu, sigma)
VaR.alpha

# alternative approach
VaR.alpha = mu + sigma*qnorm(alpha,0,1)
VaR.alpha

#
# Example: normal ES
#

mu = 10
sigma = 100
alpha = 0.95
q.alpha.z = qnorm(alpha)
ES.alpha = mu + sigma*(dnorm(q.alpha.z)/(1-alpha))
ES.alpha

#
# Estimating risk measures
#

# download data
symbol.vec = c("MSFT", "^GSPC")
getSymbols(symbol.vec, from ="2000-01-03", to = "2012-04-03")
colnames(MSFT)
start(MSFT)
end(MSFT)

# extract adjusted closing prices
MSFT = MSFT[, "MSFT.Adjusted", drop=F]
GSPC = GSPC[, "GSPC.Adjusted", drop=F]

# plot prices
plot(MSFT)
plot(GSPC)

# calculate returns
MSFT.ret = CalculateReturns(MSFT, method="simple")
GSPC.ret = CalculateReturns(GSPC, method="simple")


# remove first NA observation
MSFT.ret = MSFT.ret[-1,]
GSPC.ret = GSPC.ret[-1,]

# create combined data series
MSFT.GSPC.ret = cbind(MSFT.ret,GSPC.ret)

# plot returns
plot(MSFT.ret)
plot(GSPC.ret)

#
# calculate nonparametric risk measures
#

# standard deviation
apply(MSFT.GSPC.ret, 2, sd)

# empirical 5% and 1% quantiles (historical VaR)
apply(MSFT.GSPC.ret, 2, quantile, probs=c(0.05, 0.01))

# historical 5% and 1% ES
ES.fun = function(x, alpha=0.05) {
  qhat = quantile(x, probs=alpha)
  mean(x[x <= qhat])
}
apply(MSFT.GSPC.ret, 2, ES.fun, alpha=0.05)
apply(MSFT.GSPC.ret, 2, ES.fun, alpha=0.01)

# plot 5% VaR and ES for MSFT
VaR.MSFT.05 = quantile(MSFT.ret, probs=0.05)
ES.MSFT.05 = mean(MSFT.ret[MSFT.ret <= VaR.MSFT.05])
plot(MSFT.ret)
abline(h=VaR.MSFT.05, col="blue", lwd=2)
abline(h=ES.MSFT.05, col="green", lwd=2)
legend(x="topright", legend=c("5% VaR", "5% ES"), lwd=2, col=c("blue", "green"))

# use PerformanceAnalytics functions
args(VaR)
VaR(MSFT.GSPC.ret, p=0.95, method="historical")
ES(MSFT.GSPC.ret, p=0.95, method="historical")

#
# normal VaR and ES
#
mu.hat = apply(MSFT.GSPC.ret, 2, mean)
sigma.hat = apply(MSFT.GSPC.ret, 2, sd)
q.05.norm = mu.hat + sigma.hat*qnorm(0.05)
q.01.norm = mu.hat + sigma.hat*qnorm(0.01)
es.05.norm = -(mu.hat + sigma.hat*dnorm(qnorm(0.05))/0.05)
es.01.norm = -(mu.hat + sigma.hat*dnorm(qnorm(0.01))/0.01)


mu.hat
sigma.hat
q.05.norm
q.01.norm
es.05.norm
es.01.norm

#
# VaR and ES from Student's t distribution

normal.es.fun = function(x, alpha=0.95){
  
}
es.05 = apply

# use PerformanceAnalytics functions
VaR(MSFT.GSPC.ret, p=0.95, method="gaussian")
ES(MSFT.GSPC.ret, p=0.95, method="gaussian")

# plot SE(VaR.alpha)

alpha.vals = seq(from=0.001, to=0.10, length.out=25)
sigma = 0.1
nobs = 100
se.q = (sigma/sqrt(nobs))*sqrt(1 + 0.5*qnorm(alpha.vals)^2)
plot(alpha.vals, se.q, type="b", pch=16, col="blue",
     main="Standard Error of Normal Quantile", ylab="SE", xlab="1 - alpha")

#
# VaR and ES based on student's t distribution
#

# use fitdistr() from MASS package
?fitdistr

# Fit Student's t distribution by MLE
# assume MSFT.ret is student's t with parameters mu, sigma and v
# note: E[MSFT.ret] = mu, var(MSFT.ret) = sigma^2 * (v/(v-2)) 
# scale returns by 100 to improve numerical stability of MLE
MSFT.t.mle = fitdistr(MSFT.ret*100, densfun="t")
MSFT.t.mle
theta.hat = coef(MSFT.t.mle)
# rescale estimates
mu.MSFT.t = theta.hat["m"]/100
sigma.MSFT.t = theta.hat["s"]/100
v.MSFT.t = theta.hat["df"]

# Standard t quantiles
q.t.05 = qt(0.05, df=v.MSFT.t)
q.t.01 = qt(0.01, df=v.MSFT.t)
# Estimated t Quantiles for MSFT
q.MSFT.t.05 = mu.MSFT.t + sigma.MSFT.t*q.t.05
q.MSFT.t.01 = mu.MSFT.t + sigma.MSFT.t*q.t.01
q.MSFT.t.05
q.MSFT.t.01


t.adj.05 = (dt(q.t.05, df=v.MSFT.t)/0.05)*((v.MSFT.t + q.t.05^2)/(v.MSFT.t - 1))
t.adj.01 = (dt(q.t.01, df=v.MSFT.t)/0.01)*((v.MSFT.t + q.t.01^2)/(v.MSFT.t - 1))
es.MSFT.t.05 = -(mu.MSFT.t + sigma.MSFT.t*t.adj.05)
es.MSFT.t.01 = -(mu.MSFT.t + sigma.MSFT.t*t.adj.01)
es.MSFT.t.05
es.MSFT.t.01

# simulate data from fitted Student's t distribution
# t.v ~ standardized Student t with v df. E[t.v] = 0, var(t.v) = v/(v-2)
set.seed(123)
t.sim = mu.MSFT.t + sigma.MSFT.t*rt(n=10000, df=v.MSFT.t)
q.t.sim = quantile(t.sim, probs=c(0.05, 0.01))
es.t.05 = mean(t.sim[t.sim <= q.t.sim[1]])
es.t.01 = mean(t.sim[t.sim <= q.t.sim[2]])

q.t.sim
es.t.05
es.t.01


#
# Cornish-Fisher or Modified VaR and ES
#
# use PerformanceAnalytics functions

# Modified VaR
modifiedVaR.05 = VaR(MSFT.GSPC.ret, p=0.95, method="modified")
modifiedVaR.01 = VaR(MSFT.GSPC.ret, p=0.99, method="modified")
# Modified ES
modifiedES.05 = ES(MSFT.GSPC.ret, p=0.95, method="modified")
modifiedES.01 = ES(MSFT.GSPC.ret, p=0.99, method="modified")

# results are strange! VaR = ES!!!!
modifiedVaR.05
modifiedVaR.01
modifiedES.05
modifiedES.01

#
# portfolio risk measures
#

# equally weighted portfolio of MSFT and GSPC
port.ret = 0.5*MSFT.ret + 0.5*GSPC.ret
colnames(port.ret) = "port"
# plot(port.ret)

mean(port.ret)
sd(port.ret)
sd(as.numeric(port.ret))

# computing portfolio vol using covariance matrix
Sigma.hat = cov(MSFT.GSPC.ret)
w = c(0.5, 0.5)
sqrt(t(w)%*%Sigma.hat%*%w)

# estimating contributions to Vol
sigma.p.hat = as.numeric(sqrt(t(w)%*%Sigma.hat%*%w))
mcr.vol = Sigma.hat %*% w / sigma.p.hat
cr.vol = w * mcr.vol
pcr.vol = cr.vol / sigma.p.hat
cbind(mcr.vol, cr.vol, pcr.vol)

# check
sigma.p.hat
sum(cr.vol)
sum(pcr.vol)

# using PerformanceAnalytics function StdDev
StdDev(MSFT.GSPC.ret, portfolio_method="component", 
       weights=c(0.5, 0.5))

#
# nonparametric measures of risk budgets
#

# VaR
VaR(port.ret, p=0.95, method="historical")
VaR(port.ret, p=0.99, method="historical")
# ES
ES(port.ret, p=0.95, method="historical")
ES(port.ret, p=0.99, method="historical")

#
# Bivariate distributions for MSFT and GPSC
#

# Empirical scatterplots
plot(coredata(MSFT.ret), coredata(GSPC.ret), 
     main="Empirical Bivariate Distribution of Returns",
     ylab="GSPC", xlab="MSFT", col="blue")
abline(h=mean(GSPC.ret), v=mean(MSFT.ret))

# empirical portfolio return distribution
chart.Histogram(port.ret, main="Equally Weighted Portfolio", methods=c("add.normal", "add.qqplot"))

# simulate from fitted multivariate normal distribution
# method 1: use mvtnorm package
library(mvtnorm)
n.obs = nrow(MSFT.GSPC.ret)

# estimate mean and covariance
mu.hat = apply(MSFT.GSPC.ret, 2, mean)
Sigma.hat = cov(MSFT.GSPC.ret)
Cor.hat = cov2cor(Sigma.hat)
mu.hat
Sigma.hat
Cor.hat

set.seed(123)
sim.ret = rmvnorm(n.obs, mean=mu.hat, sigma=Sigma.hat, method="chol")

# scaterplot of simulated returns
plot(sim.ret[,1], sim.ret[,2], 
     main="Simulated Bivariate Normal Distribution of Returns",
     ylab="GSPC", xlab="MSFT", col="blue")
abline(v=mean(sim.ret[,1]), h=mean(sim.ret[,2]))


# superimpose both scatterplots
plot(coredata(MSFT.ret), coredata(GSPC.ret), 
     main="Empirical vs. Bivariate Normal",
     ylab="GSPC", xlab="MSFT", col="blue")
abline(h=mean(GSPC.ret), v=mean(MSFT.ret))
points(sim.ret[,1], sim.ret[,2], col="red")
legend(x="topleft", legend=c("Empirical", "Normal"), col=c("blue", "red"), pch=1)

# simulated equally weighted portfolio
port.ret.sim = 0.5*sim.ret[,1] + 0.5*sim.ret[,2]
chart.Histogram(port.ret.sim, main="Equally Weighted Portfolio", 
                methods=c("add.normal", "add.qqplot"))


# portfolio risk measures from normal distribution
# volatility
StdDev(port.ret)
# VaR
VaR(port.ret, p = 0.95, method="gaussian")
VaR(port.ret, p = 0.99, method="gaussian")
# ES
ES(port.ret, p = 0.95, method="gaussian")
ES(port.ret, p = 0.99, method="gaussian")


# fitting bivariate student's t to data - see SDAFE ch 5
library(MASS) # needed for cov.trob
library(mnormt) # needed for dmt
df = seq(2.1,5,.01) # 551 points
n = length(df)
loglik_max = rep(0,n)
for(i in 1:n)
{
  fit = cov.trob(coredata(MSFT.GSPC.ret),nu=df[i])
  loglik_max[i] = sum(log(dmt(coredata(MSFT.GSPC.ret),mean=fit$center,
                              S=fit$cov,df=df[i])))
}

max.lik = max(loglik_max)
v.mle = df[which(loglik_max == max.lik)]
plot(df, loglik_max, type="l", main="Profile Likelihood for Bivariate t", lwd=2, col="blue")
abline(v=v.mle, lwd=2, col="red")

# extract mle of mu and sigma given v.mle
fit.mle = cov.trob(coredata(MSFT.GSPC.ret),nu=v.mle)
mu.mle.t = fit.mle$center
Sigma.mle.t = fit.mle$cov
mu.mle.t
# show covariance matrix
Sigma.mle.t*(v.mle/(v.mle - 2))
Cor.mle.t = cov2cor(Sigma.mle.t*(v.mle/(v.mle - 2)))
Cor.mle.t

# simulate portfolio returns
# use result that Y = mu + sqrt(v/W)*Z is multivariate t

# generate Z ~ N(0, Sigma.mle.t)
set.seed(123)
Z = rmvnorm(n=n.obs, mean=c(0,0), sigma=Sigma.mle.t(v.mle/(v.mle - 2)))
# generate W ~ chi-sq(v.mle)
W = rchisq(n.obs,df=v.mle)
# simulate bivariate t
sim.ret.t = mu.mle.t + sqrt(v.mle/W)*Z
colnames(sim.ret.t) = c("MSFT","GSPC")

# plot simulated data together with actual returns

plot(coredata(MSFT.ret),coredata(GSPC.ret),  
     main="Empirical vs. Bivariate t",
     ylab="GSPC", xlab="MSFT", col="blue")
abline(h=mean(GSPC.ret), v=mean(MSFT.ret))
points(sim.ret.t, col="red")
legend(x="topleft", legend=c("Empirical", "Multivariate t"), col=c("blue", "red"), pch=1)

# compute simulated returns
port.ret.sim.t = 0.5*sim.ret.t[,"MSFT"] + 0.5*sim.ret.t[,"GSPC"]
chart.Histogram(port.ret.sim.t, main="Equally Weighted Portfolio: Student's t", 
                methods=c("add.normal", "add.qqplot"))

# calculate VaR and ES from simulated returns
# volatility
StdDev(port.ret.sim.t)
# VaR
VaR(port.ret.sim.t, p = 0.95, method="historical")
VaR(port.ret.sim.t, p = 0.99, method="historical")
# ES
ES(port.ret.sim.t, p = 0.95, method="historical")
ES(port.ret.sim.t, p = 0.99, method="historical")

# ES risk budgets
# note: ES seems to choke if data is passed in as a matrix without rownames
rownames(sim.ret.t) = as.character(index(MSFT.ret))
names(port.ret.sim.t) = rownames(sim.ret.t)
sim.ret.t = zoo(sim.ret.t, as.Date(rownames(sim.ret.t)))
port.ret.sim.t = zoo(port.ret.sim.t, as.Date(names(port.ret.sim.t)))
# rownames(sim.ret.t) = as.character(1:n.obs)
port.ES.decomp = ES(sim.ret.t, p=0.95, weights=c(0.5, 0.5), 
                    portfolio_method="component", method="historical")


VaR.p = quantile(port.ret.sim.t, prob=0.05)
idx = which(port.ret.sim.t <= VaR.p)
mcES = port.ES.decomp[["realizedcontrib"]]*port.ES.decomp[["-r_exceed/c_exceed"]]/0.5

# mcETL plot for MSFT
par(mfrow=c(2,1))
# plot fund data with VaR violations
plot.zoo(port.ret.sim.t, type="b", main="Portfolio Returns and 5% VaR Violations",
         col="blue", ylab="Returns")
abline(h=0)
abline(h=VaR.p, lwd=2, col="red")
points(port.ret.sim.t[idx], type="p", pch=16, col="red")
# plot factor data and highlight obvs associated with R <= VaR
plot.zoo(sim.ret.t[, "MSFT"], type="b", main="Mean of MSFT when PORT <= 5% VaR",
         col="blue", ylab="Returns")
abline(h=0)
abline(h=-mcES["MSFT"], lwd=2, col="red")
points(sim.ret.t[idx, "MSFT"], type="p", pch=16, col="red")
par(mfrow=c(1,1))