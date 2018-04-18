clearvars;
% javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');
% txt1={'CAT Equity';};
% txt2={'6301 JP Equity';};
input_param={'01/01/2009','Y',1,'Y'};

% function [Metrics]= copair_optimize(txt1,txt2,input_param)
%% import price and date
% startdate=char(input_param(1));
% enddate=today();
% per={'daily','non_trading_weekdays','nil_value'};
% field='EQY_WEIGHTED_AVG_PX'; %use vwap to exclude suspended days
% curr='USD';

% GET DATA
% [~, date1, price1]=blp_data(txt1,field,startdate,enddate,per,curr);
% [~, date2, price2]=blp_data(txt2,field,startdate,enddate,per,curr);

n_pair=size(price1,2)-1;


%% Initialize Optimization parameters and metrics
%optimization input
M = 60;
N = 5;
signal_step=0.25;
spread_long=-3.0:signal_step:-1.0;
spread_short=1.0:signal_step:3.0;
spread=[spread_long spread_short];
p_ADF=0.10:0.1:0.50;
hp_TH=44;
scaling=1;
cost=0;

beta_idx=cell2mat(input_param(3));
%beta_idx=1 log price
%beta_idx=2 demean log price
%beta_idx=3 normalize log price

% is_opti=char(input_param(2));
is_adf=char(input_param(4));

range1 = {M,N,spread,p_ADF};
% min_spread=min(spread);
% max_pADF=2*max(p_ADF);


%%optimization output
c_OPTI=[];
c_big_metrics=[];
% c_StockWise=cell(1,n_pair);

for sn=1:n_pair
    tday1=date1(:, sn+1); 
    adjcls1=price1(:, sn+1);    
    tday1(isnan(adjcls1))=[];
    adjcls1(isnan(adjcls1))=[];
    adjcls1(find(~tday1))=[];
    tday1(find(~tday1))=[];
    
    tday2=date2(:, sn+1); 
    adjcls2=price2(:, sn+1);
    tday2(isnan(adjcls2))=[];
    adjcls2(isnan(adjcls2))=[];
    adjcls2(find(~tday2))=[];
    tday2(find(~tday2))=[];
    
    [n1n2, idx1, idx2]=intersect(tday1, tday2); 
           
    tday_matlab=tday2(idx2);
    tempY=zeros(size(n1n2,1),2);
    tempY(:,1)=adjcls1(idx1);%stock1
    tempY(:,2)=adjcls2(idx2);%stock2
           
    %convert to log prices
    Y=log(tempY);
    tday_matlab(find(Y(:,1)==-Inf))=[];
    tday_matlab(find(Y(:,2)==-Inf))=[];
    Y(find(Y(:,1)==-Inf),:)=[];
    Y(find(Y(:,2)==-Inf),:)=[];    
    
    %%
    pfun1 = @(x) pairsFun(is_adf,beta_idx, x, Y, hp_TH,scaling, cost);
           
%     tic
    opti_idx=1;
    %1=ret,2=vol, 3=winp,4=omega,5=hp,6=trades,7=beta, 8=pADF (7 and 8 are
    %filters, not optimizing goal
    [max_idx,respmax1,param1,resp,var] = parameterSweep_v2(pfun1,range1,opti_idx);
%     toc
    
    c_para={size(spread,2)*size(p_ADF,2),6};
    
    for i=1:size(spread,2)
       for j= 1 :size(p_ADF,2)
           c_para{(i-1)*size(p_ADF,2)+j,1}=txt1{sn};
           c_para{(i-1)*size(p_ADF,2)+j,2}=txt2{sn};
           c_para{(i-1)*size(p_ADF,2)+j,3}=M;
           c_para{(i-1)*size(p_ADF,2)+j,4}=N;
           c_para{(i-1)*size(p_ADF,2)+j,5}=spread(i);
           c_para{(i-1)*size(p_ADF,2)+j,6}=p_ADF(j);
       end
    end    
    c_StockWise{1,sn}=[c_para,num2cell(resp)];
    c_newopti=[txt1{sn},txt2{sn},num2cell(param1),num2cell(resp(max_idx,:))];
    c_OPTI=[c_OPTI;c_newopti];
    c_big_metrics=[c_big_metrics;[c_para,num2cell(resp)]];
end
% cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/Coint');
% save (strcat('c_OPTI_',num2str(M),'_',num2str(N)), 'c_OPTI');
% save (strcat('c_StockWise_',num2str(M),'_',num2str(N)), 'c_StockWise');
%% adjust for gina
% price1=price1(:,2);
% price2=price2(:,2);
% date1=m2xdate(date1(:,2));
% date2=m2xdate(date2(:,2));