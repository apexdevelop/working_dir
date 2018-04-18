% clear all;
% javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar')
% cd('C:\Users\ychen\Documents\MATLAB');
% txt1={'SX7EEX GY Equity'};
% txt3={'EBANK TB Equity'};
% txt2={'SXXP Index'};
% txt4={'SET Index'};
% input_param={'01/01/2009';'Y';1;'Y'};
% 
% 
% if matlabpool('size') ~= 0
%    matlabpool close force local;
% end

function [Metrics,filtered2_stk1,filtered2_stk2,filtered2_M,filtered1_stk1,filtered1_stk2,filtered1_M,v_Rtn]= copair_find_newpair(txt1,txt2,txt3,txt4,input_param)
%% import data set from bloomberg and generate pairs
startdate=char(input_param(1));
enddate=today();
is_opti=char(input_param(2));
is_adf=char(input_param(4));
per='daily';
field='Last_Price';
curr='USD';


[names1, date1, price1]=blp_data(txt1,field,startdate,enddate,per,curr);%equity
[fnames1, fdate1, fprice1]=blp_data(txt2,field,startdate,enddate,per,curr);%market index
[names2, date2, price2]=blp_data(txt3,field,startdate,enddate,per,curr);%equity
[fnames2, fdate2, fprice2]=blp_data(txt4,field,startdate,enddate,per,curr);%market index

n_pair=size(price1,2)-1;

%% Initialize parameters and metrics
M=60;
N=5;
spread=1:0.1:2.5;
p_ADF=[0.05,0.2];
scaling=1;
cost=0;

hp_TH=66;
Beta_TH=0.5;
Rsqr_TH=0.1;
PnL_TH=0;

beta_idx=cell2mat(input_param(3));
%beta_idx=1 log price
%beta_idx=2 demean log price
%beta_idx=3 normalize log price

Metrics=[]; %store outputs
filter_idx1=[]; % store index for qualified pairs
filter_idx2=[];
v_Rtn=[];
v_Date=[];
%%
if parpool('local') == 0
   parpool local
end

range1 = {M,N,spread,p_ADF};

for sn=1:n_pair

    tday1=date1(:,sn+1); 
    adjcls1=price1(:,sn+1);
    tday1(isnan(adjcls1))=[];
    adjcls1(isnan(adjcls1))=[];
    adjcls1(find(~tday1))=[];
    tday1(find(~tday1))=[];
    
    tday_f1=fdate1(:,sn+1);
    px_f1=fprice1(:,sn+1);%index1 price
    tday_f1(isnan(px_f1))=[];
    px_f1(isnan(px_f1))=[];
    px_f1(find(~tday_f1))=[];
    tday_f1(find(~tday_f1))=[];
    
    [f1n1,idx1,idxf1]=intersect(tday1,tday_f1);
    
    tempY1=zeros(size(f1n1,1),2);
    tempY1(:,1)=adjcls1(idx1);
    tempY1(:,2)=px_f1(idxf1);
    temp_date1=tday1(idx1);
    
    tday2=date2(:, sn+1); 
    adjcls2=price2(:, sn+1);
    tday2(isnan(adjcls2))=[];
    adjcls2(isnan(adjcls2))=[];
    adjcls2(find(~tday2))=[];
    tday2(find(~tday2))=[];
    
    tday_f2=fdate2(:,sn+1);
    px_f2=fprice2(:,sn+1);%index price
    tday_f2(isnan(px_f2))=[];
    px_f2(isnan(px_f2))=[];
    px_f2(find(~tday_f2))=[];
    tday_f2(find(~tday_f2))=[];
    
    [f2n2,idx2,idxf2]=intersect(tday2,tday_f2);
           
    tempY2=zeros(size(f2n2,1),2);
    tempY2(:,1)=adjcls2(idx2);
    tempY2(:,2)=px_f2(idxf2);
    temp_date2=tday2(idx2);
           
    [fn1n2, idxn1, idxn2]=intersect(temp_date1, temp_date2); 
%     tday=m2xdate(tday2(idxn2),0);%in excel format
    tday=tday2(idxn2);
    
    equity_Y=zeros(size(fn1n2,1),2);
    index_Y=zeros(size(fn1n2,1),2);

    equity_Y(:,1)=tempY1(idxn1,1);%stock1
    index_Y(:,1)=tempY1(idxn1,2);%index1
    equity_Y(:,2)=tempY2(idxn2,1);%stock2
    index_Y(:,2)=tempY2(idxn2,2);%index2
           
    logY1=log(equity_Y);
    logY2=log(index_Y);           
    %extract country factor
    Y=extract_country(logY1,logY2,4);%rel_logY
    tday(find(Y(:,1)==-Inf))=[];
    tday(find(Y(:,2)==-Inf))=[];
    Y(find(Y(:,1)==-Inf),:)=[];
    Y(find(Y(:,2)==-Inf),:)=[];
           
    %% 
       pfun = @(x) pairsFun(is_adf,beta_idx, x, Y, scaling, cost);
       [respmax1,param1,resp1] = parameterSweep(pfun,range1);
       
       M=param1(1);
       N=param1(2);       
       Signal_TH=param1(3);
       pADF_TH=param1(4);
       [new_metric,r]=copair_sweep(beta_idx,Y,M,N,Signal_TH,pADF_TH,hp_TH,scaling,cost,tday,min(spread),max(p_ADF));
       new_metric=[param1 respmax1 new_metric];
    
              
    Metrics=[Metrics;new_metric];
    
    if sn==1
       v_Rtn=[v_Rtn r];
       v_Date=[v_Date tday];
    else
       v_Rtn=supervertcat(v_Rtn,r);
       v_Date=supervertcat(v_Date,tday);
    end
    
    %abs(Beta)<3 and abs(Beta)>0.2, Rsqr>0.1,direction=1,last
    %enter is in recent 2 month
    if abs(new_metric(12))<=1/Beta_TH && abs(new_metric(12))>=Beta_TH && new_metric(6)<=2*max(p_ADF) ...
    && new_metric(20)==1 && new_metric(22)>m2xdate(today()-60,0);    
      filter_idx1=[filter_idx1;size(Metrics,1)];
    end
    
    if new_metric(22)>m2xdate(today()-60,0);
       filter_idx2=[filter_idx2;size(Metrics,1)];
    end
           
end
       
filtered1_M=Metrics(filter_idx1,:);
filtered1_stk1=txt1(filter_idx1);
filtered1_stk2=txt3(filter_idx1);

filtered2_M=Metrics(filter_idx2,:);
filtered2_stk1=txt1(filter_idx2);
filtered2_stk2=txt3(filter_idx2);


