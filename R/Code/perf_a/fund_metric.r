##### Define function fund_data
fund_data <- function(infile) {
# Read the CSV files
raw_securities = read.csv(file_dir,header = FALSE, stringsAsFactors=F)
securities=as.matrix(raw_securities)
securities=as.matrix(sort(securities))
n_sec=dim(securities)[1]

library(Rbbg)
conn=blpConnect()
fields=c("CHG_PCT_1D")

start_date="2012-09-01"
#end_date="2017-06-30"
end_date=Sys.Date()
start.date = as.POSIXct(start_date)
end.date = as.POSIXct(end_date)

########get fund data
x_h=bdh(conn,securities,fields,start.date,end.date,option_names = "periodicitySelection", option_values = "MONTHLY",always.display.tickers = TRUE)
return(x_h)
}

###Assign input values
infile="em_list.csv"
#outfile="rcustom_output_em.csv"
outfile="rcustom_output_em_incep.csv"
#infile="asia_list.csv"
#outfile="rcustom_output_asia.csv"
#infile="mn_list.csv"
#outfile2="rpackage_output_mn.csv"
#outfile="rcustom_output_mn.csv"
#infile="allhf_list.csv"
#outfile="rcustom_output_allhf.csv"
pathname="C:Users/YChen/Documents/git/working_dir/R/Data/"

file_dir=paste(pathname,infile,sep="")
file_dir_out=paste(pathname,outfile,sep="")
#file_dir_out_2=paste(pathname,outfile2,sep="")

##call defined function fund_data
fund.data=fund_data(infile)


##### Define function fund_metric
fund_metric <- function(x_h,n.periods,is.trailing) {
  library(zoo)            # Load the zoo package
  library(xts)             # Load the xts package
  library(PerformanceAnalytics)
  
list_ret=unstack(x_h,CHG_PCT_1D~ticker)
list_date=unstack(x_h,date~ticker)
name_list=as.matrix(names(list_ret))
n_sec=dim(name_list)[1]

rfrate=0.005

df.ret=NULL;
df.metrics=NULL

for (i in 1:n_sec) {
  df.ret=as.data.frame(list_ret[i]/100)
  #df.ret=as.data.frame(list_ret["DERNMOF.US.Equity"]/100)
  df.date=as.data.frame(list_date[i])
  #df.date=as.data.frame(list_date["DERNMOF.US.Equity"])
  df.clean.ret=as.data.frame(df.ret[!is.na(df.ret)])
  colnames(df.clean.ret)=colnames(df.ret)
  df.clean.date=as.data.frame(df.date[!is.na(df.ret)])
  colnames(df.clean.date)=colnames(df.ret)
  mtx.date=as.matrix(df.clean.date)
  date.date=as.Date(mtx.date)
  fund.xts=xts(df.clean.ret,date.date)
  nrows=dim(fund.xts)[1]
  incep.rows=1:nrows
  fund.name=colnames(df.ret)
  
  if (is.trailing){
     if (nrows>=n.periods){
        trailing.rows=(nrows-n.periods+1):nrows
        ret=fund.xts[trailing.rows]
     }
  }else{
    #since inception
     ret=fund.xts[incep.rows]
     n.periods=nrows
  }
  
  
  if (nrows>=n.periods){
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
    sharpe=(ann.ret-rfrate)/ann.std
    sortino=(ann.ret-rfrate)/downrisk
    omega=Omega(ret)
    wl=length(which(ret>0))/n.periods
    skewness=skewness(ret)
    kurtosis=kurtosis(ret)
    
    
    omega=as.numeric(omega)
    
    df.ret=as.data.frame(cbind(ret))
    
    
    temp.metrics=as.data.frame(cbind(ann.ret,ann.std,downrisk,drawdown
                                        ,sharpe,sortino,omega
                                        ,wl,skewness,kurtosis),row.names=fund.name)
    df.metrics=rbind(df.metrics,temp.metrics)
  }
}

return(df.metrics)
}


###Assign input values
n.periods=1
is.trailing=FALSE
##call defined function fund_metric
output=fund_metric(fund.data,n.periods,is.trailing)

##print function output
write.csv(output, file_dir_out)