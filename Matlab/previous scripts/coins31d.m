band=1.5;
start=1;
s=250;
last=start+s;
clear summ1;
clear summary;

r=1;  
tottrade=0;

y=size(num,2);

for i = 1:y-1
    
    
tday1=txt(start+4:last+4, i); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
adjcls1=num(start:last, i); %ppp the last column contains the adjusted close prices.


for j=i+1:y
 tday2=txt(start+4:last+4, j); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
adjcls2=num(start:last, j); % PPP


tday=union(tday1, tday2); % find all the days when either GLD or GDX has data.
[foo idx idx1]=intersect(tday, tday1);
adjcls=NaN(length(tday), 2); % combining the two price series
adjcls(idx, 1)=adjcls1(idx1);
[foo idx idx2]=intersect(tday, tday2);
adjcls(idx, 2)=adjcls2(idx2);
baddata=find(any(~isfinite(adjcls), 2)); % days where any one price is missing
tday(baddata)=[];
adjcls(baddata, :)=[];

vnames=strvcat('GLD', 'GDX');

res=cadf(adjcls(:, 1), adjcls(:, 2), 0, 2); % run cointegration check using augmented Dickey-Fuller test

% prt(res, vnames); 

clear tempcls;
tempcls(:,2)=adjcls(:,2);
tempcls(:,1)=1;
results=ols(adjcls(:, 1), tempcls(:,1:2)); 
%results=ols(adjcls(:, 1), adjcls(:,2)); 
hedgeRatio=results.beta(2);
%hedgeRatio=results.beta;

z=results.resid;
rtnres = olsrtn(adjcls(:, 1), adjcls(:, 2));

%output(r,1)= i; output(r,2)= j; output(r,3)= res.adf ; output(r,4)= results.beta; output(r,5)=results.rsqr;

% A hedgeRatio of 1.6766 was found. I.e. GLD=1.6766*GDX + z, where z can be interpreted as the
% spread GLD-1.6766*GDX and should be stationary.

zscr = (z(:,1)-mean(z))/std(z);
recs=size(adjcls,1);
% Cross zero calcu
cross=0;
for ctr=2:recs
   if (zscr(ctr-1,1) > 0 && zscr(ctr,1) < 0)
       cross=cross+1; 
   elseif (zscr(ctr-1,1)<0 && zscr(ctr,1) >0)
       cross=cross+1;
   end
       
end

beta=hedgeRatio*adjcls(end,2)/adjcls(end,1);

if cross > 3 && res.adf<-2.5 && beta > 0.3 && beta < 3 
  pnlcalc; % ADDDDEDDDED 
  
summary(r,1)=i;
summary(r,2)=j;
summary(r,7)=buy+sells; %no  of trades
summary(r,3)=buydollar+selldollar; % Dollar P&L
summary(r,4)=summary(r,3)/summary(r,7); % Average P&L
summary(r,5)=daymkt/summary(r,7);
summary(r,6)= win/summary(r,7);



summary(r,8)=abs((z(recs,1)/adjcls(recs,1)*100)/zscr(recs)); 
summary(r,9)=beta;
summary(r,10)=hedgeRatio;
summary(r,11)=res.adf;
summary(r,12)=cross;
summary(r,13)=results.rsqr;
summary(r,15)=zscr(recs);
summary(r,14)=rtnres.rsqr;
r=r+1;
end

subplot(2,1,1); plot(log(adjcls))
test=zscr;
test(:,2)=band;
test(:,3)=-1*band;
test(:,4)=0;
subplot(2,1,2); plot(test)

 end
j=j+1;

end
i=i+1;
summ1=sortrows(summary,-15);

% plot(z); % This should produce a chart similar to 
