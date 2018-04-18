%the importance of determining a reasonable lag length for the VEC model (as well as the general form of the model) 
%before testing for cointegration.

clear all;
cd('C:\Users\ychen\Documents\MATLAB');
javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar');
txt1={'S Equity';'BABA Equity';'4689 JP Equity';'9984 JP Equity'};
txt2={'SPX Index';'TPX Index'};
coeff=[0.22;0.67;0.11];
startdate='2014/09/19';
enddate=today();
per={'daily','non_trading_weekdays','nil_value'};
% field='EQY_WEIGHTED_AVG_PX';
field='Last_Price';
c=blp;
for loop=1:size(txt1,1)
    new=char(txt1(loop));
    [d sec] = history(c, new,field,startdate,enddate,per);
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

c=blp;
for loop=1:size(txt2,1)
    new=char(txt2(loop));
    [d sec] = history(c, new,'Last_Price',startdate,enddate,per);
    date2(1:size(d,1),loop+1)=d(1:size(d,1),1);
    price2(1:size(d,1),loop+1)=d(1:size(d,1),2);
    
end;
close(c);

for n_time=1:size(date2,1)
    date2(n_time,1)=n_time;
end

for n_stk=1:size(price2,1)
    price2(n_stk,1)=n_stk;
end

date_ts1=date1(:,2);
px_ts1=price1(:,2);
date_ts1(isnan(px_ts1))=[];
px_ts1(isnan(px_ts1))=[];

date_ts2=date1(:,3);
px_ts2=price1(:,3);
date_ts2(isnan(px_ts2))=[];
px_ts2(isnan(px_ts2))=[];

date_ts3=date1(:,4);
px_ts3=price1(:,4);
date_ts3(isnan(px_ts3))=[];
px_ts3(isnan(px_ts3))=[];

date_ts4=date1(:,5);
px_ts4=price1(:,5);
date_ts4(isnan(px_ts4))=[];
px_ts4(isnan(px_ts4))=[];

date_index1=date2(:,2);
px_index1=price2(:,2);
date_index1(isnan(px_index1))=[];
px_index1(isnan(px_index1))=[];

date_index2=date2(:,3);
px_index2=price2(:,3);
date_index2(isnan(px_index2))=[];
px_index2(isnan(px_index2))=[];


c_dates1=cellstr(datestr(date_ts1));
c_dates2=cellstr(datestr(date_ts2));
c_dates3=cellstr(datestr(date_ts3));
c_dates4=cellstr(datestr(date_ts4));
c_dates5=cellstr(datestr(date_index1));
c_dates6=cellstr(datestr(date_index2));

t1=fints(c_dates1,px_ts1,'t1');
t2=fints(c_dates2,px_ts2,'t2');
t3=fints(c_dates3,px_ts3,'t3');
t4=fints(c_dates4,px_ts4,'t4');
t5=fints(c_dates5,px_index1,'t5');
t6=fints(c_dates6,px_index2,'t6');

newfts=merge(t1,t2,t3,t4,t5,t6,'DateSetMethod','Intersection');

tnd_mtx=fts2mat(newfts.t1,1);
str_dates=datestr(tnd_mtx(:,1));
c_dates=cellstr(str_dates);
% excel_dates=m2xdate(tnd_mtx(:,1),0);
tday=datenum(str_dates);

log_ts=log([fts2mat(newfts.t1) fts2mat(newfts.t2) fts2mat(newfts.t3) fts2mat(newfts.t4)]);
log_index=log([fts2mat(newfts.t5) fts2mat(newfts.t6)]);
rel_Y=extract_country_single([log_ts(:,4) log_index(:,2)],4);
rtn_Y=[diff(log_ts(:,4)) diff(log_index(:,1))];

rel_X1=extract_country_single([log_ts(:,1) log_index(:,1)],4);
rel_X2=extract_country_single([log_ts(:,2) log_index(:,1)],4);
rel_X3=extract_country_single([log_ts(:,3) log_index(:,2)],4);
X=[rel_X1 rel_X2 rel_X3];
% X=log_ts(:,1:3);
wX=X*coeff;

Y=[rel_Y wX log_index(:,2)]; %[softbank, (sprint,baba,yahoo japan combined), nikky]

window=44;
N=1;
Signal_TH=-1.0;
hp_TH=44;
Metrics=[];


% for Signal_TH=-2:0.1:2
    [metric,zscr,s]=copair_twoside_softbank(rtn_Y,Y(2:end,:),window,N,Signal_TH,hp_TH,tday(2:end));
    Metrics=[Metrics;metric];
% end
% [h0,~,~,~,reg] = egcitest(Y,'test','t2');
% c0 = reg.coeff(1);
% b = reg.coeff(2:end);
% beta = [1; -b];
% res0=Y*beta-c0;
% 
% 
% 
% z_res0=zeros(size(res0,1),1);
% z_res0(1:window,1)=zscore(res0(1:window,1));
% 
% for i=window : size(res0,1)
%     temp_z0=zscore(res0(i-window+1:i,1));
%     z_res0(i,1)=temp_z0(end);
% end


% secname='Softbank Modeling_Relative';
% ts1=timeseries(z_res0,c_dates,'name',secname);
% ts1.TimeInfo.StartDate=str_dates(1,:); %must be string
% ts1.TimeInfo.Format='mmm yy';
% plot(ts1,'LineWidth',2)
secname='Softbank Modeling_Relative';
ts1=timeseries(zscr,c_dates(2:end),'name',secname);
ts1.TimeInfo.StartDate=str_dates(2,:); %must be string
ts1.TimeInfo.Format='mmm yy';
plot(ts1,'LineWidth',2)
