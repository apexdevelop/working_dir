
% clear all;
% cd('C:\Users\ychen\Documents\MATLAB');
% txt1={'005490 KS Equity';'KOSPI Index';'ISIXSTSC Index';'ISIX62IU Index'};
% txt2={'10/14/2005';'monthly';'Y';'Y';'Ratio';125;20};
% javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar')

function [s2,tday_factor,final_factor,temp_pks1,temp_vls1,final_rel_equity,temp_pks2,temp_vls2,v_DF1,v_DF2]=factor_rel_equity_peak(txt1,txt2)
%% GET Bloomberg DATA
startdate=char(txt2(1));
c=blp;

if strcmp(txt2(2),'weekly')==1
   per={'weekly','non_trading_weekdays','previous_value'};
   % the choice of enddate affecting the date value when per is weekly or monthly
%    enddate='10/17/2014';
   enddate=today();
elseif strcmp(txt2(2),'monthly')==1
   per={'monthly','non_trading_weekdays','previous_value'};
   enddate='10/31/2014';
else
   per={'daily','non_trading_weekdays','previous_value'};
   enddate=today();
end

for loop=1:size(txt1,1)
    new=char(txt1(loop));
    [d sec] = history(c, new,'Last_Price',startdate,enddate,per);
%    [d sec] = history(c, new,'CHG_PCT_1D',startdate,enddate,per);
    btxt(1:size(d,1),loop+1)=d(1:size(d,1),1);
    bbpx(1:size(d,1),loop+1)=d(1:size(d,1),2);
end;

close(c);

for n_time=1:size(btxt,1)
    btxt(n_time,1)=n_time;
end

for n_stk=1:size(bbpx,1)
    bbpx(n_stk,1)=n_stk;
end
n_ob=size(btxt,1);

%% resample factor 1 and factor 2
tday_f=btxt(:,4);
px_f=bbpx(:,4);

%delete NaN
tday_f(isnan(px_f))=[];
px_f(isnan(px_f))=[];
%delete 0
tday_f(find(~px_f))=[];
px_f(find(~px_f))=[];


%% get equity and index price and resample again
t_equity=btxt(:,2);
equity=bbpx(:,2);
%delete NaN
t_equity(isnan(equity))=[];
equity(isnan(equity))=[];
%delete 0
t_equity(find(~equity))=[];
equity(find(~equity))=[];

t_index=btxt(:,3);
index=bbpx(:,3);

%delete NaN
t_index(isnan(index))=[];
index(isnan(index))=[];
%delete 0
t_index(find(~index))=[];
index(find(~index))=[];

[~, idx3, idx4]=intersect(t_equity, t_index);
t_equity=t_equity(idx3);
equity=equity(idx3);
t_index=t_index(idx4);
index=index(idx4);    
tday_r=t_index;

if strcmp(txt2(2),'weekly')==1 || strcmp(txt2(2),'monthly')==1    
   rel_equity=extract_country_single([equity index],3); 
else    
   [~, idx_r, idx_f]=intersect(tday_r, tday_f);
   
   index=index(idx_r);
   equity=equity(idx_r);
   rel_equity=extract_country_single([equity index],3); 
   tday_r=tday_r(idx_r);

   px_f=px_f(idx_f);
   tday_f=tday_f(idx_f);
end
%% timeseries manipulation
s1=length(px_f);
if strcmp(txt2(2),'daily')==1
   rel_equity_row=reshape(rel_equity,1,s1); %tsmovavg function only works on row array
   rel_equity_row=tsmovavg(rel_equity_row,'e',5);
   rel_equity=reshape(rel_equity_row(5:end),size(rel_equity_row,2)-4,1);    
   tday_r=tday_r(5:end);
   
   factor_row=reshape(px_f,1,s1);
   factor_row=tsmovavg(factor_row,'e',5);
   px_f=reshape(factor_row(5:end),size(factor_row,2)-4,1);
   tday_f=tday_f(5:end);
   s1=length(px_f);
end

tday_rel_equity=cellstr(datestr(tday_r));
tday_factor=cellstr(datestr(tday_f));

M=double(cell2mat(txt2(6)));
% N=double(cell2mat(txt2(7)));
N=20;

if s1<M
   M=s1-N-2;
end

z_factor = zeros(s1,1);
z_rel_equity = zeros(s1,1);

z_factor(1:M-1)=zscore(px_f(1:M-1));
z_rel_equity(1:M-1)=zscore(rel_equity(1:M-1));

