function stkout1 =costkall(i,j,s,band,txt,num)
global summary;
global summ2;

clear mtrade;
clear trade;

tottrade=0;
r=1;
cross=1;
sl=100000;
sg=100000;
do=5000;

  
tday1=txt(5:s, i*2-1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
adjcls1=num(1:s, i*2-1); %ppp the last column contains the adjusted close prices.

tday1=datestr(datenum(tday1, 'mm/dd/yyyy'), 'yyyymmdd'); % convert the format into yyyymmdd.
tday1=str2double(cellstr(tday1)); % convert the date strings first into cell arrays and then into numeric format.

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

prt(res, vnames); 

results=ols(adjcls(:, 1), adjcls(:, 2)); 

hedgeRatio=results.beta;
z=results.resid;
rtnres = olsrtn(adjcls(:, 1), adjcls(:, 2));

output(r,1)= i; output(r,2)= j; output(r,3)= res.adf ; output(r,4)= results.beta; output(r,5)=results.rsqr;

% Profit and loss 

zscr = (z(:,1)-mean(z))/std(z);
plot(zscr);
% Cross zero calcu
recs=size(adjcls,1);

for ctr=2:recs
   if (zscr(ctr-1,1) > 0 && zscr(ctr,1) < 0)
       cross=cross+1; 
   elseif (zscr(ctr-1,1)<0 && zscr(ctr,1) >0)
       cross=cross+1;
   end
       
end


pnlcalc; 
 
summary(1,1)=i;
summary(1,2)=j;
summary(1,3)=buy+sells; %no  of trades
summary(1,4)=buydollar+selldollar; % Dollar P&L
summary(1,5)=summary(1,4)/summary(1,3); % Average P&L
summary(1,6)=daymkt/summary(1,3);
summary(1,7)= std(mtrade(:,5));
summary(1,8)=win/summary(1,3);
summary(1,9)=summary(1,4)/summary(1,7);
summary(1,10)=hedgeRatio;
summary(1,11)=res.adf;
summary(1,12)=cross;
summary(1,13)=results.rsqr;
summary(1,15)=zscr(recs);
summary(1,14)=rtnres.rsqr;
summ=sortrows(summary,11)

subplot(2,1,1); plot(log(adjcls))
test=zscr;
test(:,2)=band;
test(:,3)=-1*band;
test(:,4)=0;
subplot(2,1,2); plot(test)


stkout1.rs=summ;
stkout1.sr=summary;