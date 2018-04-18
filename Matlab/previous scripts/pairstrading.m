cd('C:\Documents and Settings\YChen\My Documents');
% rawdata_1=csvread('DIA.csv',1,1); %read first series from csv file
% rawdata_2=csvread('SPY.csv',1,1); %read second series from csv file
% data_dia=rawdata_1(:,6);
% data_spy=rawdata_2(:,6);
data_series=[adjcls(:,1),adjcls(:,2)];
M=200;
N=10;
spread=5;
scaling=1;
SUM=sum(adjcls(:,1))+sum(adjcls(:,2));
cost=0.005*SUM;
pairs(data_series, M, N, spread, scaling, cost) 
