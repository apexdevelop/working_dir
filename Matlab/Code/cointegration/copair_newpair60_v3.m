% clearvars;
% javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');
% cd('Z:\Proj\Trading\Yan\Model 2.1\Cointegration');
% 
% [~,txt1]=xlsread('Copair_samecountry_9.xlsm','pairs','e2:e159');
% [~,txt2]=xlsread('Copair_samecountry_9.xlsm','pairs','h2:h159');
% mat_SignalTH=xlsread('Copair_samecountry_9.xlsm','pairs','s2:s159');
% mat_ADFTH=xlsread('Copair_samecountry_9.xlsm','pairs','t2:t159');
% mat_status=xlsread('Copair_samecountry_9.xlsm','pairs','u2:u159');
% mat_direction=xlsread('Copair_samecountry_9.xlsm','pairs','v2:v159');
% mat_ret=xlsread('Copair_samecountry_9.xlsm','pairs','w2:w159');
% mat_vol=xlsread('Copair_samecountry_9.xlsm','pairs','x2:x159');
% mat_winp=xlsread('Copair_samecountry_9.xlsm','pairs','y2:y159');
% mat_omega=xlsread('Copair_samecountry_9.xlsm','pairs','z2:z159');
% mat_hp=xlsread('Copair_samecountry_9.xlsm','pairs','aa2:aa159');
% mat_trades=xlsread('Copair_samecountry_9.xlsm','pairs','ab2:ab159');
% mat_enterdates=xlsread('Copair_samecountry_9.xlsm','pairs','ac2:ac159');
% mat_exitdates=xlsread('Copair_samecountry_9.xlsm','pairs','ad2:ad159');
% % txt1={'8591 JP Equity'};
% % txt2={'8306 JP Equity'};
% % v_SignalTH={2.70};
% % v_ADFTH={0.20};
% % v_status={1};
% input_param={'01/01/2009','Y',1,'Y'};


function [output_Metrics,filtered2_stk1,filtered2_stk2,filtered2_M,filtered1_stk1,filtered1_stk2,filtered1_M,v_Rtn]= copair_newpair60_v3(txt1,txt2,input_param,input_Metrics)
%% import data set from bloomberg and generate pairs
mat_SignalTH=cell2mat(input_Metrics(:,1));
mat_ADFTH=cell2mat(input_Metrics(:,2));
mat_status=cell2mat(input_Metrics(:,3));
mat_direction=cell2mat(input_Metrics(:,4));
mat_ret=cell2mat(input_Metrics(:,5));
mat_vol=cell2mat(input_Metrics(:,6));
mat_winp=cell2mat(input_Metrics(:,7));
mat_omega=cell2mat(input_Metrics(:,8));
mat_hp=cell2mat(input_Metrics(:,9));
mat_trades=cell2mat(input_Metrics(:,10));
mat_enterdates=cell2mat(input_Metrics(:,11));
mat_exitdates=cell2mat(input_Metrics(:,12));

beta_idx=cell2mat(input_param(3));
%beta_idx=1 log price
%beta_idx=2 demean log price
%beta_idx=3 normalize log price

is_adf=char(input_param(4));

startdate=char(input_param(1));
% enddate=today();
enddate=char(input_param(7));
per='daily';
field='LAST_PRICE'; %use vwap to exclude suspended days
curr='USD';

% GET DATA
[~, date1, price1]=blp_data(txt1,field,startdate,enddate,per,curr);
[~, date2, price2]=blp_data(txt2,field,startdate,enddate,per,curr);

n_pair=size(price1,2)-1;

%% Initialize parameters and metrics
M =60;
N = 5;
scaling=1;
cost=0;
hp_TH=44;

filter_hp=60;
filter_Beta=0.5;
filter_Rsqr=0.1;
filter_Winp=0;
exception=-99999;

Names1=[];%store stock1 names
Names2=[];%store stock2 names
output_Metrics=[]; %store outputs
filter_idx1=[]; % store index for qualified pairs
filter_idx2=[];
v_Rtn=[];
v_Date=[];


