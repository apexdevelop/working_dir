function results = cadf(y,x,p,l)
% PURPOSE: compute augmented Dickey-Fuller statistic for residuals
%          from a cointegrating regression, allowing for deterministic
%          polynomial trends
% ------------------------------------------------------------
% USAGE: results = cadf(y,x,p,nlag)
% where: y = dependent variable time-series vector
%        x = explanatory variables matrix
%             p = order of time polynomial in the null-hypothesis
%                 p = -1, no deterministic part
%                 p =  0, for constant term
%                 p =  1, for constant plus time-trend
%                 p >  1, for higher order polynomial
%     nlag = # of lagged changes of the residuals to include in regression
% ------------------------------------------------------------
% RETURNS: results structure
%          results.meth  = 'cadf'
%          results.alpha = autoregressive parameter estimate
%          results.adf   = ADF t-statistic
%          results.crit  =  (6 x 1) vector of critical values
%                        [1% 5% 10% 90% 95% 99%] quintiles   
%          results.nvar  = cols(x)
%          results.nlag  = nlag
%---------------------------------------------------
% SEE ALSO: prt_coint()
%--------------------------------------------------- 
% References: Said and Dickey (1984) 'Testing for Unit Roots in
% Autoregressive Moving Average Models of Unknown Order', 
% Biometrika, Volume 71, pp. 599-607.

% error checking
     if (p < -1);
        error('p cannot be < -1 in cadf');
     end;
     nobs    = rows(x);
     if (nobs - (2*l) + 1 < 1);
     error('nlags is too large in cadf; negative degrees of freedom');
     end;
    
     y       = detrend(y,p);
     x       = detrend(x,p);
     b = inv(x'*x)*x'*y;
     r       = y - x*b;
     dep     = tdiff(r,1); %produce matrix differences
     dep = trimr(dep,1,0); %RETURNS: z = x(n1+1:n-n2,:)
     k       = 0     ;
     z       = trimr(lag(r,1),1,0) ;
     
     while (k <= l)
           k = k + 1 ;
           z = [z lag(dep,k)];
     end;
          
     z       = trimr(z,l,0) ;
     dep     = trimr(dep,l,0) ;
     
     beta    = detrend(z,0)\detrend(dep,0) ;
     res     = dep - z*beta ;
     so      = (res'*res)/(rows(dep)-cols(z));
     var_cov = so*inv(z'*z) ;
     
     results.alpha = beta(1,1);
     results.adf = (beta(1,1)/sqrt(var_cov(1,1)));
     results.crit = rztcrit(nobs,cols(x),p);
     results.nlag = l;
     results.nvar = cols(x);
     results.meth = 'cadf';
    
     

