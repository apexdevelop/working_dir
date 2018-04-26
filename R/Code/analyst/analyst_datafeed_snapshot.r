start_time=Sys.time()
# setwd("C:/Users/ychen/Documents/R/Data")
# securities=c("005930 KS EQUITY","AA Equity")
# file_name1="universe_earnings.csv"

home = path.expand("~") #which is "C:/Users/YChen/Documents"
#pathname="C:/Users/YChen/Documents/git/working_dir/R/Data/"
pathname=paste(home,"/git/working_dir/R/Data/",sep="")
file_name1="analyst_ticker_s.csv"
file_dir1=paste(pathname,file_name1,sep="")
securities = read.csv(file_dir1,header = FALSE)
num_sec=dim(securities)[1]
securities=as.matrix(securities)
# securities=securities[1:num_sec,1]
# securities=sort(securities)

file_name2="broker_s.csv"
file_dir2=paste(pathname,file_name2,sep="")
brokers = read.csv(file_dir2,header = FALSE)
num_brokers=dim(brokers)[1]
overrides = brokers[1:num_brokers,1]
# overrides = brokers[1:15,1]
# overrides=c("BCA","BNP","DBG","DIR","FBC","GSR","HSB","JEF","JPM","MAC","MSR","MUS","MZS","NMR","UBS")
overrides=as.matrix(overrides)


library(Rbbg)
conn=blpConnect()
g_fields=c("SHORT_NAME","PX_LAST")
x_p=bdp(conn,securities,g_fields)

whole_window=365
lookback_window=1
start.date=as.character(Sys.Date()-whole_window,"%Y%m%d")
end.date=as.character(Sys.Date(),"%Y%m%d")

fun_last <- function(x) { tail(x, n = 1) }
fun_2nd_last <- function(x) { 
  if(length(x)>1) {
    x[length(x)-1]
  } else{NA}
}
s_fields=c("BEST_ANALYST_RATING","BEST_TARGET_PRICE")

## getting consensus rating and columns names
# x_h0=bdh(conn,securities,s_field,start.date,end.date,always.display.tickers = TRUE)
# last_rating0=unstack(x_h0,BEST_ANALYST_RATING~ticker)
# rownames(last_rating0)=unique(x_h0$date)
# v_colnames0=names(last_rating0)

## if line3 and line6 not using as.matrix,colnames=last_rating will be X7203.JP.EQUITY


override_fields=c("BEST_DATA_SOURCE_OVERRIDE")

v_colnames0=securities
mat_date=matrix(data=NA, nrow = length(overrides), ncol = length(securities),dimnames=list(overrides,v_colnames0))
mat_rating1=matrix(0, nrow = length(overrides), ncol = length(securities),dimnames=list(overrides,v_colnames0))
mat_rating0=matrix(0, nrow = length(overrides), ncol = length(securities),dimnames=list(overrides,v_colnames0))
mat_tgt1=matrix(0, nrow = length(overrides), ncol = length(securities),dimnames=list(overrides,v_colnames0))
mat_tgt0=matrix(0, nrow = length(overrides), ncol = length(securities),dimnames=list(overrides,v_colnames0))

for(i in 1:length(overrides))
{
  x_h=bdh(conn,securities,s_fields,start.date,end.date,override_fields,overrides[i],always.display.tickers = TRUE)
  x_h=na.omit(x_h)  
  list_rating=unstack(x_h,BEST_ANALYST_RATING~ticker)
  list_tgt=unstack(x_h,BEST_TARGET_PRICE~ticker)
  list_date=unstack(x_h,date~ticker)
  temp_date=sapply(list_date,fun_last)
  temp_rating1=sapply(list_rating,fun_last)
  temp_rating0=sapply(list_rating,fun_2nd_last)
  temp_rating0=unlist(temp_rating0)
  temp_tgt1=sapply(list_tgt,fun_last)
  temp_tgt0=sapply(list_tgt,fun_2nd_last)
  temp_tgt0=unlist(temp_tgt0)
  if(class(list_rating)=="list"){
    v_colnames=names(list_rating)
  } else {v_colnames=rownames(list_rating)}
  for (j in 1:length(v_colnames0))
  {
      idx=which(v_colnames==v_colnames0[j])
      if(length(idx)>0)
      {
        mat_date[i,j]=temp_date[idx]
        mat_rating1[i,j]=temp_rating1[idx]
        mat_rating0[i,j]=temp_rating0[idx]
        mat_tgt1[i,j]=temp_tgt1[idx]
        mat_tgt0[i,j]=temp_tgt0[idx]
      }
      
  }
    
}

