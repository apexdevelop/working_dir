function [txt1,txt2,txt3,edates,eprices,ertns,fdates,fprices,frtns,bdates,bprices,brtns]= sf_datafeed(sh_idx,startdate,enddate)

% clearvars;
cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/factor/single_factor');
% % javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');
filename='factors_v3.xlsx';
% oil,shipping,utility,hitachi,steel,coal,display,solar,jp_bond,kr_bond,aluminum,machinery
v_shnames={'oil','shipping','utility','hitachi','steel','coal','display','solar','jp_bond','kr_bond','aluminum1','aluminum2','machinery','semi','sugar','aapl','shenzhou'};
e_ranges={'d1:i1','d1:n1','d1:j1','d1:d1','d1:i1','d1:f1','d1:i1','d1:h1','d1:p1','d1:g1','d1:e1','d1:e1','d1:h1','d1:h1','d1:g1','d1:o1','d1:d1'};
b_ranges={'d2:i2','d2:n2','d2:j2','d2:d2','d2:i2','d2:f2','d2:i2','d2:h2','d2:p2','d2:g2','d2:e2','d2:e2','d2:h2','d2:h2','d2:g2','d2:o2','d2:d2'};
d_ranges={'d5:i51','d5:n39','d5:j31','d5:d18','d5:i38','d5:i28','d5:i32','d5:h30','d5:p29','d5:g23','d5:e27','d5:e27','d5:h24','d5:h15','d5:g19','d5:o5','d5:d9'};
% sh_idx=5;
shname=char(v_shnames(sh_idx));
[~,txt2]=xlsread(filename,shname,'b5:b100'); %factor
[~,txt1]=xlsread(filename,shname,char(e_ranges(sh_idx)));  %equity
[~,txt3]=xlsread(filename,shname,char(b_ranges(sh_idx)));  %benchmark
[effect,~]=xlsread(filename,shname,char(d_ranges(sh_idx)));  %effect


%% generate Data

% startdate='2012/3/12';
% enddate=today();
per={'daily','non_trading_weekdays','previous_value'};
curr=[];
field1='LAST_PRICE';
field2='CHG_PCT_1D';
[~, edates, eprices]=blp_data(transpose(txt1),field1,startdate,enddate,per,curr);
[~, ~, ertns]=blp_data(transpose(txt1),field2,startdate,enddate,per,curr);
[~, fdates, fprices]=blp_data(txt2,field1,startdate,enddate,per,curr);
[~, ~, frtns]=blp_data(txt2,field2,startdate,enddate,per,curr);
[~, bdates, bprices]=blp_data(transpose(txt3),field1,startdate,enddate,per,curr);
[~, ~, brtns]=blp_data(transpose(txt3),field2,startdate,enddate,per,curr);
