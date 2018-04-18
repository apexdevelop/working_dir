% http://www.mathworks.com/help/finance/portfolio-optimization-examples.html
% http://www.mathworks.com/help/finance/working-with-portfolio-constraints_bswwmte.html#bswwll0-1
clear all;
cd('X:\Yan');
% file='d_port2.txt';
% fileID=fopen(file,'r');
% T=textscan(fileID,'%s','Delimiter','\n');
% txt=T{1,1};
filename='stocks_d.xlsx';
shname='upload';
[~,txt]=xlsread(filename,shname,'a2:a100'); %tickers
[G1,~]=xlsread(filename,shname,'c2:c100');  %group1 by is important
G1=transpose(G1);
mret=0.0065;
mrsk=sqrt(0.0024);
cret=0.0008;
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

NumPorts=30;
p = setDefaultConstraints(p);
% Set lower bounds
AssetBounds=[ones(1,n_dim)*0.0025;ones(1,n_dim)*0.15];
LowerBound = AssetBounds(1,:);
UpperBound = AssetBounds(2,:);
p = setBounds(p, LowerBound, UpperBound);

% Set groups
% p = setGroups(p, G1, 0.4, 1);
% G2 = blkdiag(true(1,3), true(1,2), true(1,2), true(1,1), true(1,1), true(1,1), true(1,2), true(1,2), ...
%     true(1,1), true(1,1), true(1,2), true(1,3), true(1,2), true(1,3), true(1,3), true(1,1), true(1,3), true(1,6));
% p = addGroups(p, G2, 0.0025,0.15);
pwgt = estimateFrontier(p, NumPorts);
[prsk, pret] = estimatePortMoments(p, pwgt);
out_prsk=transpose(prsk);
out_pret=transpose(pret);
out_pwgt=100*pwgt;

%% illustrate the tangent line to the efficient frontier
% Turnover Constraint
Turnover = 0.2;
q = setTurnover(p, Turnover);
[qwgt, qbuy, qsell] = estimateFrontier(q, NumPorts);
[qrsk, qret] = estimatePortMoments(q, qwgt);
out_qrsk=transpose(qrsk);
out_qret=transpose(qret);
out_qwgt=100*qwgt;

t = setBudget(q, 0, 1);
twgt = estimateFrontier(t, NumPorts);
[trsk, tret] = estimatePortMoments(t, twgt);

%% Maximize the Sharpe Ratio
% p = setInitPort(p, 0);
swgt = estimateMaxSharpeRatio(q);
[srsk, sret] = estimatePortMoments(q, swgt);
out_swgt=100*swgt;
% Plot efficient frontiers with tangent line (0 to 1 cash) with lower
% bounds

clf;
portfolioexamples_plot('Efficient Frontier with Maximum Sharpe Ratio', ...
    {'line', prsk, pret,{'Unconstrained'}, ':b'}, ...
	{'line', qrsk, qret,{sprintf('%g%% Turnover', 100*Turnover)}}, ...
    {'scatter', srsk, sret, {'Sharpe'},'r'}, ...
	{'scatter', mrsk, mret, {'Market'}}, ...
	{'scatter', ersk, eret, {'Equal'},'b'});
%     {'line', trsk, tret, [], [], 1}, ...



