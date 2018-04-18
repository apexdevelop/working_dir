%Post pair identification, Punit Pujara 09/15/03
%file input needs all data filled

%key inputs
startdate=2200;
tradetime=90;
nooftimes=6;
intialreg=365;
deviate=2;
cover=1;

clc;
clear u;
clear main;
clear bigprice;
clear bigtrade;
clear summary;
clear summarytrade;

main(:,1)=FNM(startdate:startdate-1+tradetime*nooftimes+intialreg,1);
main(:,2)=FRE(startdate:startdate-1+tradetime*nooftimes+intialreg,1);
clear trades;
clear price;
clear y;

for bigone=1:(size(main,1)-intialreg-mod(size(main,1)-intialreg,tradetime))/tradetime

clear trades;
clear price;
clear u;
clear y;

u(:,:)=main(tradetime*(bigone-1)+1:tradetime*(bigone-1)+intialreg+tradetime,:);
trades=[0 0 0 0 -1];

for j=1:size(u,2)
    price(1,j)=1;
    
    for i=2:intialreg-2
        y(i,j)=(u(i,j)-u(i-1,j))/u(i-1,j); %rtn
        price(i,j)=price(i-1,j)*(1+y(i,j));
    end
end
results=ols(y(:,1),y(:,2));
summary(bigone,1)=results.rsqr;
summary(bigone,3)=results.beta;

%difference std dev calcuation


for j=1:size(u,2)
    price(intialreg-1,j)=1;
    for i=intialreg:size(u,1)
        y(i,j)=(u(i,j)-u(i-1,j))/u(i-1,j); %rtn
        price(i,j)=price(i-1,j)*(1+y(i,j));
    end
end

results=ols(y(intialreg:end,1),y(intialreg:end,2));
summary(bigone,2)=results.rsqr;
summary(bigone,4)=results.beta;


price(:,3)=price(:,1)-price(:,2);
diffsd=std(price(1:intialreg,3))*sqrt(tradetime/intialreg);
price(:,4)=deviate*diffsd;
price(:,5)=-deviate*diffsd;

tradeswitch=0;
rtnseries=10000;

for i=intialreg:size(price,1)
   ctr=ctr+1;
   
       %when long y
       if tradeswitch==1 & (price(i,1)>=price(i,2) | i==size(price,1));
           shares=price(tradedate,2)/price(tradedate,1);   
           trades(tradedate,1)=(price(tradedate,2)-price(i,2))*shares;%gain from short position
           trades(tradedate,2)=-price(tradedate,1)+price(i,1);%gain from long position           
           trades(tradedate,3)=trades(tradedate,1)+trades(tradedate,2);
           trades(tradedate,4)=tradedate;
           trades(tradedate,5)=i-tradedate;
           rtnseries=rtnseries+rtnseries*trades(tradedate,3);
           tradeswitch=0;
       elseif tradeswitch==-1 & (price(i,1)<=price(i,2) | i==size(price,1));
           shares=price(tradedate,2)/price(tradedate,1);   
           trades(tradedate,1)=(-price(tradedate,2)+price(i,2))*shares;%gain from long position
           trades(tradedate,2)=price(tradedate,1)-price(i,1);%gain from short position           
           trades(tradedate,3)=trades(tradedate,1)+trades(tradedate,2);
           trades(tradedate,4)=tradedate;
           trades(tradedate,5)=i-tradedate;
           rtnseries=rtnseries+rtnseries*trades(tradedate,3);
           tradeswitch=0;
       end 
   
    if tradeswitch==0;
       if price(i,3)>deviate*diffsd;
           %short y long x
           tradeswitch=-1;
           tradedate=i;
       elseif price(i,3)<-deviate*diffsd;
           %y short x
           tradeswitch=1;
           tradedate=i;
       end
   end
   

   
end   
%bigends know
    if bigone==1 
    bigprice=[price(end-tradetime+1:end,:)];
    
        if size(trades,1)>1
        bigtrade=[trades(end-tradetime+1:end,:)];
        else
        bigtrade=[trades(1:end,:)];
        end
        
    elseif size(trades,1)>1
    bigprice=[bigprice; price(end-tradetime+1:end,:)];
    bigtrade=[bigtrade;trades(end-tradetime+1:end,:)];
    end
    
summarytrade(bigone,1)=sum(bigtrade(:,3));

end
sum(bigtrade(:,3))/nooftimes
figure(1)
subplot(2,2,1), plot(bigtrade(:,3)), subplot(2,2,2), plot(bigprice(:,1:2)), subplot(2,2,3), plot(summary(:,1:2)), subplot(2,2,4), plot(summarytrade) 
figure(2)

for i=1:nooftimes
    numberg=nooftimes-mod(nooftimes,2);
    subplot(numberg-1,numberg,i),plot(bigprice(i*tradetime-tradetime+1:i*tradetime,:));
end
