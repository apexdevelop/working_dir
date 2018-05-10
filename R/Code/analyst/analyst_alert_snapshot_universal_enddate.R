#####
##field data for some stocks update timely, others not, that's why have to use both universal and customized enddate

library(xlsx)
current_time=Sys.time()
current_date=Sys.Date()
str_current_date2=format(current_date,'%m%d%Y')

home = path.expand("~") #which is "C:/Users/YChen/Documents"
pathname=paste(home,"/git/working_dir/R/Data/",sep="")
#pathname="C:/Users/YChen/Documents/git/working_dir/R/Data/"
#file_name1=paste("analyst_alert_",str_current_date2,".csv",sep="")
file_name1=paste("analyst_alert_",str_current_date2,".xlsx",sep="")
file_dir1=paste(pathname,file_name1,sep="")
#rawdata = read.csv(file_dir1,header = TRUE)
rawdata = read.xlsx(file_dir1,1,header = TRUE)
num_ob=dim(rawdata)[1]
col_time=as.matrix(rawdata[,2])
col_date=as.matrix(rawdata[,1])
col_ticker = as.matrix(rawdata[,3])
col_condition = as.matrix(rawdata[,5])

##############################################################
out_broker=matrix(data=NA, nrow=num_ob)
for (i in 1:num_ob) {
  new_condition=col_condition[i]
  if (grepl("by", new_condition)) {
    ls_location = gregexpr(pattern ='by',new_condition)
    temp_idx = unlist(ls_location)
    #broker
    str_broker = substr(new_condition,temp_idx+3,nchar(new_condition))
    out_broker[i] = str_broker
  }
}

file_name2="broker_l.csv"
file_dir2=paste(pathname,file_name2,sep="")
broker.and.code = read.csv(file_dir2,header = FALSE,stringsAsFactors =FALSE)
out.broker.code=matrix(data=NA, nrow=num_ob)
in.broker.name=as.matrix(broker.and.code[,2])
for (i in 1:num_ob) {
  idx=which(in.broker.name==out_broker[i])
  if(length(idx)>0)
  {
    out.broker.code[i]=broker.and.code[idx,1]
  }
}

library(Rbbg)
jarpath=paste(home,"/git/working_dir/R/blpapi3.jar",sep="")
#conn1=blpConnect(blpapi.jar.file="C:\\blp\\DAPI\\APIv3\\JavaAPI\\v3.11.1.1\\lib\\blpapi3.jar")
conn1=blpConnect(blpapi.jar.file=jarpath)
g_fields=c("SHORT_NAME","PX_LAST","BEST_TARGET_PRICE","CHG_PCT_2D","CHG_PCT_5D","REL_INDEX")
x_p=bdp(conn1,col_ticker,g_fields)
out_name=as.matrix(x_p[,1])
out_px=as.matrix(x_p[,2])
out_avgtp = as.matrix(x_p[,3])
out_chg2d = as.matrix(x_p[,4])
out_chg5d = as.matrix(x_p[,5])
out_benchmark=as.matrix(paste(x_p[,6]," INDEX",sep=""))
blpDisconnect(conn1)

conn2=blpConnect()
g_fields2=c("CHG_PCT_2D","CHG_PCT_5D")
x_p2=bdp(conn2,out_benchmark,g_fields2)
blpDisconnect(conn2)

out_bchg2d = as.matrix(x_p2[,1])
out_bchg5d = as.matrix(x_p2[,2])
re_chg2d = out_chg2d - out_bchg2d
re_chg5d = out_chg5d - out_bchg5d

fun_last <- function(x) { tail(x, n = 1) }
fun_2nd_last <- function(x) { 
  if(length(x)>1) {
    x[length(x)-1]
  } else{NA}
}

fun_3rd_last <- function(x) { 
  if(length(x)>2) {
    x[length(x)-2]
  } else{NA}
}

out_oldtp=matrix(data=NA, nrow=num_ob)
out_newtp2=matrix(data=NA, nrow=num_ob)
out_oldertp=matrix(data=NA, nrow=num_ob)
out_newrating_numeric=matrix(data=NA, nrow=num_ob)
out_oldrating_numeric=matrix(data=NA, nrow=num_ob)
out_olderrating_numeric=matrix(data=NA, nrow=num_ob)

