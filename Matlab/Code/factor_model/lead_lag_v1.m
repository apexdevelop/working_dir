
clear all;
cd('C:\Users\ychen\Documents\MATLAB');
javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar');
v_names={'oil','shipping','utility','toshiba','hitachi','steel','coal','display','sony','solar','bond','softbank','aluminum','auto','spx','machinery','insurance'};
d_ranges={'b6:b39','b6:b40','b6:b29','b6:b35','b6:b31','b6:b37','b6:b34','b6:b39','b6:b40','b6:b37','b6:b52','b6:b10','b6:b28','b6:b22','b6:b37','b6:b28','b6:b23'};
w_ranges={'b40:b46','b41:b47','b30:b30','b36:b36','b32:b32','b38:b41','b35:b35','b40:b41','b41:b42','b38:b43','b53:b53','b11:b11','b29:b43','b23:b38','b39:b39','b29:b29','b24:b29'};
v_nab=[0,2,0,0,0,2,0,0,0,0,0,0,0,0,0];
sh_idx=1;

shname=char(v_names(sh_idx));
[~,txt1]=xlsread('factors_pval.xlsx',shname,char(d_ranges(sh_idx))); %factor
[~,txt2]=xlsread('factors_pval.xlsx',shname,'d1:zz1'); %equity
[~,txt3]=xlsread('factors_pval.xlsx',shname,'d2:zz2'); %market

window=66; % for calculating z
%% generate daily factor's Data
% curr='USD';
curr=[];
startdate='2012/01/04';
enddate=today();
per_n={'daily','non_trading_weekdays','nil_value'};
per_p={'daily','non_trading_weekdays','previous_value'};
field1='Last_Price';
field2='CHG_PCT_1D';
field3='CHG_PCT_5D';

[~, ~, eprices]=blp_data(transpose(txt2),field1,startdate,enddate,per_p,curr);
[~, edates, ertns_1d]=blp_data(transpose(txt2),field2,startdate,enddate,per_p,curr);
[~, ~, ertns_5d]=blp_data(transpose(txt2),field3,startdate,enddate,per_p,curr);

n_equity=size(txt2,2);


z_ertns_1d=zeros(1,n_equity);
z_ertns_5d=zeros(1,n_equity);
z_epxs=zeros(1,n_equity);
%% calculate zscore for equities
for p=1:n_equity
    ertn_1d=ertns_1d(:,p+1);
    ertn_1d=ertn_1d(~isnan(ertn_1d));
    edate_1d=edates(~isnan(ertn_1d),p+1);
    ertn_1d(find(~edate_1d))=[];
    
    ertn_5d=ertns_5d(:,p+1);
    ertn_5d=ertn_5d(~isnan(ertn_5d));
    ertn_5d(find(~edate_1d))=[];
    
    epx=eprices(:,p+1);
    epx=epx(~isnan(epx));
    epx(find(~edate_1d))=[];

    if window<size(ertn_1d,1)
       z_window=window;
    else
       z_window=size(ertn_1d,1);
    end
    
    temp_z1d=zscore(ertn_1d(end-z_window+1:end));
    z_ertns_1d(p)=temp_z1d(end);
    
    temp_z5d=zscore(ertn_5d(end-z_window+1:end));
    z_ertns_5d(p)=temp_z5d(end);
    
    temp_zpx=zscore(epx(end-z_window+1:end));
    z_epxs(p)=temp_zpx(end);
end


