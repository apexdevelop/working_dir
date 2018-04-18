

%The Engle-Granger Test for Cointegration

dates=btxt(:,2);
%Y = rbbpx(:,2:end); 
 Y = rbbpx;
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
b = reg.coeff(2);

COrd = get(gca,'ColorOrder'); 
set(gca,'NextPlot','ReplaceChildren','ColorOrder',circshift(COrd,3)) 
plot(dates,Y*[1;-b]-c0,'LineWidth',2)
title('Cointegrating Relation')
axis tight
grid on


