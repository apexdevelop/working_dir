
clear all;
cd('X:\Yan');
file='d_port.txt';
fileID=fopen(file,'r');
T=textscan(fileID,'%s','Delimiter','\n');
txt=T{1,1};

% [num,txt]=xlsread('Cost Price Calculation','rawdata','g1:g1000');
javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar')
%% generate Data
startdate='2014/11/14';
enddate=today();
per={'daily','non_trading_weekdays','previous_value'};
c=blp;
    for loop=1:size(txt,1)
        new=char(txt(loop));
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

N_days=size(rtn_Y,1);
avg_d_rtn=mean(rtn_Y);
exp_yr_r=(1+avg_d_rtn/100).^N_days-1;
d_cov=cov(rtn_Y./100);
exp_yr_cov=d_cov.*N_days;

NumPorts=10;

AssetBounds=[ones(1,n_dim)*0.005;ones(1,n_dim)*0.99];


% [~,p]=chol(d_cov);
% [PRisk,PRoR,PWts]=frontcon(exp_yr_r,exp_yr_cov,NumPorts);
[PRisk,PRoR,PWts]=frontcon(exp_yr_r,exp_yr_cov,NumPorts,[],AssetBounds);
