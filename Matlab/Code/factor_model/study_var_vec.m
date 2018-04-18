clear all

load VAR_data
Y=VAR_data(:,2:4);

[~,~,~,~,reg] = egcitest(Y,'test','t2');
 
c0 = reg.coeff(1);
b = reg.coeff(2:end);

%% Estimating VEC Model Parameters

q = 3;
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
a = P(:,1); %a is adjusting coefficient
B1 = P(:,2:q+1);
B2 = P(:,end-q:end-1);
c1 = P(:,end); %c1 is constant
 
% Display model coefficients
% a,b,c0,B1,B2,c1
FY=X*P';
res = DY-FY;
EstCov = cov(res);