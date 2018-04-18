## Simu l a t e VAR( 2 )-da t a 1
library(dse)
library(vars)
## S e t t i n g the lag-p o l y n omi a l A(L )
Apoly <- array(c(1.0, -0.5, 0.3, 0, 0.2, 0.1, 0, -0.2, 0.7, 1, 0.5, -0.3),c(3, 2, 2))
#I(k)---Apoly[1,,]
#A(1)---Apoly[2,,]
#A(2)---Apoly[3,,]

## S e t t i n g Co v a r i a n c e to i d e n t i t y -ma t r i x
B<-diag(2)
## S e t t i n g c o n s t a n t term to 5 and 10
TRD<-c(5,10)
## Gen e r a t in g the VAR( 2 ) model
var2 <- ARMA(A = Apoly , B = B, TREND = TRD)

## S imu l a t i n g 500 o b s e r v a t i o n s
#
varsim<-simulate(var2,sampleT=500,noise=list(w=matrix(rnorm(1000),nrow=500,ncol=2)),rng=list(seed=c(123456)))

## Obtaining the generated series
vardat<-matrix(varsim$output,nrow=500,ncol=2)
colnames(vardat)<-c("y1","y2")
## Plotting the series
plot.ts(vardat,main="",xlab="")
## Determining an appropriate lag-order
infocrit<-VARselect(vardat,lag.max=3,type="const")
## Es t ima t i n g the model
varsimest<-VAR(vardat,p=2,type="const",season=NULL,exogen=NULL)
## Al t e r n a t i v e l y , s e l e c t i o n a c c o r d i n g to AIC
varsimest<-VAR(vardat,p=2,type="const",lag.max=3,ic="SC")
## Che ck ing the r o o t s
roots<-roots(varsimest)

var2c.serial <- serial.test(varsimest,lags.pt=16, type ="PT.asymptotic")
var2c.serial
plot(var2c.serial, names = "y1") 
plot(var2c.serial, names = "y2")
var2c.norm=normality.test(varsimest,multivariate.only=TRUE)
args(vars:::plot.varcheck)
plot(var2c.norm)


##Causality tests
##Granger and instantaneous causality
var.causal=causality(varsimest,cause="y2")
