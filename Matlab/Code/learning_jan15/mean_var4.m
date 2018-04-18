% http://www.mathworks.com/help/finance/portfolio-optimization-examples.html
clear all;
cd('X:\Yan');
file='d_port2.txt';
fileID=fopen(file,'r');
T=textscan(fileID,'%s','Delimiter','\n');
txt=T{1,1};

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
mret=exp_m_r(1);
mrsk=sqrt(exp_m_cov(1));
cret=0.0004;
crsk=sqrt(2.49e-06);

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

% %obtain range of risks and returns
% [rsk, ret] = estimatePortMoments(p, estimateFrontierLimits(p));

%% illustrate the tangent line to the efficient frontier
% q = setBudget(p, 0, 1);
% qwgt = estimateFrontier(q, 20);
% [qrsk, qret] = estimatePortMoments(q, qwgt);
% 
% % Plot efficient frontier with tangent line (0 to 1 cash)
% 
% clf;
% portfolioexamples_plot('Efficient Frontier with Tangent Line', ...
% 	{'line', prsk, pret}, ...
% 	{'line', qrsk, qret, [], [], 1}, ...
% 	{'scatter', [mrsk, crsk, ersk], [mret, cret, eret], {'Market', 'Cash', 'Equal'}}, ...
% 	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

%% Find a portfolio with a targeted return and targeted risk
TargetReturn=0.20;
TargetRisk=0.15;
awgt=estimateFrontierByReturn(p,TargetReturn/12);
[arsk,aret]=estimatePortMoments(p,awgt);

bwgt=estimateFrontierByRisk(p,TargetRisk/sqrt(12));
[brsk,bret]=estimatePortMoments(p,bwgt);
% aBlotter = dataset({100*awgt(awgt > 0),'Weight'}, 'obsnames', p.AssetList(awgt > 0));
% col_list=transpose(p.AssetList);
% col_list=strrep(col_list,'''','');
% aBlotter = dataset({100*awgt(awgt > 0),'Weight'},{transpose(p.AssetList(awgt > 0)),'Ticker'});
% bBlotter = dataset({100*bwgt(bwgt > 0),'Weight'}, 'obsnames', p.AssetList(bwgt > 0));

% Plot efficient frontier with targeted portfolios
clf;
portfolioexamples_plot('Efficient Frontier with Targeted Portfolios', ...
    {'line',prsk,pret}, ...
    {'scatter',[mrsk, crsk,ersk],[mret,cret,eret],{'Market','Cash','Equal'}}, ...
    {'scatter', arsk,aret,{sprintf('%g%% Return',100*TargetReturn)}}, ...
    {'scatter', brsk,bret,{sprintf('%g%% Risk',100*TargetRisk)}});
%     {'scatter', sqrt(diag(p.AssetCovar)),p.AssetMean,p.AssetList,'.r'});


%% Transaction Cost and Turnover Constraint
BuyCost = 0.0020;
SellCost = 0.0020;
Turnover = 0.2;

q = setCosts(p, BuyCost, SellCost);
q = setTurnover(q, Turnover);
[qwgt, qbuy, qsell] = estimateFrontier(q, NumPorts);
[qrsk, qret] = estimatePortMoments(q, qwgt);
% Plot efficient frontiers with gross and net returns

clf;
portfolioexamples_plot('Efficient Frontier with and without Transaction Costs', ...
	{'line', prsk, pret, {'Unconstrained'}, ':b'}, ...
	{'line', qrsk, qret, {sprintf('%g%% Turnover', 100*Turnover)}}, ...
	{'scatter', [mrsk, crsk, ersk], [mret, cret, eret], {'Market', 'Cash', 'Equal'}}, ...
	{'scatter', sqrt(diag(p.AssetCovar)), p.AssetMean, p.AssetList, '.r'});

% AssetBounds=[ones(1,n_dim)*0.01;ones(1,n_dim)*0.99];
% LowerBound = AssetBounds(1,:);
% UpperBound = AssetBounds(2,:);
% p = setBounds(p, LowerBound, UpperBound);


