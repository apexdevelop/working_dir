% http://www.mathworks.com/help/finance/portfolio-optimization-examples.html
clear all;
cd('X:\Yan');
file='d_port2.txt';
fileID=fopen(file,'r');
T=textscan(fileID,'%s','Delimiter','\n');
txt=T{1,1};

mret=0.0065;
mrsk=sqrt(0.0024);
cret=0.0027;
crsk=sqrt(2.49e-06);

javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar')
%% generate Data
startdate='2014/11/14';
enddate=today();
per={'daily','non_trading_weekdays','previous_value'};
c=blp;
for loop=1:size(txt,1)
        new=strcat(char(txt(loop)), ' EQUITY');
        [d1, sec1] = history(c, new,'CHG_PCT_1D',startdate,enddate,per);
        [d2, sec2] = history(c, new,'Last_Price',startdate,enddate,per);
        dates(1:size(d1,1),loop)=d1(1:size(d1,1),1);
        rtns(1:size(d1,1),loop)=d1(1:size(d1,1),2);
        prices(1:size(d2,1),loop)=d2(1:size(d2,1),2);
end;
close(c);
n_dim=size(rtns,2);
tday1=dates(:, 1);
rtn1=rtns(:, 1);
px1=prices(:, 1);
tday1(find(~tday1))=[];
rtn1(find(~tday1))=[];
px1(find(~tday1))=[];

for k=2:n_dim
    tday2=dates(:, k); 
    rtn2=rtns(:, k);
    px2=prices(:, k);
    tday2(find(~tday2))=[];
    rtn2(find(~tday2))=[];
    px2(find(~tday2))=[];
    [n1n2, idx1, idx2]=intersect(tday1, tday2);
    tday1=tday1(idx1);
    rtn_Y=[rtns(idx1,1:k-1) rtns(idx2,k:end)];
    px_Y=[prices(idx1,1:k-1) prices(idx2,k:end)];
end

N_days=22;
avg_d_rtn=mean(rtn_Y)/100;
exp_m_r=(1+avg_d_rtn).^N_days-1;
d_cov=cov(rtn_Y./100);
exp_m_cov=d_cov.*N_days;

%% Create a Portfolio Project
p=Portfolio('AssetList',txt,'RiskFreeRate',cret);
p=setAssetMoments(p,exp_m_r,exp_m_cov);

% equal-weighted portfolio
p = setInitPort(p, 1/p.NumAssets);
[ersk, eret] = estimatePortMoments(p, p.InitPort);

%% Set up a portfolio optimization problem

NumPorts=20;
p = setDefaultConstraints(p);
pwgt = estimateFrontier(p, NumPorts);
[prsk, pret] = estimatePortMoments(p, pwgt);
out_prsk=transpose(prsk);
out_pret=transpose(pret);
out_pwgt=100*pwgt;

%% illustrate the tangent line to the efficient frontier
t = setBudget(p, 0, 1);
twgt = estimateFrontier(t, NumPorts);
[trsk, tret] = estimatePortMoments(t, twgt);


%% Maximize the Sharpe Ratio
p = setInitPort(p, 0);
swgt = estimateMaxSharpeRatio(p);
[srsk, sret] = estimatePortMoments(p, swgt);
out_swgt=100*swgt;
% Plot efficient frontiers with turnover constraints and tangent line (0 to 1 cash)

clf;
portfolioexamples_plot('Efficient Frontier with Maximum Sharpe Ratio', ...
	{'line', prsk, pret,}, ...
    {'line', trsk, tret, [], [], 1}, ...
    {'scatter', srsk, sret, {'Sharpe'},'r'}, ...
	{'scatter', [mrsk, crsk], [mret, cret], {'Market', 'Cash'}}, ...
	{'scatter', ersk, eret, {'Equal'},'b'});

% 	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});


