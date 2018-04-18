function prt(results,vnames,fid)
% PURPOSE: Prints results structures returned by most functions
%          by calling the appropriate printing function
%---------------------------------------------------
% USAGE: prt(results,vnames,fid)
% Where: results = a results structure returned an econometric function
%        vnames  = an optional vector of variable names
%        fid     = file-id for printing results to a file
%                  (defaults to the MATLAB command window)
%---------------------------------------------------               
%                 e.g. vnames = ['y    ',
%                                'x1   ',  NOTE: fixed width
%                                'x2   ',        like all MATLAB
%                                'cterm'];       strings
%                 e.g. fid = fopen('ols.out','wr');
% --------------------------------------------------
% NOTES: you may use prt(results,[],fid) to print
%        output to a file with no vnames
%        this is simply a wrapper function that calls another function
% --------------------------------------------------        
% RETURNS:
%        nothing, just prints the regression results
% --------------------------------------------------
% SEE ALSO: plt()
%---------------------------------------------------   

% written by:
% James P. LeSage, Dept of Economics
% University of Toledo
% 2801 W. Bancroft St,
% Toledo, OH 43606
% jpl@jpl.econ.utoledo.edu

% error checking on inputs
if ~isstruct(results)
error('prt: requires a structure input');
elseif nargin == 3
arg = 0;
 [vsize junk] = size(vnames); % user may supply a blank argument
   if vsize > 0
   arg = 3;          
   end;
elseif nargin == 2
arg = 2;
elseif nargin == 1
arg = 1;
else
error('Wrong # of inputs to prt');
end;

method = results(1).meth;

% call appropriate printing routine
switch method

case {'arma','boxcox','boxcox2','hwhite','lad','logit','mlogit','nwest','ols','olsc',...
      'olsar1','olst','probit','ridge','robust','theil','tobit','tsls'} 
     % call prt_reg
     if arg == 1
     prt_reg(results);
     elseif arg == 2
     prt_reg(results,vnames);
     elseif arg == 3
     prt_reg(results,vnames,fid);
     else
     prt_reg(results,[],fid);
     end;

case {'switch_em','hmarkov_em'}
     % call prt_swm
     if arg == 1
     prt_swm(results);
     elseif arg == 2
     prt_swm(results,vnames);
     elseif arg == 3
     prt_swm(results,vnames,fid);
     else
     prt_swm(results,[],fid);
     end;

case {'thsls','sur'} 
     % call prt_eqs
     if arg == 1
     prt_eqs(results);
     elseif arg == 2
     prt_eqs(results,vnames);
     elseif arg == 3
     prt_eqs(results,vnames,fid);
     else
     prt_eqs(results,[],fid);
     end;

case {'var','bvar','rvar','ecm','becm','recm'} 
     % call prt_var
     if arg == 1
     prt_var(results);
     elseif arg == 2
     prt_var(results,vnames);
     elseif arg == 3
     prt_var(results,vnames,fid);
     else
     prt_var(results,[],fid);
     end;

case {'bvar_g','rvar_g','becm_g','recm_g'} 
     % call prt_varg
     if arg == 1
     prt_varg(results);
     elseif arg == 2
     prt_varg(results,vnames);
     elseif arg == 3
     prt_varg(results,vnames,fid);
     else
     prt_varg(results,[],fid);
     end;

case {'johansen','adf','cadf'}
     % call prt_coint
     if arg == 1
     prt_coint(results);
     elseif arg == 2
     prt_coint(results,vnames);
     elseif arg == 3
     prt_coint(results,vnames,fid);
     else
     prt_coint(results,[],fid);
     end;

case {'coda','raftery','apm','momentg'}
     % call prt_coda
     if arg == 1
     prt_coda(results);
     elseif arg == 2
     prt_coda(results,vnames);
     elseif arg == 3
     prt_coda(results,vnames,fid);
     else
     prt_coda(results,[],fid);
     end;
     
case {'ar_g','ols_g', 'bma_g', 'tobit_g','probit_g'}
     % call prt_gibbs
     if arg == 1
     prt_gibbs(results);
     elseif arg == 2
     prt_gibbs(results,vnames);
     elseif arg == 3
     prt_gibbs(results,vnames,fid);
     else
     prt_gibbs(results,[],fid);
     end;

case {'sar','sar_g','sart_g','sarp_g','sac','sac_g','far','far_g','sem','sem_g', ...
 'moran','lmerror','lratios','walds','lmsar','semo','sdm','sdm_g','semp_g', ...
 'sacp_g','semt_g','sact_g','sdmt_g','sdmp_g'}     
     % call prt_spat
     if arg == 1
     prt_spat(results);
     elseif arg == 2
     prt_spat(results,vnames);
     elseif arg == 3
     prt_spat(results,vnames,fid);
     else
     prt_spat(results,[],fid);
     end;

case {'gwr','bgwr','bgwrv','gwr_logit','gwr_probit'}
     % call prt_gwr
     if arg == 1
     prt_gwr(results);
     elseif arg == 2
     prt_gwr(results,vnames);
     elseif arg == 3
     prt_gwr(results,vnames,fid);
     else
     prt_gwr(results,[],fid);
     end; 

case {'casetti','darp','bcasetti'}
     % call prt_cas
     if arg == 1
     prt_cas(results);
     elseif arg == 2
     prt_cas(results,vnames);
     elseif arg == 3
     prt_cas(results,vnames,fid);
     else
     prt_cas(results,[],fid);
     end;   
    
    
otherwise
error('results structure not known by prt function');

end;


