% clear all;
% cd('C:\Users\ychen\Documents\MATLAB');
% txt1={'10/14/2005';'monthly';'N';'Y'};
% txt2={'CHMMAPRO Index';'SPX Index';'2600 HK Equity';'HSI Index'};
% javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar');
 
function [s2,tday_cell,final1,temp_pks1,temp_vls1,final2,temp_pks2,temp_vls2,v_DF1,v_DF2]=single_peak_vally(txt1,txt2)
%% GET Bloomberg DATA
startdate=char(txt1(1));
c=blp;

if strcmp(txt1(2),'weekly')==1
   per={'weekly','non_trading_weekdays','previous_value'};
   % the choice of enddate affecting the date value when per is weekly or monthly
   enddate='11/7/2014';
elseif strcmp(txt1(2),'monthly')==1
   per={'monthly','non_trading_weekdays','previous_value'};
   enddate='10/31/2014';
else
   per={'daily','non_trading_weekdays','previous_value'};
   enddate=today();
end

for loop=1:size(txt2,1)
    new=char(txt2(loop));
    [d sec] = history(c, new,'PX_LAST',startdate,enddate,per);
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

%% resample factor 1 and factor 2
% stock1 and index1
tday1=btxt(:,2);
px1=bbpx(:,2);
%delete NaN
tday1(isnan(px1))=[];
px1(isnan(px1))=[];
%delete 0
tday1(find(~px1))=[];
px1(find(~px1))=[];

if strcmp(char(txt1(3)),'Y')==1
   tday_f1=btxt(:,3);
   px_f1=bbpx(:,3);%index1 price
   tday_f1(isnan(px_f1))=[];
   px_f1(isnan(px_f1))=[];
   tday_f1(find(~px_f1))=[];
   px_f1(find(~px_f1))=[];
   [f1n1,idx1,idxf1]=intersect(tday1,tday_f1);
    
   px1=px1(idx1);
   px_f1=px_f1(idxf1);
   tday1=tday1(idx1);
end

% stock2 and index2
tday2=btxt(:,4);
px2=bbpx(:,4);
tday2(isnan(px2))=[];
px2(isnan(px2))=[];
tday2(find(~px2))=[];
px2(find(~px2))=[];

if strcmp(char(txt1(4)),'Y')==1
   tday_f2=btxt(:,5);
   px_f2=bbpx(:,5);%index price
   tday_f2(isnan(px_f2))=[];
   px_f2(isnan(px_f2))=[];
   tday_f2(find(~px_f2))=[];
   px_f2(find(~px_f2))=[];
   [f2n2,idx2,idxf2]=intersect(tday2,tday_f2);
           
   px2=px2(idx2);
   px_f2=px_f2(idxf2);
   tday2=tday2(idx2);
end

if strcmp(txt1(2),'daily')==1
   [fn1n2, idxn1, idxn2]=intersect(tday1, tday2);
   tday2=tday2(idxn2);
   px1=px1(idxn1);%stock1
   if strcmp(char(txt1(3)),'Y')==1
      px_f1=px_f1(idxn1);%index1
   end
   px2=px2(idxn2);%stock2
   if strcmp(char(txt1(4)),'Y')==1
      px_f2=px_f2(idxn2);%index2
   end
end

equity_Y=[px1 px2];

if strcmp(char(txt1(3)),'Y')==1
   rel_px1=extract_country_single([px1 px_f1],3);
   factor1=rel_px1;
else
   factor1=px1;
end

if strcmp(char(txt1(4)),'Y')==1
   rel_px2=extract_country_single([px2 px_f2],3);   
   factor2=rel_px2;
else
   factor2=px2;
end

%% timeseries manipulation

s1=length(factor1);

N=20;
if s1>125
   M=125;
else
   M=s1-N-2;
end

% for Cointegration Test

