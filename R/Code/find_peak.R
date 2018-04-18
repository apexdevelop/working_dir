esa=read.csv("ESA.csv")
spx=read.csv("SPX.csv")
esa=esa[1:2000,2]
#esa=(esa-mean(esa))/sd(esa)

esa <- diff(sign(diff(esa, na.pad = FALSE)), na.pad = FALSE)
pks=which(esa<0)+2
thresh=3

if (!missing(thresh)) {
        pks[esa[pks - 1] - esa[pks] > thresh]
    } else pks


spx=spx[1:2000,2]
spx=(spx-mean(spx))/sd(spx)
library(quantmod)
op <- par(mfrow=c(2,1))
plot(esa, type="l",col="red",ylim=c(-2,3))
p_esa=findPeaks(esa,0.4)-1
points(p_esa, esa[p_esa])
p_esa

plot(spx,type="l",col="blue",ylim=c(-2,1.5))
p_spx=findPeaks(spx,0.1)-1
points(p_spx, spx[p_spx])
p_spx

#par(op)
#dev.off()



