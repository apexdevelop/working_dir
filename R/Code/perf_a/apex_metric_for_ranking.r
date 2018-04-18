
library(zoo)            # Load the zoo package
library(xts)             # Load the xts package
library(PerformanceAnalytics)
# Read the CSV files
ytd.mon=12
ann.rf=0.005
pathname="C:/Users/YChen/Documents/git/working_dir/R/Data/"
infile.1="apex_list.csv" #no heading
outfile.1="apex_metric.csv"

file.dir.in.1=paste(pathname,infile.1,sep="")
file.dir.out.1=paste(pathname,outfile.1,sep="")

apex.ret.raw=read.csv(file.dir.in.1,header = FALSE)
apex.name="APEXGCE.US.Equity"
apex.date=as.Date(apex.ret.raw[,1], format = "%m/%d/%Y")
df.ret.apex=as.data.frame(apex.ret.raw[,2]) #apex inception ret
colnames(df.ret.apex)=apex.name
nrows.apex=dim(df.ret.apex)[1]

########get fund data
benchmark=c("HFRIFWI Index","MXWO Index")
library(Rbbg)
conn=blpConnect()
fields=c("CHG_PCT_1D")

start_date="2012-09-01"
end_date=Sys.Date()
start.date = as.POSIXct(start_date)
end.date = as.POSIXct(end_date)

bench.h=bdh(conn,benchmark,fields,start.date,end.date,option_names = "periodicitySelection", option_values = "MONTHLY",always.display.tickers = TRUE)
list.b.ret=unstack(bench.h,CHG_PCT_1D~ticker)
list.b.date=unstack(bench.h,date~ticker)
df.b.ret=as.data.frame(list.b.ret/100)
df.b.date=as.data.frame(list.b.date[1])
mtx.b.date=as.matrix(df.b.date)
date.b.date=as.Date(mtx.b.date)
nrows.b=dim(df.b.ret)[1]


###2017 YTD
year.date.apex=format(apex.date,"%Y")
idx.2017.apex=which(year.date.apex=="2017")
ret.2017.apex=df.ret.apex[idx.2017.apex,]
nrows.2017.apex=length(ret.2017.apex)

last.mon.ret.apex=as.numeric(df.ret.apex[nrows.apex,])
ytd.ret.apex=prod(ret.2017.apex+1)-1

nmon=12 #nmon in a year
v.colnames=c("1yr","3yr","5yr")
v.nyr=c(1,3,5)
metric.all=NULL

for (i in 1:3) {
  n.periods=v.nyr[i]*nmon
  trailing.rows=(nrows.apex-n.periods+1):nrows.apex
  ret=df.ret.apex[trailing.rows,]

  totalret=prod(ret+1)-1
  ann.ret=(totalret+1)^(12/n.periods)-1

  ann.std=sd(ret)*sqrt(12)
  downrisk=sd(ret[(ret<0)])*sqrt(12)
  v.cumret=matrix(1,nrow=n.periods+1,ncol=1)
  v.maxdd=matrix(0,nrow=n.periods,ncol=1)
  for (j in 2:(n.periods+1)){
    v.cumret[j]=v.cumret[j-1]*(ret[j-1]+1)
    v.maxdd[j-1]=v.cumret[j]/max(v.cumret[1:j])-1
  }
  drawdown=min(v.maxdd)

  sharpe=(ann.ret-ann.rf)/ann.std

  ##sortino
  if (is.na(downrisk)){
    sortino=NA
  } else{
    if (downrisk==0) {
      sortino=NA
    } else {
      sortino=(ann.ret-ann.rf)/downrisk
    }
  }


  #inforatio
  ret.bhf=df.b.ret[trailing.rows,1]
  excess.bhf=ret-ret.bhf
  totalret.excess=prod(excess.bhf+1)-1
  ann.excessret=(totalret.excess+1)^(12/n.periods)-1
  ann.excessstd=sd(excess.bhf)*sqrt(12)
  inforatio=ann.excessret/ann.excessstd

  ####calculate beta and alpha
  ret.bidx=df.b.ret[trailing.rows,2]
  fit=lm(ret~ret.bidx)
  alpha=coef(fit)[1]
  beta=abs(coef(fit)[2])
  ####calculate correlation
  corr.bhf=abs(cor(ret,ret.bhf))
  corr.bidx=abs(cor(ret,ret.bidx))

  gain=sum(ret[ret>=0])
  loss=sum(ret[ret<0])
  omega=gain/(gain+abs(loss))
  wl=length(which(ret>0))/n.periods

  skewness=skewness(ret)
  kurtosis=kurtosis(ret)

  metric=rbind(last.mon.ret.apex,ytd.ret.apex,ann.ret,ann.std,
               downrisk,drawdown,sharpe,sortino,inforatio,
               alpha,beta,corr.bhf,corr.bidx,omega,wl,
               skewness,kurtosis)
  colnames(metric)=v.colnames[i]
  metric.all=cbind(metric.all,metric)
}

write.csv(metric.all, file.dir.out.1)



