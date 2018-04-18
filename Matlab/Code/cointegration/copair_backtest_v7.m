
% function [pairoutput,zscr]=copair_backtest_v7(c_Stock,beta_idx,Y,M,N,old_Signal_TH,old_pADF_TH,hp_TH,scaling,cost,tday_m,old_status,direction,old_ret,old_vol,old_winp,old_omega,old_hp,old_trades,old_enterdate_m,old_exitdate_m)
% %% Process input args
% if ~exist('scaling','var') 
%     %exist('name','kind') if 'kind'='var',returns 1
%     scaling = 1;
% end
%  
% if ~exist('cost','var')
%     cost = 0;
% end
%  
%  
% if nargin == 1
%     % default values
%     M = 240;
%     N = 40;
% elseif nargin == 2
%     error('PAIRS:NoRebalancePeriodDefined',...
%         'When defining a lookback window, the rebalancing period must also be defined')
% end

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
       [~,ltp,~,~,ltreg] = egcitest(Y(j-1250:j,:),'alpha',old_pADF_TH);
       v_ltADF(j0-size(Y,1)+250)=ltp;
   end
   lt_pADF=mean(v_ltADF);
else
   [~,ltp,~,~,ltreg] = egcitest(Y,'alpha',old_pADF_TH);
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
      [~,~,~,~,reg1_rtn] = egcitest(rtn_NY1,'alpha',old_pADF_TH);
      
      switch beta_idx
          case 1
              NY1=Y(j-M+1:j,:);
          case 2
              NY1=Y(j-M+1:j,:)-repmat(mean(Y(j-M+1:j,:)),M,1);
          case 3
              NY1=zscore(Y(j-M+1:j,:));
      end
      [h,pValue,~,~,reg1_log] = egcitest(NY1,'alpha',old_pADF_TH);
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
         zscr(j:j+N-1)=(v_residual(j:j+N-1)-mean(reg1_log.res))/reg1_log.RMSE;

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
%          zscr(j:end)=(v_residual(j:end)-mean(v_residual(j-M+1:j)))/reg1_log.RMSE;
         zscr(j:end)=(v_residual(j:end)-mean(reg1_log.res))/reg1_log.RMSE;
      end
      j=j+N;
   end 

else
   diff_NY1=diff(Y); %diff log is log return
   rtn_NY1=diff_NY1-repmat(mean(diff_NY1),size(Y,1)-1,1);
   [~,~,~,~,reg1_rtn] = egcitest(rtn_NY1,'alpha',old_pADF_TH);
   
   [h,pValue,~,~,reg1_log] = egcitest(Y,'alpha',old_pADF_TH);
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
zscr_mov=[zscr_row(1:4) temp_mov(5:end)];

signal_l2=zscr(end-2);
signal_l=zscr(end-1);
signal_c=zscr(end); %find the zscr today and decide whether to trade or not

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
% trade_window=round(M/5);
trade_window=round(1*avg_cross_elapsed);

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
   last_extreme=0;
   last_distance=0;
   last_elapsed=-1;
end
%% Calculate performance statistics
new_status=0; %no trades for this run
db_subset=cell2mat(c_Stock(:,3:6));

for j=size(Y,1)-22:size(Y,1)
    if old_status==0 
       if new_status==0 % no trades before this run and for this run
          new_Signal_TH=old_Signal_TH;
          new_pADF_TH=old_pADF_TH; 
          new_ret=-99999;
          new_vol=-99999;
          new_winp=-99999;
          new_omega=-99999;
          new_hp=-99999;
          new_trades=-99999;
          excel_enter_date=m2xdate(700000,0);
          excel_exit_date=m2xdate(900000,0);

          if (zscr(j)>=1 && zscr(j)<=zscr(j-1) && zscr(j)>=0.75*zscr(j-1)) ...
             ||(zscr(j)<=-1 && zscr(j)>=zscr(j-1) && zscr(j)<=0.75*zscr(j-1))
             new_enterdate_m=tday_m(j);
             excel_enter_date=m2xdate(new_enterdate_m);
             new_status=1;
             direction=-zscr(j)/abs(zscr(j));
             if direction ==1
                s(j, 1) = 1;
                s(j, 2) = - s(j, 1);
             elseif direction==-1
                s(j, 1) = -1;
                s(j, 2) = - s(j, 1);
             end
             new_Signal_TH=roundn((zscr(j)+3)/0.25,0)*0.25-3;
             if new_Signal_TH<-3
                new_Signal_TH = -3;  
             end
             if new_Signal_TH>3
                new_Signal_TH =3;  
             end
          
             new_pADF_TH=roundn(v_pADF(j),-1);
             if new_pADF_TH<0.1
                new_pADF_TH = 0.1;  
             end
             if new_pADF_TH>0.5
                new_pADF_TH =0.5;  
             end
             
             %locate rows based on signal and pADF
             TH_target=[M,N,new_Signal_TH,new_pADF_TH];
             thLia=ismembertol(db_subset,TH_target,'ByRows',true);
             TH_idx=find(thLia);
             new_ret=cell2mat(c_Stock(TH_idx,7)); 
             new_vol=cell2mat(c_Stock(TH_idx,8));
             new_winp=cell2mat(c_Stock(TH_idx,9));
             new_omega=cell2mat(c_Stock(TH_idx,10));
             new_hp=cell2mat(c_Stock(TH_idx,11));
             new_trades=cell2mat(c_Stock(TH_idx,12));
             
          end
          
       else
          %if there is already trades for current round
