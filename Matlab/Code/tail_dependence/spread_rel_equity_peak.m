
% clear all;
% cd('C:\Users\ychen\Documents\MATLAB');
% txt1={'005490 KS Equity';'KOSPI Index';'ISIXSTSC Index';'ISIX62IU Index'};
% txt2={'10/14/2005';'monthly';'Y';'Y';'Ratio';125;20};
% javaaddpath('C:\blp\ServerAPI\APIv3\JavaAPI\v3.4.5.5\lib\blpapi3.jar')

function [s2,tday_spread,final_spread,temp_pks1,temp_vls1,final_rel_equity,temp_pks2,temp_vls2,v_DF1,v_DF2]=spread_rel_equity_peak(txt1,txt2)
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
tday1=btxt(:,4);
factor1=bbpx(:,4);

%delete NaN
tday1(isnan(factor1))=[];
factor1(isnan(factor1))=[];
%delete 0
tday1(find(~factor1))=[];
factor1(find(~factor1))=[];

tday2=btxt(:,5);
factor2=bbpx(:,5);

%delete NaN
tday2(isnan(factor2))=[];
factor2(isnan(factor2))=[];
%delete 0
tday2(find(~factor2))=[];
factor2(find(~factor2))=[];

[foo, idx1, idx2]=intersect(tday1, tday2);
tday1=tday1(idx1);
tday2=tday2(idx2);
factor1=factor1(idx1);
factor2=factor2(idx2);    
tday_s=tday2;

%calculate spread
if strcmp(txt2(5),'Ratio')==1
   spread=factor1(1:end)./factor2(1:end);
elseif strcmp(txt2(5),'Spread')==1
   spread=factor1(1:end)-factor2(1:end); 
else
end

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
   [~, idx_r, idx_s]=intersect(tday_r, tday_s);
   
   index=index(idx_r);
   equity=equity(idx_r);
   rel_equity=extract_country_single([equity index],3); 
   tday_r=tday_r(idx_r);

   spread=spread(idx_s);
   tday_s=tday_s(idx_s);
end
%% timeseries manipulation
s1=length(spread);
if strcmp(txt2(2),'daily')==1
   rel_equity_row=reshape(rel_equity,1,s1); %tsmovavg function only works on row array
   rel_equity_row=tsmovavg(rel_equity_row,'e',5);
   rel_equity=reshape(rel_equity_row(5:end),size(rel_equity_row,2)-4,1);    
   tday_r=tday_r(5:end);
   
   spread_row=reshape(spread,1,s1);
   spread_row=tsmovavg(spread_row,'e',5);
   spread=reshape(spread_row(5:end),size(spread_row,2)-4,1);
   tday_s=tday_s(5:end);
   s1=length(spread);
end

tday_rel_equity=cellstr(datestr(tday_r));
tday_spread=cellstr(datestr(tday_s));

M=double(cell2mat(txt2(6)));
% N=double(cell2mat(txt2(7)));
N=20;

if s1<M
   M=s1-N-2;
end

z_spread = zeros(s1,1);
z_rel_equity = zeros(s1,1);

z_spread(1:M-1)=zscore(spread(1:M-1));
z_rel_equity(1:M-1)=zscore(rel_equity(1:M-1));

j=M;
while j<=s1
      mu_spread=mean(spread(j-M+1:j));
      sigma_spread=std(spread(j-M+1:j));
      mu_rel_equity=mean(rel_equity(j-M+1:j));
      sigma_rel_equity=std(rel_equity(j-M+1:j));
      
      if j<=s1-N         
         z_spread(j:j+N-1)=(spread(j:j+N-1)-mu_spread)/sigma_spread;
         z_rel_equity(j:j+N-1)=(rel_equity(j:j+N-1)-mu_rel_equity)/sigma_rel_equity;
      else         
         z_spread(j:end)=(spread(j:end)-mu_spread)/sigma_spread;
         z_rel_equity(j:end)=(rel_equity(j:end)-mu_rel_equity)/sigma_rel_equity;
      end               
      j=j+N;
end 

is_normal_spread=char(txt2(3));
if strcmp(is_normal_spread,'Y')
   final_spread =z_spread;
   tday_spread=tday_spread;
else
   final_spread =spread;
   tday_spread=tday_spread;
end

is_normal_rel_equity=char(txt2(4));
if strcmp(is_normal_rel_equity,'Y')
   final_rel_equity =z_rel_equity;
else
   final_rel_equity =rel_equity;
end

v_lag=2:40;
v_DF1=find_dof(spread,rel_equity,v_lag);
v_DF2=find_dof(rel_equity,spread,v_lag);

% tday_index=tday_index(M:end);
s2=length(final_spread);
%% find peaks
x1=1:s2;
x2=1:s2;
final_rel_equity_row=reshape(final_rel_equity,1,s2);
final_spread_row=reshape(final_spread,1,s2);

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

minpeak1=quantile(final_spread_row,0.5);
minpeak2=quantile(final_rel_equity_row,0.5);

% TH1= (max(final_spread_row)-min(final_spread_row))/s2;
TH2= (max(final_rel_equity_row)-min(final_rel_equity_row))/s2;
TH1=0;
 

[pks1,locs1]=findpeaks(final_spread_row,'MINPEAKHEIGHT',minpeak1,'MINPEAKDISTANCE',min_distance,'THRESHOLD',TH1,'SORTSTR','none');
[pks2,locs2]=findpeaks(final_rel_equity_row,'MINPEAKHEIGHT',minpeak2,'MINPEAKDISTANCE',min_distance,'THRESHOLD',TH2,'SORTSTR','none');

final_spread_row_inv=-final_spread_row;
final_rel_equity_row_inv=-final_rel_equity_row;

minpeak1_inv=quantile(-final_spread_row,0.5);
minpeak2_inv=quantile(-final_rel_equity_row,0.5);

TH1_inv=TH1;
TH2_inv=TH2; 

[vls1,locs_v1]=findpeaks(final_spread_row_inv,'MINPEAKHEIGHT',minpeak1_inv,'MINPEAKDISTANCE',min_distance,'THRESHOLD',TH1_inv);
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