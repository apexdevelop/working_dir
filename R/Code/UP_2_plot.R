################8.1###############################
plot(Days, pik[,1], col="blue", type="l", ylim=range(pik), 
     main = '"A" and "B"', ylab="")
lines(Days, pik[,2], col="red")
grid()
legend("topright",c('"A"','"B"'),col=c("blue","red"),lty=c(1,1))
################8.2################################
"plot(alphas, crps, col="blue", type="l", ylab="", 
     main='20 Year Return vs. mix of "A" and "B"',
     xlab='Fraction of "A" in Portfolio')
points(alphas, crps, pch=19, cex=0.5, col="red")
abline(h=mean(crps), col="green")
text(0.5, mean(crps)*1.05, labels="Return from Universal Portfolio")
grid()"
###############################8.3####################