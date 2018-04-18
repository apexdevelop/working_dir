# setwd("E:/Apex/backtesting")
# mydata = read.csv("^OEX.csv", header=T)
#setwd("E:/Apex/project2")
mydata = read.csv("project2.csv", stringsAsFactors=F)

rt_J=mydata[,4]
rt_N=mydata[,5]
z_J=mydata[,7]
z_N=mydata[,8]
gc=mydata[,9]

Y=mydata[,7]
#use zscore to caculate Y
# rt_J=mydata[,3]

tday=mydata[,1]
enter_disp=2.5
exit_disp=-1
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
#set 40 trades to prohibit trade too more to safe
nob=dim(mydata)[1]
ncol=dim(mydata)[2]
s = matrix(0,nob,1)
r_trade = matrix(0,nob,1)
OPEN=matrix(0,nob,1)
CPnL=matrix(0,nob,1)

av_ret=NULL
stdev=NULL
trade_N=NULL
hp=NULL
winp=NULL
last_exit=NULL
last_enter=NULL

# enter_disp=as.matrix(rep(1,times=4))
# exit_disp=as.matrix(seq(-1,-2.5,by=-0.5))
enter_1=NULL
exit_1=NULL
# for (a in 1:4){
#   enter_d=enter_disp[a]
#   exit_d=exit_disp[a]
enter_d=1
exit_d=-1
gc1=as.matrix(seq(0.05,0.2,by=0.05))
for (a in 1:4){
  grca=gc1[a]

#if (gc>grca){

if (enter_d>0) {
  for (j in 3:nob) {
    if (is_open!=0) {
     s[j,1]=s[j-1,1]
            r_trade[entryIDX]=0
      current_r=rbind(0,(s[entryIDX:j-1] %*% rt_J[entryIDX:j-1]))
      r_trade[j]= sum(current_r)
      cumul_r= rbind(0,s[1:j-1] %*% rt_J[1:j-1])
      CPnL[j]= sum(cumul_r)

      
      if (direction==1 && Y[j]<exit_d | (r_trade[j]<=-15) | j-entryIDX > hp_TH)
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
     if  (Y[j]>= enter_d)
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
    current_r=rbind(0,s[entryIDX:j-1] %*%  rt_J[entryIDX:j-1])
    r_trade[j]= sum(current_r)
    cumul_r= rbind(0,s[1:j-1] %*% rt_J[1:j-1])
    CPnL[j]= sum(cumul_r)


  if (direction==-1 && Y[j]>exit_d | (r_trade[j]<-15) | j-entryIDX > hp_TH){
    trades=trades+1
    ret_v=rbind(ret_v,r_trade[j])
    hp_v=rbind(hp_v,j-entryIDX)
    Exit=rbind(Exit,j)
    is_open=0
    direction=0

  } else { }

  } else (CPnL[j]= CPnL[j-1])
  {if (Y[j]<= enter_d)
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
{  lastenter=tday[Enter[length(Enter)]]
} else {
  lastenter=NA
}

if (length(Enter)!=0 && length(Exit)!=0)
{    if (length(Enter)>=1)
  {    std=sd(ret_v)
       stdev=rbind(stdev,std)
       #stdev
    }
  lastexit=tday[Exit[length(Exit)]]      
  wins=length(which(ret_v>0))                 
  avrt=mean(ret_v)
  hp_1=round(mean(hp_v))
  winp_1=wins/trades
  
} else {
  lastexit=NA
  avrt=-100
  std=0
  hp_1=-100
  winp_1=-100
  trades=-100}
  
  enter_1=rbind(enter_1,enter_d)
  exit_1=rbind(exit_1,exit_d)
  av_ret=rbind(av_ret,avrt)
  trade_N=rbind(trade_N,trades)
  hp=rbind(hp,hp_1)
  winp=rbind(winp,winp_1)
  last_exit=rbind(last_exit,lastexit)
  last_enter=rbind(last_enter,lastenter)
  
}
output <- data.frame(enter_disp,exit_disp,av_ret,stdev,trade_N,hp,winp,last_exit,last_enter)
write.csv (output, file ="output3.csv")


# enter_disp=as.vector(seq(0.05,0.2,by=0.05))
# exit_disp=as.vector(rep(-1,times=4))
# enter=NULL
# exit=NULL
# for (a in 1:4){
#   e=enter_disp[a]
#   d=exit_disp[a]
#   enter=rbind(enter,e)
#   exit=rbind(exit,d)
#   }