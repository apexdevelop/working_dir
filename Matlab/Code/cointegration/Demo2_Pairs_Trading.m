javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.6.1.0\lib\blpapi3.jar')
cd('C:\Users\ychen\Documents\MATLAB');
clear all;
%% Load data
blp_test; %import data set from bloomberg
s=size(btxt,1); %time period

for n=1:1
    tday1=dtxt(1:s, n+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
    adjcls1=px(1:s, n+1); %ppp the last column contains the adjusted close prices.
    for m=2:2
        tday2=dtxt(1:s, m+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
        adjcls2=px(1:s, m+1); % PPP

        tday=union(tday1, tday2); % find all the days when either GLD or GDX has data.
        [foo idx idx1]=intersect(tday, tday1); %foo=tday(idx,:),foo=tday1(idx1,:)
        adjcls=NaN(length(tday), 2); % combining the two price series,initialized by NaN matrix
        adjcls(idx, 1)=adjcls1(idx1);
        [foo idx idx2]=intersect(tday, tday2);
        adjcls(idx, 2)=adjcls2(idx2);
        baddata=find(any(~isfinite(adjcls), 2)); % days where any one price is missing,isfinite()=0 if NaN
        tday(baddata)=[];
        adjcls(baddata, :)=[];        
        %convert to log prices
        adjcls1_log=log(adjcls(:,1));
        adjcls2_log=log(adjcls(:,2));
        adjcls=[adjcls1_log adjcls2_log];
    end
    
end

series=adjcls;

%% The cointegration test framework

egcitest(series)
% (A zero indicates failure to reject the null hypothesis that no
% cointegrating relationship exists.)
%%
% Even so, there are smaller windows of time where a cointegrating
% relationship does exist.
[h, ~, ~, ~, reg1] = egcitest(series);
display(h)
%%
% The test estimates the coefficients of the cointegrating regression as
% well as the residuals and the standard errors of the residuals: all
% useful information for any pairs trading strategy.
display(reg1)

%% The pairs trading strategy
% The following function describes our pairs strategy.
% edit pairs

%%
% We may test this strategy as we do our other rules:
pairs(series, 420, 60);
% Note that this strategy will not trade if the most recent minutes do not
% show signs of cointegration and that the size of the long/short positions
% are dynamically scaled with the volatility of the cointegrating
% relationship.  Many other customizations can be made.

%%
% We can use our existing parameter sweep framework to identify the best
% combination of calibration window and rebalancing frequency.
if matlabpool('size') == 0
    matlabpool local
end

window = 120:60:420;
freq   = 10:10:60;
range = {window, freq};

annualScaling = 1;
cost = 0.01;

pfun = @(x) pairsFun(x, series, annualScaling, cost);

tic
[~,param] = parameterSweep(pfun,range);
toc

pairs(series, param(1), param(2), 1, annualScaling, cost)
%%
% Despite the fact that these historically-tracking time series have
% diverged, we can still create a profitable pairs trading strategy by
% frequently recalibrating.