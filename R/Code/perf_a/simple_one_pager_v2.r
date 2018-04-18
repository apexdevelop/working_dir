#.libPaths("~/OneDrive/Documents/Modeling/R/win-library/3.1")
library(zoo)            # Load the zoo package
library(xts)             # Load the xts package
library(PerformanceAnalytics)
# Read the CSV files
#ytd.mon=10
ann.rf=0.005
pathname="C:/Users/YChen/Documents/git/working_dir/R/Data/"
infile.1="apex_list.csv" #no heading
infile.2="peer_list.csv"
outfile.1="output_apex.csv"
outfile.2="roll12_std.csv"
outfile.3="cum_dollar.csv"

file.dir.in.1=paste(pathname,infile.1,sep="")
file.dir.in.2=paste(pathname,infile.2,sep="")
file.dir.out.1=paste(pathname,outfile.1,sep="")
file.dir.out.2=paste(pathname,outfile.2,sep="")
file.dir.out.3=paste(pathname,outfile.3,sep="")

#apex.ret=Return.read(file.dir.in.1, frequency="m",format.in = "excel")

apex.ret.raw=read.csv(file.dir.in.1,header = FALSE)
apex.name="APEXGCE.US.Equity"
apex.date=as.Date(apex.ret.raw[,1], format = "%m/%d/%Y")
df.apex.ret=as.data.frame(apex.ret.raw[,2])
colnames(df.apex.ret)=apex.name
apex.xts=xts(df.apex.ret,apex.date)

nrows.apex=dim(apex.xts)[1]
incep.rows.apex=1:nrows.apex
ret.incep.apex=apex.xts[incep.rows.apex]

###2017 YTD
year.date.apex=format(apex.date,"%Y")
idx.2017.apex=which(year.date.apex=="2017")
ret.2017.apex=df.apex.ret[idx.2017.apex,]
nrows.2017.apex=length(ret.2017.apex)

last.mon.ret.apex=as.numeric(ret.incep.apex[nrows.apex])
ytd.ret.apex=prod(ret.2017.apex+1)-1

##3 year
trailing36.rows.apex=(nrows.apex-36+1):nrows.apex
ret.3yr.apex=df.apex.ret[trailing36.rows.apex,]

##5 year
trailing60.rows.apex=(nrows.apex-60+1):nrows.apex
ret.5yr.apex=df.apex.ret[trailing60.rows.apex,]


totalret.3yr.apex=prod(ret.3yr.apex+1)-1
ann.ret.3yr.apex=(totalret.3yr.apex+1)^(12/36)-1

totalret.5yr.apex=prod(ret.5yr.apex+1)-1
ann.ret.5yr.apex=(totalret.5yr.apex+1)^(12/60)-1

ann.ret.incep.apex=Return.annualized(ret.incep.apex)
ann.std.incep.apex=StdDev.annualized(ret.incep.apex)
downrisk.incep.apex=sd(ret.incep.apex[(ret.incep.apex<0)])*sqrt(12)
drawdown.incep.apex=maxDrawdown(ret.incep.apex,invert=FALSE)
sharpe.incep.apex=(ann.ret.incep.apex-ann.rf)/ann.std.incep.apex
#sortino.incep.apex=SortinoRatio(ret.incep.apex)
#omega.incep.apex=Omega(ret.incep.apex)
#wl.incep.apex=UpsideFrequency(ret.incep.apex,MAR=0)
#skewness.incep.apex=skewness(ret.incep.apex)
#kurtosis.incep.apex=kurtosis(ret.incep.apex)

ytd.ret.apex=as.numeric(ytd.ret.apex)
ann.ret.incep.apex=as.numeric(ann.ret.incep.apex)
ann.std.incep.apex=as.numeric(ann.std.incep.apex)
sharpe.incep.apex=as.numeric(sharpe.incep.apex)
#sortino.incep.apex=as.numeric(sortino.incep.apex)
#omega.incep.apex=as.numeric(omega.incep.apex)

####calculating rolling 12mon std
roll12.std.apex=matrix(0,nrow=nrows.apex-11,ncol=1)
colnames(roll12.std.apex)=apex.name
for (j in 1:(nrows.apex-11)) {
  roll12.std.apex[j]=sd(df.apex.ret[j:(j+11),])*sqrt(12)
}

###calculating cumulative return vector for every month
mat.cumret.apex=matrix(0,nrow=nrows.apex+1,ncol=1)
colnames(mat.cumret.apex)=apex.name
mat.cumret.apex[1]=1
for (j in 2:(nrows.apex+1)) {
   mat.cumret.apex[j]=prod(df.apex.ret[1:(j-1),]+1)
}

########get fund data
raw_securities = read.csv(file.dir.in.2,header = FALSE, stringsAsFactors=F)
#raw_securities = read.csv(file_dir,header = FALSE)
securities=as.matrix(raw_securities) #bdh will resort securities
#securities=as.matrix(sort(securities))
n_sec=dim(securities)[1]

library(Rbbg)
#conn=blpConnect("blpapi.jar.file","~/OneDrive/Documents/Modeling/R")
conn=blpConnect()
fields=c("CHG_PCT_1D")

start_date="2012-09-01"
#end_date="2017-11-30"
end_date=Sys.Date()
start.date = as.POSIXct(start_date)
end.date = as.POSIXct(end_date)

x_h=bdh(conn,securities,fields,start.date,end.date,option_names = "periodicitySelection", option_values = "MONTHLY",always.display.tickers = TRUE)
list_ret=unstack(x_h,CHG_PCT_1D~ticker)
list_date=unstack(x_h,date~ticker)
name_list=as.matrix(names(list_ret))
n_sec=dim(name_list)[1]

