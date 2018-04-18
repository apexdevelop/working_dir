function [EstSpec,EstSE,logL,W] = vgxvarx(Spec,Y,X,Y0,varargin)
%VGXVARX Estimate VARX model parameters
%
% Syntax:
%
%	EstSpec = vgxvarx(Spec,Y);
%	[EstSpec,EstSE,logL,W] = vgxvarx(Spec,Y,X,Y0,param1,val1,param2,val2,...);
%
% Description:
%
%   Maximum likelihood estimation of VARX model parameters.
%
% Input Argument:
%
%	Spec - A model specification structure for a multidimensional VARX time
%	  series process, as produced by VGXSET or VGXVARX. Spec should contain
%	  model dimensions, a lag structure, if any, and parameter estimation
%	  indicators ("solve" parameters), if any. Initial values for parameter
%	  estimates are unnecessary.
%
%	Y - Response data. Y is a numObs-by-numDims matrix representing numObs
%	  observations of a single path of a numDims-dimensional time series.
%	  If Y contains multiple paths (that is, if Y is a 3D array), VGXVARX
%	  uses only the first path to estimate the parameters in Spec. The last
%	  observation is assumed to be the most recent.
%
% Optional Input Arguments:
%
%	X - Exogenous data. X is a a numObs-by-1 cell vector with each cell
%	  containing a numDims-by-numX design matrix X(t) so that, for some b,
%	  X(t)*b is the regression component of a single numDims-dimensional
%	  response Y(t) at time t. X represents one path of the explanatory
%	  variables.
%
%	Y0 - Presample response data. Y0 is a numPresampleYObs-by-numDims
%	  matrix representing numPresampleYObs observations of a single path of
%	  a numDims-dimensional time series. If Y0 is empty or if
%	  numPresampleYObs is less than the maximum AR lag in Spec, presample
%	  values are padded with zeros. If numPresampleYObs is greater than the
%	  maximum AR lag, the most recent samples from the last rows of each
%	  path of Y0 are used.
%
% Optional Input Parameter Name/Value Pairs:
%
%   It is sufficient to use only the leading characters that uniquely
%   identify a parameter. Case is ignored.
%
%	Name          Values	  Description
%	------------  ----------  ---------------------------------------------
%	'CovarType'   'full'	  Form of the estimated covariance matrix. The
%	              'diagonal'  default value of 'full' indicates that the
%	                          entire covariance matrix is to be estimated.
%	                          The value 'diagonal' indicates a diagonal
%	                          covariance matrix. This parameter overrides
%	                          any Qsolve specification in Spec.
%
%	'StdErrType'  'mean'	  Form of the estimated standard errors. The
%	              'all'       default value of 'mean' indicates that only
%	              'none'      the standard errors associated with the
%	                          parameters of the conditional mean are to be
%	                          estimated. The value 'all' indicates that the
%	                          standard errors associated with all
%	                          parameters, including the parameters for the
%							  innovations covariance, are to be estimated.
%							  The value 'none' indicates that no standard
%							  errors are to be estimated.
%
%	'IgnoreMA'	  'no'		  Directs how to handle moving average terms in
%	              'yes'       the specification structure. The default
%	                          value of 'no' indicates that it is an error
%	                          to have any moving average terms in the
%	                          specification structure. The value 'yes'
%	                          indicates that any moving average terms are
%	                          to be ignored, and not passed to the output
%	                          EstSpec. For example, if a VARMA(1,1) model
%	                          is specified and IgnoreMA is 'yes', the model
%	                          is treated as a pure VAR(1) model with no
%	                          moving average terms.
%
%	'MaxIter'	  positive	  Maximum number of iterations for parameter
%                 integer     estimation. The default value is 1000. For a
%                             least-squares fit, set MaxIter to 1. For a
%                             feasible generalized least-squares fit, set
%                             MaxIter to 2.
%
%	'TolParam'	  positive    Convergence tolerance for changes in the
%	              double      parameter estimates. The check at iteration k 
%                             is:
% 
%                               norm(x(k)-x(k-1)) <
%                                 sqrt(length(x))*TolParam*(1+norm(x(k)))
% 
%                             where x is the vector of parameter estimates.
%                             The default value is sqrt(eps). Both
%                             'TolParam' and 'TolObj' must be satisfied to
%                             terminate the optimization before 'MaxIter'
%                             iterations.
%
%	'TolObj'	  positive    Convergence tolerance for changes in the
%	              double      objective loglikelihood function. The check 
%                             at iteration k is:
% 
%                               abs(obj(k)-obj(k-1)) <
%                                 TolObj*(1+abs(obj(k)))
% 
%                             where obj is the objective loglikelihood
%                             function. The default value is eps^(3/4).
%                             Both 'TolParam' and 'TolObj' must be
%                             satisfied to terminate the optimization
%                             before 'MaxIter' iterations.
%
% Output Arguments:
%
%   EstSpec - VARX model specification structure containing the parameter
%     estimates. EstSpec has the same structure as Spec.
%
%   EstSE - VARX model specification structure containing the standard
%     errors of the parameter estimates. EstSE has the same structure as
%     Spec. Standard errors are maximum likelihood estimates, so a degree-
%     of-freedom adjustment is necessary to form ordinary least squares
%     estimates. To adjust for numObs observations and numActive
%     unrestricted parameters (as reported by VGXCOUNT), multiply by
%
%	    sqrt(numObs/(numObs-numActive-1))
%
%   logL - Optimized loglikelihood objective function value associated with
%     the parameter estimates found in EstSpec.
%
%	W - Inferred innovations process (fit residuals), the same size as Y.

% Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.8 $   $Date: 2010/10/08 16:41:45 $

% Step 1 - Initialization

if nargin < 2
    
	error(message('econ:vgxvarx:MissingInputArgument'))
      
end

if nargin < 3
	X = [];
end

if nargin < 4
	Y0 = [];
end

if isempty(Spec) || ~isa(Spec,'vgxset')
    
	error(message('econ:vgxvarx:InvalidSpecification1'))
    
end

Spec.checkParameters();

if Spec.isStandardError
    
    error(message('econ:vgxvarx:InvalidSpecification2'))
      
end

if isempty(Y)
    
	error(message('econ:vgxvarx:NullOperationNoData'));
end

Spec = internal.econ.vgxmodelset(Spec);
Spec = internal.econ.vgxsolveset(Spec);

% Process name-value pairs, if any:

if nargin > 4
    
	if mod(nargin-4,2) ~= 0
        
	   error(message('econ:vgxvarx:InvalidNameValuePair'))
         
	end

	names = {'covartype', 'stderrtype', 'ignorema', 'maxiter', 'tolparam', 'tolobj'}; % Names
	values = {'full', 'mean', 'no', 100, sqrt(eps), eps^(3/4)};	% Default values

	try
	   [covartype,stderrtype,ignorema,maxiter,tolparam,tolobj] ...
		   = validatePVpairs(names,values,varargin{:});
	catch E
	   E.throw
	end

	% Check optional arguments:

	% covartype = 'full', 'diagonal'
	if strcmpi(covartype(1),'f')        
		covartype = 'full';        
	elseif strcmpi(covartype(1),'d')        
		covartype = 'diagonal';        
    else
        
		error(message('econ:vgxvarx:InvalidCovarType'))
        
	end
	
	% stderrtype = 'mean', 'all', 'none'
	if strcmpi(stderrtype(1),'m')
		stderrtype = 'mean';
	elseif strcmpi(stderrtype(1),'a') % Permit 'full' as equivalent to 'all'
		stderrtype = 'all';
	elseif strcmpi(stderrtype(1),'f') % Permit 'full' as equivalent to 'all'
		stderrtype = 'all';
	elseif strcmpi(stderrtype(1),'n')
		stderrtype = 'none';
    else
        
		error(message('econ:vgxvarx:InvalidStdErrType'))
          
	end
	
	% ignorema = 'no', 'yes' or true, false
	if ~islogical(ignorema)
		if ischar(ignorema) && strcmpi(ignorema(1),'n')
			ignorema = false;
		elseif ischar(ignorema) && strcmpi(ignorema(1),'y')
			ignorema = true;
        else
            
			error(message('econ:vgxvarx:InvalidIgnoreMA'))
              
		end
	end
	
	% maxiter > 0
	if maxiter <= 0 || mod(maxiter,1) ~= 0
        
	   error(message('econ:vgxvarx:InvalidMaxIter'))
      
	end

	% tolparam > 0
	if tolparam <= 0
        
		error(message('econ:vgxvarx:InvalidTolerance1'))
        
	end
	
	% tolobj > 0
	if tolobj <= 0
        
		error(message('econ:vgxvarx:InvalidTolerance2'))
          
	end
    
