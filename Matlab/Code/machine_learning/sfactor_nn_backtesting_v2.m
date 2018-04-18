function [Metrics,Perf,R,Beta,Alpha] = sfactor_nn_backtesting_v2(opt_y,sh_idx,N)
%% Backtesting
cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/ML');
TH_prc=95;
Metrics=[];
Perf=[];
R=[];
Beta=[];
Alpha=[];
%Step 1 choices of how to get Y
if opt_y==1
   %option 1 load trainedY directly from database
   cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/ML');
   Sout=load(strcat('out', num2str(sh_idx), '_lag_',num2str(N)));

   Sperf=load(strcat('cPerf', num2str(sh_idx), '_lag_',num2str(N)));
   SR=load(strcat('cR', num2str(sh_idx), '_lag_',num2str(N)));
   SBeta=load(strcat('cBeta', num2str(sh_idx), '_lag_',num2str(N)));
   SAlpha=load(strcat('cAlpha', num2str(sh_idx), '_lag_',num2str(N)));
   Sob=load(strcat('ob', num2str(sh_idx)));
   Sexret=load(strcat('exret', num2str(sh_idx)));
   Sdate=load(strcat('date', num2str(sh_idx)));
   ctrainY=Sout.trainY;

   cPerf=Sperf.cPerf;
   cR=SR.cR;
   cBeta=SBeta.cBeta;
   cAlpha=SAlpha.cAlpha;
   cell_ob=Sob.cell_ob;
   cell_exret=Sexret.cell_exret;
   cell_date=Sdate.cell_date;
   [n_equity,n_factor]=size(cell_exret);

   for m=1:n_equity
       for n=1:n_factor
           nob=cell_ob{m,n};
           %M is the lookback period. It could be a fixed number<=nob
           M=nob-N;       
           Y_backtest=ctrainY{m,n};
           Perf=[cPerf{m,n};Perf];
           R=[cR{m,n};R];
           Beta=[cBeta{m,n};Beta];
           Alpha=[cAlpha{m,n};Alpha];
           date_backtest=cell_date{m,n}(nob-M+1:end);
           y_TH=prctile(Y_backtest,TH_prc);
           exrtn_backtest=cell_exret{m,n}(nob-M+1:end);
           [s,ret_v,newmetric]=general_backtest_v1(exrtn_backtest,Y_backtest,y_TH,date_backtest);
           Metrics=[Metrics; newmetric];       
       end
   end
elseif opt_y==2
   %option 2 load stored network, recreate input data and generate new Y
   cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/ML');
   Snet=load(strcat('net', num2str(sh_idx), '_lag_',num2str(N)));
   cnet=Snet.net;
   [n_equity,n_factor]=size(cnet);
   %load data from saved database
   Starget=load(strcat('target', num2str(sh_idx), '_lag_',num2str(N)));
   cell_target=Starget.targetY;
      
   Sob=load(strcat('ob', num2str(sh_idx)));
   cell_ob=Sob.cell_ob;
      
   Spx=load(strcat('px', num2str(sh_idx)));
   cell_px=Spx.cell_px;
      
   Sexret=load(strcat('exret', num2str(sh_idx)));
   cell_exret=Sexret.cell_exret;
      
   Sdate=load(strcat('date', num2str(sh_idx)));
   cell_date=Sdate.cell_date;

   ctestY=cell(n_equity,n_factor);

      for m=1:n_equity
          for n=1:n_factor
              nob=cell_ob{m,n};
              %M is the lookback period. It could be a fixed number<=nob
              M=nob-N;
%               if nob<M
%                  M=nob-N;
%               end          
              in_test=zeros(N,M);
              Px_Y=cell_px{m,n};
              date=cell_date{m,n};
              exret=cell_exret{m,n};
              for t=1:N
                  in_test(t,:)=transpose(Px_Y(nob-M-N+t+1:nob-N+t,2));
              end
              ctestY{m,n} = sim(cnet{m,n},in_test);
              Y_backtest=ctestY{m,n};
              Y_target=cell_target{m,n}(nob-M-N+1:nob-N);
              new_perf=mse(cnet{m,n},Y_target,Y_backtest,'normalization','standard');%same with cPerf{m,n} in sfactor_nn_trainning
              Perf=[new_perf;Perf];
              [new_r,new_beta,new_alpha] = regression(Y_target,Y_backtest);
              R=[new_r;R];
              Beta=[new_beta;Beta];
              Alpha=[new_alpha;Alpha];
              date_backtest=date(nob-M+1:end);
              y_TH=prctile(Y_backtest,TH_prc);
              exrtn_backtest=exret(nob-M+1:end);
              [s,ret_v,newmetric]=general_backtest_v1(exrtn_backtest,Y_backtest,y_TH,date_backtest);
              Metrics=[Metrics; newmetric];
          end
      end
end




