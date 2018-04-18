############figure 1 #############
require(logopt)
M=3680
pik_A=rep(0,M)
A<- read.csv("C:/Users/yanyan/Documents/Stock_A.csv")
for(i in 1:M ){
pik_A[i]=A[3681-i,7]
}
pik_B=rep(0,M)
B<- read.csv("C:/Users/yanyan/Documents/Stock_B.csv")
for(i in 1:M ){
pik_B[i]=B[3681-i,7]
}

pik<- cbind(pik_A,pik_B)
nDays <- dim(pik)[1]
nStocks <- dim(pik)[2]
Days <- 1:nDays

xik=w2x(pik)
first=rep(1,2)
xik=xik[-1,]
xik=rbind(t(first),xik)
###############write.csv(xik, file="C:/Users/yanyan/Documents/xik.csv")####
prices.ik_A=cumprod(xik[,1])
prices.ik_B=cumprod(xik[,2])
prices.ik=cbind(prices.ik_A,prices.ik_B)

plot(Days, prices.ik[,1], col="blue", type="l", ylim=range(prices.ik), 
     main = '"SPY" and "DIA" increased price factor', ylab="")
lines(Days, prices.ik[,2], col="red")
grid()
legend("topright",c('"SPY"','"DIA"'),col=c("blue","red"),lty=c(1,1))

prices.ik[M,]

#####################figure 2 #####################
alphas<- seq(0,1,by=0.01)
crps<- alphas
for (i in 1:length(crps)){
    crps[i]<- crp(xik,c(alphas[i],1-alphas[i]))[nDays]
}

plot(alphas, crps, col="blue", type="l", ylab="", 
     main='15 Year Return vs. mix of "SPY" and "DIA"',
     xlab='Fraction of "SPY" in Portfolio')
points(alphas, crps, pch=19, cex=0.5, col="red")
abline(h=mean(crps), col="green")
text(0.5, mean(crps)*1.05, labels="Return from Universal Portfolio")
grid()

##############################fig 3 ###################################
universal <- xik[,1] * 0
for (i in 1:length(crps)) {
  universal <- universal + crp(xik, c(alphas[i], 1-alphas[i]))
}

universal <- universal / length(alphas)

plot(Days, prices.ik[,1], col="blue", type="l", ylim=range(prices.ik, universal), 
     main = 'Universal Portfolios with "SPY" and "DIA"', ylab="")
lines(Days, prices.ik[,2], col="red")
lines(Days, universal, col="green")
legend("topleft",c('"SPY"','"DIA"','"universal"'),
       col=c("blue","red","green"),lty=c(1,1,1))
grid()

#############################best weights##################3
b.opt <- bcrp.optim(xik)
crp.opt <- crp(xik, b.opt)
print(sprintf("Best weights (%.3f,%.3f), terminal wealth %.3f",
b.opt[1], b.opt[2], crp.opt[nDays]))

crp.universal <- universal.cover(xik, 20)
print(sprintf("Terminal wealth of universal portfolio is %.4f",
crp.universal[nDays]))

log(crp.opt[nDays]/crp.universal[nDays])/nDays