v_ticker=NULL
v_event=NULL
v_date=NULL
v_broker=NULL
v_rate0=NULL
v_rate1=NULL
v_tgt0=NULL
v_tgt1=NULL


for(i in 1:length(overrides))
{
  for(j in 1:length(securities))
  {
     
    if (is.na(mat_date[i,j])==FALSE) {
     if (as.Date(mat_date[i,j])>=Sys.Date()-lookback_window){
       temp_rate0=mat_rating0[i,j]
       temp_rate1=mat_rating1[i,j]
       temp_tgt0=mat_tgt0[i,j]
       temp_tgt1=mat_tgt1[i,j]
       if (is.na(temp_rate0)) {        
          temp_event="Initiation"       
       } else {
         diff_rate=as.numeric(temp_rate1)-as.numeric(temp_rate0)
         diff_tgt=as.numeric(temp_tgt1)-as.numeric(temp_tgt0)
         if(diff_rate>0){
           temp_event2="Upgrade"
         } else if(diff_rate<0) {
           temp_event2="Downgrade"           
         } else {temp_event2=" "}
         if(diff_tgt>0){
           temp_event1="TP+"
         } else if(diff_tgt<0) {
           temp_event1="TP-"           
         } else {temp_event1=" "}
         temp_event=paste0(temp_event1,temp_event2)
       }
       if (is.na(temp_rate0) || diff_rate!=0 || diff_tgt!=0){
         temp_ticker=securities[j]
         temp_eventdate=mat_date[i,j]
         temp_broker=overrides[i]
         
         v_event=rbind(v_event,temp_event)
         v_ticker=rbind(v_ticker,temp_ticker)
         v_date=rbind(v_date,temp_eventdate)
         v_broker=rbind(v_broker,temp_broker)
         v_rate0=rbind(v_rate0,temp_rate0)
         v_rate1=rbind(v_rate1,temp_rate1)
         v_tgt0=rbind(v_tgt0,temp_tgt0)
         v_tgt1=rbind(v_tgt1,temp_tgt1)
       }
     }
   } 
  }
}

n_ob=length(v_broker)
mb=as.matrix(brokers)
# c_broker=as.character(v_broker)
# l_idx=apply(as.matrix(mb[1:num_brokers,1]), 1, function(x) all(x %in% c_broker)) 
# v_bnames=as.matrix(mb[l_idx,2])

v_bnames=v_broker
for (j in 1:n_ob)
{
  idx=which(overrides==v_broker[j])
  if(length(idx)>0)
  {
    v_bnames[j]=mb[idx,2]
  }
  
}

mat_enames=as.matrix(x_p[,1])
v_enames=v_ticker
for (j in 1:n_ob)
{
  idx=which(securities==v_ticker[j])
  if(length(idx)>0)
  {
    v_enames[j]=mat_enames[idx]
  }
  
}

mat_px=as.matrix(x_p[,2])
v_px=v_tgt1
for (j in 1:n_ob)
{
  idx=which(securities==v_ticker[j])
  if(length(idx)>0)
  {
    v_px[j]=mat_px[idx]
  }
  
}

v_summary=data.frame(v_event,v_date,v_bnames,v_ticker,v_enames,v_tgt0,v_tgt1,v_rate1,v_rate0,v_px,row.names=c(1:dim(v_ticker)[1]))
# write.csv(v_summary, "analyst_date.csv")
outf_name="tp_snapshot.xlsx"
outf_dir=paste(pathname,outf_name,sep="")
library(xlsx)
write.xlsx(v_summary, sheetName="Sheet1",outf_dir,showNA=FALSE)
end_time=Sys.time()
end_time - start_time