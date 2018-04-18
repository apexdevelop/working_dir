function c_output = accuracy_medium_sf(vYret,vXret,vDate,M,N,l_pattern,l_np,prc,x)
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
        v_accuracy(i) = corr_train_test_ret_sf(vYret,vXret,vDate,M,N,l_pattern,l_np,prc,x(i,1), x(i,2), x(i,3), x(i,4), x(i,5), x(i,6));  
    end
end
c_output=v_accuracy;