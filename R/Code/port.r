library(zoo)            # Load the zoo package
library(xts)             # Load the xts package
# Read the CSV files
path1="./Data/port_test.csv"
mydata = read.csv(path1,header = FALSE, stringsAsFactors=F)
securities=as.matrix(mydata[,1])
df_w=as.data.frame(mydata[,2],row.names=securities)
n_sec=dim(securities)[1]

library(Rbbg)
conn=blpConnect()
fields=c("CHG_PCT_1D")

window=1715
start.date=as.character(Sys.Date()-window,"%Y%m%d")
end.date=as.character(Sys.Date(),"%Y%m%d")
x_h=bdh(conn,securities,fields,start.date,end.date,always.display.tickers = TRUE)
x_h=na.omit(x_h) 
list_ret=unstack(x_h,CHG_PCT_1D~ticker)
list_date=unstack(x_h,date~ticker)

name_list=as.matrix(names(list_ret))

df_date1=as.data.frame(list_date[1])
mtx_date1=as.matrix(df_date1)
date1=as.Date(mtx_date1)
ret1=as.data.frame(list_ret[1])
data1=xts(ret1,date1)
temp.xts=data1

for(i in 2:n_sec)
{
  df_date2=as.data.frame(list_date[i])
  mtx_date2=as.matrix(df_date2)
  date2=as.Date(mtx_date2)
  ret2=as.data.frame(list_ret[i])
  data2=xts(ret2,date2)
  temp.xts=merge(temp.xts,data2,all=FALSE)
}

df_new_w=as.data.frame(df_w,row.names=name_list)
for (j in 1:n_sec)
{
  idx=which(securities==name_list[j])
  if(length(idx)>0)
  {
    df_new_w[j,1]=df_w[idx,1]
  }
}

mat_w=as.matrix(df_new_w)
mat_ret=as.matrix(temp.xts)
new_date=as.Date(row.names(mat_ret))
port_ret=mat_ret%*%mat_w
port_NAV=port_ret
n_ob=dim(port_ret)[1]
ini_NAV=1000
port_ret2=port_ret/100+1
for (i in 1:n_ob)
{
  port_NAV[i]=prod(port_ret2[1:i])*ini_NAV
}

plot(port_NAV)
write.csv(port_NAV, "portNAV_output.csv")
write.csv(port_ret, "portRET_output.csv")