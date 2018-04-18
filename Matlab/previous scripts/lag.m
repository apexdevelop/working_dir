function z = lag(x,n,v)
% PURPOSE:  creates a matrix or vector of lagged values
% -------------------------------------------------------
% USAGE: z = lag(x,n,v)
% where: x = input matrix or vector, (nobs x k)
%        n = order of lag
%        v = (optional) initial values (default=0)
% e.g.
%     z = lag(x) creates a matrix of x, lagged 1 observations
%     z = lag(x,n) creates a matrix of x, lagged n observations
%     z = lag(x,n,v) creates a matrix of x, lagged n observations,
%         with initial values taking a value v.
% ------------------------------------------------------
% RETURNS: z = matrix or vector of lags (nobs x k)
% ------------------------------------------------------
% SEE ALSO: mlag() 
%---------------------------------------------------

% written by:
% James P. LeSage, Dept of Economics
% University of Toledo
% 2801 W. Bancroft St,
% Toledo, OH 43606
% jpl@jpl.econ.utoledo.edu

   if nargin == 1; n = 1;
   elseif n <= 0; n = 1;
   end;
   if nargin <= 2;
     v = 0;
   end;
   zt = ones(n,cols(x))*v;
   z = [ zt; trimr(x,0,n)];


