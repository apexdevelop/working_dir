function [pairoutput,r]=copair_backtest_learnfromtech(beta_idx,Y,M,N,Signal_TH,pADF_TH,hp_TH,scaling,cost,tday,min_spread,max_pADF,status)
%% Process input args
if ~exist('scaling','var') 
    %exist('name','kind') if 'kind'='var',returns 1
    scaling = 1;
end
 
if ~exist('cost','var')
    cost = 0;
end
 
 
if nargin == 1
    % default values
    M = 240;
    N = 40;
elseif nargin == 2
    error('PAIRS:NoRebalancePeriodDefined',...
        'When defining a lookback window, the rebalancing period must also be defined')
end

% Very often, the pairs will be convincingly cointegrated, or convincingly
% NOT cointegrated.  In these cases, a warning is issued not to read too
% much into the test statistic.  Since we don't use the test statistic, we
% can suppress these warnings.
warning('off', 'econ:egcitest:LeftTailStatTooSmall')
warning('off', 'econ:egcitest:LeftTailStatTooBig')
%% Sweep across the entire time series           
%Conduct Regression to calculate residual and compute ADF stat

v_spread=Y(:,1)-Y(:,2);
z_spread=zeros(size(Y,1),1);

if M<size(Y,1)
   z_spread(1:M-1)=zscore(v_spread(1:M-1));
   for j=M : size(Y,1)
       temp_z=zscore(v_spread(j-M+1:j));
       z_spread(j)=temp_z(M);
   end
else
   z_spread=zscore(v_spread);
end

last_zspread=z_spread(size(Y,1));

zscr=zeros(size(Y,1),1);
s = zeros(size(Y,1),size(Y,2));
v_h = zeros(size(Y,1),1);         
v_residual=zeros(size(Y,1),1);
r_trade = zeros(size(Y,1),1);
CPnL=zeros(size(Y,1),1);
v_Beta = zeros(size(Y,1),1);
v_pADF = zeros(size(Y,1),1);
%% Calculate Z-residual

%calculate long term pADF
v_ltADF=zeros(250,1);
if size(Y,1)>=1502
   for j0=size(Y,1)-249:size(Y,1)    
       [~,ltp,~,~,ltreg] = egcitest(Y(j-1250:j,:),'alpha',pADF_TH);
       v_ltADF(j0-size(Y,1)+250)=ltp;
   end
   lt_pADF=mean(v_ltADF);
else
   [~,ltp,~,~,ltreg] = egcitest(Y,'alpha',pADF_TH);
   lt_pADF=ltp;
end


%calculate rolling pADF and Beta

if M< size(Y,1)
   j=M;
   while j<=size(Y,1)
      NY1=[];
      NY2=[];
      diff_NY1=diff(Y(j-M+1:j,:)); %diff log is log return
      rtn_NY1=diff_NY1-repmat(mean(diff_NY1),M-1,1);
      [~,~,~,~,reg1_rtn] = egcitest(rtn_NY1,'alpha',pADF_TH);
      
      switch beta_idx
          case 1
              NY1=Y(j-M+1:j,:);
          case 2
              NY1=Y(j-M+1:j,:)-repmat(mean(Y(j-M+1:j,:)),M,1);
          case 3
              NY1=zscore(Y(j-M+1:j,:));
      end
      [h,pValue,~,~,reg1_log] = egcitest(NY1,'alpha',pADF_TH);
      b=reg1_log.coeff(2:end);
      v_Beta(j:j+N-1)=b*ones(N,1);
      v_h(j:j+N-1)=h*ones(N,1);
      v_pADF(j:j+N-1)=pValue*ones(N,1);
      
      if j<=size(Y,1)-N
         switch beta_idx
          case 1
              NY2=Y(j:j+N-1,:);
          case 2
              NY2=Y(j:j+N-1,:)-repmat(mean(Y(j:j+N-1,:)),N,1);
          case 3
              NY2=zscore(Y(j:j+N-1,:));
         end
         v_residual(j:j+N-1)=NY2*[1;-b]-reg1_log.coeff(1);
         zscr(j:j+N-1)=(v_residual(j:j+N-1)-mean(v_residual(j-M+1:j)))/reg1_log.RMSE;

      else
          switch beta_idx
          case 1
              NY2=Y(j:end,:);
          case 2
              NY2=Y(j:end,:)-repmat(mean(Y(j:end,:)),size(Y,1)-j+1,1);
          case 3
              NY2=zscore(Y(j:end,:));
         end
         v_residual(j:end)=NY2*[1;-b]-reg1_log.coeff(1);
         zscr(j:end)=(v_residual(j:end)-mean(v_residual(j-M+1:j)))/reg1_log.RMSE;
      end
      j=j+N;
   end 