conn3=blpConnect()
s_fields=c("BEST_ANALYST_RATING","BEST_TARGET_PRICE")
override_field=c("BEST_DATA_SOURCE_OVERRIDE")
whole_window=365
lookback_window=1
char.start.date=as.character(Sys.Date()-whole_window,"%Y%m%d")
char.end.date=as.character(Sys.Date(),"%Y%m%d")

for (i in 1:num_ob) {
  if (is.na(out.broker.code[i])) {
    override_value = "BST"
  } else {
    override_value = trimws(out.broker.code[i])
  }
  
  #end.date=as.Date(col_date[i],format='%m/%d/%Y')
  #char.start.date=as.character(end.date-whole_window,"%Y%m%d")
  #char.end.date=as.character(end.date,"%Y%m%d")
  
  x_h=bdh(conn3,col_ticker[i],s_fields,char.start.date,char.end.date,override_field,override_value,always.display.tickers = TRUE)
  #blpDisconnect(conn3)
  x_h=na.omit(x_h)  
  df_rating=unstack(x_h,BEST_ANALYST_RATING~ticker)
  df_tgt=unstack(x_h,BEST_TARGET_PRICE~ticker)
  
  temp_rating1=sapply(df_rating,fun_last)
  if(is.logical(temp_rating1[[1]])){
    out_newrating_numeric[i]=NA
  }else {
    out_newrating_numeric[i]=unlist(temp_rating1)
  }
  
  out_oldrating_numeric[i]=sapply(df_rating,fun_2nd_last)
  out_olderrating_numeric[i]=sapply(df_rating,fun_3rd_last)
  out_oldtp[i]=sapply(df_tgt,fun_2nd_last)
  temp_newtp2=sapply(df_tgt,fun_last)
  out_oldertp[i]=sapply(df_tgt,fun_3rd_last)
  if(is.logical(temp_newtp2[[1]])){
    out_newtp2[i]=NA
  }else {
    out_newtp2[i]=unlist(temp_newtp2)
  }
}

out_newtp_px = (out_newtp2/out_px-1)*100
out_oldtp_px = (out_oldtp/out_px-1)*100
##upgrade and downgrade event, the target price change calculation is better to use the field
chg_tgt = (out_newtp2 - out_oldtp)/out_oldtp*100
chg_rating=out_newrating_numeric-out_oldrating_numeric
out_newtp_avgtp = (out_newtp2 /out_avgtp-1)*100

###########################################
str_current_date=format(Sys.Date(),'%m/%d/%Y')
pre_date=current_date - 1
str_pre_date=format(pre_date,'%m/%d/%Y')

US_str = paste(str_pre_date,' 16:00:00')
US_cutoff = strptime(US_str,'%m/%d/%Y %H:%M:%S')

JP_str = paste(str_current_date,' 02:00:00')
JP_cutoff = strptime(JP_str,'%m/%d/%Y %H:%M:%S')

HK_str = paste(str_current_date,' 04:00:00')
HK_cutoff = strptime(HK_str,'%m/%d/%Y %H:%M:%S')

KR_str = paste(str_current_date,' 02:30:00')
KR_cutoff = strptime(KR_str,'%m/%d/%Y %H:%M:%S')

TW_str = paste(str_current_date,' 01:30:00')
TW_cutoff = strptime(TW_str,'%m/%d/%Y %H:%M:%S')

out_label_cutoff=matrix( data=NA, nrow=num_ob)
out_event=matrix(data=NA, nrow=num_ob)

out_newtp=matrix(data=NA, nrow=num_ob)
out_newrating=matrix(data=NA, nrow=num_ob)

