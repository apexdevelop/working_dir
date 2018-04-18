
% clear all;
% cd('C:\Users\ychen\Documents\MATLAB');
% txt1={'FXI Equity';'CNY Curncy';'CCN+12M Curncy'};
% txt2={'3/30/2013';'daily';'N';'Y'};
% javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar')

function [s2,tday_spread,final_spread,temp_pks1,temp_vls1,final_index,temp_pks2,temp_vls2,v_DF1,v_DF2]=spread_equity_peak(txt1,txt2)
%% GET Bloomberg DATA
startdate=char(txt2(1));
c=blp;

if strcmp(txt2(2),'weekly')==1
   per={'weekly','non_trading_weekdays','previous_value'};
   % the choice of enddate affecting the date value when per is weekly or monthly
   enddate='11/21/2014';
elseif strcmp(txt2(2),'monthly')==1
   per={'monthly','non_trading_weekdays','previous_value'};
   enddate='10/31/2014';
else
%    per={'daily','non_trading_weekdays','previous_value'};
   per='daily';
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
tday1=btxt(:,3);
factor1=bbpx(:,3);

%delete NaN
tday1(isnan(factor1))=[];
factor1(isnan(factor1))=[];
%delete 0
tday1(find(~factor1))=[];
factor1(find(~factor1))=[];


tday2=btxt(:,4);
factor2=bbpx(:,4);

%delete NaN
tday2(isnan(factor2))=[];
factor2(isnan(factor2))=[];
%delete 0
tday2(find(~factor2))=[];
factor2(find(~factor2))=[];

[~, idx1, idx2]=intersect(tday1, tday2);
% tday1=tday1(idx1);
tday2=tday2(idx2);
factor1=factor1(idx1);
factor2=factor2(idx2);    
tday_s=tday2;

%calculate spread
% spread=factor1(1:end)./factor2(1:end);
spread=factor1(1:end)-factor2(1:end);  

%% get index price and resample again
t_index=btxt(:,2);
index=bbpx(:,2);

%delete NaN
t_index(isnan(index))=[];
index(isnan(index))=[];
%delete 0
t_index(find(~index))=[];
index(find(~index))=[];

[~, idx_i, idx_s]=intersect(t_index, tday_s);

index=index(idx_i);
t_index=t_index(idx_i);
spread=spread(idx_s);
tday_s=tday_s(idx_s);

%% timeseries manipulation
s1=length(spread);
if strcmp(per,'daily')==1
   index_row=reshape(index,1,s1); %tsmovavg function only works on row array
   index_row=tsmovavg(index_row,'e',5);
   index=reshape(index_row(5:end),size(index_row,2)-4,1);    
   t_index=t_index(5:end);
   
   spread_row=reshape(spread,1,s1);
   spread_row=tsmovavg(spread_row,'e',5);
   spread=reshape(spread_row(5:end),size(spread_row,2)-4,1);
   tday_s=tday_s(5:end);   
end
s1=length(spread);
% tday_index=cellstr(datestr(t_index));
tday_spread=cellstr(datestr(tday_s));

N=20;
if s1>125
   M=125;
else
   M=s1-N-2;
end

% for Cointegration Test
% Y=[index spread];

z_spread = zeros(s1,1);
z_index = zeros(s1,1);

z_spread(1:M-1)=zscore(spread(1:M-1));
z_index(1:M-1)=zscore(index(1:M-1));

j=M;
while j<=s1
      mu_spread=mean(spread(j-M+1:j));
      sigma_spread=std(spread(j-M+1:j));
      mu_index=mean(index(j-M+1:j));
      sigma_index=std(index(j-M+1:j));
      
      if j<=s1-N         
         z_spread(j:j+N-1)=(spread(j:j+N-1)-mu_spread)/sigma_spread;
         z_index(j:j+N-1)=(index(j:j+N-1)-mu_index)/sigma_index;
      else         
         z_spread(j:end)=(spread(j:end)-mu_spread)/sigma_spread;
         z_index(j:end)=(index(j:end)-mu_index)/sigma_index;
      end               
      j=j+N;
end 

is_normal_spread=char(txt2(3));
if strcmp(is_normal_spread,'Y')
   final_spread =z_spread;
else
   final_spread =spread;
end

is_normal_index=char(txt2(4));
if strcmp(is_normal_index,'Y')
   final_index =z_index;
else
   final_index =index;
end

v_lag=2:40;
v_DF1=find_dof(spread,index,v_lag);
v_DF2=find_dof(index,spread,v_lag);

% tday_index=tday_index(M:end);
s2=length(final_spread);
%% find peaks
x1=1:s2;
x2=1:s2;
final_index_row=reshape(final_index,1,s2);
final_spread_row=reshape(final_spread,1,s2);

% minpeakdistance must between 1 and 30, as the findpeak function required
% min_distance=floor(s2/10);

if strcmp(txt2(2),'weekly')==1
    min_distance=8;
elseif strcmp(txt2(2),'daily')==1
    min_distance=22;
elseif strcmp(txt2(2),'monthly')==1
    min_distance=4;
else
end

minpeak1=quantile(final_spread_row,0.4);
minpeak2=quantile(final_index_row,0.4);

TH1= (max(final_spread_row)-min(final_spread_row))/s2;
TH2= (max(final_index_row)-min(final_index_row))/s2; 

[pks1,locs1]=findpeaks(final_spread_row,'MINPEAKHEIGHT',minpeak1,'MINPEAKDISTANCE',min_distance,'THRESHOLD',TH1,'SORTSTR','none');
[pks2,locs2]=findpeaks(final_index_row,'MINPEAKHEIGHT',minpeak2,'MINPEAKDISTANCE',min_distance,'THRESHOLD',TH2,'SORTSTR','none');

final_spread_row_inv=-final_spread_row;
final_rel_equity_row_inv=-final_index_row;

minpeak1_inv=quantile(-final_spread_row,0.4);
minpeak2_inv=quantile(-final_index_row,0.4);

TH1_inv=TH1;
TH2_inv=TH2; 

[vls1,locs_v1]=findpeaks(final_spread_row_inv,'MINPEAKHEIGHT',minpeak1_inv,'MINPEAKDISTANCE',min_distance,'THRESHOLD',TH1_inv);
[vls2,locs_v2]=findpeaks(final_rel_equity_row_inv,'MINPEAKHEIGHT',minpeak2_inv,'MINPEAKDISTANCE',min_distance,'THRESHOLD',TH2_inv);

% subplot(2,1,1); plot(final_spread_row);
% hold on; 
% plot(x1(locs1(1,:)),pks1,'k^','markerfacecolor',[1 0 0]);
% subplot(2,1,2); plot(final_index_row);
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


temp_pks1=NaN(s2,1);
temp_pks1(locs1)=pks1;

temp_pks2=NaN(s2,1);
temp_pks2(locs2)=pks2;

temp_vls1=NaN(s2,1);
temp_vls1(locs_v1)=-vls1;

temp_vls2=NaN(s2,1);
temp_vls2(locs_v2)=-vls2;
