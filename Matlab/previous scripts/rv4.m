x=sonsqqq(1:end,2:3);
a=sonsqqq(1:end,4:5)/100;
clc;


daysregress=60;
startpoint=daysregress+60;
boundregress=25;
stepbound=5;
impterm=boundregress;
bidask=.025;
fudgefactor=0.00;
vega=100000;

clear variance;
clear bet;
clear bet2;
clear volgain;
clear trades;
clear trades2;
clear y;
clear variance2;
clear volterms;

hit=0;
hit2=0;

for j=1:size(x,2)
    for i=2:size(x,1)
        y(i-1,j)=log(x(i,j))-log(x(i-1,j));
    end
end



% base forecasting regression and imp filling realized calc
for i=startpoint:size(y,1)
   results=ols(y(i-daysregress+1:i,1),y(i-daysregress+1:i,2));
   bet(i,1)=results.beta;
   variance(i,1)=a(i+1,1)^2;
   variance(i,2)=a(i+1,2)^2;
   variance(i,6)=var(y(i-impterm+1:i,1))*250;
   variance(i,7)=var(y(i-impterm+1:i,2))*250;
   volterms(i,1)=sqrt(variance(i,6));
   volterms(i,3)=sqrt(variance(i,7));
   volterms(i,2)=a(i+1,1);
   volterms(i,4)=a(i+1,2);
end



% regressions for boundries
for i=boundregress:size(y,1)
   results=ols(y(i-boundregress+1:i,1),y(i-boundregress+1:i,2));
   bet2(i,1)=results.beta;
   variance2(i,1)=var(results.resid)*250;
   variance2(i,2)=sqrt(variance2(i,1));
end

% beta changes
for i=boundregress+1:size(bet2,1)
    bet2(i,2)=bet2(i,1)/bet2(i-1,1)-1;
end