df.corr.apex=NULL
df.corr.all=NULL
df.metrics.incep=NULL
roll12.std.all=NULL
mat.cumret.all=NULL
#i=2
for (i in 1:n_sec) {
  df.ret=as.data.frame(list_ret[i]/100)
  fund.name=colnames(df.ret)
  df.date=as.data.frame(list_date[i])
  df.clean.ret=as.data.frame(df.ret[!is.na(df.ret)])
  colnames(df.clean.ret)=fund.name
  df.clean.date=as.data.frame(df.date[!is.na(df.ret)])
  colnames(df.clean.date)=colnames(df.ret)
  mtx.date=as.matrix(df.clean.date)
  date.date=as.Date(mtx.date)
  fund.xts=xts(df.clean.ret,date.date)
  nrows=dim(fund.xts)[1]
  
  ###2017 YTD ret
  year.date=format(date.date,"%Y")
  idx.2017=which(year.date=="2017")
  ret.2017=df.clean.ret[idx.2017,]
  nrows.2017=length(ret.2017)
  
  incep.rows=1:nrows
  ret.incep=fund.xts[incep.rows]
  last.mon.ret=as.numeric(ret.incep[nrows])
  ytd.ret=prod(ret.2017+1)-1
  
  ##3 year
  trailing36.rows=(nrows-36+1):nrows
  ret.3yr=df.clean.ret[trailing36.rows,]
  
  ##5 year
  trailing60.rows=(nrows-60+1):nrows
  ret.5yr=df.clean.ret[trailing60.rows,]
  
  totalret.3yr=prod(ret.3yr+1)-1
  ann.ret.3yr=(totalret.3yr+1)^(12/36)-1
  
  totalret.5yr=prod(ret.5yr+1)-1
  ann.ret.5yr=(totalret.5yr+1)^(12/60)-1
  
  ann.ret.incep=Return.annualized(ret.incep)
  ann.std.incep=StdDev.annualized(ret.incep)
  downrisk.incep=sd(ret.incep[(ret.incep<0)])*sqrt(12)
  drawdown.incep=maxDrawdown(ret.incep,invert=FALSE)
  sharpe.incep=(ann.ret.incep-ann.rf)/ann.std.incep
  
  ###Correlation
  single.corr.apex=cor(ret.incep,ret.incep.apex)#if exchange two inputs, row name and column name will exchange, have to use cbind next line
  df.corr.apex=rbind(df.corr.apex,single.corr.apex)
  
  
  temp.df.corr=NULL
  for (j in 1:n_sec) {
    df.ret.pair=as.data.frame(list_ret[j]/100)
    single.corr=cor(df.ret.pair,df.ret)
    temp.df.corr=rbind(temp.df.corr,single.corr)
  }
  df.corr.all=cbind(df.corr.all,temp.df.corr)
  
  sortino.incep=SortinoRatio(ret.incep)
  #info_ratio.incep=InformationRatio(ret.incep,bench.incep,12)
  
  omega.incep=Omega(ret.incep)
  wl.incep=UpsideFrequency(ret.incep,MAR=0)

  skewness.incep=skewness(ret.incep)
  kurtosis.incep=kurtosis(ret.incep)
  
  ytd.ret=as.numeric(ytd.ret)
  #cum.ret.incep=as.numeric(cum.ret.incep)
  ann.ret.incep=as.numeric(ann.ret.incep)
  ann.std.incep=as.numeric(ann.std.incep)
  sharpe.incep=as.numeric(sharpe.incep)
  sortino.incep=as.numeric(sortino.incep)
  omega.incep=as.numeric(omega.incep)
  
  temp.metrics.incep=as.data.frame(cbind(last.mon.ret,ytd.ret,
                                         ann.ret.3yr,ann.ret.5yr,ann.ret.incep,ann.std.incep,
                     downrisk.incep,drawdown.incep,sharpe.incep),row.names=fund.name)
  df.metrics.incep=rbind(df.metrics.incep,temp.metrics.incep)
  
  ###calculating rolling 12mon std
  roll12.std=matrix(0,nrow=nrows-11,ncol=1)
  colnames(roll12.std)=fund.name
  for (j in 1:(nrows-11)) {
    roll12.std[j]=sd(ret.incep[j:(j+11)])*sqrt(12)
  }
  roll12.std.all=cbind(roll12.std.all,roll12.std)
  
  ###calculating cumulative return vector for every month
  mat.cumret=matrix(0,nrow=nrows+1,ncol=1)
  colnames(mat.cumret)=fund.name
  mat.cumret[1]=1
  for (j in 2:(nrows+1)) {
    mat.cumret[j]=prod(ret.incep[1:(j-1)]+1)
  }
  mat.cumret.all=cbind(mat.cumret.all,mat.cumret)
}

t.df.metrics.incep=t(df.metrics.incep)


df.metrics.incep.apex=as.data.frame(cbind(last.mon.ret.apex,ytd.ret.apex,ann.ret.3yr.apex,
                                          ann.ret.5yr.apex,ann.ret.incep.apex,ann.std.incep.apex,
                                          downrisk.incep.apex,drawdown.incep.apex,sharpe.incep.apex),row.names=apex.name)
t.df.metrics.apex=t(df.metrics.incep.apex)

final.metrics=cbind(t.df.metrics.apex,t.df.metrics.incep)
df.corr.all=cbind(df.corr.apex,df.corr.all)
final.metrics=rbind(final.metrics,df.corr.all)
roll12.std.all=cbind(roll12.std.apex,roll12.std.all)
mat.cumret.all=cbind(mat.cumret.apex,mat.cumret.all)
cumdollar.all=mat.cumret.all*1000

write.csv(final.metrics, file.dir.out.1)
write.csv(roll12.std.all, file.dir.out.2)
write.csv(cumdollar.all, file.dir.out.3)