z1 = zeros(s1,1);
z2 = zeros(s1,1);
zscr = zeros(s1,1);
j=M;
while j<=s1
%       [h,pValue,stat,~,reg1] = egcitest(Y(j-M+1:j, :));
      mu1=mean(factor1(j-M+1:j));
      sigma1=std(factor1(j-M+1:j));
      mu2=mean(factor2(j-M+1:j));
      sigma2=std(factor2(j-M+1:j));
      
      if j<=s1-N
         z1(j:j+N-1)=(factor1(j:j+N-1)-mu1)/sigma1;
         z2(j:j+N-1)=(factor2(j:j+N-1)-mu2)/sigma2;
      else
         z1(j:end)=(factor1(j:end)-mu1)/sigma1;
         z2(j:end)=(factor2(j:end)-mu2)/sigma2;
      end
      j=j+N;
end 


% final1 =factor1(M:end);
% final2 =factor2(M:end);
final1 =factor1;
final2 =factor2;
% tday_cell=cellstr(datestr(tday2(M:end),'mm/dd/yyyy'));
tday_cell=cellstr(datestr(tday2,'mm/dd/yyyy'));

v_lag=2:40;
v_DF1=find_dof(factor1,factor2,v_lag);
v_DF2=find_dof(factor2,factor1,v_lag);
%% find peaks
% s2=length(final1);
s2=s1;
x1=1:s2;
x2=1:s2;
% final1_row=reshape(final1,1,s2);
% final2_row=reshape(final2,1,s2);
final1_row=reshape(factor1,1,s2);
final2_row=reshape(factor2,1,s2);

% minpeakdistance must between 1 and 30, as the findpeak function required

if strcmp(txt1(2),'weekly')==1
    min_distance=8;
elseif strcmp(txt1(2),'daily')==1
    min_distance=22;
elseif strcmp(txt1(2),'monthly')==1
    min_distance=4;
else
end

minpeak1=quantile(final1_row,0.4);
minpeak2=quantile(final2_row,0.4);

TH1= (max(final1_row)-min(final1_row))/s2;
TH2= (max(final2_row)-min(final2_row))/s2; 

[pks1,locs1]=findpeaks(final1_row,'MINPEAKHEIGHT',minpeak1,'MINPEAKDISTANCE',min_distance,'THRESHOLD',TH1,'SORTSTR','none');
[pks2,locs2]=findpeaks(final2_row,'MINPEAKHEIGHT',minpeak2,'MINPEAKDISTANCE',min_distance,'THRESHOLD',TH2,'SORTSTR','none');


final1_row_inv=-final1_row;
final2_row_inv=-final2_row;

minpeak1_inv=quantile(-final1_row,0.4);
minpeak2_inv=quantile(-final2_row,0.4);

TH1_inv=TH1;
TH2_inv=TH2;
% TH1_inv=max(final1_row_inv)-quantile(final1_row_inv,1-1/s2);
% TH2_inv= max(final2_row_inv)-quantile(final2_row_inv,1-1/s2); 

[vls1,locs_v1]=findpeaks(final1_row_inv,'MINPEAKHEIGHT',minpeak1_inv,'MINPEAKDISTANCE',min_distance,'THRESHOLD',TH1_inv);
[vls2,locs_v2]=findpeaks(final2_row_inv,'MINPEAKHEIGHT',minpeak2_inv,'MINPEAKDISTANCE',min_distance,'THRESHOLD',TH2_inv);

temp_pks1=NaN(s2,1);
temp_pks1(locs1)=pks1;

temp_pks2=NaN(s2,1);
temp_pks2(locs2)=pks2;

temp_vls1=NaN(s2,1);
temp_vls1(locs_v1)=-vls1;

temp_vls2=NaN(s2,1);
temp_vls2(locs_v2)=-vls2;

% subplot(2,1,1); plot(final1_row);
% hold on; 
% plot(x1(locs1(1,:)),pks1,'k^','markerfacecolor',[1 0 0]);
% subplot(2,1,2); plot(final2_row);
% hold on; 
% plot(x2(locs2(1,:)),pks2,'k^','markerfacecolor',[1 0 0]);
% 
% subplot(2,1,1); plot(final1_row);
% hold on; 
% plot(x1(locs_v1(1,:)),-vls1,'k^','markerfacecolor',[0 0 1]);
% subplot(2,1,2); plot(final2_row);
% hold on; 
% plot(x2(locs_v2(1,:)),-vls2,'k^','markerfacecolor',[0 0 1]);