% calculate boundaries
for i=startpoint:size(bet)
    bet(i,2)=bet(i,1)*(1+max(bet2(i+boundregress-1:i,2)));
    bet(i,3)=bet(i,1)*(1+min(bet2(i+1:startpoint-boundregress+i,2)));
    variance(i,3)=bet(i,2)^2*variance(i,2)+max(variance2(i+1:startpoint-boundregress+i,1));
    variance(i,4)=bet(i,3)^2*variance(i,2)+min(variance2(i+1:startpoint-boundregress+i,1));

    %indpendent is expensive
    if variance(i,1)>variance(i,3)+bidask^2+fudgefactor 
        hit=hit+1;
        variance(i,5)=(variance(i,1)-variance(i,3))^0.5-bidask;
        
        if i<size(variance,1)-impterm
        trades(i,1)=st2(x(startpoint+i,1),x(startpoint+i,1),sqrt(variance(i,1))-bidask/2,0.015,0,0.0833);
        trades(i,2)=st2(x(startpoint+i,2),x(startpoint+i,2),sqrt(variance(i,2))+bidask/2,0.015,0,0.0833);
        trades(i,3)=round(x(startpoint+i,2)/x(startpoint+i,1));
        trades(i,4)=round(bet(i,1));
        trades(i,5)=trades(i,1)*trades(i,3);
        trades(i,6)=trades(i,2)*trades(i,4);
        trades2(i,1)=trades(i,4)*abs(x(startpoint+i,2)-x(startpoint+i+25,2))-trades(i,3)*abs(x(startpoint+i,1)-x(startpoint+i+25,1))-trades(i,5)+trades(i,6);
        trades2(i,2)=-(trades(i,3)+trades(i,4))/100;
        trades2(i,3)=trades2(i,1)+trades2(i,2);
        trades2(i,4)=trades(i,6)-trades(i,5);
        trades2(i,5)=-1;
        trades2(i,6)=bet(i,2)^2-bet(i+25,1)^2; %if plus then beta forcast was good
        trades2(i,7)=variance(i,3)-variance2(startpoint+i,1); %if plus then idsy forecast was good
        volgain(i,1)=variance(i,1)-variance(i+impterm,6)-bet(i,2)^2*(variance(i,2)-variance(i+impterm,7));
        volgain(i,3)=trades2(i,6)*variance(i+impterm,7); %volgain because of beta
        volgain(i,4)=max(variance2(i+1:startpoint-boundregress+i,1))-variance2(startpoint+i,1);%volgain because of idsy
        volgain(i,5)=bet2(startpoint+i,1)^2*variance(i+impterm,7)+variance2(startpoint+i,1)-variance(i+impterm,6);
        if volgain(i,1)>0
            volgain(i,2)=vega*sqrt(volgain(i,1));
            else
            volgain(i,2)=-1*vega*sqrt(abs(volgain(i,1)));
            end
            
        end
    
    end 
   
    %indpendent is cheap
    if variance(i,1)+bidask^2+fudgefactor<variance(i,4)     
       hit2=hit+1;
       variance(i,5)=(variance(i,4)-variance(i,1))^0.5-bidask;
     
       
       if i<size(variance,1)-impterm
       trades(i,1)=st2(x(startpoint+i,1),x(startpoint+i,1),sqrt(variance(i,1))+bidask/2,0.015,0,0.0833);
       trades(i,2)=st2(x(startpoint+i,2),x(startpoint+i,2),sqrt(variance(i,2))-bidask/2,0.015,0,0.0833);
       trades(i,3)=round(x(startpoint+i,2)/x(startpoint+i,1));
       trades(i,4)=round(bet(i,1));
       trades(i,5)=trades(i,1)*trades(i,3);
       trades(i,6)=trades(i,2)*trades(i,4);
       trades2(i,1)=-trades(i,4)*abs(x(startpoint+i,2)-x(startpoint+i+25,2))+trades(i,3)*abs(x(startpoint+i,1)-x(startpoint+i+25,1))+trades(i,5)-trades(i,6);
       trades2(i,2)=-(trades(i,3)+trades(i,4))/100;
       trades2(i,3)=trades2(i,1)+trades2(i,2);
       trades2(i,4)=trades(i,5)-trades(i,6);
       trades2(i,5)=1;
       trades2(i,6)=-bet(i,3)^2+bet(i+25,1)^2; %if plus then beta forcast was good
       trades2(i,7)=-variance(i,4)+variance2(startpoint+i,1); %if plus then idsy forecast was good
       volgain(i,1)=-variance(i,1)+variance(i+impterm,6)+bet(i,3)^2*(variance(i,2)-variance(i+impterm,7));
       volgain(i,3)=trades2(i,6)^2*variance(i,2); %volgain because of beta
       volgain(i,4)=-min(variance2(i+1:startpoint-boundregress+i,1))+variance2(startpoint+i,1);%volgain because of idsy
       volgain(i,5)=bet2(startpoint+i,1)^2*variance(i+impterm,7)+variance2(startpoint+i,1)-variance(i+impterm,6);
           if volgain(i,1)>0
            volgain(i,2)=vega*sqrt(volgain(i,1));
            else
            volgain(i,2)=-1*vega*sqrt(abs(volgain(i,1)));
            end
       end

           
   end
   

      
end

%realized volgain
subplot(3,3,1), plot(volgain(:,2)), subplot(3,3,2), plot(volgain(:,3)) 
subplot(3,3,3),plot(trades2(:,3)),subplot(3,3,4),plot(variance2(:,2))
subplot(3,3,5),plot(volgain(:,4)),subplot(3,3,6),plot(bet)
subplot(3,3,7),plot(volgain(:,5)),subplot(3,3,8),plot(trades2(:,7))

avgvolgain=sum(trades2(:,3))/sum(trades2(:,4))*100
avgvolgain2=sum(trades2(:,3))/(sum(trades(:,5))+sum(trades(:,6)))*100