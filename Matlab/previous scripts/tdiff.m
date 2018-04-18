function dmat = tdiff(x,k)
% PURPOSE: produce matrix differences
% -----------------------------------------
% USAGE: dmat = tdiff(x,k)
% where:    x = input matrix (or vector) of length nobs
%           k = lagged difference order
% -----------------------------------------
% NOTE: uses trimr() and lag()
% -----------------------------------------
% RETURNS: dmat = matrix or vector, differenced by k-periods
%                 e.g. x(t) - x(t-k), of length nobs, 
%                 (first k observations are zero)
% -----------------------------------------
% SEE ALSO: trimr() modeled after Gauss trimr function
% -----------------------------------------


% error checking on inputs
if (nargin ~= 2)
 error('Wrong # of arguments to tdiff');
end;

[nobs nvar] = size(x);

if ( k == 0)
 dmat = x;

elseif k ==1
    dmat = zeros(nobs,nvar);
 dmat(2:nobs,:) = x(2:nobs,:)-x(1:nobs-1,:);
else

    tmp = x - lag(x,1);
    for ndiff = 2:k;
    tmp = tmp - lag(tmp,1);
    end;
    dmat = tmp;
end;


