clear all;
cd('C:\Users\ychen\Documents\MATLAB');
javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.8.8.2\lib\blpapi3.jar')
txt1={'MS Equity';'8306 JP Equity'};
txt2={'SPX Index';'HSI Index'};

startdate='2009/01/04';
enddate=today();
per={'daily','non_trading_weekdays','previous_value'};
c=blp;
for loop=1:size(txt1,1)
    new=char(txt1(loop));
    [d sec] = history(c, new,'Last_Price',startdate,enddate,per);
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
c_dates3=cellstr(datestr(date_index1));
c_dates4=cellstr(datestr(date_index2));

t1=fints(c_dates1,px_ts1,'t1');
t2=fints(c_dates2,px_ts2,'t2');
t3=fints(c_dates3,px_index1,'t3');
t4=fints(c_dates4,px_index2,'t4');

newfts=merge(t1,t2,t3,t4,'DateSetMethod','Intersection');

log_ts=log([fts2mat(newfts.t1) fts2mat(newfts.t2)]);
log_index=log([fts2mat(newfts.t3) fts2mat(newfts.t4)]);

rel_Y1=extract_country_single([log_ts(:,1) log_index(:,1)],4);
rel_Y2=extract_country_single([log_ts(:,2) log_index(:,2)],4);

% Y=[rel_Y1 rel_Y2];

tnd_mtx=fts2mat(newfts.t1,1);
str_dates=datestr(tnd_mtx(:,1));
c_dates=cellstr(str_dates);
tday=datenum(str_dates);
excel_dates=m2xdate(tday,0);

Y=log_ts;
X=[ones(size(Y,1),1) Y(:,2)];
% [bhat, bint, R, Rint, Stats]=regress(Y(:,1),X);

%% Engle-Granger

[h,pValue,~,~,reg1] = egcitest(Y,'test','t2');
% c0 = reg1.coeff(1);
% b = reg1.coeff(2:end);
% beta = [1; -b];
% res0=Y*beta-c0;
res0=reg1.res;

% window=22;
% 
% z_res0=zeros(size(res0,1),1);
% z_res0(1:window,1)=zscore(res0(1:window,1));
% for i=window : size(res0,1)
%     temp_z0=zscore(res0(i-window+1:i,1));
%     z_res0(i,1)=temp_z0(end);
% end

z_res1=zscore(res0);

mean_mov_5d=zeros(10,1);
sd_mov_5d=zeros(10,1);
sharpe_mov_5d=zeros(10,1);

for j=5:5
    ub=1+j*0.1;
    lb=1+(j-1)*0.1;
    v_ind=find(z_res1>=lb & z_res1<ub);
 
    v_mov_5d=zeros(size(v_ind,1),1);
    for i=1:size(v_ind,1)
        if v_ind(i) < (size(z_res1,1)-4)
           v_mov_5d(i) = z_res1(v_ind(i)+5)-z_res1(v_ind(i));
        end
    end
    mean_mov_5d(j)=mean(v_mov_5d);
    sd_mov_5d(j)=std(v_mov_5d);
    sharpe_mov_5d(j)=mean_mov_5d(j)/sd_mov_5d(j);
end

hist(v_mov_5d);
% plot(sharpe_mov_5d);
% legend('sharpe_mov_5d','Location','NW');
