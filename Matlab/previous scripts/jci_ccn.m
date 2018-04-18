

%The Engle-Granger Test for Cointegration

tday1=btxt(:,2);
adjcls1=bbpx(:, 2);

tday2=btxt(:,3);
adjcls2=bbpx(:, 3); 
tday=union(tday1, tday2); % find all the days when either GLD or GDX has data.
baddata1=find(any(tday));
tday(baddata1)=[];
[foo idx idx1]=intersect(tday, tday1);
Y=NaN(length(tday), 2); % combining the two price series
Y(idx, 1)=adjcls1(idx1);
[foo idx idx2]=intersect(tday, tday2);
Y(idx, 2)=adjcls2(idx2);
baddata=find(any(~isfinite(Y), 2)); % days where any one price is missing
tday(baddata)=[];
Y(baddata, :)=[];

tday_str=datestr(tday);
% tday_cell=cellstr(tday_str);

ts1=timeseries(Y(:,1),1:size(Y,1));
ts1.Name='CCN+12M Curncy';
ts1.TimeInfo.Units='days';
ts1.TimeInfo.StartDate=tday_str(1,:);
ts1.TimeInfo.Format='mmm yy';
ts1.Time=ts1.Time - ts1.Time(1);
subplot(2,1,1); 
plot(ts1,'LineWidth',2)
% set(gca,'XTick',tday);
% datetick('x','dd');
xlabel('Time')
ylabel('Curncy Value')
legend(names(1),'location','NW')
%title('Proxy for RMB inflow')
axis tight
grid on

ts2=timeseries(Y(:,2),1:size(Y,1));
ts2.Name='HSCCI Index';
ts2.TimeInfo.Units='days';
ts2.TimeInfo.StartDate=tday_str(1,:);
ts2.TimeInfo.Format='mmm yy';
ts2.Time=ts2.Time - ts2.Time(1);
subplot(2,1,2); 
plot(ts2,'LineWidth',2)
xlabel('Time')
ylabel('Index Value')
legend(names(2),'location','NW')
axis tight
grid on

[h,pValue,stat,cValue] = jcitest(Y,'model','H1','lags',1:2);

%sbionlinfit

% [~,~,~,~,reg] = egcitest(Y,'test','t2');
%  
% c0 = reg.coeff(1);
% b = reg.coeff(2);
% 
% COrd = get(gca,'ColorOrder'); 
% set(gca,'NextPlot','ReplaceChildren','ColorOrder',circshift(COrd,3)) 
% plot(tday,Y*[1;-b]-c0,'LineWidth',2)
% title('Cointegrating Relation')
% axis tight
% grid on