else
   diff_NY1=diff(Y); %diff log is log return
   rtn_NY1=diff_NY1-repmat(mean(diff_NY1),size(Y,1)-1,1);
   [~,~,~,~,reg1_rtn] = egcitest(rtn_NY1,'alpha',pADF_TH);
   
   [h,pValue,~,~,reg1_log] = egcitest(Y,'alpha',pADF_TH);
   b=reg1_log.coeff(2:end);
   v_Beta(1:end)=b*ones(size(Y,1),1);
   v_h(1:end)=h*ones(size(Y,1),1);
   v_pADF(1:end)=pValue*ones(size(Y,1),1);
   v_residual=reg1_log.res;
   zscr=zscore(v_residual);
end    

% moving average
zscr_row=reshape(zscr,1,size(zscr,1));
temp_mov=tsmovavg(zscr_row,'e',5);
zscr_mov=[zscr_row(1:4) temp_move(5:end)];

signal_l2=zscr(end-2);
signal_l=zscr(end-1);
signal_c=zscr(end); %find the zscr today and decide whether to trade or not

zscr2=zeros(size(Y,1),1);

v_h2 = zeros(size(Y,1),1);         
v_residual2=zeros(size(Y,1),1);
v_Beta2 = zeros(size(Y,1),1);
v_pADF2 = zeros(size(Y,1),1);

   M2=240; 
   j=M2;
   while j<=size(Y,1)
      NY1=[];
      NY2=[];
      switch beta_idx
          case 1
              NY1=Y(j-M+1:j,:);
          case 2
              NY1=Y(j-M+1:j,:)-repmat(mean(Y(j-M+1:j,:)),M,1);
          case 3
              NY1=zscore(Y(j-M+1:j,:));
      end
      [h,pValue,~,~,reg1_log] = egcitest(NY1,'alpha',pADF_TH);
      b=reg1_log.coeff(2:end);
      v_Beta2(j:j+N-1)=b*ones(N,1);
      v_h2(j:j+N-1)=h*ones(N,1);
      v_pADF2(j:j+N-1)=pValue*ones(N,1);
      
      if j<=size(Y,1)-N
         switch beta_idx
          case 1
              NY2=Y(j:j+N-1,:);
          case 2
              NY2=Y(j:j+N-1,:)-repmat(mean(Y(j:j+N-1,:)),N,1);
          case 3
              NY2=zscore(Y(j:j+N-1,:));
         end
         v_residual2(j:j+N-1)=NY2*[1;-b]-reg1_log.coeff(1);
         zscr2(j:j+N-1)=(v_residual2(j:j+N-1)-mean(v_residual2(j-M+1:j)))/reg1_log.RMSE;

      else
          switch beta_idx
          case 1
              NY2=Y(j:end,:);
          case 2
              NY2=Y(j:end,:)-repmat(mean(Y(j:end,:)),size(Y,1)-j+1,1);
          case 3
              NY2=zscore(Y(j:end,:));
         end
         v_residual2(j:end)=NY2*[1;-b]-reg1_log.coeff(1);
         zscr2(j:end)=(v_residual2(j:end)-mean(v_residual2(j-M+1:j)))/reg1_log.RMSE;
      end
      j=j+N;
   end 


%Calculating # of times spread cross 0 line
cross=0;
v_cross=[];
for ctr=2:size(Y,1)
   if (zscr(ctr-1,1) > 0 && zscr(ctr,1) < 0)
       cross=cross+1;
       v_cross=[v_cross;ctr];
   elseif (zscr(ctr-1,1)<0 && zscr(ctr,1) >0)
       cross=cross+1;
       v_cross=[v_cross;ctr];
   end   
end
%annual number of cross
yr_cross=round(cross/(size(Y,1)/225));
diff_cross=diff(v_cross);
avg_cross_elapsed=round(mean(diff_cross));

