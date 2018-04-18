#setwd("E:/Apex/project2")
mydata = read.csv("perf_data.csv", stringsAsFactors=F)
test_avg=sapply(mydata[,2:9],mean)
test_avg1=lapply(mydata[,2:9],mean)
date=as.Date(mydata[,1],"%m/%d/%Y")
# date1=strptime(mydata[!is.na(mydata[,2]),1],"%m/%d/%Y")
rt=mydata[,2]
rt_1=mydata[,3]
Downside=mydata[,4]
HFRIEM=mydata[,5]
HFRIAWJ=mydata[,6]
HFRIEMNI=mydata[,7]
HFRIFWI=mydata[,8]
MXAP=mydata[,9]
count=dim(mydata)[1]
market=rbind('APEXGCE','HFRIEM','HFRIAWJ','HFRIEMNI','HFRIFWI','MXAP')

avg=mean(rt)
avg1=mean(HFRIEM)
avg2=mean(HFRIAWJ)
avg3=mean(HFRIEMNI)
avg4=mean(HFRIFWI)
avg5=mean(MXAP)

rd_1=NULL
rd_2=NULL
rd_3=NULL
rd_4=NULL
rd_5=NULL
for (i in 2:count){
  rd_1[i]=rt[i]-HFRIEM[i]
}
ret=mean(rt)-mean(HFRIEM)
IR_1=ret/sd(rd_1[2:count])

for (i in 2:count){
  rd_2[i]=rt[i]-HFRIAWJ[i]
}
ret=mean(rt)-mean(HFRIAWJ)
IR_2=ret/sd(rd_2[2:count])

for (i in 2:count){
  rd_3[i]=rt[i]-HFRIEMNI[i]
}
ret=mean(rt)-mean(HFRIEMNI)
IR_3=ret/sd(rd_3[2:count])

for (i in 2:count){
  rd_4[i]=rt[i]-HFRIFWI[i]
}
ret=mean(rt)-mean(HFRIFWI)
IR_4=ret/sd(rd_4[2:count])

for (i in 2:count){
  rd_5[i]=rt[i]-MXAP[i]
}
ret=mean(rt)-mean(MXAP)
IR_5=ret/sd(rd_5[2:count])
Information_Ratio=rbind(0,IR_1,IR_2,IR_3,IR_4,IR_5)

rtp=rt[which(rt>0)]
rtn=rt[which(rt<=0)]
rt_pos=mean(rtp)
rt_neg=mean(rtn)
fr=pnorm(0,avg,sd(rtn))
omega=((1-fr)/fr)*((rt_pos-0)/(0-rt_neg))
omega_test=sum(rtp)/abs(sum(rtn))

rtp1=HFRIEM[which(HFRIEM>0)]
rtn1=HFRIEM[which(HFRIEM<=0)]
rt_pos1=mean(rtp1)
rt_neg1=mean(rtn1)
fr1=pnorm(0,rt_neg1,sd(rtn1))
omega1=((1-fr1)/fr1)*((rt_pos1-0)/(0-rt_neg1))

rtp2=HFRIAWJ[which(HFRIAWJ>0)]
rtn2=HFRIAWJ[which(HFRIAWJ<=0)]
rt_pos2=mean(rtp2)
rt_neg2=mean(rtn2)
fr2=pnorm(0,rt_neg2,sd(rtn2))
omega2=((1-fr2)/fr2)*((rt_pos2-0)/(0-rt_neg2))

rtp3=HFRIEMNI[which(HFRIEMNI>0)]
rtn3=HFRIEMNI[which(HFRIEMNI<=0)]
rt_pos3=mean(rtp3)
rt_neg3=mean(rtn3)
fr3=pnorm(0,rt_neg3,sd(rtn3))
omega3=((1-fr3)/fr3)*((rt_pos3-0)/(0-rt_neg3))

rtp4=HFRIFWI[which(HFRIFWI>0)]
rtn4=HFRIFWI[which(HFRIFWI<=0)]
rt_pos4=mean(rtp4)
rt_neg4=mean(rtn4)
fr4=pnorm(0,rt_neg4,sd(rtn4))
omega4=((1-fr4)/fr4)*((rt_pos4-0)/(0-rt_neg4))

rtp5=MXAP[which(MXAP>0)]
rtn5=MXAP[which(MXAP<=0)]
rt_pos5=mean(rtp5)
rt_neg5=mean(rtn5)
fr5=pnorm(0,rt_neg5,sd(rtn5))
omega5=((1-fr5)/fr5)*((rt_pos5-0)/(0-rt_neg5))
Omega=rbind(omega,omega1,omega2,omega3,omega4,omega5)

