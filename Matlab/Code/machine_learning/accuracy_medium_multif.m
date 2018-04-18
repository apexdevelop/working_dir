function c_output = accuracy_medium_multif(rtn_Y,disp_col,v_factor1,z_turnover_mov,tday1,M,N,l_pattern,l_np,prc,x)
% define pairs to accept vectorized inputs and return only sharpe ratio
%%
% Copyright 2010, The MathWorks, Inc.
% All rights reserved.

[row,col] = size(x);
v_accuracy=zeros(row,1);

% run simulation
parfor i = 1:row
    switch col
        case 6
        v_accuracy(i) = corr_train_test_ret_multif(rtn_Y,disp_col,v_factor1,z_turnover_mov,tday1,M,N,l_pattern,l_np,prc,x(i,1), x(i,2), x(i,3), x(i,4), x(i,5), x(i,6));
%         v_accuracy(i) = corr_train_test_ret_multif(rtn_Y,disp_col,v_factor1,z_turnover_mov,tday1,M,N,l_pattern,l_np,prc,x(i,1), x(i,2), x(i,3), x(i,4), x(i,5), x(i,6),x(i,7), x(i,8), x(i,9), x(i,10), x(i,11), x(i,12));
    end
end
c_output=v_accuracy;