%           %locate rows based on signal and pADF
%           TH_target=[new_Signal_TH,new_pADF_TH];
%           thLia=ismembertol(db_subset,TH_target,'ByRows',true);
%           TH_idx=find(thLia);
%           new_ret=cell2mat(c_Stock(TH_idx,7)); 
%           new_vol=cell2mat(c_Stock(TH_idx,8));
%           new_winp=cell2mat(c_Stock(TH_idx,9));
%           new_omega=cell2mat(c_Stock(TH_idx,10));
%           new_hp=cell2mat(c_Stock(TH_idx,11));
%           new_trades=cell2mat(c_Stock(TH_idx,12));
          entryIDX=find(tday_m==new_enterdate_m);
          
          excel_exit_date=m2xdate(900000,0);
          s(j,1)=s(j-1,1);
          s(j, 2) = -s(j, 1);
          v_current_trade=sum([0 0; s(entryIDX:j-1, :) .* diff(Y(entryIDX:j,:))] ,2);
          sum_current_trade= sum(v_current_trade);
          
          % to avoid exit right after enter :j>entryIDX+2
          if j>entryIDX+2 && ((direction==-1 && zscr(j)<-0.25*new_Signal_TH) || (direction==-1 && zscr(j)>-0.25*new_Signal_TH) ...
          || (j-entryIDX>hp_TH)|| (sum_current_trade<-0.15) || v_pADF(j)>0.8)
             new_status=0;
             new_exitdate_m=tday_m(j);
             excel_exit_date=m2xdate(new_exitdate_m);
          end
       end
    else
       %if old_status==1, there is trade from previous run
       new_Signal_TH=old_Signal_TH;
       new_pADF_TH=old_pADF_TH;
       new_ret=old_ret;
       new_vol=old_vol;
       new_winp=old_winp;
       new_omega=old_omega;
       new_hp=old_hp;
       new_trades=old_trades;
       excel_enter_date=m2xdate(old_enterdate_m);
       excel_exit_date=m2xdate(old_exitdate_m);
       entryIDX=find(tday_m==old_enterdate_m);
       
       s(j,1)=s(j-1,1);
       s(j, 2) = -s(j, 1);
       v_current_trade=sum([0 0; s(entryIDX:j-1, :) .* diff(Y(entryIDX:j,:))] ,2);
       sum_current_trade= sum(v_current_trade);
       
       if j>entryIDX+2 && ((direction==-1 && zscr(j)<-0.25*old_Signal_TH) || (direction==-1 && zscr(j)>-0.25*old_Signal_TH) ...
          || (j-entryIDX>hp_TH)|| (sum_current_trade<-0.15) || v_pADF(j)>0.8)
          old_status=0;
          new_exitdate_m=tday_m(j);
          excel_exit_date=m2xdate(new_exitdate_m);
       end
    end
     
end
final_status=new_status+old_status;
beta=reg1_rtn.coeff(2);
R2=reg1_log.RSq;


%% build output
% pairoutput=[new_pADF_TH,pValue,last_zspread,signal_l2,signal_l,signal_c,new_Signal_TH,new_ret,new_vol,new_winp,new_omega,new_hp,new_trades,reg1_rtn.coeff(2),reg1_log.RSq,...
%    avg_cross_elapsed,yr_cross,last_elapsed,last_distance,last_extreme,lt_pADF,excel_enter_date,excel_exit_date];
pairoutput=[last_zspread,signal_l2,signal_l,signal_c,new_Signal_TH,new_pADF_TH,final_status,direction,new_ret,new_vol,new_winp,new_omega,new_hp,new_trades,excel_enter_date,excel_exit_date,pValue,lt_pADF,beta,R2,...
   avg_cross_elapsed,yr_cross,last_elapsed,last_distance,last_extreme];
