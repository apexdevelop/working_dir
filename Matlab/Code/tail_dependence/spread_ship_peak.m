
% clear all;
% cd('C:\Users\ychen\Documents\MATLAB');
% txt1={'7203 JP Equity';'7267 JP Equity';'JDCSTYTA Index';'JDCSHNDA Index'};
% txt2={'11/5/2004';'monthly';'Y';'Y'};
% javaaddpath('C:\blp\ServerAPI\APIv3\JavaAPI\v3.4.5.5\lib\blpapi3.jar')
function [s2,tday_f,final_spread_f,temp_pks1,temp_vls1,final_spread_e,temp_pks2,temp_vls2,v_DF]=spread_ship_peak(txt1,txt2)
%% GET Bloomberg DATA
enddate=today();
startdate=char(txt2(1));
c=blp;

%active_days_only,non_trading_weekdays,all_calendar_days
if strcmp(txt2(2),'weekly')==1
   per={'weekly','non_trading_weekdays','previous_value'};
elseif strcmp(txt2(2),'monthly')==1
   per={'monthly','non_trading_weekdays','previous_value'};
   enddate='10/31/2014';
else
   per={'daily','non_trading_weekdays','previous_value'}; 
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

%% resample equity1 and equity2
tday1=btxt(:,2);
equity1=bbpx(:,2);

%delete NaN
tday1(isnan(equity1))=[];
equity1(isnan(equity1))=[];
%delete 0
tday1(find(~tday1))=[];
equity1(find(~tday1))=[];

tday2=btxt(:,3);
equity2=bbpx(:,3);
%delete NaN
tday2(isnan(equity2))=[];
equity2(isnan(equity2))=[];
%delete 0
tday2(find(~tday2))=[];
equity2(find(~tday2))=[];

[~, idx1, idx2]=intersect(tday1, tday2);
tday1=tday1(idx1);
tday2=tday2(idx2);
equity1=equity1(idx1);
equity2=equity2(idx2);    
tday_e=tday2;

%calculate spread_e

spread_e=equity1(1:end)-equity2(1:end);  

%% resample factor 1 and factor 2
tday3=btxt(:,4);
factor1=bbpx(:,4);
%delete NaN
tday3(isnan(factor1))=[];
factor1(isnan(factor1))=[];
%delete 0
tday3(find(~tday3))=[];
factor1(find(~tday3))=[];

tday4=btxt(:,5);
factor2=bbpx(:,5);
%delete NaN
tday4(isnan(factor2))=[];
factor2(isnan(factor2))=[];
%delete 0
tday4(find(~tday4))=[];
factor2(find(~tday4))=[];

[~, idx3, idx4]=intersect(tday3, tday4);
tday3=tday3(idx3);
tday4=tday4(idx4);
factor1=factor1(idx3);
factor2=factor2(idx4);    
tday_f=tday4;

%calculate spread_f

spread_f=factor1(1:end)-factor2(1:end);  

%% resample spread_e and spread_f
[~, idx5, idx6]=intersect(tday_e, tday_f);

spread_e=spread_e(idx5);
tday_e=tday_e(idx5);

spread_f=spread_f(idx6);
tday_f=tday_f(idx6);

%% timeseries manipulation
if strcmp(txt2(2),'daily')==1
   spread_e_row=reshape(spread_e,1,size(spread_e,1)); %tsmovavg function only works on row array
   spread_e_row=tsmovavg(spread_e_row,'e',5);
   spread_e=reshape(spread_e_row(5:end),size(spread_e_row,2)-4,1);    
   tday_e=tday_e(5:end);
   
   spread_f_row=reshape(spread_f,1,size(spread_f,1));
   spread_f_row=tsmovavg(spread_f_row,'e',5);
   spread_f=reshape(spread_f_row(5:end),size(spread_f_row,2)-4,1);
   tday_f=tday_f(5:end);   
end

s1=length(spread_f);
tday_f=cellstr(datestr(tday_f));
tday_e=cellstr(datestr(tday_e));

N=20;
M=125;
if s1<M
   M=s1-N-2;
end

% for Cointegration Test
Y=[spread_e spread_f];

z_spread_f = zeros(s1,1);
z_spread_e = zeros(s1,1);