dr=sd(rt[which(rt<0)])
dr1=sd(HFRIAWJ[which(HFRIAWJ<=0)])
dr2=sd(HFRIAWJ[which(HFRIAWJ<=0)])
dr3=sd(HFRIEMNI[which(HFRIEMNI<=0)])
dr4=sd(HFRIFWI[which(HFRIFWI<=0)])
dr5=sd(MXAP[which(MXAP<=0)])
SOR1=(avg-avg1)/dr1
SOR2=(avg-avg2)/dr2
SOR3=(avg-avg3)/dr3
SOR4=(avg-avg4)/dr4
SOR5=(avg-avg5)/dr5
Sortino_Ratio=rbind(0,SOR1,SOR2,SOR3,SOR4,SOR5)

max_d1=min(rt[3:6])
max_d2=min(rt[7:18])
max_d3=min(rt[19:30])
max_d4=min(rt[31:42])
max_d5=min(rt[43:54])
max_d6=min(rt[55:61])
maxd=mean(max_d1,max_d2,max_d3,max_d4,max_d5,max_d6)
car=(abs(rt[3]/rt[count])^(1/5))-1
ste=car/abs(maxd-0.1)

max_d1.1=min(HFRIEM[3:6])
max_d1.2=min(HFRIEM[7:18])
max_d1.3=min(HFRIEM[19:30])
max_d1.4=min(HFRIEM[31:42])
max_d1.5=min(HFRIEM[43:54])
max_d1.6=min(HFRIEM[55:61])
maxd1=mean(max_d1.1,max_d1.2,max_d1.3,max_d1.4,max_d1.5,max_d1.6)
car1=(abs(HFRIEM[3]/HFRIEM[count])^(1/5))-1
ste1=car1/abs(maxd1-0.1)

max_d2.1=min(HFRIAWJ[3:6])
max_d2.2=min(HFRIAWJ[7:18])
max_d2.3=min(HFRIAWJ[19:30])
max_d2.4=min(HFRIAWJ[31:42])
max_d2.5=min(HFRIAWJ[43:54])
max_d2.6=min(HFRIAWJ[55:61])
maxd2=mean(max_d2.1,max_d2.2,max_d2.3,max_d2.4,max_d2.5,max_d2.6)
car2=(abs(HFRIAWJ[3]/HFRIAWJ[count])^(1/5))-1
ste2=car2/abs(maxd2-0.1)

max_d3.1=min(HFRIEMNI[3:6])
max_d3.2=min(HFRIEMNI[7:18])
max_d3.3=min(HFRIEMNI[19:30])
max_d3.4=min(HFRIEMNI[31:42])
max_d3.5=min(HFRIEMNI[43:54])
max_d3.6=min(HFRIEMNI[55:61])
maxd3=mean(max_d3.1,max_d3.2,max_d3.3,max_d3.4,max_d3.5,max_d3.6)
car3=(abs(HFRIEMNI[3]/HFRIEMNI[count])^(1/5))-1
ste3=car3/abs(maxd3-0.1)

max_d4.1=min(HFRIFWI[3:6])
max_d4.2=min(HFRIFWI[7:18])
max_d4.3=min(HFRIFWI[19:30])
max_d4.4=min(HFRIFWI[31:42])
max_d4.5=min(HFRIFWI[43:54])
max_d4.6=min(HFRIFWI[55:61])
maxd4=mean(max_d4.1,max_d4.2,max_d4.3,max_d4.4,max_d4.5,max_d4.6)
car4=(abs(HFRIFWI[3]/HFRIFWI[count])^(1/5))-1
ste4=car4/abs(maxd4-0.1)

max_d5.1=min(MXAP[3:6])
max_d5.2=min(MXAP[7:18])
max_d5.3=min(MXAP[19:30])
max_d5.4=min(MXAP[31:42])
max_d5.5=min(MXAP[43:54])
max_d5.6=min(MXAP[55:61])
maxd5=mean(max_d5.1,max_d5.2,max_d5.3,max_d5.4,max_d5.5,max_d5.6)
car5=(abs(MXAP[3]/MXAP[count])^(1/5))-1
ste5=car5/abs(maxd5-0.1)
Sterling_Ratio=rbind(ste,ste1,ste2,ste3,ste4,ste5)

beta1=cor(rt,HFRIEM)*(sd(rt)/sd(HFRIEM))
beta2=cor(rt,HFRIAWJ)*(sd(rt)/sd(HFRIAWJ))
beta3=cor(rt,HFRIEMNI)*(sd(rt)/sd(HFRIEMNI))
beta4=cor(rt,HFRIFWI)*(sd(rt)/sd(HFRIFWI))
beta5=cor(rt,MXAP)*(sd(rt)/sd(MXAP))
tr1=(avg-avg1)/beta1
tr2=(avg-avg2)/beta2
tr3=(avg-avg3)/beta3
tr4=(avg-avg4)/beta4
tr5=(avg-avg5)/beta5
Treynor_Ratio=rbind(0,tr1,tr2,tr3,tr4,tr5)

dataframe <- data.frame(market,Information_Ratio,Omega,Sortino_Ratio,Sterling_Ratio,Treynor_Ratio)
write.csv(dataframe,"ratios.csv",row.names = F,quote = F )
