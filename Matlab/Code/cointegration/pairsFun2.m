function totret = pairsFun2(beta_idx,x,data,scaling,cost)
% define pairs to accept vectorized inputs and return only sharpe ratio
%%
% Copyright 2010, The MathWorks, Inc.
% All rights reserved.

[row,col] = size(x);
totret=zeros(row,1);

% x = round(x);

if ~exist('scaling','var')
    scaling = 1;
end
if ~exist('cost','var')
    cost = 0;
end

% run simulation
parfor i = 1:row
    switch col
        case 2
        [~,totret(i),~] = pairs2(beta_idx,data, x(i,1), x(i,2), 1, 0.05,scaling,cost);
        case 3
        [~,totret(i),~] = pairs2(beta_idx,data, x(i,1), x(i,2), x(i,3), 0.05,scaling,cost);
        case 4
        [~,totret(i),~] = pairs2(beta_idx,data, x(i,1), x(i,2), x(i,3), x(i,4),scaling,cost);
    end
end