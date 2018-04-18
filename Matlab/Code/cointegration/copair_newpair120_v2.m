clearvars;
javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');
cd('Z:\Proj\Trading\Yan\Model 2.1\Cointegration');

[~,txt1]=xlsread('Copair_samecountry_9.xlsm','pairs','e2:e159');
[~,txt2]=xlsread('Copair_samecountry_9.xlsm','pairs','h2:h159');
v_SignalTH=xlsread('Copair_samecountry_9.xlsm','pairs','u2:u159');
v_ADFTH=xlsread('Copair_samecountry_9.xlsm','pairs','o2:o159');
v_status=xlsread('Copair_samecountry_9.xlsm','pairs','ad2:ad159');
% txt1={'8591 JP Equity'};
% txt2={'8306 JP Equity'};
% v_SignalTH={2.70};
% v_ADFTH={0.20};
% v_status={1};
input_param={'01/01/2009','Y',1,'Y'};
mat_SignalTH=v_SignalTH;
mat_ADFTH=v_ADFTH;
mat_status=v_status;


% function [Metrics,filtered2_stk1,filtered2_stk2,filtered2_M,filtered1_stk1,filtered1_stk2,filtered1_M,v_Rtn]= copair_newpair120(txt1,txt2,input_param,v_SignalTH, v_ADFTH, v_status)
%% import data set from bloomberg and generate pairs

% mat_SignalTH=cell2mat(v_SignalTH);
% mat_ADFTH=cell2mat(v_ADFTH);
% mat_status=cell2mat(v_status);

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

M =120;
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

% if parpool('local') == 0
%    parpool local
% end

min_spread=1;
max_pADF=0.4;

cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/Coint');
S_OPTI=load('c_OPTI');
c_OPTI=S_OPTI.c_OPTI;
S_StockWise=load('c_StockWise');
c_StockWise=S_StockWise.c_StockWise;

c_rn1=cell(1,n_pair);
c_cn1=cell(1,n_pair);
c_rn2=cell(1,n_pair);
c_cn2=cell(1,n_pair);

nameCell=[txt1 txt2];
nameStr=string(nameCell);

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
    open_Signal_TH=mat_SignalTH(sn);
    open_pADF_TH=mat_ADFTH(sn);
    new_name=nameStr(sn,:);
    db_name=string(c_OPTI(:,1:2));
    stkLia=ismember(db_name,new_name,'rows');
    stk_idx=find(stkLia); % find logical 1
%     [rn1,cn1]=find(strcmp(c_OPTI,txt1{sn}));
%     [rn2,cn2]=find(strcmp(c_OPTI,txt2{sn}));
    
%     if isempty(rn1)==0 && isempty(rn2)==0
%        if size(rn1,1)>=size(rn2,1)
%           stk_idx=find(rn1==rn2);
%        else
%           stk_idx=find(rn2==rn1);
%        end
%     else
%        stk_idx=[];
%     end
    
    if isempty(stk_idx)==0
       db_subset=cell2mat(c_StockWise{1,stk_idx}(:,5:6));
       TH_target=[1,0.15];
%        indx=ismember(db_subset,TH_target,'rows');
       thLia=ismembertol(db_subset,TH_target,'ByRows',true);
       TH_idx=find(thLia);
       [new_metric,zscr]=copair_backtest_v7(c_StockWise{1,stk_idx},beta_idx,Y,M,N,open_Signal_TH,open_pADF_TH,hp_TH,scaling,cost,tday_matlab,mat_status(sn));  
       Metrics=[Metrics;new_metric];
    end  
%     tday_excel=m2xdate(tday2(idx2),0);
%     if sn==1
%        v_Rtn=[v_Rtn r];
%        v_Date=[v_Date tday_excel];
%     else
%        v_Rtn=supervertcat(v_Rtn,r);
%        v_Date=supervertcat(v_Date,tday_excel);
%     end
%     
%     %abs(Beta)<3 and abs(Beta)>0.2, long term pADF<=0.1,direction=1,has
%     %enter is in recent 2 month
%     if abs(new_metric(10))<=1/Beta_TH && abs(new_metric(10))>=Beta_TH && new_metric(2)<=max_pADF ...
%     && new_metric(16)==1 && new_metric(19)>m2xdate(today()-60,0)    
%       filter_idx1=[filter_idx1;size(Metrics,1)];
%     end
%     
%     % enter is in recent 2 month and expected rtn>0
%     if new_metric(19)>m2xdate(today()-60,0) ...
% %        && new_metric(11)>0
%        filter_idx2=[filter_idx2;size(Metrics,1)];
%     end

end
       
% filtered1_M=Metrics(filter_idx1,:);
% filtered1_stk1=txt1(filter_idx1);
% filtered1_stk2=txt2(filter_idx1);
% 
% filtered2_M=Metrics(filter_idx2,:);
% filtered2_stk1=txt1(filter_idx2);
% filtered2_stk2=txt2(filter_idx2);
% % cd('C:\Users\ychen\Documents\MATLAB');
