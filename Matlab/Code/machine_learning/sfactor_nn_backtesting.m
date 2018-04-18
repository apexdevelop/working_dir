function Metrics = sfactor_nn_backtesting(opt_y,opt_x,sh_idx,N)
% opt_x=opt_x_backtest;
% N=10;
%% Backtesting
cd('Y:/working_directory/Matlab/Data/ML');
TH_prc=95;
Metrics=[];

% Names=[];
%Step 1 choices of how to get Y
if opt_y==1
   %option 1 load trainedY directly from database
   cd('Y:/working_directory/Matlab/Data/ML');
   Sout=load(strcat('out', num2str(sh_idx)));
   Sob=load(strcat('ob', num2str(sh_idx)));
   Sexret=load(strcat('exret', num2str(sh_idx)));
   Sdate=load(strcat('date', num2str(sh_idx)));
   ctrainY=Sout.trainY;
   cell_ob=Sob.cell_ob;
   cell_exret=Sexret.cell_exret;
   cell_date=Sdate.cell_date;
   [n_equity,n_factor]=size(cell_exret);
   cd('Y:/working_directory/Matlab/Code');
   for m=1:n_equity
       for n=1:n_factor
           nob=cell_ob{m,n};
           %M is the lookback period. It could be a fixed number<=nob
           M=nob-N;       
           Y_backtest=ctrainY{m,n};
           date_backtest=cell_date{m,n}(nob-M+1:end);
           y_TH=prctile(Y_backtest,TH_prc);
           exrtn_backtest=cell_exret{m,n}(nob-M+1:end);
           [s,ret_v,newmetric]=nn_backtest_v1(exrtn_backtest,Y_backtest,y_TH,date_backtest);
           Metrics=[Metrics; newmetric];
%            Names=[Names; transpose(new_txt1)];        
       end
   end
elseif opt_y==2
   %option 2 load stored network, recreate input data and generate new Y
   cd('Y:/working_directory/Matlab/Data/ML');
   Snet=load(strcat('net', num2str(sh_idx)));
   cnet=Snet.net;
   [n_equity,n_factor]=size(cnet);
   %Step 2 choices of how to recreate input data
   if opt_x==1
   %option 1 pull data from Bloomberg
   [txt1,txt2,txt3,cell_px,cell_ret,cell_exret,cell_ob,cell_date]= sfactor_generateData(sh_idx);
   elseif opt_x==2
   %option 2 load data from saved database
      Sob=load(strcat('ob', num2str(sh_idx)));
      Spx=load(strcat('px', num2str(sh_idx)));
      Sexret=load(strcat('exret', num2str(sh_idx)));
      Sdate=load(strcat('date', num2str(sh_idx)));
      cell_ob=Sob.cell_ob;
      cell_px=Spx.cell_px;
      cell_exret=Sexret.cell_exret;
      cell_date=Sdate.cell_date;
   end
      ctestY=cell(n_equity,n_factor);
      cd('Y:/working_directory/Matlab/Code');

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
              date_backtest=date(nob-M+1:end);
              y_TH=prctile(Y_backtest,TH_prc);
              exrtn_backtest=exret(nob-M+1:end);
              [s,ret_v,newmetric]=general_backtest_v1(exrtn_backtest,Y_backtest,y_TH,date_backtest);
              Metrics=[Metrics; newmetric];
%               Names=[Names; transpose(new_txt1)];
          end
      end
end




