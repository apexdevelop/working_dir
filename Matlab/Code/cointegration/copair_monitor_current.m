% clear all;
% javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar')
% cd('C:\Users\ychen\Documents\MATLAB');
% txt1={'WBA equity'};
% txt2={'OEX index'};
% cell_SignalTH={0.18};
% cell_ADFTH={0.25};
% input_param={'01/01/2009',1};
% cell_lookback={200};
% cell_rebalance={30};
% cell_isopen={0};
% cell_Direction={0};
% cell_enterdate={'12/22/2014'};
% cell_exitdate={'7/14/1916'};
% 
% if matlabpool('size') ~= 0
%    matlabpool close force local;
% end

function [Metrics1,Metrics2]= copair_monitor_current(txt1,txt2,input_param,cell_lookback,cell_rebalance,cell_ADFTH,cell_SignalTH,cell_isopen,cell_Direction,cell_enterdate,cell_exitdate)

%% import data set from bloomberg and generate pairs

startdate=char(input_param(1));
per='daily';

[~, date1, price1]=blp_test(txt1,startdate,per);
[~, date2, price2]=blp_test(txt2,startdate,per);

n_pair=size(price1,2)-1;

%% Initialize parameters and metrics
% M = 80;
% N = 15;

beta_idx=cell2mat(input_param(2));
%beta_idx=1 log price
%beta_idx=2 demean log price
%beta_idx=3 normalize log price

v_lookback=cell2mat(cell_lookback);
v_rebalance=cell2mat(cell_rebalance);
v_ADFTH=cell2mat(cell_ADFTH);
v_SignalTH=cell2mat(cell_SignalTH);
v_isopen=cell2mat(cell_isopen);
v_direction=cell2mat(cell_Direction);

Metrics1=[]; %store outputs
Metrics2=[]; %store outputs
%%
if matlabpool('size') == 0
   matlabpool local
end


for sn=1:n_pair
    tday1=date1(:, sn+1); 
    adjcls1=price1(:, sn+1);
    tday1(find(~tday1))=[];
    adjcls1(find(~adjcls1))=[];
    
    tday2=date2(:, sn+1); 
    adjcls2=price2(:, sn+1);
    tday2(find(~tday2))=[];
    adjcls2(find(~adjcls2))=[];
    [n1n2, idx1, idx2]=intersect(tday1, tday2); 
           
    Y=zeros(size(n1n2,1),2);
    Y(:,1)=adjcls1(idx1);%stock1
    Y(:,2)=adjcls2(idx2);%stock2
           
    %convert to log prices
    logY=log(Y);
    
    switch v_lookback(sn)
        case 40
            M=40;
        case 80
            M=80;
        case 120
            M=120;
        case 160
            M=160;
        case 200
            M=200;
        otherwise
            M=240;
    end
    
    switch v_rebalance(sn)
        case 10
            N=10;
        case 20
            N=20; 
        case 30
            N=30;
        case 40
            N=40;
        case 50
            N=50;
        otherwise
            N=60;
    end
    
    %% 
    [new_metric1,new_metric2]=copair_sweep_current(beta_idx,logY,M,N,v_ADFTH(sn),v_SignalTH(sn),v_isopen(sn),v_direction(sn),char(cell_enterdate(sn)),char(cell_exitdate(sn))); 
    Metrics1=[Metrics1;new_metric1];
    Metrics2=[Metrics2;new_metric2];
end

