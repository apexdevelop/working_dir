function c_output = pairsFun(is_adf,beta_idx,x,data,hp_TH,scaling,cost)
% define pairs to accept vectorized inputs and return only sharpe ratio
%%
% Copyright 2010, The MathWorks, Inc.
% All rights reserved.

[row,col] = size(x);
v_adj_ret=zeros(row,1);
v_adj_vol=zeros(row,1);
v_winp=zeros(row,1);
v_hp=zeros(row,1);
v_trades=zeros(row,1);
v_omega=zeros(row,1);
v_coeff=zeros(row,1);
v_ADF=zeros(row,1);

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
        [v_adj_ret(i),v_adj_vol(i),v_winp(i),v_omega(i),v_hp(i),v_trades(i),v_coeff(i),v_ADF(i)] = pairs_v2(is_adf,beta_idx,data, x(i,1), x(i,2), 1, 0.05,hp_TH,scaling,cost);
        case 3
        [v_adj_ret(i),v_adj_vol(i),v_winp(i),v_omega(i),v_hp(i),v_trades(i),v_coeff(i),v_ADF(i)] = pairs_v2(is_adf,beta_idx,data, x(i,1), x(i,2), x(i,3), 0.05,hp_TH,scaling,cost);
        case 4
        [v_adj_ret(i),v_adj_vol(i),v_winp(i),v_omega(i),v_hp(i),v_trades(i),v_coeff(i),v_ADF(i)] = pairs_v2(is_adf,beta_idx,data, x(i,1), x(i,2), x(i,3), x(i,4),hp_TH,scaling,cost);
    end
end
c_output=[v_adj_ret,v_adj_vol,v_winp,v_omega,v_hp,v_trades,v_coeff,v_ADF];