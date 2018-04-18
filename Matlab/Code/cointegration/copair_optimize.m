clearvars;
javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');
cd('Z:\Proj\Trading\Yan\Model 2.1\Cointegration');
[~,txt1]=xlsread('Copair_optimize.xlsm','pairs','e2:e2');
[~,txt2]=xlsread('Copair_optimize.xlsm','pairs','h2:h2');
input_param={'01/01/2009','Y',1,'Y'};

% function [Metrics]= copair_optimize(txt1,txt2,input_param)
%% import data set from bloomberg and generate pairs


beta_idx=cell2mat(input_param(3));
%beta_idx=1 log price
%beta_idx=2 demean log price
%beta_idx=3 normalize log price

is_opti=char(input_param(2));
is_adf=char(input_param(4));

startdate=char(input_param(1));
enddate=today();
per={'daily','non_trading_weekdays','nil_value'};
field='EQY_WEIGHTED_AVG_PX'; %use vwap to exclude suspended days
curr='USD';

% GET DATA
[~, date1, price1]=blp_data(txt1,field,startdate,enddate,per,curr);
[~, date2, price2]=blp_data(txt2,field,startdate,enddate,per,curr);

n_pair=size(price1,2)-1;

%% Initialize parameters and metrics
M = 30;
N = 5;
signal_step=0.5;
spread=1.0:signal_step:3.0;
p_ADF=0.05:0.05:0.20;
scaling=1;
cost=0;

biret=zeros(size(spread,2),size(p_ADF,2));


hp_TH=44;
Beta_TH=0.5;
Rsqr_TH=0.1;
PnL_TH=0;


Metrics=[]; %store outputs
filter_idx1=[]; % store index for qualified pairs
filter_idx2=[];
v_Rtn=[];
v_Date=[];

if parpool('local') == 0
   parpool local
end

range1 = {M,N,spread,p_ADF};
min_spread=min(spread);
max_pADF=2*max(p_ADF);


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
    
    pfun1 = @(x) pairsFun(is_adf,beta_idx, x, Y, scaling, cost);
           
    tic
    [respmax1,param1,resp,var] = parameterSweep(pfun1,range1);
    toc
    
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
    
%     stk1=strrep(c_para(:,1),'''','');
%     stk2=strrep(c_para(:,2),'''','');
%     c_para1=[stk1,stk2,c_para(:,3:end)];
    
    c_result=[c_para,num2cell(resp)];

%     for i=1:size(spread,2)
%        for j= 1 :size(p_ADF,2)
%            biret(i,j)=resp1(:,:,i,j);
%        end
%     end
%     
%     pADF_TH=param1(4);
    
%     new_metric=copair_sweep_optimize(beta_idx,Y,M,N,pADF_TH,biret,signal_step);
%     new_metric=[param1 respmax1 new_metric];
% 
%     Metrics=[Metrics;new_metric];
%     tday_excel=m2xdate(tday2(idx2),0);

end
