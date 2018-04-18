function results=ols(y,x)
% PURPOSE: least-squares regression 
%---------------------------------------------------
% USAGE: results = ols(y,x)
% where: y = dependent variable vector    (nobs x 1)
%        x = independent variables matrix (nobs x nvar)
%---------------------------------------------------
% RETURNS: a structure
%        results.meth  = 'ols'
%        results.beta  = bhat     (nvar x 1)
%        results.alpha  = ahat     (nvar x 1)
%        results.tstat = t-stats  (nvar x 1)
%        results.yhat  = yhat     (nobs x 1)
%        results.resid = residuals (nobs x 1)
%        results.sige  = e'*e/(n-k)   scalar
%        results.rsqr  = rsquared     scalar
%        results.rbar  = rbar-squared scalar
%        results.dw    = Durbin-Watson Statistic
%        results.nobs  = nobs
%        results.nvar  = nvars
%        results.y     = y data vector (nobs x 1)
%        results.bint  = (nvar x2 ) vector with 95% confidence intervals on beta
%---------------------------------------------------
% SEE ALSO: prt(results), plt(results)
%---------------------------------------------------

% written by:
% James P. LeSage, Dept of Economics
% University of Toledo
% 2801 W. Bancroft St,
% Toledo, OH 43606
% jlesage@spatial-econometrics.com
%
% Barry Dillon (CICG Equity)
% added the 95% confidence intervals on bhat
if (nargin ~= 2); error('Wrong # of arguments to ols'); 
else
 [nobs nvar] = size(x); [nobs2 junk] = size(y);
 if (nobs ~= nobs2); error('x and y must have same # obs in ols'); 
 end;
end;

results.meth = 'ols';
results.y = y;
results.nobs = nobs;
results.nvar = nvar;

[q r] = qr(x,0);
xpxi = (r'*r)\eye(nvar);


xm=x-mean(x);
xm_sq=xm.^2;
results.beta=(xm'*y)/sum(xm_sq);
results.alpha=mean(y)-mean(x)*results.beta;
results.yhat = x*results.beta;
results.resid = (y - results.yhat-results.alpha);
SSR = results.resid'*results.resid; %Residual Sum of Squres
results.sige = SSR/(nobs-nvar); %sige is var(results.resid);
sigma_beta=results.sige/sum(xm_sq);
tcrit=-tdis_inv(.025,nobs);
results.bint=[results.beta-tcrit.*sigma_beta, results.beta+tcrit.*sigma_beta];
results.tstat = results.beta./(sqrt(sigma_beta));
ym = y - mean(y);
TSS = ym'*ym; %Total Sum of Squares
results.rsqr = 1.0 - SSR/TSS; % r-squared
SSR_bar = SSR/(nobs-nvar);
TSS_bar = TSS/(nobs-1.0);
if TSS_bar ~= 0
results.rbar = 1 - (SSR_bar/TSS_bar); % rbar-squared
else
    results.rbar = results.rsqr;
end;
ediff = results.resid(2:nobs) - results.resid(1:nobs-1);
results.dw = (ediff'*ediff)/SSR; % durbin-watson
results.vcov = results.sige*xpxi; % covariance matrix of the parameters
