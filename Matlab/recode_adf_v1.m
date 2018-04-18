%-------------doing regression on residuals
% Model'AR': y(t) = a*y(t-1) + b1*(1-L)y(t-1) + b2*(1-L)y(t-2) + ... + bp*(1-L)y(t-p) + e(t)      

y=reg1.res;
L=length(y);
testY = y(2:end,1);
testT = L-1;   % Effective sample size
X = y(1:end-lags-1,1);
             
% Run the regression: testY~X, non intercept
[Q,R] = qr(X,0);
a = R\(Q'*testY);
%the above two lines could be replaced by model = sm.OLS(y,x);results =
%model.fit();a = results.params.iloc[0] and don't add constant to x
yHat = X*a;
res2 = testY-yHat;
sigma=var(res2);
Cov=sigma*inv(X'*X);
%-----calculate tstat
se_a = sqrt(diag(Cov));
testStat = (a-1)/se_a;

%----find pValue of tstat
Y=NY1;

sigLevels = [0.001 (0.005:0.005:0.10) (0.125:0.025:0.20) ...
                   (0.80:0.025:0.875) (0.90:0.005:0.995) 0.999];
sampSizes = [10 15 20 25 30 40 50 75 100 150 200 300 500 1000 10000];
[numObs,numDims] = size(Y);
% Load critical values:
S_CV = load('Data_EGCITest');
cd('Z:\Proj\Coding Translatation');
EGCV = S_CV.CV.EGCV;

%tableDim: 1 + number of estimated parameters in cointegrating vector, excluding deterministic terms (1:12)     
tableDim = 1 + 1; 
CVTable = EGCV(:,:,2,1,tableDim);
CVTableRow = interp2(sigLevels,sampSizes,CVTable(1:end-1,:),sigLevels,numObs,'linear');
% testStat=stat;
testPValue = interp1(CVTableRow,sigLevels,testStat,'linear');

% cd('Z:\Proj\Coding Translatation');
% save ('Data_EGCITest', 'CV');
    