z_spread_f(1:M-1)=zscore(spread_f(1:M-1));
z_spread_e(1:M-1)=zscore(spread_e(1:M-1));

zscr = zeros(s1,1);
j=M;
while j<=s1
%       [h,pValue,stat,~,reg1] = egcitest(Y(j-M+1:j, :));
%       b=reg1.coeff(2:end);
      mu_spread_f=mean(spread_f(j-M+1:j));
      sigma_spread_f=std(spread_f(j-M+1:j));
      mu_spread_e=mean(spread_e(j-M+1:j));
      sigma_spread_e=std(spread_e(j-M+1:j));
      
      if j<=s1-N
%          residual=Y(j:j+N-1,:)*[1;-b]-reg1.coeff(1);
%          zscr(j:j+N-1)=(residual-0)/reg1.RMSE;
         z_spread_f(j:j+N-1)=(spread_f(j:j+N-1)-mu_spread_f)/sigma_spread_f;
         z_spread_e(j:j+N-1)=(spread_e(j:j+N-1)-mu_spread_e)/sigma_spread_e;
      else
%          residual=Y(j:end,:)*[1;-b]-reg1.coeff(1);
%          zscr(j:end)=(residual-0)/reg1.RMSE;
         z_spread_f(j:end)=(spread_f(j:end)-mu_spread_f)/sigma_spread_f;
         z_spread_e(j:end)=(spread_e(j:end)-mu_spread_e)/sigma_spread_e;
      end
      j=j+N;
end 

is_normal_spread_f=char(txt2(3));
if strcmp(is_normal_spread_f,'Y')
   final_spread_f =z_spread_f;
else
   final_spread_f =spread_f;
end

is_normal_spread_e=char(txt2(4));
if strcmp(is_normal_spread_e,'Y')
   final_spread_e =z_spread_e;
else
   final_spread_e =spread_e;
end

v_lag=2:40;
v_DF=find_dof(spread_f,spread_e,v_lag);

s2=length(final_spread_f);
%% find peaks
x1=1:s2;
x2=1:s2;
final_spread_e_row=reshape(final_spread_e,1,s2);
final_spread_f_row=reshape(final_spread_f,1,s2);

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

minpeak1=quantile(final_spread_f_row,0.4);
minpeak2=quantile(final_spread_e_row,0.4);

TH1=max(final_spread_f_row)-quantile(final_spread_f_row,0.999);
TH2= max(final_spread_e_row)-quantile(final_spread_e_row,0.999); 

[pks1,locs1]=findpeaks(final_spread_f_row,'MINPEAKHEIGHT',minpeak1,'MINPEAKDISTANCE',min_distance,'THRESHOLD',TH1,'SORTSTR','none');
[pks2,locs2]=findpeaks(final_spread_e_row,'MINPEAKHEIGHT',minpeak2,'MINPEAKDISTANCE',min_distance,'THRESHOLD',TH2,'SORTSTR','none');

final_spread_f_row_inv=-final_spread_f_row;
final_spread_e_row_inv=-final_spread_e_row;

minpeak1_inv=quantile(-final_spread_f_row,0.4);
minpeak2_inv=quantile(-final_spread_e_row,0.4);

TH1_inv=max(final_spread_f_row_inv)-quantile(final_spread_f_row_inv,0.999);
TH2_inv= max(final_spread_e_row_inv)-quantile(final_spread_e_row_inv,0.999); 

[vls1,locs_v1]=findpeaks(final_spread_f_row_inv,'MINPEAKHEIGHT',minpeak1_inv,'MINPEAKDISTANCE',min_distance,'THRESHOLD',TH1_inv);
[vls2,locs_v2]=findpeaks(final_spread_e_row_inv,'MINPEAKHEIGHT',minpeak2_inv,'MINPEAKDISTANCE',min_distance,'THRESHOLD',TH2_inv);

temp_pks1=NaN(s2,1);
temp_pks1(locs1)=pks1;

temp_pks2=NaN(s2,1);
temp_pks2(locs2)=pks2;

temp_vls1=NaN(s2,1);
temp_vls1(locs_v1)=-vls1;

temp_vls2=NaN(s2,1);
temp_vls2(locs_v2)=-vls2;

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
