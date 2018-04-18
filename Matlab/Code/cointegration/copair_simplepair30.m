 % clear all;
% javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.8.8.2\lib\blpapi3.jar'); % for using blp in function (blp_txt)
% cd('X:\Yan\Model 2.1\Cointegration');
% % [~,txt1]=xlsread('Copair_samecountry_8.xlsm','pairs','e3:e3');
% % [~,txt2]=xlsread('Copair_samecountry_8.xlsm','pairs','h3:h3');
% % v_SignalTH=xlsread('Copair_samecountry_8.xlsm','pairs','u3:u3');
% % v_ADFTH=xlsread('Copair_samecountry_8.xlsm','pairs','o3:o3');
% % v_status=xlsread('Copair_samecountry_8.xlsm','pairs','ad3:ad3');
% txt1={'8591 JP Equity'};
% txt2={'8306 JP Equity'};
% v_SignalTH={2.70};
% v_ADFTH={0.20};
% v_status={1};
% input_param={'01/01/2009','Y',1,'Y'};
% % mat_SignalTH=v_SignalTH;
% % mat_ADFTH=v_ADFTH;
% % mat_status=v_status;
% % 
% if matlabpool('size') ~= 0
%    matlabpool close force local;
% end

function Metrics= copair_simplepair30(txt1,txt2,input_param,v_SignalTH, v_ADFTH)
%% import data set from bloomberg and generate pairs

mat_SignalTH=cell2mat(v_SignalTH);
mat_ADFTH=cell2mat(v_ADFTH);

beta_idx=cell2mat(input_param(3));
%beta_idx=1 log price
%beta_idx=2 demean log price
%beta_idx=3 normalize log price

is_adf=char(input_param(4));

startdate=char(input_param(1));
enddate=today();
per='daily';
field='LAST_PRICE'; %use vwap to exclude suspended days
curr='USD';

% GET DATA
[~, date1, price1]=blp_data(txt1,field,startdate,enddate,per,curr);
[~, date2, price2]=blp_data(txt2,field,startdate,enddate,per,curr);

n_pair=size(price1,2)-1;

%% Initialize parameters and metrics
% M_idx=cell2mat(input_param(4));
% switch M_idx
%   case 4 
%    M = 120;
%   case 2
%    M=60;
%   case 1   
%    M=30;
% end

M =30;
N = 5;
scaling=1;
cost=0;

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

min_spread=1;
max_pADF=0.4;


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
    Signal_TH=mat_SignalTH(sn);
    pADF_TH=mat_ADFTH(sn);
    
    new_metric=copair_backtest_simple_v1(beta_idx,Y,M,N,Signal_TH,pADF_TH,hp_TH,scaling,cost,tday_matlab,min_spread,max_pADF);
      
    Metrics=[Metrics;new_metric];  
end
