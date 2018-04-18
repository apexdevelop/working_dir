clearvars;
N=10; % N is the lag or number of input series
%% Generate Date
% opt_save_generate=1; % save
% [txt1,txt2,txt3,cell_px,cell_ret,cell_exret,cell_ob,cell_date,cell_target]= sfactor_generateData(sh_idx,opt_save_generate,N);
%% Neural Network Training
opt_save_train=1; % save
opt_x_train=2; %load price and return from saved database
[net,trainY,inX,tr,Test_perf]= sfactor_nn_training(sh_idx,opt_x_train,opt_save_train,txt1,txt2,txt3,N);

%% Backtesting
n_equity=size(txt1,2);
n_factor=size(txt2,1);
Names=[];
for m=1:n_equity %equity and market
    for n=1:n_factor %factor
        new_txt1=[txt1(m);txt2(n);txt3(m)];
        Names=[Names; transpose(new_txt1)];
    end
end

opt_y=1; %load trainedY directly from database
% opt_y=2; % %option 2 load stored network, recreate input data and generate new Y
opt_x_backtest=2; %load price and return from saved database
[Metrics,Perf] = sfactor_nn_backtesting_v2(opt_y,opt_x_backtest,sh_idx,N);
