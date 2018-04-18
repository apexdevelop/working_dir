% clear all;
% cd('C:\Users\ychen\Documents\MATLAB');
% javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar');
% txt1={'005490 KS Equity';'005490 KS Equity';'005490 KS Equity';'005490 KS Equity';'005490 KS Equity';'005490 KS Equity';'005490 KS Equity'};
% txt2={'TWSE Index';'TWD Curncy';'6753 JP Equity';'034220 KS Equity';'005930 KS Equity';'GLW Equity';'5201 JP Equity'};
% input_param={'01/01/2009','Y',2,'Y'};
% cell_SignalTH={1};
% cell_ADFTH={0.45};

function Metrics= granger_engel_2var(txt1,txt2,input_param,cell_SignalTH,cell_ADFTH)
%% import data set from bloomberg and generate pairs

is_opti=char(input_param(2));
startdate=char(input_param(1));
per={'daily','non_trading_weekdays','previous_value'};
is_adf=char(input_param(4));

[~, date1, price1]=blp_test(txt1,startdate,per);
[~, date2, price2]=blp_test(txt2,startdate,per);

n_pair=size(price1,2)-1;

%% Initialize parameters and metrics
M = 120;
N   = 10;
spread=1:0.1:2.5;
p_ADF=[0.15,0.25,0.35,0.45];

scaling=1;
cost=0;
hp_TH=66;

beta_idx=cell2mat(input_param(3));
Metrics=[]; %store outputs
if matlabpool('size') == 0
   matlabpool local
end

if is_opti=='Y'
   range1 = {M,N,spread,p_ADF};
end

for sn=1:n_pair
    tday1=date1(:, sn+1); 
    adjcls1=price1(:, sn+1);
    tday1(isnan(adjcls1))=[];
    adjcls1(isnan(adjcls1))=[];
    tday1(find(~tday1))=[];
    adjcls1(find(~adjcls1))=[];
    
    tday2=date2(:, sn+1); 
    adjcls2=price2(:, sn+1);
    tday2(isnan(adjcls2))=[];
    adjcls2(isnan(adjcls2))=[];
    tday2(find(~tday2))=[];
    adjcls2(find(~adjcls2))=[];
    [n1n2, idx1, idx2]=intersect(tday1, tday2); 

    tday_matlab=tday2(idx2);
    Y=zeros(size(n1n2,1),2);
    Y(:,1)=adjcls1(idx1);%stock
    Y(:,2)=adjcls2(idx2);%factor1
    %convert to log prices
    logY=log(Y);
           
    %%
       pfun1 = @(x) pairsFun(is_adf,beta_idx, x, logY, scaling, cost);
           
       tic
       [respmax1,param1,resp1] = parameterSweep(pfun1,range1);
       toc
           
       M=param1(1);
       N=param1(2);
       Signal_TH=param1(3);
       pADF_TH=param1(4);
       [new_metric,r]=copair_sweep(beta_idx,logY,M,N,Signal_TH,pADF_TH,hp_TH,scaling,cost,tday_matlab,min(spread),max(p_ADF));
       new_metric=[param1 new_metric];
    Metrics=[Metrics;new_metric];

end