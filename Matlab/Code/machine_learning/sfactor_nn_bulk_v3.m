clearvars;
%for generating data
new_data=0;
sh_idx=5;
startdate='2012/3/12';
enddate=today();
%for training
new_train=1;
mov_window=1;
maxlag=10;
size_hidden=10; %side of hidden layer

cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/factor/single_factor');
filename='factors_v2.xlsx';
% oil,shipping,utility,hitachi,steel,coal,display,solar,jp_bond,kr_bond,aluminum,machinery
v_shnames={'oil','shipping','utility','hitachi','steel','coal','display','solar','jp_bond','kr_bond','aluminum1','aluminum2','machinery','semi','sugar','aapl','shenzhou'};
e_ranges={'d1:s1','d1:n1','d1:j1','d1:d1','d1:m1','d1:f1','d1:i1','d1:h1','d1:p1','d1:g1','d1:e1','d1:e1','d1:h1','d1:h1','d1:g1','d1:o1','d1:d1'};
b_ranges={'d2:s2','d2:n2','d2:j2','d2:d2','d2:m2','d2:f2','d2:i2','d2:h2','d2:p2','d2:g2','d2:e2','d2:e2','d2:h2','d2:h2','d2:g2','d2:o2','d2:d2'};
d_ranges={'d5:s51','d5:n39','d5:j31','d5:d18','d5:m38','d5:i28','d5:i32','d5:h30','d5:p29','d5:g23','d5:e27','d5:e27','d5:h24','d5:h15','d5:g19','d5:o5','d5:d9'};
shname=char(v_shnames(sh_idx));
[~,txt2]=xlsread(filename,shname,'b5:b100'); %factor
[~,txt1]=xlsread(filename,shname,char(e_ranges(sh_idx)));  %equity
[~,txt3]=xlsread(filename,shname,char(b_ranges(sh_idx)));  %benchmark
[effect,~]=xlsread(filename,shname,char(d_ranges(sh_idx)));  %effect
%% Generate Data
if new_data==1
   disp('pulling data time');
   tic
   opt_save_generate=1; % save
   [cell_px,cell_ret,cell_exret,cell_ob,cell_date]= sfactor_generateData_v2(sh_idx,opt_save_generate,startdate,enddate);
   toc
end
%% Nolinear Autoregressive Neural Network Training
matTestR=[];
matTestBeta=[]; 
matTestAlpha=[];
matTestErr=[];

matTotalR=[];
matTotalBeta=[]; 
matTotalAlpha=[];
matTotalErr=[];
if new_train==1
   % N is the lag or number of input series
   for N=1:maxlag
       opt_save_train=1; % save training net
       disp('training data time');
       tic
       [net,trainY,inX,tr,v_test_perf,v_total_perf]= sfactor_nn_nvar(txt1,txt2,txt3,sh_idx,opt_save_train,mov_window,N,size_hidden);
       toc
       matTestR=[matTestR v_test_perf(:,1)];
       matTestBeta=[matTestBeta v_test_perf(:,2)];
       matTestAlpha=[matTestAlpha v_test_perf(:,3)];
       matTestErr=[matTestErr v_test_perf(:,4)];
       
       matTotalR=[matTotalR v_total_perf(:,1)];
       matTotalBeta=[matTotalBeta v_total_perf(:,2)];
       matTotalAlpha=[matTotalAlpha v_total_perf(:,3)];
       matTotalErr=[matTotalErr v_total_perf(:,4)];
   end
end
%% Backtesting
matRet=[];
matVol=[];
matWinp=[];
cMetrics=cell(maxlag,1); %trade backtesting result in each cell
for N=1:maxlag
   disp('backtesting time');
   tic
   n_equity=size(txt1,2);
   n_factor=size(txt2,1);
   Names=[];
   for m=1:n_equity %equity and market
       for n=1:n_factor %factor
           new_txt1=[txt1(m);txt2(n);txt3(m)];
           Names=[Names; transpose(new_txt1)];
       end
   end

   backtest_Metrics = sfactor_nn_backtesting_v3(sh_idx,N);
   cMetrics{N,1}=backtest_Metrics;

   matRet=[matRet backtest_Metrics(:,1)];
   matVol=[matVol backtest_Metrics(:,2)];
   matWinp=[matWinp backtest_Metrics(:,3)];
   toc
end
strNames=string(Names);