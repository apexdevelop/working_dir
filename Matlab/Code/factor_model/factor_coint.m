function [new_date new_res]=factor_coint(i,dates1,dates2,dates3,prices1,prices2,prices3)

date1=dates1(:,i+1);
zeroind1=find(~date1);
date1(zeroind1)=[];
price1=prices1(:,i+1);

date2=dates2(:,i+1);
zeroind2=find(~date2);
date2(zeroind2)=[];
price2=prices2(:,i+1);

[~, idx1 idx2]=intersect(date1, date2);   
tmpprice1=price1(idx1);
tmpprice2=price2(idx2);
    
comdate1=date1(idx1);  

date3=dates3(:,i+1);
zeroind3= find(~date3);
date3(zeroind3)=[];
price3=prices3(:,i+1);
    
[~, comidx2, idx3]=intersect(comdate1, date3);   
fprice1=tmpprice1(comidx2);
fprice2=tmpprice2(comidx2);
fprice3=price3(idx3);
comdate2=comdate1(comidx2);

nprice1=(fprice1-mean(fprice1))/std(fprice1);
nprice2=(fprice2-mean(fprice2))/std(fprice2);
nprice3=(fprice3-mean(fprice3))/std(fprice3);
Y=[nprice1 nprice2 nprice3];
% [beta1,bint1,r1,rint1,stats1]=regress(nprice1,[ones(size(Y,1),1) Y(:,2:3)]);
% egci_ccn;
new_res=vec(Y);
new_date=comdate2(4:end);
% end
