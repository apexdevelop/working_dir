 r=1;  
 tottrade=0;

y=(size(num,2)+1)/2;
band=1.5;
s=500;
sl=100000;
sg=100000;
do=5000;

for i = 1:y-1
    
    
tday1=txt(5:s, i*2-1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
adjcls1=num(1:s, i*2-1); %ppp the last column contains the adjusted close prices.

tday1=datestr(datenum(tday1, 'mm/dd/yyyy'), 'yyyymmdd'); % convert the format into yyyymmdd.
tday1=str2double(cellstr(tday1)); % convert the date strings first into cell arrays and then into numeric format.


for j=i+1:y
 
tday2=txt(5:s, j*2-1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
adjcls2=num(1:s, j*2-1); % PPP

tday2=datestr(datenum(tday2, 'mm/dd/yyyy'), 'yyyymmdd'); % convert the format into yyyymmdd.
tday2=str2double(cellstr(tday2)); % convert the date strings first into cell arrays and then into numeric format.


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

% Cross zero calcu
recs=size(adjcls,1);

cross=0;
for ctr=2:recs
   if (zscr(ctr-1,1) > 0 && zscr(ctr,1) < 0)
       cross=cross+1; 
   elseif (zscr(ctr-1,1)<0 && zscr(ctr,1) >0)
       cross=cross+1;
   end
       
end



if cross > 3 && results.rsqr>abs(0.4)&& rtnres.rsqr>abs(0.3)&& res.adf<-2.5 %hedgeRatio > 0.5 && hedgeRatio < 2.5 &&

    pnlcalc;

summary(r,1)=i;
summary(r,2)=j;
summary(r,3)=buy+sells; %no  of trades
summary(r,4)=buydollar+selldollar; % Dollar P&L
summary(r,5)=summary(r,4)/summary(r,3); % Average P&L
summary(r,6)=daymkt/summary(r,3);
summary(r,8)=win/summary(r,3);
summary(r,7)= std(mtrade(:,5));
summary(r,9)=hedgeRatio*adjcls(end,2)/adjcls(end,1);
summary(r,10)=hedgeRatio;
summary(r,11)=res.adf;
summary(r,12)=cross;
summary(r,13)=results.rsqr;
summary(r,15)=zscr(recs);
summary(r,14)=rtnres.rsqr;
end

plot(zscr);


j=j+1;
r=r+1;
end
i=i+1;
end
summ=sortrows(summary,11);
% plot(z); % This should produce a chart similar to 
