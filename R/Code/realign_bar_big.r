library(zoo)            # Load the zoo package
library(xts)             # Load the xts package
# Read the CSV files into data frames
setwd("./Data")
mydata = read.csv("dispersion_bar_big.csv", stringsAsFactors=F)
n_cols=dim(mydata)[2]
n_sec=n_cols/2
date1=strptime(mydata[!is.na(mydata[,2]),1],"%m/%d/%Y %H:%M")
data1=xts(na.omit(mydata[,2]),date1)
temp.xts=data1
for(i in 2:n_sec)
{
  date2=strptime(mydata[!is.na(mydata[,2*i]),2*i-1],"%m/%d/%Y %H:%M")
  data2=xts(na.omit(mydata[,2*i]),date2)
  temp.xts=merge(temp.xts,data2,all=FALSE)
}
all.xts=temp.xts
all.df=as.data.frame(all.xts)
write.csv(as.data.frame(all.xts), "bar_result_big.csv")
n_ob=dim(all.df)[1]
mat_indx=as.matrix(all.df[2:n_ob,1])
mat_comp=as.matrix(all.df[,2:n_sec])

test_date=row.names(all.df)
date=as.Date(test_date)
udate=unique(date)
len_udate=length(udate)
mat_uidx=matrix(0,nrow=len_udate,ncol=1)

for (i in 1:len_udate)
{
  mat_uidx[i]=which(date==udate[i])[1]
}

#except for first day, the following days should calculate return based on previous day's close
#from substruct 1 from 2nd element of mat_uidx
adj_mat_uidx=mat_uidx
adj_mat_uidx[2:len_udate]=mat_uidx[2:len_udate]-1

rep_mat_uidx=matrix(0,nrow=n_ob,ncol=1)

rep_mat_uidx[1:adj_mat_uidx[2]]=adj_mat_uidx[1]

for (i in 2:(len_udate-1)) {
  rep_mat_uidx[(adj_mat_uidx[i]+1):adj_mat_uidx[i+1]]=rep(adj_mat_uidx[i],adj_mat_uidx[i+1]-adj_mat_uidx[i])
}

rep_mat_uidx[(adj_mat_uidx[len_udate]+1):n_ob]=adj_mat_uidx[len_udate]


fun_ret <- function(x) {
  n=dim(x)[1]
  mat_base=as.matrix(x[rep_mat_uidx[2:n]])
  x[2:n]/mat_base-1
}
mat_comp_ret=apply(mat_comp,2,fun_ret)
mat_disp=as.matrix(apply(mat_comp_ret,1,sd))
#which(mat_disp==0)
plot(mat_disp,mat_indx)
plot(mat_indx,mat_disp)

mydata2 = read.csv("dispersion_bar_siyuan.csv", stringsAsFactors=F)
mat_indx2=as.matrix(mydata2[,2])
mat_disp2=as.matrix(mydata2[,3])/100

fun_ret2 <- function(x) {
  n=dim(x)[1]
  x[2:n]/x[1:n-1]-1
}
mat_indx2_ret=fun_ret2(mat_indx2)
n_disp2=dim(mat_disp2)[1]
plot(mat_disp2[2:n_disp2],mat_indx2_ret)