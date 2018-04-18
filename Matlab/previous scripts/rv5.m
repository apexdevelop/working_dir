x=cbkx(end-1000:end-500,1:2);
a=cbkximp(end-1000:end-500,1:2)/100;
clc;


daysregress=120;
startpoint=daysregress+100;
boundregress=120;
stepbound=5;
impterm=25;
bidask=.025;
fudgefactor=0.00;
vega=100000;
cibet=2;
ciidsy=3;

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
% calculate the returns here
for j=1:size(x,2)
    for i=2:size(x,1)
        y(i-1,j)=log(x(i,j))-log(x(i-1,j));
    end
end



% base forecasting regression and imp filling realized calc
for i=startpoint:size(y,1)
    % i=120:349, except last 60 days of y
   results=ols(y(i-daysregress+1:i,1),y(i-daysregress+1:i,2));
    %ols(y(61:120)
   bet(i,1)=results.beta;
   % as a start take the implied variance of 121. i.e today implied as today
   variance(i,1)=a(i+1,1)^2;
   variance(i,2)=a(i+1,2)^2;
   % take the realized variance 96:120
   variance(i,6)=var(y(i-impterm+1:i,1))*250;
   % realized variance of last 25 days stored today
   variance(i,7)=var(y(i-impterm+1:i,2))*250;
   volterms(i,1)=sqrt(variance(i,6));
   volterms(i,3)=sqrt(variance(i,7));
   volterms(i,2)=a(i+1,1);
   volterms(i,4)=a(i+1,2);
end



% regressions for boundries identification of idsy
for i=boundregress:size(y,1)
    %25:350
   results=ols(y(i-boundregress+1:i,1),y(i-boundregress+1:i,2));
    % y(1:25)
   bet2(i,1)=results.beta;
   variance2(i,1)=var(results.resid)*250;
   variance2(i,2)=sqrt(variance2(i,1));
end

% beta changes
for i=boundregress+1:size(bet2,1)
    % 2:326
    bet2(i,2)=bet2(i,1)/bet2(i-1,1)-1;
end

% calculate boundaries
for i=startpoint:size(bet)
    % 120:350
    %bet(i,2)=bet(i,1)*(1+max(bet2(i-startpoint+boundregress+1:i,2)));
    %bet(120)=bet2(61:120)
    %bet(i,3)=bet(i,1)*(1+min(bet2(i-startpoint+boundregress+1:i,2)));
    
    bet(i,2)=bet(i,1)+cibet*std(bet2(i-startpoint+boundregress+1:i,1));
    bet(i,3)=bet(i,1)-cibet*std(bet2(i-startpoint+boundregress+1:i,1));;
    
    variance2(i,3)=ciidsy*std(variance2(i-startpoint+boundregress:i,1))+mean(variance2(i-startpoint+boundregress:i,1));
    variance2(i,4)=-ciidsy*std(variance2(i-startpoint+boundregress:i,1))+mean(variance2(i-startpoint+boundregress:i,1));
    variance(i,3)=bet(i,2)^2*variance(i,2)+variance2(i,3);
    variance(i,4)=bet(i,3)^2*variance(i,2)+variance2(i,4);

    %Citi is expensive
    if variance(i,1)>variance(i,3)+bidask^2+fudgefactor 
        hit=hit+1;
        % measuring the level of expensiveness
        variance(i,5)=(variance(i,1)-variance(i,3))^0.5-bidask;
        
        if i<size(variance,1)-impterm
        trades(i,1)=st2(x(i+1,1),x(i+1,1),sqrt(variance(i,1))-bidask/2,0.015,0,0.0833);
        trades(i,2)=st2(x(i+1,2),x(i+1,2),sqrt(variance(i,2))+bidask/2,0.015,0,0.0833);
        trades(i,3)=round(x(i+1,2)/x(i+1,1));
        trades(i,4)=round(bet(i,1));
        trades(i,5)=trades(i,1)*trades(i,3);
        trades(i,6)=trades(i,2)*trades(i,4);
        % go short citi and long bkx
        trades2(i,1)=trades(i,4)*abs(x(i+1,2)-x(i+1+25,2))-trades(i,3)*abs(x(i+1,1)-x(i+1+25,1))-trades(i,5)+trades(i,6);
        % trading cost per share
        trades2(i,2)=-(trades(i,3)+trades(i,4))/100;
        trades2(i,3)=trades2(i,1)+trades2(i,2);
        % intial investment
        trades2(i,4)=trades(i,6)-trades(i,5);
        trades2(i,5)=-1;
        trades2(i,6)=bet(i,2)^2-bet2(i+impterm,1)^2; %if plus then beta forcast was good
        trades2(i,7)=variance2(i,3)-variance2(i+impterm,1); %if plus then idsy forecast was good
        volgain(i,1)=variance(i,1)-variance(i+impterm,6)-bet(i,2)^2*(variance(i,2)-variance(i+impterm,7));
        volgain(i,3)=trades2(i,6)^2*(variance(i+impterm,7)-variance(i+impterm,6)); %volgain because of beta
        volgain(i,4)=trades2(i,7);%volgain because of idsy
        %volgain(i,5)=bet2(startpoint+i,1)^2*variance(i+impterm,7)+variance2(startpoint+i,1)-variance(i+impterm,6);
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
       trades(i,1)=st2(x(i+1,1),x(i+1,1),sqrt(variance(i,1))+bidask/2,0.015,0,0.0833);
       trades(i,2)=st2(x(i+1,2),x(i+1,2),sqrt(variance(i,2))-bidask/2,0.015,0,0.0833);
       trades(i,3)=round(x(i+1,2)/x(i+1,1));
       trades(i,4)=round(bet(i,1));
       trades(i,5)=trades(i,1)*trades(i,3);
       trades(i,6)=trades(i,2)*trades(i,4);
       trades2(i,1)=-trades(i,4)*abs(x(i+1,2)-x(i+1+25,2))+trades(i,3)*abs(x(i+1,1)-x(i+1+25,1))+trades(i,5)-trades(i,6);
       trades2(i,2)=-(trades(i,3)+trades(i,4))/100;
       trades2(i,3)=trades2(i,1)+trades2(i,2);
       trades2(i,4)=trades(i,5)-trades(i,6);
       trades2(i,5)=1;
       trades2(i,6)=-bet(i,3)^2+bet2(i+impterm,1)^2; %if plus then beta forcast was good
       trades2(i,7)=-variance2(i,4)+variance2(i+impterm,1); %if plus then idsy forecast was good
       volgain(i,1)=-variance(i,1)+variance(i+impterm,6)+bet(i,3)^2*(variance(i,2)-variance(i+impterm,7));
       volgain(i,3)=trades2(i,6)^2*(variance(i+impterm,7)-variance(i+impterm,6)); %volgain because of beta
       volgain(i,4)=trades2(i,7);%volgain because of idsy
       %volgain(i,5)=bet2(startpoint+i,1)^2*variance(i+impterm,7)+variance2(startpoint+i,1)-variance(i+impterm,6);
           if volgain(i,1)>0
            volgain(i,2)=vega*sqrt(volgain(i,1));
            else
            volgain(i,2)=-1*vega*sqrt(abs(volgain(i,1)));
            end
       end
           
   end
   

      
end

% reports

for i=startpoint:size(bet2,1)-impterm
    %120:225
    bet(i,4)=bet2(i+impterm,1);
    idsy(i,1)=variance2(i+impterm,1);
    idsy(i,2)=variance2(i,3);
    idsy(i,3)=variance2(i,4);
end

%realized volgain
subplot(2,3,1), plot(bet(startpoint:end-impterm,2:4)), subplot(2,3,2),plot(idsy(startpoint:end,1:3))  
subplot(2,3,3),plot(trades2(startpoint:end,6)), subplot(2,3,4),plot(trades2(startpoint:end,7)) 
subplot(2,3,5), plot(volgain(startpoint:end,3)), subplot(2,3,6),plot(trades2(startpoint:end,3))


avgvolgain2=sum(trades2(:,3))/((sum(trades(:,5))+sum(trades(:,6)))/2)*250/(size(x,1)-startpoint)*100