for (i in 1:num_ob) {
  ticker = col_ticker[i]
  temp_str=substr(ticker,nchar(ticker)-8,nchar(ticker))
  country = substr(temp_str,1,2)

  if (country == 'JP'){
    cutoff=JP_cutoff
  } else if (country == 'HK'){
    cutoff = HK_cutoff
  } else if (country == 'KS'){
    cutoff = KR_cutoff
  } else if (country == 'TW'){
    cutoff = TW_cutoff
  } else if (country == 'US'){
    cutoff = US_cutoff
  } else {
    cutoff = HK_cutoff
  }

  str_new_time = col_time[i]
  str_new_date = col_date[i]
  str_new_datetime = paste(str_new_date,' ', str_new_time)
  new_datetime = strptime(str_new_datetime,'%m/%d/%Y %H:%M:%S')

  if (new_datetime>cutoff){
    label_cutoff='A'
  } else {
    label_cutoff='B/D'
  }

  out_label_cutoff[i]=label_cutoff

  new_condition=col_condition[i]

  if (grepl("by", new_condition)) {
    ls_location = gregexpr(pattern ='by',new_condition)
    temp_idx = unlist(ls_location)
    #broker
    
    #event
    #target price
    if (grepl("Target Px", new_condition)) {
       if (grepl("Target Px increased", new_condition)) {
         str_tg='TP+'
       } else if (grepl("Target Px decreased", new_condition)) {
         str_tg='TP-'
       } else {}
       ls_tg_idx=gregexpr(pattern ='creased to',new_condition)
       tg_idx = unlist(ls_tg_idx)
       str_tp = substr(new_condition,tg_idx+11,temp_idx-2)
       # Splitting the string in integer and decimal part
       number.part <- strsplit(str_tp, ".", fixed = T)
       integer.part=number.part[[1]][1]   # Integer part
       n.dgt.integer = nchar(integer.part)
       decimal.part=number.part[[1]][2]   # Decimal part. Note the effect of the leading zeros
       n.dgt.decimal = nchar(decimal.part)
       if (!is.na(n.dgt.decimal)) {
          n.dgt = n.dgt.integer + n.dgt.decimal
       } else {
          n.dgt = n.dgt.integer
       }
       options(digits = n.dgt)
       float_tp = as.numeric(str_tp)
       out_newtp[i] = float_tp
       ##under event of target price change, better to use snapshot new target price to calculate chg_tgt
       if (!is.na(out_newtp[i]) && !is.na(out_oldtp[i])>0){
       if (out_newtp[i]!=out_oldtp[i]) {
         chg_tgt[i] = (out_newtp[i] - out_oldtp[i])/out_oldtp[i]*100
       } else {
         ##sometimes the 2nd_last field info already updated, so has to go futher in the past to get the old tgt px
         chg_tgt[i] = (out_newtp[i] - out_oldertp[i])/out_oldertp[i]*100
         out_oldtp_px[i] = (out_oldertp[i]/out_px[i]-1)*100
       }
       }
       out_newtp_px[i] = (out_newtp[i]/out_px[i]-1)*100
       out_newtp_avgtp[i] = (out_newtp[i] /out_avgtp[i]-1)*100
    } else {
      str_tg=''
    }
    
    ##purpose of this section is to add tp change to rating change event
    ##in the headline, it may only say upgrade, but the tgt also changed
    if (!is.na(chg_tgt[i]) && chg_tgt[i]>0) {
      str_tg= 'TP+'
    } else if (!is.na(chg_tgt[i]) && chg_tgt[i]<0) {
      str_tg = 'TP-'
    } 
    
    #rating
    if (grepl("Upgraded", new_condition)) {
      str_rating='Upgrade'
    } else if (grepl("Downgraded", new_condition)) {
      str_rating='Downgrade'
    } else if (grepl("Initiated", new_condition)) {
      str_rating='Initiation'
    } else {
      str_rating=''
    }
  
    if (grepl("graded", new_condition)) {
      ls_rating_idx=gregexpr(pattern ='graded to',new_condition)
      rating_idx = unlist(ls_rating_idx)
      str_newrating = substr(new_condition,rating_idx+9,temp_idx-2)
      out_newrating[i] = str_newrating
      #if field rating doesn't match with news, go to the past further
      #if news came before market, new rating and tgt today is the same with yesterday, so latest field info and news don't match
      #but there is another case that news came after market, and field info has not yet been updated, then the output will be wrong
      if (!is.na(chg_rating[i])) {
      if (chg_rating[i]==0){
        out_newrating_numeric[i]=out_oldrating_numeric[i]
        out_oldrating_numeric[i]=out_olderrating_numeric[i]
        chg_rating[i]=out_newrating_numeric[i]-out_oldrating_numeric[i]
        
        out_newtp[i] = out_oldtp[i]
        chg_tgt[i] = (out_newtp[i] - out_oldertp[i])/out_oldertp[i]*100
        out_oldtp_px[i] = (out_oldertp[i]/out_px[i]-1)*100
        out_newtp_px[i] = (out_newtp[i]/out_px[i]-1)*100
        out_newtp_avgtp[i] = (out_newtp[i] /out_avgtp[i]-1)*100
      }
      }
      
    } else if (grepl("Initiated", new_condition)) {
      ls_rating_idx=gregexpr(pattern ='Coverage at',new_condition)
      rating_idx = unlist(ls_rating_idx)
      str_newrating = substr(new_condition,rating_idx+11,temp_idx-2)
      out_newrating[i] = str_newrating
    }
  
    str_event= paste(str_tg,str_rating)
    out_event[i]=str_event
  }
}

