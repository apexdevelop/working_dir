function stkout1 =costkpr(i,j,s,band)
global ressumm;
clear mtrade;
clear trade;
[num,txt]=xlsread('regstk');
tottrade=0;
r=1;
cross=1;
sl=5;
sg=10;
do=10;

  
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

adj=adjcls;

for div=1:3
    
res=cadf(adjcls(:, 1), adjcls(:, 2), 0, 2); % run cointegration check using augmented Dickey-Fuller test

results=ols(adjcls(:, 1), adjcls(:, 2)); 

hedgeRatio=results.beta;
z=results.resid;
rtnres = olsrtn(adjcls(:, 1), adjcls(:, 2));

output(div,1)= i; output(div,2)= j; output(div,3)= res.adf ; output(div,4)= results.beta; output(div,5)=results.rsqr;

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
 
summary(div,1)=i;
summary(div,2)=j;
summary(div,3)=buy+sells; %no  of trades
summary(div,4)=buydollar+selldollar; % Dollar P&L
summary(div,5)=summary(div,4)/summary(div,3); % Average P&L
summary(div,6)=daymkt/summary(div,3);
summary(div,7)= 0;%std(mtrade(:,5));
summary(div,8)=win/summary(div,3);
summary(div,9)=0%summary(div,4)/summary(div,7);
summary(div,10)=hedgeRatio;
summary(div,11)=res.adf;
summary(div,12)=cross;
summary(div,13)=results.rsqr;
summary(div,14)=rtnres.rsqr
summary(div,15)=zscr(recs)

test=zscr;
test(:,2)=band;
test(:,3)=-1*band;
test(:,4)=0;
subplot(2,1,1); plot(log(adjcls))
subplot(2,1,2); plot(test)

sammid=s/2;

if div==1 adjcls=adj(1:sammid,:); end
if div==2 adjcls=adj(sammid:end,:); end

end

stkout1.ressumm=summary
