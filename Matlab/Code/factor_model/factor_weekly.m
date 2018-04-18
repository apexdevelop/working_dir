% how about calculating longterm correlation to decide negative or positive
% correlation
clearvars;
cd('C:\Users\ychen\Documents\MATLAB');
javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');
% shipping,utility,steel,coal,display,solar,bond,aluminum,exports,hitachi
shname='shipping';
[~,txt]=xlsread('factors_weekly.xlsx',shname,'a3:a9'); %factor

%% generate Data
startdate='2012/3/12';
enddate=today();
% per={'weekly','active_days_only','nil_value'};
per={'daily','non_trading_weekdays','nil_value'};

c=blp;
for loop=1:size(txt,1)
        new=char(txt(loop));
        [d1, sec] = history(c, new,'CHG_PCT_1D',startdate,enddate,per);
        [d2, sec] = history(c, new,'Last_Price',startdate,enddate,per);
        [d3, sec] = history(c, new,'CHG_PCT_5D',startdate,enddate,per);
        dates_5d(1:size(d1,1),loop)=d1(1:size(d1,1),1);
        rtns_5d(1:size(d1,1),loop)=d1(1:size(d1,1),2);
        fprices(1:size(d2,1),loop)=d2(1:size(d2,1),2);
        dates_1m(1:size(d3,1),loop)=d3(1:size(d3,1),1);
        rtns_1m(1:size(d3,1),loop)=d3(1:size(d3,1),2);
end;
close(c);

%% Initialize parameters
window=26;
N=1;
short_Metrics=[];
long_Metrics=[];

for n=1:size(txt,1) %factor
    tday_5d=dates_5d(:, n); 
    rtn_5d=rtns_5d(:,n);
    px=fprices(:, n);
    tday_1m=dates_1m(:,n);
    rtn_1m=rtns_1m(:,n);
    

%     tday_5d(isnan(px))=[];
    rtn_5d_forz=rtn_5d(~isnan(rtn_5d));
%     rtn_5d(isnan(px))=[];
%     px(isnan(px))=[];
    px_forz=px(~isnan(px));
    

%     tday_1m(isnan(rtn_1m))=[];
    rtn_1m_forz=rtn_1m(~isnan(rtn_1m));
%     rtn_1m(isnan(rtn_1m))=[];
    
%     px(find(~tday_5d))=[];
%     rtn_5d(find(~tday_5d))=[];
%     tday_5d(find(~tday_5d))=[];
%     
%     rtn_1m(find(~tday_1m))=[];
%     tday_1m(find(~tday_1m))=[];


    if window<size(rtn_5d_forz,1)
       M=window;
    else
       M=size(rtn_5d_forz,1);
    end
    
    short_zpx=zeros(size(px_forz,1),1);
    short_zpx(1:M-1)=zscore(px_forz(1:M-1));
    for i=M : size(px_forz,1)
        temp_zpx=zscore(px_forz(i-M+1:i,1));
        short_zpx(i,1)=temp_zpx(end);
    end
    long_zpx=zeros(size(px,1),1);
    long_zpx(~isnan(px))=short_zpx;
    
    short_z5d=zeros(size(rtn_5d_forz,1),1);
    short_z5d(1:M-1)=zscore(rtn_5d_forz(1:M-1));
    for i=M : size(rtn_5d_forz,1)
        temp_z5d=zscore(rtn_5d_forz(i-M+1:i,1));
        short_z5d(i,1)=temp_z5d(end);
    end    
    long_z5d=zeros(size(rtn_5d,1),1);
    long_z5d(~isnan(rtn_5d))=short_z5d;
    
    short_z1m=zeros(size(rtn_1m_forz,1),1);
    short_z1m(1:M-1)=zscore(rtn_1m_forz(1:M-1));
    for i=M : size(rtn_1m_forz,1)
        temp_z1m=zscore(rtn_1m_forz(i-M+1:i,1));
        short_z1m(i,1)=temp_z1m(end);
    end    
    long_z1m=zeros(size(rtn_1m,1),1);
    long_z1m(~isnan(rtn_1m))=short_z1m;
    
    short_metric=[rtn_5d_forz(end) short_z5d(end) rtn_1m_forz(end) short_z1m(end) short_zpx(end)];
    long_metric=[rtn_5d(end) long_z5d(end) rtn_1m(end)  long_z1m(end) long_zpx(end)];
%     short_Metrics=[short_Metrics;short_metric];
%     long_Metrics=[long_Metrics;long_metric];
end

str_dates=datestr(dates_5d);
c_dates=cellstr(str_dates);