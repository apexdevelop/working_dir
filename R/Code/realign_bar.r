#library(zoo)            # Load the zoo package
library(xts)
# Read the CSV files into data frames
setwd("./Data")
mydata = read.csv("dispersion_bar.csv", stringsAsFactors=F)
n_cols=dim(mydata)[2]
n_sec=n_cols/2
date1=strptime(mydata[!is.na(mydata[,2]),1],"%m/%d/%Y %H:%M")
data1=xts(na.omit(mydata[,2]),date1)
temp.xts=data1
for(i in 2:n_sec)
{
date2=strptime(mydata[!is.na(mydata[,2*i]),2*i-1],"%m/%d/%Y %H:%M")
#date3=strptime(mydata[!is.na(mydata[,6]),5],"%m/%d/%Y %H:%M")
data2=xts(na.omit(mydata[,2*i]),date2)
#data3=xts(na.omit(mydata[,6]),date3)

temp.xts=merge(temp.xts,data2,all=FALSE)
#all.xts=merge(temp.xts,data1,all=FALSE)
}
all.xts=temp.xts
write.csv(as.data.frame(all.xts), "bar_result.csv")