else
    
	if internal.econ.ismatdiagonal(Spec.Qsolve)
		covartype = 'diagonal';
	else
		covartype = 'full';
	end
	stderrtype = 'mean';
	ignorema = false;
	maxiter = 1000;
	tolparam = sqrt(eps);
	tolobj = eps^(3/4);
    
end

if ndims(Y) > 2
    
	warning('econ:vgxvarx:MultiplePaths',...
		    'Response data has multiple paths. \nUsing first path only.')
        
	Y = Y(:,:,1);
    
end

[numObs,numDims] = size(Y);
if numDims ~= Spec.n
	if numObs == Spec.n
        
		warning(message('econ:vgxvarx:TransposedInnovations'))
        
		Y = Y';
		numObs = size(Y,1);
        
	else
        
		error(message('econ:vgxvarx:IncompatibleDimensions'))
          
	end
    
end

if ~isempty(X)
    
	if min(size(X)) > 1
        
		warning('econ:vgxvarx:MultiplePaths',...
			    'Exogenous data has multiple paths. \nUsing first path only.')
        
	end
    
end

% Step 2 - Pull dimensions and lags out of specification structure

numDims = Spec.n;
p = Spec.nAR;
q = Spec.nMA;
k = Spec.nX;

n2 = numDims*numDims;

% Build total number of parameters in model:

K = 0;

if ~isempty(Spec.a)
	K = K + numDims;
end

if ~isempty(Spec.b)
	K = K + k;
end

if ~isempty(Spec.AR)
	K = K + p*n2;
end

if q > 0
    
	if ignorema
		Spec.nMA = 0;
		Spec.MAlag = [];
		Spec.MA = [];
		Spec.MAsolve = [];
        
	else
        
		error(message('econ:vgxvarx:InvalidModelStructure'))
          
	end
    
end

if ~isempty(Spec.ARlag)	% nA is the maximum lag for AR terms
	nA = max(Spec.ARlag);
	ARlag = Spec.ARlag;
else
	nA = p;
	ARlag = 1:p;
end

% Step 3 - Set up exogenous inputs, if any

if Spec.nX > 0
    
	if ~isempty(X)
        
		X = internal.econ.vgxinitexogx(X,numObs,1);
        
	else
        
		error(message('econ:vgxvarx:MissingExogenousData'))
        
	end
    
end

% Step 4 - Set up initial conditions

Y0 = internal.econ.vgxinitprocx(Spec,Y0);

% Step 5 - Set up parameter vector and parameter mapping

x = [];	     % Parameter vector
xsolve = []; % Parameter solve vector

if ~isempty(Spec.a)
	x = [ x; Spec.a ];
	if ~isempty(Spec.asolve)
		xsolve = [ xsolve; Spec.asolve ];
	else
		xsolve = [ xsolve; true(numDims,1) ];
	end
