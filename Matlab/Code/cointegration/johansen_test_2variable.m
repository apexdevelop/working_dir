%the importance of determining a reasonable lag length for the VEC model (as well as the general form of the model) 
%before testing for cointegration.

clear all;
cd('C:\Users\ychen\Documents\MATLAB');
javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar')
txt1={'105560 KS Equity';'055550 KS Equity'};
txt2={'TPX Index';'SPX Index'};

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

% rel_Y1=extract_country_single([log_ts(:,1) log_index(:,1)],4);
% rel_Y2=extract_country_single([log_ts(:,2) log_index(:,2)],4);
% Y=[rel_Y1 rel_Y2];

Y=log_ts;
tnd_mtx=fts2mat(newfts.t1,1);
str_dates=datestr(tnd_mtx(:,1));
c_dates=cellstr(str_dates);
% excel_dates=m2xdate(tnd_mtx(:,1),0);
tday=datenum(str_dates);

Signal_TH=1.5;
pADF_TH=0.20;
hp_TH=44;
M=500;
N=5;
%% Engle-Granger

% [h_e,~,~,~,reg] = egcitest(Y,'test','t2');
% c0 = reg.coeff(1);
% b = reg.coeff(2:end);
% beta = [1; -b];
method='engle';
[metric_e,beta_e,z_res_e]=copair_test(method,Y,M,N,Signal_TH,pADF_TH,hp_TH,tday);

%% Johansen
% Normalize the 1st cointegrating relation(1st column) with respect to
%  the 1st variable, to make it comparable to Engle-Granger:
[h_j,pValue,stat,~,mles] = jcitest(Y,'model','H1');
BJ = mles.r1.paramVals.B;
c0J = mles.r1.paramVals.c0;
BJ1n = BJ(:,1)/BJ(1,1);
c0J1n = c0J(1)/BJ(1,1);

method='johansen';
[metric_j,beta_j,z_res_j]=copair_test(method,Y,M,N,Signal_TH,pADF_TH,hp_TH,tday);
plus_outliers=find(z_res_j>5);
z_res_j(plus_outliers)=4;
minus_outliers=find(z_res_j<-5);
z_res_j(minus_outliers)=-5;
%% Comparison
% res_e2=Y*beta-c0;
% z_res_e=zscore(res_e2);

% res_j=Y*BJ1n+c0J1n;
% z_res_j=zscore(res_j);

% Plot the normalized Johansen cointegrating relation together
%  with the original Engle-Granger cointegrating relation:

v_res=[z_res_e,z_res_j];

secname=[char(txt1(1)) ' and ' char(txt1(2))];
ts1=timeseries(v_res,c_dates,'name',secname);
ts1.TimeInfo.StartDate=str_dates(1,:); %must be string
ts1.TimeInfo.Format='mmm yy';
plot(ts1,'LineWidth',2)

% COrd = get(gca,'ColorOrder');
% plot(c_dates,z_res_e,'LineWidth',2,'Color',COrd(4,:))
% hold on
% plot(c_dates,z_res_j,'--','LineWidth',2,'Color',COrd(5,:))
legend(['Engle-Granger ',num2str(M),'d Rolling'],'Johansen MLE','Location','NW')
% legend(['Engle-Granger ',num2str(M),'d Rolling'],'Engle-Granger Whole','Location','NW')
title([secname, ' Cointegrating Relation'])
xlabel('Time')
ylabel('z_residual')
axis tight
grid on
% hold off

% j=M;
% NY1=Y(j-M+1:j,:);
% [h,pValue,~,~,mles] = jcitest(NY1,'model','H1','display','off');
% BJ2 = mles.r1.paramVals.B;
% BJ1n2 = BJ2(:,1)/BJ2(1,1)
% j=j+N