a1=read.csv("2311_TT.csv")
a2=read.csv("2353_TT.csv")
a3
a4
a5
a6
a7
a8
a9
a10
a11


a1=a1[5:265,5]
a1=(a1-mean(a1))/sd(a1)

a2=a2[5:265,5]
a2=(a2-mean(a2))/sd(a2)

library(quantmod)
op <- par(mfrow=c(2,1))
plot(a1, type="l",col="red",ylim=c(-2,3))
p_a1=findPeaks(a1,0.09)-1
points(p_a1, a1[p_a1])
p_a1

plot(a2,type="l",col="blue",ylim=c(-2,3))
p_a2=findPeaks(a2,0.03)-1
points(p_a2, a2[p_a2])
p_a2

#par(op)
#dev.off()

lag1=p_a1-p_a2
sd1=sd(lag1)
sd1

