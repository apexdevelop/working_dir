clearvars;
javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');
% txt1={'005490 KS Equity';'ISIXSTSC Index';'ISIX62IU Index'};
txt1={'7201 JP Equity';'7203 JP Equity';'7267 JP Equity'};
% txt1={'2600 HK Equity';'AWC AU Equity';'LAA Comdty'};
txt2={'TPX Index';'TPX Index';'TPX Index'};
% txt2={'HSI Index';'AS51 Index'};

startdate='2014/03/22';
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



log_ts = log(price1(:,2:end));
log_index = log(price2(:,2:end)); 

% rel_Y1=extract_country_single([log_ts(:,1) log_index(:,1)],4);
% rel_Y2=extract_country_single([log_ts(:,2) log_index(:,2)],4);
% rel_Y3=extract_country_single([log_ts(:,3) log_index(:,3)],4);
% rel_Y3=log_ts(:,3);

% Y=[rel_Y1 rel_Y2 rel_Y3];
Y=log_ts;

dates=m2xdate(date1(:,2),0);

%% Engle-Granger

[h1,~,~,~,reg] = egcitest(Y,'test','t2');
c0 = reg.coeff(1);
b = reg.coeff(2:end);
beta = [1; -b];

%% Johansen
[h2,~,stat,~,mles] = jcitest(Y,'model','H1*');
BJ = mles.r2.paramVals.B;
c0J = mles.r2.paramVals.c0;


% Normalize the 1st cointegrating relation(1st column) with respect to
%  the 1st variable, to make it comparable to Engle-Granger:
BJ1n = BJ(:,1)/BJ(1,1);
c0J1n = c0J(1)/BJ(1,1);

BJ2n = BJ(:,2)/BJ(1,2);
c0J2n = c0J(2)/BJ(1,2);

%% Comparison
% res1=Y*beta-c0;
res0=Y*beta-c0;
res1=Y*BJ1n+c0J1n;
res2=Y*BJ2n+c0J2n;

% window=22;
% 
% z_res1=zeros(size(res1,1),1);
% z_res2=zeros(size(res2,1),1);
% 
% z_res1(1:window,1)=zscore(res1(1:window,1));
% z_res2(1:window,1)=zscore(res2(1:window,1));
% 
% for i=window : size(res1,1)
%     temp_z1=zscore(res1(i-window+1:i,1));
%     temp_z2=zscore(res2(i-window+1:i,1));
%     z_res1(i,1)=temp_z1(end);
%     z_res2(i,1)=temp_z2(end);
% end

z_res0=zscore(res0);
z_res1=zscore(res1);
z_res2=zscore(res2);
% Plot the normalized Johansen cointegrating relation together
%  with the original Engle-Granger cointegrating relation:

COrd = get(gca,'ColorOrder');
plot(dates,z_res0,'LineWidth',2,'Color',COrd(3,:))
hold on
plot(dates,z_res1,'LineWidth',2,'Color',COrd(4,:))
hold on
plot(dates,z_res2,'--','LineWidth',2,'Color',COrd(5,:))
% legend('Engle-Granger OLS','Johansen MLE','Location','NW')
legend('Engle-Granger OLS','Johansen 1','Johansen 2','Location','NW')
title('{\bf Cointegrating Relation}')
axis tight
grid on
hold off