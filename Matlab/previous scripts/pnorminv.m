function z = pnorminv(p,mu,sigma)
%NORMINV Inverse of the normal cumulative distribution function (cdf).
%   X = NORMINV(P,MU,SIGMA) finds the inverse of the normal cdf with
%   mean, MU, and standard deviation, SIGMA.
%
%   The size of X is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    
%
%   Default values for MU and SIGMA are 0 and 1 respectively.
%
%   See also NORMCDF, ERF, ERFC, ERFINV, ERFCINV.

%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 7.1.1 and 26.2.2

%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 2.12 $  $Date: 2002/01/17 21:31:31 $

if nargin < 2, mu = 0; end
if nargin < 3, sigma = 1; end

[errorcode p mu sigma] = pdistchck(3,p,mu,sigma);
if errorcode > 0
    error('Requires non-scalar arguments to match in size.');
end

% It is numerically preferable to use the complementary error function
% and norminv(p) = -sqrt(2)*erfcinv(2*p) to produce accurate results
% for p near zero.

z = (-sqrt(2)*sigma).*perfcinv(2*p) + mu;