j=M;
while j<=s1
      mu_factor=mean(px_f(j-M+1:j));
      sigma_factor=std(px_f(j-M+1:j));
      mu_rel_equity=mean(rel_equity(j-M+1:j));
      sigma_rel_equity=std(rel_equity(j-M+1:j));
      
      if j<=s1-N         
         z_factor(j:j+N-1)=(px_f(j:j+N-1)-mu_factor)/sigma_factor;
         z_rel_equity(j:j+N-1)=(rel_equity(j:j+N-1)-mu_rel_equity)/sigma_rel_equity;
      else         
         z_factor(j:end)=(px_f(j:end)-mu_factor)/sigma_factor;
         z_rel_equity(j:end)=(rel_equity(j:end)-mu_rel_equity)/sigma_rel_equity;
      end               
      j=j+N;
end 

is_normal_factor=char(txt2(3));
if strcmp(is_normal_factor,'Y')
   final_factor =z_factor;
   tday_factor=tday_factor;
else
   final_factor =px_f;
   tday_factor=tday_factor;
end

is_normal_rel_equity=char(txt2(4));
if strcmp(is_normal_rel_equity,'Y')
   final_rel_equity =z_rel_equity;
else
   final_rel_equity =rel_equity;
end

v_lag=2:40;
v_DF1=find_dof(px_f,rel_equity,v_lag);
v_DF2=find_dof(rel_equity,px_f,v_lag);

% tday_index=tday_index(M:end);
s2=length(final_factor);
%% find peaks
x1=1:s2;
x2=1:s2;
final_rel_equity_row=reshape(final_rel_equity,1,s2);
final_factor_row=reshape(final_factor,1,s2);

% minpeakdistance must between 1 and 30, as the findpeak function required
% min_distance=floor(s2/10);

if strcmp(txt2(2),'weekly')==1
    min_distance=8;
elseif strcmp(txt2(2),'daily')==1
    min_distance=22;
elseif strcmp(txt2(2),'monthly')==1
    min_distance=2;
else
end

minpeak1=quantile(final_factor_row,0.5);
minpeak2=quantile(final_rel_equity_row,0.5);

% TH1= (max(final_spread_row)-min(final_spread_row))/s2;
TH2= (max(final_rel_equity_row)-min(final_rel_equity_row))/s2;
TH1=0;
 

[pks1,locs1]=findpeaks(final_factor_row,'MINPEAKHEIGHT',minpeak1,'MINPEAKDISTANCE',min_distance,'THRESHOLD',TH1,'SORTSTR','none');
[pks2,locs2]=findpeaks(final_rel_equity_row,'MINPEAKHEIGHT',minpeak2,'MINPEAKDISTANCE',min_distance,'THRESHOLD',TH2,'SORTSTR','none');

final_factor_row_inv=-final_factor_row;
final_rel_equity_row_inv=-final_rel_equity_row;

minpeak1_inv=quantile(-final_factor_row,0.5);
minpeak2_inv=quantile(-final_rel_equity_row,0.5);

TH1_inv=TH1;
TH2_inv=TH2; 

[vls1,locs_v1]=findpeaks(final_factor_row_inv,'MINPEAKHEIGHT',minpeak1_inv,'MINPEAKDISTANCE',min_distance,'THRESHOLD',TH1_inv);
[vls2,locs_v2]=findpeaks(final_rel_equity_row_inv,'MINPEAKHEIGHT',minpeak2_inv,'MINPEAKDISTANCE',min_distance,'THRESHOLD',TH2_inv);


temp_pks1=NaN(s2,1);
temp_pks1(locs1)=pks1;

temp_pks2=NaN(s2,1);
temp_pks2(locs2)=pks2;

temp_vls1=NaN(s2,1);
temp_vls1(locs_v1)=-vls1;

temp_vls2=NaN(s2,1);
temp_vls2(locs_v2)=-vls2;
% 
% subplot(2,1,1); plot(final_spread_row);
% hold on; 
% plot(x1(locs1(1,:)),pks1,'k^','markerfacecolor',[1 0 0]);
% subplot(2,1,2); plot(final_rel_equity_row);
% hold on; 
% plot(x2(locs2(1,:)),pks2,'k^','markerfacecolor',[1 0 0]);

%     if size(locs1)>size(locs2)
%        for t=1:size(locs2)
%              if abs(locs1(t)-locs2(t))>30 && abs(locs2(t)-locs1(t+1)<30)
%                 locs1(t)=[];
%              end
%        end
%     else
%        if abs(locs1(size(locs1,2))-locs2(size(locs2,2)))>30
%           locs2(size(locs2,2))=[];
%        end
%        if  abs(locs1(1)-locs2(1))>30
%            locs2(1)=[];
%        end