end

if ~isempty(Spec.b) && Spec.nX > 0
	x = [ x; Spec.b ];
	if ~isempty(Spec.bsolve)
		xsolve = [ xsolve; Spec.bsolve ];
	else
		xsolve = [ xsolve; true(k,1) ];
	end
end

if ~isempty(Spec.AR)
	for i = 1:Spec.nAR
		x = [ x; Spec.AR{i}(:) ]; %#ok
		if ~isempty(Spec.ARsolve)
			xsolve = [ xsolve; Spec.ARsolve{i}(:) ]; %#ok
		else
			xsolve = [ xsolve; true(n2,1) ]; %#ok
		end
	end
end

if isempty(x) || sum(xsolve) == 0
    
	warning(message('econ:vgxvarx:NoEstimation'))
    
	EstSpec = Spec;
	EstSE = [];
	return
end

xsolve = logical(xsolve);

P = eye(K,K);
PU = P(xsolve,:);  % Map between parameters and unrestricted parameters
PR = P(~xsolve,:); % Map between parameters and restricted parameters

if isempty(PR)
	xR = [];
else
	xR = PR*x;
end

% Step 6 - Set up multivariate regression problem

D = cell(numObs,1);
if ~isempty(Spec.AR0)
	R = zeros(numObs,numDims);
	for t = 1:numObs
		R(t,:) = ((Spec.AR0)*Y(t,:)')';
	end
else
	R = Y;
end

if ~isempty(Spec.MA0)
	MA0inv = inv(Spec.MA0);
	for t = 1:numObs
		R(t,:) = (MA0inv*R(t,:)')'; %#ok
	end
end

is_a = ~isempty(Spec.a);
is_b = ~isempty(Spec.b) && Spec.nX > 0;
is_MA0 = ~isempty(Spec.MA0);

for t = 1:numObs
	Zt = [];
	
	if is_MA0
		if is_a
			Zt = [ Zt MA0inv ]; %#ok
		end
		
		if is_b
			Zt = [ Zt (MA0inv*X{t}) ]; %#ok
		end
		
		for i = 1:p
			if t <= ARlag(i)
                U = kron(Y0(nA-ARlag(i)+t,:),MA0inv);
			else
				U = kron(Y(t-ARlag(i),:),MA0inv);
			end
			Zt = [ Zt U ]; %#ok
		end
	else
		if is_a
			Zt = [ Zt eye(numDims,numDims) ]; %#ok
		end

		if is_b
			Zt = [ Zt X{t} ]; %#ok
		end

		for i = 1:p
			if t <= ARlag(i)
				U = kron(Y0(nA-ARlag(i)+t,:),eye(numDims));
			else
				U = kron(Y(t-ARlag(i),:),eye(numDims));
			end
			Zt = [ Zt U ]; %#ok
		end
	end
	
	if isempty(xR)
		D{t} = Zt;
	else
		D{t} = Zt*PU';
		R(t,:) = R(t,:)-(Zt*PR'*xR)';
	end
end

% Step 7 - Solve for parameters

if strmatch(covartype,'full')
	Spec.Qsolve = true(numDims);
else
	Spec.Qsolve = logical(eye(numDims));
end

if strcmpi(stderrtype,'all')
	varformat = 'full';
else
	varformat = 'beta';
end

if isempty(xR)
    
	if strmatch(stderrtype,'none')
        
		[x,Q] = mvregress(D,R, 'covtype',covartype, 'varformat',varformat, ...
			'vartype','fisher', 'maxiter',maxiter, 'tolparam',tolparam, 'tolobj',tolobj);
        
	else
        
		[x,Q,~,xvar] = mvregress(D,R, 'covtype',covartype, 'varformat',varformat, ...
			'vartype','fisher', 'maxiter',maxiter, 'tolparam',tolparam, 'tolobj',tolobj);
		xstderr = sqrt(diag(xvar));
        
	end
    
else
    
    if strmatch(stderrtype,'none')
        
		[xU,Q] = mvregress(D,R, 'covtype',covartype, 'varformat',varformat, ...
			'vartype','fisher', 'maxiter',maxiter, 'tolparam',tolparam, 'tolobj',tolobj);
        
    elseif strmatch(stderrtype,'mean')
        
		[xU,Q,~,xvar] = mvregress(D,R, 'covtype',covartype, 'varformat',varformat, ...
			'vartype','fisher', 'maxiter',maxiter, 'tolparam',tolparam, 'tolobj',tolobj);
		xstderrU = sqrt(diag(xvar));
		xstderr = PU'*xstderrU + PR'*zeros(size(xR));
        
    else
        
		[xU,Q,~,xvar] = mvregress(D,R, 'covtype',covartype, 'varformat',varformat, ...
			'vartype','fisher', 'maxiter',maxiter, 'tolparam',tolparam, 'tolobj',tolobj);
		xstderrU = sqrt(diag(xvar));
        
        if strmatch(covartype,'full')
			kn = (numDims*(numDims + 1))/2;
        else
			kn = numDims;
        end
        
		Qstderr = xstderrU(end-kn+1:end);
		xstderrU = xstderrU(1:end-kn);
		xstderr = PU'*xstderrU + PR'*zeros(size(xR));
		xstderr = [ xstderr; Qstderr ];
        
    end
    
	x = PU'*xU + PR'*xR;
    
end

% Step 8 - Pack specification structure with parameter estimates

EstSpec = Spec;

ii = 0;

if ~isempty(EstSpec.a)
	EstSpec.a = x(1:numDims);
	ii = ii + numDims;
end

if ~isempty(EstSpec.b)
	EstSpec.b = x(ii+1:ii+k);
	ii = ii + k;
end

if ~isempty(EstSpec.AR)
	for i = 1:p
		EstSpec.AR{i} = reshape(x(ii+1:ii+n2),numDims,numDims);
		ii = ii + n2;
	end
end

EstSpec.Q = Q;

[numParam,numActive] = vgxcount(EstSpec);

EstSpec.T = numObs;
EstSpec.NumParam = numParam;
EstSpec.NumActive = numActive;

% Step 9 - Pack standard errors, if requested

if ~isempty(strmatch(stderrtype,'none'))
	EstSE = vgxset.empty;
else	
	EstSE = EstSpec;
	EstSE.isStandardError = true;
	
	ii = 0;

	if ~isempty(EstSpec.a)
		EstSE.a = xstderr(1:numDims);
		ii = ii + numDims;
	end

	if ~isempty(EstSpec.b)
		EstSE.b = xstderr(ii+1:ii+k);
		ii = ii + k;
	end

	if ~isempty(EstSpec.AR)
		for i = 1:p
			EstSE.AR{i} = reshape(xstderr(ii+1:ii+n2),numDims,numDims);
			ii = ii + n2;
		end
	end

	if strmatch(stderrtype,'all')
		Qstd = zeros(numDims,numDims);
		if strmatch(covartype,'full')
			for i = 1:numDims
				for j = 1:i
					ii = ii + 1;
					Qstd(i,j) = xstderr(ii);
					Qstd(j,i) = Qstd(i,j);
				end
			end
		else
			for i = 1:numDims
				ii = ii + 1;
				Qstd(i,i) = xstderr(ii);
			end
		end
		EstSE.Q = Qstd;
	else
		EstSE.Q = [];
	end
end

% Step 10 - Clean up specification structures

EstSpec = vgxset(EstSpec);
EstSE = vgxset(EstSE);

% Step 11 - Compute loglikelihood, if requested

if nargout > 2
	[W,logL] = vgxinfer(EstSpec,Y,X,Y0); % If Y has multiple paths, now there is only one
end