min_spread=1;
max_pADF=0.4;

cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/Coint');
S_OPTI=load(strcat('c_OPTI_',num2str(M),'_',num2str(N)));
c_OPTI=S_OPTI.c_OPTI;
S_StockWise=load(strcat('c_StockWise_',num2str(M),'_',num2str(N)));
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
           
    tday_m=tday2(idx2);
    tempY=zeros(size(n1n2,1),2);
    tempY(:,1)=adjcls1(idx1);%stock1
    tempY(:,2)=adjcls2(idx2);%stock2
           
    %convert to log prices
 
    Y=log(tempY);
    tday_m(find(Y(:,1)==-Inf))=[];
    tday_m(find(Y(:,2)==-Inf))=[];
    Y(find(Y(:,1)==-Inf),:)=[];
    Y(find(Y(:,2)==-Inf),:)=[];
    
    old_ret=mat_ret(sn);
    old_vol=mat_vol(sn);
    old_winp=mat_winp(sn);
    old_omega=mat_omega(sn);
    old_hp=mat_hp(sn);
    old_trades=mat_trades(sn);
    old_status=mat_status(sn);
    direction=mat_direction(sn);
    enterdate_m=x2mdate(mat_enterdates(sn));
    exitdate_m=x2mdate(mat_exitdates(sn));
    %%
    old_Signal_TH=mat_SignalTH(sn);
    old_pADF_TH=mat_ADFTH(sn);
    new_name=nameStr(sn,:);
    db_name=string(c_OPTI(:,1:2));
    stkLia=ismember(db_name,new_name,'rows');
    stk_idx=find(stkLia); % find logical 1
    if isempty(stk_idx)==0
       Names1=[Names1;new_name(1)];
       Names2=[Names2;new_name(2)];
%        db_subset=cell2mat(c_StockWise{1,stk_idx}(:,5:6));
%        TH_target=[1,0.15];
%        thLia=ismembertol(db_subset,TH_target,'ByRows',true);
%        TH_idx=find(thLia);
       c_Stock=c_StockWise{1,stk_idx}; 
       [new_metric,zscr]=copair_backtest_v7(c_Stock,beta_idx,Y,M,N,old_Signal_TH,old_pADF_TH,hp_TH,scaling,cost,tday_m,old_status,direction,old_ret,old_vol,old_winp,old_omega,old_hp,old_trades,enterdate_m,exitdate_m);
       is_database=1;
       new_metric=[new_metric is_database];
    else
       %no metrics in database, can only run new backtesting
       [new_metric,zscr]=copair_backtest6(beta_idx,Y,M,N,old_Signal_TH,old_pADF_TH,hp_TH,scaling,cost,tday_m,min_spread,max_pADF,old_status);
       is_database=0;
       new_metric=[new_metric is_database];
    end
    output_Metrics=[output_Metrics;new_metric];
    
    %% filtering
    %filtering criteria1 
    %abs(Beta)<3 and abs(Beta)>0.2, long term pADF<=0.1,is_open=1,has
    %enter is in recent 2 month,Winp>0.5
    if abs(new_metric(19))<=1/filter_Beta && abs(new_metric(19))>=filter_Beta && new_metric(18)<=max_pADF ...
    && new_metric(7)==1 && new_metric(15)>m2xdate(today()-filter_hp,0) && new_metric(11)>filter_Winp    
      filter_idx1=[filter_idx1;size(output_Metrics,1)];
    end
    
    %filtering criteria2
    % enter is in recent 2 month and expected rtn>0
    if new_metric(15)>m2xdate(today()-filter_hp,0) ...
%        && new_metric(11)>filter_Winp
       filter_idx2=[filter_idx2;size(output_Metrics,1)];
    end    
end
filtered1_M=output_Metrics(filter_idx1,:);
filtered1_stk1=txt1(filter_idx1);
filtered1_stk2=txt2(filter_idx1);

filtered2_M=output_Metrics(filter_idx2,:);
filtered2_stk1=txt1(filter_idx2);
filtered2_stk2=txt2(filter_idx2);       

