

%The Engle-Granger Test for Cointegration

% plot(dates,Y,'LineWidth',2)
% xlabel('Year')
% ylabel('Index Value')
% legend(txt,'location','NW')
% title('Equity and Bond Proxy for Insurance Company')
% axis tight
% grid on

[h,pValue,stat,cValue] = egcitest(Y,'test',{'t1','t2'});

[~,~,~,~,reg] = egcitest(Y,'test','t2');
 
c0 = reg.coeff(1);
b = reg.coeff(2:end);

% COrd = get(gca,'ColorOrder'); 
% set(gca,'NextPlot','ReplaceChildren','ColorOrder',circshift(COrd,3)) 
% 
% eninpstr=datestr(comdate2);
% dates=cellstr(eninpstr); %convert string to cell string,because ts object require cell string date
% secname=[char(names(1)) ' regression residual'];
% ts1=timeseries(Y*[1;-b]-c0,dates,'name',secname);
% ts1.TimeInfo.StartDate=eninpstr(1,:); %must be string
% ts1.TimeInfo.Format='mmm yy';
% plot(ts1,'LineWidth',2)
% xlabel('Time')
% ylabel('residual')
% axis tight
% grid on

% plot(comdate2,Y*[1;-b]-c0,'LineWidth',2)
% title('Cointegrating Relation')
% axis tight
% grid on


