%Post pair identification, Punit Pujara 09/15/03
%file input needs all data filled
clc;
clear u;
u(:,1)=f(1:500,25);
u(:,2   )=f(1:500,28);
clear stats;
clear coint;
clear uniroot;
clear y;
daysreg=365;
deviate=2;
cover=0;
shares=100;

width=size(u,2);

for j=1:size(u,2)
    for i=2:size(u,1)
        y(i,j)=(u(i,j)-u(i-1,j))/u(i-1,j);
    end
end

ctr=0

for i=daysreg:size(u,1)-10
       ctr=ctr+1;
       results=ols(y(i-daysreg+2:i,1),y(i-daysreg+2:i,2));
       stats(i,1)=results.beta;
       stats(i,2)=results.rsqr;
       stats(i,3)=results.sige
       stats(i,4)=results.resid(end,1);
       zscore(i,1)=stats(i,4)/results.sige;
end       

tradeswitch=0;
rtnseries=10000;

for i=daysreg:size(y,2)-1       
    
   if tradeswitch==1;
       %when long y
       if zscore(i,1)>=cover;
           trades(tradedate,1)=(u(tradedate,2)-u(i,2))*stats(tradedate,3);%gain from short position
           trades(tradedate,2)=-u(tradedate,1)+u(i,1)%gain from long position           
           trades(tradedate,3)=trades(tradedate,4)+trades(tradedate,5);
           trades(tradedate,4)=u(tradedate,1)-u(tradedate,2);
           trades(tradedate,5)=i-tradedate;
           trades(tradedate,6)=trades(tradedate,3)/trades(tradedate,4);
           rtnseries=rtnseries+rtnseries*trades(tradedate,6)
           tradeswitch=0;
       end
   end

   if trandeswitch==-1;
       if zscore(i,1)<=cover;
           trades(tradedate,1)=(-u(tradedate,2)+u(i,2))*stats(tradedate,3);%gain from long position
           trades(tradedate,2)=u(tradedate,1)-u(i,1)%gain from short position           
           trades(tradedate,3)=trades(tradedate,4)+trades(tradedate,5); %total gain
           trades(tradedate,4)=-u(tradedate,1)+u(tradedate,2); %total investment
           trades(tradedate,5)=i-tradedate;%days
           trades(tradedate,6)=trades(tradedate,3)/trades(tradedate,4); %rtn
           rtnseries=rtnseries+rtnseries*trades(tradedate,6)
           tradeswitch=0;
       end 
   end
   
    if tradeswitch==0;
       if zscore(i,1)>deviate;
           %short y long x
           tradeswitch=-1;
           tradedate=i;
       end
   
       if zscore(i,1)<-1*deviate;
           %y short x
           tradeswitch=1;
           tradedate=i;
       end
   end
   
end   

subplot(1,2,1), plot(uniroot(:,4)), subplot(1,2,2), plot(uniroot(:,1))