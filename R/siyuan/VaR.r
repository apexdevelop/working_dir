setwd("E:/Apex/project2")
mydata = read.csv("perf_data.csv", stringsAsFactors=F)
date=as.Date(mydata[,1],"%m/%d/%Y")
# date1=strptime(mydata[!is.na(mydata[,2]),1],"%m/%d/%Y")
rt=mydata[,2]
HFRIEM=mydata[,5]
HFRIAWJ=mydata[,6]
HFRIEMNI=mydata[,7]
HFRIFWI=mydata[,8]
MXAP=mydata[,9]
count=dim(mydata)[1]
zscore=NULL
zscore=scale(rt[1:19],center=T,scale=T)

corr1=NULL
corr2=NULL
corr3=NULL
corr4=NULL
corr5=NULL
co1=cor(rt[1:19],HFRIEM[1:19])
co2=cor(rt[1:19],HFRIAWJ[1:19])
co3=cor(rt[1:19],HFRIEMNI[1:19])
co4=cor(rt[1:19],HFRIFWI[1:19])
co5=cor(rt[1:19],MXAP[1:19])
corr1=matrix(co1,nrow=19,ncol=1)
corr2=matrix(co2,nrow=19,ncol=1)
corr3=matrix(co3,nrow=19,ncol=1)
corr4=matrix(co4,nrow=19,ncol=1)
corr5=matrix(co5,nrow=19,ncol=1)
for (i in 1:count){
  cor1=cor(rt[i:(20+i)],HFRIEM[i:(20+i)])
  cor2=cor(rt[i:(20+i)],HFRIAWJ[i:(20+i)])
  cor3=cor(rt[i:(20+i)],HFRIEMNI[i:(20+i)])
  cor4=cor(rt[i:(20+i)],HFRIFWI[i:(20+i)])
  cor5=cor(rt[i:(20+i)],MXAP[i:(20+i)])
  corr1=rbind(corr1,cor1)
  corr2=rbind(corr2,cor2)
  corr3=rbind(corr3,cor3)
  corr4=rbind(corr4,cor4)
  corr5=rbind(corr5,cor5)
}
corr_1=as.matrix(as.vector(corr1))
corr_2=as.matrix(as.vector(corr2))
corr_3=as.matrix(as.vector(corr3))
corr_4=as.matrix(as.vector(corr4))
corr_5=as.matrix(as.vector(corr5))
VaR1=NULL
VaR2=NULL
VaR3=NULL
VaR4=NULL
VaR5=NULL
for (i in 1:19){
  VaR1[i]=(mean(rt[1:19])-corr_1[i]*zscore[i])*100
  VaR2[i]=(mean(rt[1:19])-corr_2[i]*zscore[i])*100
  VaR3[i]=(mean(rt[1:19])-corr_3[i]*zscore[i])*100
  VaR4[i]=(mean(rt[1:19])-corr_4[i]*zscore[i])*100
  VaR5[i]=(mean(rt[1:19])-corr_5[i]*zscore[i])*100
}

HFEM_var=NULL
HFAWJ_var=NULL
HFEMNI_var=NULL
HFFWI_var=NULL
MXA_var=NULL
HFEM_var=matrix(VaR1,nrow=19,ncol=1)
HFAWJ_var=matrix(VaR2,nrow=19,ncol=1)
HFEMNI_var=matrix(VaR3,nrow=19,ncol=1)
HFFWI_var=matrix(VaR4,nrow=19,ncol=1)
MXA_var=matrix(VaR5,nrow=19,ncol=1)
for (j in 1:count){
  cor1=cor(rt[j:(20+j)],HFRIEM[j:(20+j)])
  cor2=cor(rt[j:(20+j)],HFRIAWJ[j:(20+j)])
  cor3=cor(rt[j:(20+j)],HFRIEMNI[j:(20+j)])
  cor4=cor(rt[j:(20+j)],HFRIFWI[j:(20+j)])
  cor5=cor(rt[j:(20+j)],MXAP[j:(20+j)])
  avr=mean(rt[j:(20+j)])
  sd=sd(rt[j:(20+j)])
  zs=(rt[j]-avr)/sd
  HFEM=(avr-cor1*zs)*100
  HFAWJ=(avr-cor2*zs)*100
  HFEMNI=(avr-cor3*zs)*100
  HFFWI=(avr-cor4*zs)*100
  MXA=(avr-cor5*zs)*100
  HFEM_var=rbind(HFEM_var,HFEM)
  HFAWJ_var=rbind(HFAWJ_var,HFAWJ)
  HFEMNI_var=rbind(HFEMNI_var,HFEMNI)
  HFFWI_var=rbind(HFFWI_var,HFFWI)
  MXA_var=rbind(MXA_var,MXA)
  }
HFRIEM_var=as.matrix(as.vector(HFEM_var))
HFRIAWJ_var=as.matrix(as.vector(HFAWJ_var))
HFRIEMNI_var=as.matrix(as.vector(HFEMNI_var))
HFRIFWI_var=as.matrix(as.vector(HFFWI_var))
MXAP_var=as.matrix(as.vector(MXA_var))

HFRIEM_var=HFRIEM_var[!is.na(HFRIEM_var)]
HFRIAWJ_var=HFRIAWJ_var[!is.na(HFRIAWJ_var)]
HFRIEMNI_var=HFRIEMNI_var[!is.na(HFRIEMNI_var)]
HFRIFWI_var=HFRIFWI_var[!is.na(HFRIFWI_var)]
MXAP_var=MXAP_var[!is.na(MXAP_var)]

dataframe <- data.frame(HFRIEM_var,HFRIAWJ_var,HFRIEMNI_var,HFRIFWI_var,MXAP_var)
# dataframe <- dataframe[!is.na(dataframe)]
write.csv(dataframe, "VaR.csv")


