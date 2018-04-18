# setwd("C:/Users/ychen/Documents/R/Data")
# securities=c("005930 KS EQUITY","AA Equity")
# file_name1="universe_earnings.csv"
pathname="./Data/"
file_name1="analyst_ticker_s.csv"
file_dir1=paste(pathname,file_name1,sep="")
securities = read.csv(file_dir1,header = FALSE)
num_sec=dim(securities)[1]
# securities=securities[1:20,1]
securities=as.matrix(securities)
# securities=sort(securities)

file_name2="broker.csv"
file_dir2=paste(pathname,file_name2,sep="")
brokers = read.csv(file_dir2,header = FALSE)
num_brokers=dim(brokers)[1]
overrides = brokers[1:num_brokers,1]
# overrides = brokers[1:5,1]
# overrides=c("BCA","BNP","DBG","DIR","FBC","GSR","HSB","JEF","JPM","MAC","MSR","MUS","MZS","NMR","UBS")
overrides=as.matrix(overrides)


library(Rbbg)
conn=blpConnect()
g_fields=c("SHORT_NAME","PX_LAST","BEST_TARGET_PRICE","BEST_ANALYST_REC_1WK_CHG","BEST_TARGET_1WK_CHG")
x_p=bdp(conn,securities,g_fields)
atp2p=(x_p[,3]/x_p[,2]-1)*100
x_p[,5]=x_p[,5]/x_p[,2]*100

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
mat_tgt02p=matrix(0, nrow = length(overrides), ncol = length(securities),dimnames=list(overrides,v_colnames0))
mat_tgt12p=matrix(0, nrow = length(overrides), ncol = length(securities),dimnames=list(overrides,v_colnames0))

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
      idx0=which(v_colnames==v_colnames0[j])
      if(length(idx0)>0)
      {
        mat_date[i,j]=temp_date[idx0]
        mat_rating1[i,j]=temp_rating1[idx0]
        mat_rating0[i,j]=temp_rating0[idx0]
        mat_tgt1[i,j]=temp_tgt1[idx0]
        mat_tgt0[i,j]=temp_tgt0[idx0]
        mat_tgt02p[i,j]=(as.numeric(temp_tgt0[idx0])/as.numeric(x_p[j,2])-1)*100
        mat_tgt12p[i,j]=(as.numeric(temp_tgt1[idx0])/as.numeric(x_p[j,2])-1)*100
        
      }
      
  }
    
}

v_ticker=NULL
v_event=NULL
v_date=NULL
v_broker=NULL
v_rate=NULL
v_tp2p=NULL
v_chgrate=NULL
v_chgtp=NULL

for(i in 1:length(overrides))
{
  for(j in 1:length(securities))
  {
    if (is.na(mat_date[i,j])==FALSE) {
     if (as.Date(mat_date[i,j])<Sys.Date()-lookback_window){
       temp_rate=as.numeric(mat_rating1[i,j])
       temp_tp2p=as.numeric(mat_tgt12p[i,j])       
       temp_chg_rate=x_p[j,4]
       temp_chg_tp=x_p[j,5]
       if (is.na(temp_rate)==FALSE && is.na(temp_tp2p)==FALSE && is.na(temp_chg_rate)==FALSE && is.na(temp_chg_tp)==FALSE) {
         if(temp_rate<=2)
         {
           if(temp_tp2p<15){temp_event=" "}
           else{
               if (temp_chg_rate>0 & temp_chg_tp>=0) {temp_event="Upgrade"}
               else if(temp_chg_rate<=0 & temp_chg_tp<0) {temp_event="Cut TP"}
               else if(temp_chg_rate>0 & temp_chg_tp<0) {temp_event="Upgrade and Cut TP"}
               else {temp_event="Upgrade Or Cut TP"}
           }
         } else if(temp_rate>=4)
         {
           if(temp_tp2p>5){temp_event=" "}
           else{
               if (temp_chg_rate<0 & temp_chg_tp<=0) {temp_event="Downgrade"}
               else if(temp_chg_rate>=0 & temp_chg_tp>0) {temp_event="Raise TP"}
               else if(temp_chg_rate<0 & temp_chg_tp>0) {temp_event="Downgrade and Raise TP"}
               else {temp_event="Downgrade Or Raise TP"}
           }
         } else {temp_event=" "}
       }
       
       if (temp_event!=" "){
         temp_ticker=securities[j]
         temp_eventdate=mat_date[i,j]
         temp_broker=overrides[i]
         
         v_event=rbind(v_event,temp_event)
         v_ticker=rbind(v_ticker,temp_ticker)
         v_date=rbind(v_date,temp_eventdate)
         v_broker=rbind(v_broker,temp_broker)
         v_rate=rbind(v_rate,temp_rate)
         v_tp2p=rbind(v_tp2p,temp_tp2p)
         v_chgrate=rbind(v_chgrate,temp_chg_rate)
         v_chgtp=rbind(v_chgtp,temp_chg_tp)
       }
     }
   } 
  }
}

n_ob=length(v_broker)
mb=as.matrix(brokers)


v_bnames=v_broker
for (j in 1:n_ob)
{
  idx1=which(overrides==v_broker[j])
  if(length(idx1)>0)
  {
    v_bnames[j]=mb[idx1,2]
  }
  
}

mat_enames=as.matrix(x_p[,1])
v_enames=v_ticker
for (j in 1:n_ob)
{
  idx2=which(securities==v_ticker[j])
  if(length(idx2)>0)
  {
    v_enames[j]=mat_enames[idx2]
  }
  
}

mat_px=as.matrix(x_p[,2])
v_px=v_tp2p
for (j in 1:n_ob)
{
  idx2=which(securities==v_ticker[j])
  if(length(idx2)>0)
  {
    v_px[j]=mat_px[idx2]
  }
  
}


mat_atp2p=as.matrix(atp2p)
v_atp2p=v_tp2p
for (j in 1:n_ob)
{
  idx2=which(securities==v_ticker[j])
  if(length(idx2)>0)
  {
    v_atp2p[j]=mat_atp2p[idx2]
  }
  
}

v_summary=data.frame(v_event,v_bnames,v_ticker,v_enames,v_tp2p,v_rate,v_atp2p,v_chgrate,v_chgtp,v_date,row.names=c(1:dim(v_ticker)[1]))

library(xlsx)
write.xlsx(v_summary, sheetName="Sheet1","predict_recom.xlsx", showNA=FALSE)