if isempty(v_cross)==0 && v_cross(end)~=size(Y,1)    
   if mean(zscr(v_cross(end)+1:end))>=0
    [last_extreme, I]=max(zscr(v_cross(end)+1:end));
    last_distance=last_extreme-zscr(end);
   else
    [last_extreme, I]=min(zscr(v_cross(end)+1:end));
    last_distance=zscr(end)-last_extreme;
   end
   last_elapsed=size(Y,1)-v_cross(end)-I;
else
   last_extreme=-100;
   last_distance=-100;
   last_elapsed=-100;
end

  %% Calculate Performance statistics based on current spread
trades=0;                          
Enter=[];
Exit=[];
Long=[];
Short=[];
ret_v=[];
hp_v=[];
is_open=0;
direction=0;

% judging if last day's signal is at least 0.5z and pValue is less than 0.4
if Signal_TH>=0.5*min_spread && lt_pADF<=max_pADF
   for j=M:size(Y,1)
         if is_open~=0 %that means position opened  
            s(j,1)=s(j-1,1);
            for col=2:size(Y,2)
                s(j,col) = - s(j, 1);
            end
                        
            r_trade(entryIDX)=0;
            current_r=sum([0 0; s(entryIDX:j-1, :) .* diff(Y(entryIDX:j,:))] ,2);
            r_trade(j)= sum(current_r);
            cumul_r= sum([0 0; s(1:j-1, :) .* diff(Y(1:j,:))] ,2);
            CPnL(j)= sum(cumul_r);
            
            %exit
            if (s(j,1)==-1 && mean(zscr(j-1:j))>=0.3) ...
            || (s(j,1)==1 && mean(zscr(j-2:j))<=-0.3) ...
            || r_trade(j)<-0.15 || j-entryIDX > hp_TH ...
                trades=trades+1;
                ret_v=[ret_v;r_trade(j)];
                hp_v=[hp_v;j-entryIDX];
                Exit=[Exit;j];
                is_open=0;
                direction=0;
            end
         else   %position not opened
            CPnL(j)= CPnL(j-1);
            if  s(j-1,1)==0 && mean(zscr2(j-2:j))>=-1 && mean(zscr2(j-2:j))<=1 && mean(zscr(j-1:j))>=1.5
                s(j, 1) = -1;
                for col=2:size(Y,2)
                    s(j,col) = - s(j, 1);
                end
                entryIDX=j;
                is_open=1;
                direction=-1;
                Enter=[Enter;j];
                Short=[Short;j];
            elseif s(j-1,1)==0 && mean(zscr2(j-2:j))>=-1 && mean(zscr2(j-2:j))<=1 && mean(zscr(j-1:j))<=-1.5
                s(j, 1) = 1;
                for col=2:size(Y,2)
                    s(j,col) = - s(j, 1);
                end
                entryIDX=j;
                is_open=1;
                direction=1;
                Enter=[Enter;j];
                Long=[Long;j];
            else
            end
         end
   end
end

if isempty(Enter)==0
   last_enter=m2xdate(tday(Enter(end)),0); 
else
   last_enter=m2xdate(700000,0);
end

if isempty(Enter)==0 && isempty(Exit)==0   
      last_exit=m2xdate(tday(Exit(end)),0);
      wins=size(find(ret_v>0),1);                       
      av_ret=mean(ret_v);
      hp=round(mean(hp_v));
      winp=wins/trades;
      yr_trades=round(trades/(size(Y,1)/225));
else
      last_exit=m2xdate(700000,0);
      av_ret=-100;
      hp=-100;
      winp=-100;
      yr_trades=-100; 
end

% daily return
r  = sum([0 0; s(1:end-1, :) .* diff(Y) - abs(diff(s))*cost/2] ,2);

%% build output
% v_Beta=v_Beta(M:end);
% v_pADF=v_pADF(M:end);
% m_Beta=mean(v_Beta);
% m_pADF=mean(v_pADF);


pairoutput=[pADF_TH, pValue,last_zspread,signal_l2,signal_l,signal_c,Signal_TH,av_ret,winp,reg1_rtn.coeff(2),reg1_log.RSq,...
   hp,avg_cross_elapsed,yr_trades,yr_cross,is_open,direction,last_exit,last_enter,last_elapsed,last_distance,last_extreme,lt_pADF];

