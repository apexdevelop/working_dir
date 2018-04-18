%the importance of determining a reasonable lag length for the VEC model (as well as the general form of the model) 
%before testing for cointegration.

clear all;
cd('C:\Users\ychen\Documents\MATLAB');
javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar');
txt1={'8750 JP Equity';'NKY Index';'GJGB10 Index'};

startdate='2013/09/19';
enddate=today();
per={'daily','non_trading_weekdays','nil_value'};
c=blp;
for loop=1:size(txt1,1)
    new=char(txt1(loop));
    [d sec] = history(c, new,'LAST_PRICE',startdate,enddate,per);
    date1(1:size(d,1),loop+1)=d(1:size(d,1),1);
    price1(1:size(d,1),loop+1)=d(1:size(d,1),2);
    
end;
close(c);

for n_time=1:size(date1,1)
    date1(n_time,1)=n_time;
end

for n_stk=1:size(price1,1)
    price1(n_stk,1)=n_stk;
end

%8750 jp
date_ts1=date1(:,2);
px_ts1=price1(:,2);
date_ts1(isnan(px_ts1))=[];
px_ts1(isnan(px_ts1))=[];

%nky index
date_ts2=date1(:,3);
px_ts2=price1(:,3);
date_ts2(isnan(px_ts2))=[];
px_ts2(isnan(px_ts2))=[];

%gjgb10 index
date_ts3=date1(:,4);
rate_ts3=price1(:,4);
date_ts3(isnan(rate_ts3))=[];
rate_ts3(isnan(rate_ts3))=[];
px_ts3=exp(rate_ts3).^2;
% px_ts3=100-exp(rate_ts3);

c_dates1=cellstr(datestr(date_ts1));
c_dates2=cellstr(datestr(date_ts2));
c_dates3=cellstr(datestr(date_ts3));

t1=fints(c_dates1,px_ts1,'t1');
t2=fints(c_dates2,px_ts2,'t2');
t3=fints(c_dates3,px_ts3,'t3');

newfts=merge(t1,t2,t3,'DateSetMethod','Intersection');

tnd_mtx=fts2mat(newfts.t1,1);
str_dates=datestr(tnd_mtx(:,1));
c_dates=cellstr(str_dates);
% excel_dates=m2xdate(tnd_mtx(:,1),0);
tday=datenum(str_dates);

log_ts=log([fts2mat(newfts.t1) fts2mat(newfts.t2) fts2mat(newfts.t3)]);
rtn_Y=[diff(log_ts(:,1)) diff(log_ts(:,2))];

window=130;
N=15;
% Signal_TH=-1.0;
hp_TH=44;
Metrics=[];

for Signal_TH=0.5:0.1:2
    [metric,zscr,s]=copair_twoside_softbank(rtn_Y,log_ts(2:end,:),window,N,Signal_TH,hp_TH,tday(2:end));
    Metrics=[Metrics;metric];
end

% Y=log_ts;
% [h0,~,~,~,reg] = egcitest(Y,'test','t2');
% c0 = reg.coeff(1);
% b = reg.coeff(2:end);
% beta = [1; -b];
% res0=Y*beta-c0;
% 
% 
% z_res0=zeros(size(res0,1),1);
% z_res0(1:window,1)=zscore(res0(1:window,1));
% 
% for i=window : size(res0,1)
%     temp_z0=zscore(res0(i-window+1:i,1));
%     z_res0(i,1)=temp_z0(end);
% end
% 
% 
secname=[char(txt1(1)) ' -- ' char(txt1(2)) ' and ' char(txt1(3))];
ts1=timeseries(zscr,c_dates(2:end),'name',secname);
ts1.TimeInfo.StartDate=str_dates(2,:); %must be string
ts1.TimeInfo.Format='mmm yy';
plot(ts1,'LineWidth',2)

