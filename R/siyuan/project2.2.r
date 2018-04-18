setwd("Z:/Proj/Trading/Amie Ma")
mydata = read.csv("perf_data.csv", stringsAsFactors=F)
date=as.Date(mydata[,1],"%m/%d/%Y")
# date1=strptime(mydata[!is.na(mydata[,2]),1],"%m/%d/%Y")
rt=mydata[,2]
rt_1=mydata[,3]
Downside=mydata[,4]
HFRIEM=mydata[,5]
HFRIAWJ=mydata[,6]
HFRIEMNI=mydata[,7]
HFRIFWI=mydata[,8]
MXAP=mydata[,9]
count=dim(mydata)[1]
rf=0.005
Mouth_end=rt[count]
#rt[54:count] it starts from No.55, and have 7 numbers
YTD2017=prod(rt[54:count]+1)-1
CumulativeReturn=prod(rt[2:count]+1)-1
AdjustedY=(CumulativeReturn+1)^(12/(count-1))-1
Std=sd(rt[2:count]+1)*sqrt(12)
DownsideStd=sd(Downside[2:count]+1)*sqrt(12)

Cumul=NULL
Cumul=matrix(1,nrow=1,ncol=1)
for (i in 2:count){
  Cumul[i]=Cumul[i-1]*rt_1[i]
}
Max=NULL
Max=matrix(0,nrow=1,ncol=1)
for (j in 2:count){
  Max[j]=Cumul[j]/max(Cumul[1:(j-1)])-1
}
MaxDraw=min(Max)

Sharpe=(AdjustedY-rf)/Std
#install.packages("moments")
library(moments)
Skewness=skewness(rt, na.rm = FALSE)
Kurtosis=kurtosis(rt, na.rm = FALSE)

Corr_HFRIEM=cor(rt,HFRIEM)
Corr_HFRIAWJ=cor(rt,HFRIAWJ)
Corr_HFRIEMNI=cor(rt,HFRIEMNI)
Corr_HFRIFWI=cor(rt,HFRIFWI)
Corr_MXAP=cor(rt,MXAP)

dataframe <- data.frame(AdjustedY,CumulativeReturn,Std,DownsideStd,MaxDraw,Sharpe,Skewness,Kurtosis,Corr_HFRIEM,Corr_HFRIAWJ,Corr_HFRIEMNI,Corr_HFRIFWI,Corr_MXAP)
write.csv(dataframe, "project2.2.csv")
