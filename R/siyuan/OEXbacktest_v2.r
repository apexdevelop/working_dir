#setwd("E:/Apex/backtesting")
setwd("Y:/working_directory/R")
mydata = read.csv("^OEX.csv", header=T)
#Y=mydata[,4]
Y=mydata[,5]
v_rtn=mydata[,3]
enter_disp=mydata[,7]
exit_disp=mydata[,8]
tday=mydata[,1]
enter_disp=1
exit_disp=0
trades=0                       
Enter=NULL
Exit=NULL
Long=NULL
Short=NULL

ret_v=NULL
hp_v=NULL
is_open=0
direction=0
hp_TH=40
nob=dim(mydata)[1]
ncol=dim(mydata)[2]
s = matrix(0,nob,1)
r_trade = matrix(0,nob,1)
OPEN=matrix(0,nob,1)
CPnL=matrix(0,nob,1)
if (enter_disp>0) {
  for (j in 3:nob) {
    if (is_open!=0) {
     s[j,1]=s[j-1,1]
            r_trade[entryIDX]=0
      current_r=rbind(0,(s[entryIDX:j-1] %*% v_rtn[entryIDX:j-1]))
      r_trade[j]= sum(current_r)
      cumul_r= rbind(0,s[1:j-1] %*% v_rtn[1:j-1])
      CPnL[j]= sum(cumul_r)

      
      if (direction==1 && Y[j]<exit_disp | (r_trade[j]<=-15) | j-entryIDX > hp_TH)
      {
        trades=trades+1
        ret_v=rbind(ret_v,r_trade[j])
        hp_v=rbind(hp_v,j-entryIDX)
        Exit=rbind(Exit,j)
        is_open=0
        direction=0
      }  
    } else 
    {
      CPnL[j]= CPnL[j-1] 
     if  (Y[j]>= enter_disp)
      { s[j, 1] = 1
        entryIDX=j
        is_open=1
        direction=1
        Enter=rbind(Enter,j)
        OPEN[j]=is_open
        Long=rbind(Long,j)}}}
  } else {
for (j in 3:nob)
{ if (is_open!=0)
  { s[j,1]=s[j-1,1]

    r_trade[entryIDX]=0;
    current_r=rbind(0,s[entryIDX:j-1] %*%  v_rtn[entryIDX:j-1])
    r_trade[j]= sum(current_r)
    cumul_r= rbind(0,s[1:j-1] %*% v_rtn[1:j-1])
    CPnL[j]= sum(cumul_r)


  if (direction==-1 && Y[j]>exit_disp | (r_trade[j]<-15) | j-entryIDX > hp_TH ){
    trades=trades+1
    ret_v=rbind(ret_v,r_trade[j])
    hp_v=rbind(hp_v,j-entryIDX)
    Exit=rbind(Exit,j)
    is_open=0
    direction=0
  } else { }

  } else (CPnL[j]= CPnL[j-1])
  {if (Y[j]<= enter_disp)
  {   s[j, 1] = -1
    entryIDX=j
    is_open=1
    direction=-1
    Enter=rbind(Enter,j)
    Short=rbind(Short,j)
  } else { }}
 }

}

if (length(Enter)!=0)
{  last_enter=tday[Enter[length(Enter)]]
} else {
  last_enter=NA
}

if (length(Enter)!=0 && length(Exit)!=0)
{    if (length(Enter)>=1)
  {    stdev=sd(ret_v)
  }
  last_exit=tday[Exit[length(Exit)]]      
            wins=length(which(ret_v>0))                 
            av_ret=mean(ret_v)
            hp=round(mean(hp_v))
            winp=wins/trades
} else {
  last_exit=NA
  av_ret=-100
  stdev=0
  hp=-100
  winp=-100
  trades=-100}

output <- data.frame(enter_disp,exit_disp,av_ret,stdev,trades,hp,winp,last_exit,last_enter)
#write.table (output, file ="output.csv")
write.csv (output, file ="output.csv")

