function avgret = factorFun(v_rtn,Zspread,f_ret,x,v_causal,exit_causal,tday,effect)
% Copyright 2010, The MathWorks, Inc.
% All rights reserved.

[row,col] = size(x);
avgret=zeros(row,1);


% run simulation
parfor i = 1:row
       avgret(i) = factors(v_rtn,Zspread,f_ret,x(i,1),v_causal,x(i,2),exit_causal,tday,effect)      
end