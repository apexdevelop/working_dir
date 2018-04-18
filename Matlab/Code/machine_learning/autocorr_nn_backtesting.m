% function [Metrics,Perf] = autocorr_nn_backtesting(opt_y,opt_x,sh_idx,N)
N=size(inputDelays,2);
%% Backtesting

TH_prc=95;
Metrics=[];
Perf=[];
enddate=today();
% Names=[];
%Step 1 choices of how to get Y
% if opt_y==1
   %option 1 load trainedY directly from database
   cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/ML');
   Sout=load(strcat('out', '_autocorr_',datestr(enddate)));
   Sperf=load(strcat('callPerf', '_autocorr_',datestr(enddate)));
   Sob=load(strcat('ob', '_autocorr_',datestr(enddate)));
   Sexrtn=load(strcat('exrtn', '_autocorr_',datestr(enddate)));
   Sdate=load(strcat('c_date', '_autocorr_',datestr(enddate)));
   cTrainY=Sout.cTrainY;
   cPerf=Sperf.callPerf;
   cell_ob=Sob.cell_ob;
   cell_exrtn=Sexrtn.cell_exrtn;
   cell_date=Sdate.c_date;
   n_pair=size(cell_exrtn,1);
   for m=1:n_pair
           nob=cell_ob{m,1}-1;
           %M is the lookback period. It could be a fixed number<=nob
           M=nob-N;       
           Y_backtest=transpose(cell2mat(cTrainY{m,1}));
           Perf=[cPerf{m,1};Perf];
           date_backtest=cell_date{m,1}(nob-M+2:end);
           y_TH=prctile(Y_backtest,TH_prc);
           exrtn_backtest=cell_exrtn{m,1}(nob-M+1:end);
           [s,ret_v,newmetric]=general_backtest_v1(exrtn_backtest,Y_backtest,y_TH,date_backtest);
           Metrics=[Metrics; newmetric];       
   end
% elseif opt_y==2
%    %option 2 load stored network, recreate input data and generate new Y
%    cd('Y:/working_directory/Matlab/Data/ML');
%    Snet=load(strcat('net', num2str(sh_idx)));
%    cnet=Snet.net;
%    [n_equity,n_factor]=size(cnet);
%    %Step 2 choices of how to recreate input data
%    if opt_x==1
%    %option 1 pull new data from Bloomberg
%     opt_save=2; % don't save the new data from bloomberg to database
%    [txt1,txt2,txt3,cell_px,cell_ret,cell_exret,cell_ob,cell_date,cell_target]= sfactor_generateData(sh_idx, opt_save);
%    elseif opt_x==2
%    %option 2 load data from saved database
%       Starget=load(strcat('target', num2str(sh_idx)));
%       cell_target=Starget.targetY;
%       
%       Sob=load(strcat('ob', num2str(sh_idx)));
%       cell_ob=Sob.cell_ob;
%       
%       Spx=load(strcat('px', num2str(sh_idx)));
%       cell_px=Spx.cell_px;
%       
%       Sexret=load(strcat('exret', num2str(sh_idx)));
%       cell_exret=Sexret.cell_exret;
%       
%       Sdate=load(strcat('date', num2str(sh_idx)));
%       cell_date=Sdate.cell_date;
%    end
%       ctestY=cell(n_equity,n_factor);
%       cd('Y:/working_directory/Matlab/Code');
% 
%       for m=1:n_equity
%           for n=1:n_factor
%               nob=cell_ob{m,n};
%               %M is the lookback period. It could be a fixed number<=nob
%               M=nob-N;
% %               if nob<M
% %                  M=nob-N;
% %               end          
%               in_test=zeros(N,M);
%               Px_Y=cell_px{m,n};
%               date=cell_date{m,n};
%               exret=cell_exret{m,n};
%               for t=1:N
%                   in_test(t,:)=transpose(Px_Y(nob-M-N+t+1:nob-N+t,2));
%               end
%               ctestY{m,n} = sim(cnet{m,n},in_test);
%               Y_backtest=ctestY{m,n};
%               Y_target=cell_target{m,n}(nob-M-N+1:nob);
%               new_perf=mse(net,Y_target,Y_backtest,'normalization','standard');
%               Perf=[new_perf;Perf];
%               date_backtest=date(nob-M+1:end);
%               y_TH=prctile(Y_backtest,TH_prc);
%               exrtn_backtest=exret(nob-M+1:end);
%               [s,ret_v,newmetric]=general_backtest_v1(exrtn_backtest,Y_backtest,y_TH,date_backtest);
%               Metrics=[Metrics; newmetric];
%           end
%       end
% end




