function backtest_Metrics = sfactor_nn_backtesting_v3(sh_idx,N)
%% Backtesting
cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/ML');
TH_prc=95;
backtest_Metrics=[];

   %load trainedY directly from database
   cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/ML');
   Sout=load(strcat('out', num2str(sh_idx), '_lag_',num2str(N)));
   
   Sob=load(strcat('ob', num2str(sh_idx)));
   Sexret=load(strcat('exret', num2str(sh_idx)));
   Sdate=load(strcat('date', num2str(sh_idx)));
   cOutputs=Sout.cOutputs;
   
   cell_ob=Sob.cell_ob;
   cell_exret=Sexret.cell_exret;
   cell_date=Sdate.cell_date;
   [n_equity,n_factor]=size(cell_exret);

   for m=1:n_equity
       for n=1:n_factor
           nob=cell_ob{m,n};
           %M is the lookback period. It could be a fixed number<=nob
%            M=nob-N;
           M=nob;
           Y_backtest=transpose(cell2mat(cOutputs{m,n}));
           date_backtest=cell_date{m,n}(nob-M+1:end);
           y_TH=prctile(Y_backtest,TH_prc);
           exrtn_backtest=cell_exret{m,n}(nob-M+N+1:end);
           [s,ret_v,newmetric]=general_backtest_v1(exrtn_backtest,Y_backtest,y_TH,date_backtest);
           backtest_Metrics=[backtest_Metrics; newmetric];       
       end
   end





