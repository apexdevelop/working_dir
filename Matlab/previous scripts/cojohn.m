i=1;
j=2;
k=3;

s=500;
band=1.5;


clear mtrade;
clear trade;
bbstk;
tottrade=0;
r=1;
cross=1;
sl=5;
sg=10;
do=10;

  
tday1=dtxt(1:s, i+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
adjcls1=px(1:s, i+1); %ppp the last column contains the adjusted close prices.

tday2=dtxt(1:s, j+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
adjcls2=px(1:s, j+1); % PPP

tday3=dtxt(1:s, k+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
adjcls3=px(1:s, k+1); % PPP

tday=union(union(tday1, tday2),tday3); % find all the days when either GLD or GDX has data.
adjcls=NaN(length(tday), 2); % combining the two price series

[foo idx idx1]=intersect(tday, tday1);
adjcls(idx, 1)=adjcls1(idx1);
[foo idx idx2]=intersect(tday, tday2);
adjcls(idx, 2)=adjcls2(idx2);

[foo idx idx3]=intersect(tday, tday3);
adjcls(idx, 3)=adjcls3(idx3);

baddata=find(any(~isfinite(adjcls), 2)); % days where any one price is missing
tday(baddata)=[];
adjcls(baddata, :)=[];


y = adjcls; % use all eight states
nlag = 9;
cterm = 0;
result = johansen(y,cterm,nlag);

% print results with variable names
prt_coint(result,stocks);

%%adj=adjcls;

%%for div=1:3
cross=0;    
res=cadf(adjcls(:, 1), adjcls(:, 2), 0, 2); % run cointegration check using augmented Dickey-Fuller test

results=ols(adjcls(:, 1), adjcls(:, 2)); 

hedgeRatio=results.beta;
z=results.resid;
rtnres = olsrtn(adjcls(:, 1), adjcls(:, 2:end));

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
 
sumjohn(1,1)=i;
sumjohn(1,2)=j;
sumjohn(1,3)=result.lr1(1,1); %no  of trades
sumjohn(1,4)=result.lr2(1,1); % Dollar P&L
sumjohn(1,5)=sumpair(div,4)/sumpair(div,3); % Average P&L
sumpair(div,6)=daymkt/sumpair(div,3);
sumpair(div,7)= 0;%std(mtrade(:,5));
sumpair(div,8)=win/sumpair(div,3);
%sumpair(div,9)=0; %sumpair(div,4)/sumpair(div,7);
sumpair(div,9)=hedgeRatio*adjcls(end,2)/adjcls(end,1); %Beta
sumpair(div,10)=hedgeRatio;
sumpair(div,11)=results.adf;
sumpair(div,12)=cross;
sumpair(div,13)=results.rsqr;
sumpair(div,14)=rtnres.rsqr;
sumpair(div,15)=zscr(recs);


test=zscr;
test(:,2)=band;
test(:,3)=-1*band;
test(:,4)=0;
subplot(2,1,1); plot(log(adjcls))
subplot(2,1,2); plot(test)

%sammid=s/2;

%if div==1 adjcls=adj(1:sammid,:); end
%if div==2 adjcls=adj(sammid:end,:); end
%end
