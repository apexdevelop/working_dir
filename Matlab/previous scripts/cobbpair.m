i=1;
j=2;
s=500;
band=1.5;


clear mtrade;
clear trade;
bbtic; %%%% Get BB data
tottrade=0;
r=1;
cross=1;
sl=5;
sg=10;
do=10;
bbtic;
  
tday1=dtxt(1:s, i+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
adjcls1=px(1:s, i+1); %ppp the last column contains the adjusted close prices.

tday2=dtxt(1:s, j+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
adjcls2=px(1:s, j+1); % PPP

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
clear tempcls;
tempcls(:,2)=adjcls(:,2);
tempcls(:,1)=1;

results=ols(adjcls(:, 1), tempcls(:,1:2)); 
%results=ols(adjcls(:, 1), adjcls(:,2)); 
constant=results.beta;
hedgeRatio=results.beta(2);
%hedgeRatio=results.beta;
z=results.resid;
rtnres = olsrtn(adjcls(:, 1), adjcls(:, 2));

%output(div,1)= i; output(div,2)= j; output(div,3)= res.adf ; output(div,4)= results.beta; output(div,5)=results.rsqr;

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
 
sumpair(div,1)=i;
sumpair(div,2)=j;
sumpair(div,7)=buy+sells; %no  of trades
sumpair(div,3)=buydollar+selldollar; % Dollar P&L
sumpair(div,4)=sumpair(div,3)/sumpair(div,7); % Average P&L
sumpair(div,5)=daymkt/sumpair(div,7);
sumpair(div,6)=win/sumpair(div,7);
sumpair(div,8)=abs((z(recs,1)/adjcls(recs,1)*100)/zscr(recs)); 
sumpair(div,9)=hedgeRatio*adjcls(end,2)/adjcls(end,1); %% Beta
sumpair(div,10)=hedgeRatio;
sumpair(div,11)=res.adf;
sumpair(div,12)=cross;
sumpair(div,13)=results.rsqr;
sumpair(div,14)=rtnres.rsqr;
sumpair(div,15)=zscr(recs);
sammid=s/2;

if div==1 adjcls=adj(1:sammid,:);
    test2=zscr;
    test2(:,2)=band;
    test2(:,3)=-1*band;
    test2(:,4)=0; 
end

if div==2 adjcls=adj(sammid:end,:); end

clear test;
test=zscr;
test(:,2)=band;
test(:,3)=-1*band;
test(:,4)=0;
subplot(2,1,2); plot(test)
subplot(2,1,1); plot(test2)
end

stkout1=sumpair;