################# is forced##################
is_forced=matrix(data=NA, nrow=num_ob)
for (i in 1:num_ob) {
  if(!is.na(out_newrating_numeric[i]) && !is.na(out_oldrating_numeric[i]) && !is.na(out_oldtp_px[i]) && !is.na(out_newtp_px[i])){
    if (out_newrating_numeric[i] == out_oldrating_numeric[i]) {
      if (out_oldrating_numeric[i]>=4 && out_oldtp_px[i]<=15 && out_newtp_px[i]>15){
        is_forced[i]="Forced"
      }
    
      if ((out_oldrating_numeric[i]<=2) && (out_oldtp_px[i]>=-5) && (out_newtp_px[i]<-5)){
        is_forced[i]="Forced"
      }
    
      if (out_oldrating_numeric[i]==3 && out_oldtp_px[i]<=-5 && out_newtp_px[i]>-5){
        is_forced[i]="Forced"
      }
    
      if (out_oldrating_numeric[i]==3 && out_oldtp_px[i]>=15 && out_newtp_px[i]<15){
        is_forced[i]="Forced"
      }
    }
  }
}

################# Score##################
out_score=matrix(data=NA, nrow=num_ob)
for (i in 1:num_ob) {
  score_rating = 0
  score_tp = 0
  score_time = 0
  score_forced = 0
  if (!is.na(chg_rating[i])) {
    if (!chg_rating[i]==0){
      score_rating = chg_rating[i]/2
    }
  }
  
  if (!is.na(chg_tgt[i])) {
    if (chg_tgt[i]>0){
      score_tp = 0.5
    } else if(chg_tgt[i]<0){
      score_tp = -0.5
    }
  }
  
  
  if (out_label_cutoff[i]=="A"){
      score_time = 1
  }
  
  if (!is.na(is_forced[i])) {
    if (is_forced[i]=="forced"){
      score_forced = 1
    }
  }
  
  out_score[i] = score_rating + score_tp + score_time + score_forced

}


is_forced[is.na(is_forced)]=""
out_oldtp[is.na(out_oldtp)]=""
out_newtp2[is.na(out_newtp2)]=""
out_newtp[is.na(out_newtp)]=""
out_newtp_px[is.na(out_newtp_px)]=""
out_oldtp_px[is.na(out_oldtp_px)]=""
chg_tgt[is.na(chg_tgt)]=""
out_newtp_avgtp[is.na(out_newtp_avgtp)]=""
out_newrating[is.na(out_newrating)]=""
out_newrating_numeric[is.na(out_newrating_numeric)]=""
out_oldrating_numeric[is.na(out_oldrating_numeric)]=""
chg_rating[is.na(chg_rating)]=""
chg_rating[chg_rating==0]=""
out_score[is.na(out_score)]=""


output = cbind(out_label_cutoff,out_event,col_date,out_broker,out_name,is_forced,out_newtp_px,out_oldtp_px,chg_tgt,out_newtp_avgtp,re_chg2d,re_chg5d,out_newrating,out_newrating_numeric,out_oldrating_numeric,chg_rating,out_score)
df.output=as.data.frame(output)
colnames(df.output)=c("time","event","date","broker","name","is_forced","newtp_to_px","oldtp_to_px","chg_tgt","newtp_avgtp","chg_2d","chg_5d","char_newrating","newrating","oldrating","chg_rating","score")


file_name3=paste("universal_analyst_output_",str_current_date2,".csv",sep="")
file_dir3=paste(pathname,file_name3,sep="")
write.csv(df.output, file_dir3)

####Reference
#https://stackoverflow.com/questions/32974199/convert-string-to-numeric-defining-the-number-of-decimal-digits