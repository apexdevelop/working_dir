function [res]= vec(Y)
%% The Engle-Granger Test for Cointegration

% plot(dates,Y,'LineWidth',2)
% xlabel('Year')
% ylabel('Index Value')
% legend(txt,'location','NW')
% title('Equity and Bond Proxy for Insurance Company')
% axis tight
% grid on

% [h,pValue,stat,cValue] = egcitest(Y,'test',{'t1','t2'});

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


%% Estimating VEC Model Parameters

q = 2;
[numObs,numDims] = size(Y);
tBase = (q+2):numObs; % Commensurate time base, all lags
T = length(tBase); % Effective sample size
YLags = lagmatrix(Y,0:(q+1)); % Y(t-k) on observed time base
LY = YLags(tBase,(numDims+1):2*numDims); 
% Y(t-1) on commensurate time base
 
% Form multidimensional differences so that 
% the kth numDims-wide block of
% columns in DelatYLags contains (1-L)Y(t-k+1):
 
DeltaYLags = zeros(T,(q+1)*numDims);
for k = 1:(q+1)
    DeltaYLags(:,((k-1)*numDims+1):k*numDims) = ...
               YLags(tBase,((k-1)*numDims+1):k*numDims) ...
             - YLags(tBase,(k*numDims+1):(k+1)*numDims);
end
 

% first three columns are deltaY(t),middle ones are deltaY(t-1),last ones
% are deltaY(t-2)

DY = DeltaYLags(:,1:numDims); % (1-L)Y(t)
DLY = DeltaYLags(:,(numDims+1):end); % [(1-L)Y(t-1),...,(1-L)Y(t-q)]

% Perform the regression: 
X = [(LY*[1;-b]-c0),DLY,ones(T,1)];
P = (X\DY)'; % [a,B1,...,Bq,c1]
a = P(:,1);
B1 = P(:,2:3);
B2 = P(:,4:5);
c1 = P(:,end);
 
% Display model coefficients
% a,b,c0,B1,B2,c1
FY=X*P';
res = DY-FY;
EstCov = cov(res);

% legend_vec={'DY','FY'};
% 
% 
% plot(comdate2(4:end),[DY(:,1) FY(:,1)],'LineWidth',2)
% xlabel('Year')
% ylabel('Percent')
% title('{\bf Forecast Path}')
% legend(legend_vec,'location','NW')
% axis tight
% grid on
% hold off
res=res(:,1);
