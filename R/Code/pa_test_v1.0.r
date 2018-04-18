library("PerformanceAnalytics")
myret=read.csv("./Data/risk_returns.csv", stringsAsFactors=F)
myret_dates <- as.Date(myret[,1],"%m/%d/%Y")
nRows=dim(myret)[1]
nCols=dim(myret)[2]
myret.zoo=zoo(myret[,2:nCols],myret_dates)
#myret.zoo=read.csv.zoo("./Data/risk_returns.csv", format="%m/%d/%Y")
myret.xts=as.xts(myret.zoo)
myret.xts=myret.xts/100
wgt=read.csv("./Data/risk_weights.csv",colClasses=c("numeric","numeric"))
wgt1=wgt[,1];
wgt2=wgt[,2]*100;
wgt3=wgt[,3];
#table.DownsideRisk(myret.xts[,1:6],Rf=.03/12)
paraVaR=VaR(myret.xts, p=.99, method="gaussian",portfolio_method = c("marginal"),weights=wgt1)
histVaR=VaR(myret.xts, p=.99, method="historical",portfolio_method = "component",weights=wgt1)
ma_contri=as.matrix(paraVaR$contribution)
sum_contri=sum(ma_contri)
ma_pctVaR=as.matrix(paraVaR$pct_contrib_VaR)
sum_VaR=sum(ma_pctVaR)