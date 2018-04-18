
function out=coint3(i,j,c,band)
 % make sure previously defined variables are erased.

r=1;
cross=1;
[num, txt]=xlsread('inco'); %PPP read a spreadsheet named "GLD.xls" into MATLAB. 
[num2, txt2]=xlsread('inco'); % read a spreadsheet named "GDX.xls" into MATLAB.

y=size(num);

    
tday1=txt(2:c, 1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
 
tday1=datestr(datenum(tday1, 'mm/dd/yyyy'), 'yyyymmdd'); % convert the format into yyyymmdd.
 
tday1=str2double(cellstr(tday1)); % convert the date strings first into cell arrays and then into numeric format.
 
adjcls1=num(1:c, i); %ppp the last column contains the adjusted close prices.


 
tday2=txt2(2:c, 1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.

 
tday2=datestr(datenum(tday2, 'mm/dd/yyyy'), 'yyyymmdd'); % convert the format into yyyymmdd.
 
tday2=str2double(cellstr(tday2)); % convert the date strings first into cell arrays and then into numeric format.

adjcls2=num2(1:c, j); % PPP

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

% Output from cadf function:

%  Augmented DF test for co-integration variables:                        GLD,GDX  
% CADF t-statistic        # of lags   AR(1) estimate 
%      -3.35698533                1        -0.060892 
% 
%    1% Crit Value    5% Crit Value   10% Crit Value 
%           -3.819           -3.343           -3.042 

% The t-statistic of -3.36 which is in between the 1% Crit Value of -3.819
% and the 5% Crit Value of -3.343 means that there is a better than 95%
% probability that these 2 time series are cointegrated.



results=ols(adjcls(:, 1), adjcls(:, 2)); 

hedgeRatio=results.beta;
z=results.resid;


output(r,1)= i; output(r,2)= j; output(r,3)= res.adf ; output(r,4)= results.beta; output(r,5)=results.rsqr;

% A hedgeRatio of 1.6766 was found. I.e. GLD=1.6766*GDX + z, where z can be interpreted as the
% spread GLD-1.6766*GDX and should be stationary.
plot(z); % This should produce a chart similar to 


zscr = (z(:,1)-mean(z))/std(z);

% Cross zero calcu
for ctr=2:c-1
   if (zscr(ctr-1,1) > 0 && zscr(ctr,1) < 0)
       cross=cross+1; 
   elseif (zscr(ctr-1,1)<0 && zscr(ctr,1) >0)
       cross=cross+1;
   end
       
end




tog=0;
buy=0;
sells=0;
buydollar=0;
selldollar=0;
win=0;
daymkt=0
for ctr=1:c-2
  
    if (zscr(ctr, 1)>band && tog==0)
        tog=1;
        trade(ctr,2)=100/(hedgeRatio*adjcls(ctr,2));
        trade(ctr,3)=100/(adjcls(ctr,1));
        trade(ctr,4)=100/hedgeRatio-100;
        sells=sells+1;
        bctr=ctr;
     else if (zscr(ctr, 1) < -1*band && tog==0)
        tog=2;
        trade(ctr,2)=100/adjcls(ctr,1);
        trade(ctr,3)=100/(hedgeRatio*adjcls(ctr,2));
        trade(ctr,4)=100-100/hedgeRatio;
        sells=sells+1;
        sctr=ctr;
        end
    end

    trade(ctr,1)=tog;
    tottrade=buy+sells;
 
    if ((tog==1) && (zscr(ctr, 1)<0))
        tog=0;
        trade(ctr,5)=(adjcls(ctr,2)*trade(bctr,2)- adjcls(ctr,1)*trade(bctr,3))-trade(bctr,4);
        selldollar=selldollar+trade(ctr,5);
        trade(ctr,2)=100/(hedgeRatio*adjcls2(ctr,1));
        trade(ctr,3)=100/(adjcls1(ctr,1));
        trade(ctr, 6)=ctr-bctr;
        daymkt=daymkt+trade(ctr,6);
        
        mtrade(tottrade,1)=i;
        mtrade(tottrade,2)=j;
        mtrade(tottrade,3)=tday(ctr);
        mtrade(tottrade,4)=1;
        mtrade(tottrade,5)=trade(ctr,5);
        mtrade(tottrade,6)=daymkt;
        
        if trade(ctr,5)>0, win=win+1; end
     else if  (tog==2) && (zscr(ctr, 1)> 0)
        tog=0;
        trade(ctr,5)=(adjcls(ctr,1)*trade(sctr,2)-adjcls(ctr,2)*trade(sctr,3))-trade(sctr,4);
        buydollar=buydollar+trade(ctr,5);
        trade(ctr,2)=100/adjcls(ctr,1);
        trade(ctr,3)=100/(hedgeRatio*adjcls(ctr,2));
        trade(ctr, 6)=ctr-sctr;
        daymkt=daymkt+trade(ctr,6);
        
        mtrade(tottrade,1)=i;
        mtrade(tottrade,2)=j;
        mtrade(tottrade,3)=tday(ctr);
        mtrade(tottrade,4)=2;
        mtrade(tottrade,5)=trade(ctr,5);
        mtrade(tottrade,6)=daymkt;
        
        if trade(ctr,5)>0, win=win+1; end
        end
    end
    ctr=ctr+1;
end
summary(1,1)=i;
summary(1,2)=j;
summary(1,3)=band;
summary(1,3)=buy+sells; %no  of trades
summary(1,4)=buydollar+selldollar; % Dollar P&L
summary(1,5)=summary(1,2)/summary(1,1); % Average P&L
summary(1,6)=daymkt/summary(1,1);
summary(1,8)=win/summary(1,1);
summary(1,7)= std(mtrade(:,5));
summary(1,9)=summary(1,4)/summary(1,7);
summary(1,10)=hedgeRatio;
summary(1,11)=res.adf;
summary(1,12)=cross;
summary(1,13)=results.rsqr;

plot(zscr);
out=summary;
