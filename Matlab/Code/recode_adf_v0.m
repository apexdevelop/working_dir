%-------------doing regression on residuals
% Model'AR': y(t) = a*y(t-1) + b1*(1-L)y(t-1) + b2*(1-L)y(t-2) + ... + bp*(1-L)y(t-p) + e(t)      

y=reg1.res;
L=length(y);
testY = y(2:end,1);
testT = L-1;   % Effective sample size
X = y(1:end-1,1);
             
% Run the regression: testY~X, non intercept
[Q,R] = qr(X,0);
a = R\(Q'*testY);
%the above two lines could be replaced by model = sm.OLS(y,x);results =
%model.fit();a = results.params.iloc[0] and don't add constant to x
yHat = X*a;
res2 = testY-yHat;
SSE=res2'*res2;
dfe=testT-1;
MSE=SSE/dfe;
sigma=var(res2);
Cov=MSE*inv(X'*X);
%-----calculate tstat
se_a = sqrt(diag(Cov));
testStat = (a-1)/se_a;

%----calculate v_h
cValue=-2.7421;
if testStat<cValue
   h=1;
else
   h=0;
end