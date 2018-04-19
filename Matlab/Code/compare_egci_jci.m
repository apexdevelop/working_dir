clear all;
cd('C:\Users\ychen\Documents\MATLAB');
load Data_Canada
Y = Data(:,3:end); % Interest rate data
[~,~,~,~,reg] = egcitest(Y,'test','t2');
c0 = reg.coeff(1);
b = reg.coeff(2:3);
beta = [1; -b];

[~,~,stat,~,mles] = jcitest(Y,'model','H1*');
BJ2 = mles.r2.paramVals.B;
c0J2 = mles.r2.paramVals.c0;

% Normalize the 2nd cointegrating relation with respect to
%  the 1st variable, to make it comparable to Engle-Granger:
BJ2n = BJ2(:,2)/BJ2(1,2);
c0J2n = c0J2(2)/BJ2(1,2);

% Plot the normalized Johansen cointegrating relation together
%  with the original Engle-Granger cointegrating relation:

COrd = get(gca,'ColorOrder');

plot(dates,Y*beta-c0,'LineWidth',2,'Color',COrd(4,:))
hold on
plot(dates,Y*BJ2n+c0J2n,'--','LineWidth',2,'Color',COrd(5,:))
legend('Engle-Granger OLS','Johansen MLE','Location','NW')
title('{\bf Cointegrating Relation}')
axis tight
grid on
hold off