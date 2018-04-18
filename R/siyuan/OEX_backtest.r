setwd("E:/Apex/backtesting")
mydata = read.csv("^OEX.csv", header=T)
Y=mydata[,4]
v_rtn=mydata[,3]
enter_disp=mydata[,7]
exit_disp=mydata[,8]
tday=mydata[,1]
enter_disp=1
exit_disp=0
trades=0                       
Enter=0
Exit=0
Long=0
Short=0
ret_v=0
hp_v=0
is_open=0
direction=0
hp_TH=40
nob=dim(mydata)[1]
ncol=dim(mydata)[2]
s = matrix(0,nob,ncol)
r_trade = matrix(0,nob,1)
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

      
      if (direction==1 && Y[j]<exit_disp | (r_trade[j]=15) | j-entryIDX > hp_TH)
      {
        trades=trades+1
        ret_v=rbind(ret_v,r_trade[j])
        hp_v=rbind(hp_v,j-entryIDX)
        Exit=rbind(Exit,j)
        is_open=0
        direction=0
      }  
    } else (CPnL[j]= CPnL[j-1]) 
    { if  (Y[j]>= enter_disp)
      { s[j, 1] = 1
        entryIDX=j
        is_open=1
        direction=1
        Enter=rbind(Enter,j)
        Long=rbind(Long,j)}}}}

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
  } else { }}}


if (is.na(Enter)==0)
{ last_enter=m2xdate(tday(Enter(length(Enter))),0)
} else {
  last_enter=m2xdate(700000,0)
}
if (is.na(Enter)==0 && is.na(Exit)==0)
{ if (length(Enter)>=1)
  {stdev=sd(ret_v)}
  last_exit=m2xdate(tday(Exit(length(Enter)),0))      
                    wins=dim(which(ret_v>0),1)                  
                    av_ret=mean(ret_v)
                    hp=round(mean(hp_v))
                    winp=wins/trades
} else {
  last_exit=m2xdate(700000,0)
  av_ret=-100
  stdev=0
  hp=-100
  winp=-100
  trades=-100}

output <- data.frame(enter_disp,exit_disp,av_ret,stdev,trades,hp,winp,last_exit,last_enter)
write.table (output, file ="output.csv")

