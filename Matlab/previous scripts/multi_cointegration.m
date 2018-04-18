cd('C:\Documents and Settings\YChen\My Documents');
clear H;
clear P;
clear S;
clear y;

blp_simple;

n_stock=size(px,2)-1;
n_t=size(px,1);

dates=btxt(:,2);
Y = px(:,2:end); 
 
plot(dates,Y,'LineWidth',2)
xlabel('Year')
ylabel('Index Value')
legend(txt,'location','NW')
title('Equity and Bond Proxy for Insurance Company')
axis tight
grid on

[h,pValue,stat,cValue] = egcitest(Y,'test',{'t1','t2'});

[~,~,~,~,reg] = egcitest(Y,'test','t2');
 
c0 = reg.coeff(1);
b = reg.coeff(2:3);

COrd = get(gca,'ColorOrder'); 
set(gca,'NextPlot','ReplaceChildren','ColorOrder',circshift(COrd,3)) 
plot(dates,Y*[1;-b]-c0,'LineWidth',2)
title('{\bf Cointegrating Relation}')
axis tight
grid on