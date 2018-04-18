% function varargout = pairs(is_adf, beta_idx, Y, M, N, Signal_TH, pADF_TH,scaling, cost)
% PAIRS returns a trading signal for a simple pairs trading strategy
 
%%
% Copyright 2010, The MathWorks, Inc.
% All rights reserved.
 
%% Process input args
if ~exist('scaling','var') 
    %exist('name','kind') if 'kind'='var',returns 1
    scaling = 1;
end
 
if ~exist('cost','var')
    cost = 0;
end
 
if ~exist('Signal_TH', 'var')
    Signal_TH = 1;
end
 
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
% Every N periods, we use the previous M periods' worth of information to
% estimate the cointegrating relationship (if it exists).
%
% We then use this estimated relationship to identify trading opportunities
% until the next rebalancing date.

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

zscr=zeros(size(Y,1),1);
v_residual=zeros(size(Y,1),1);
s = zeros(size(Y,1),2);
v_pADF = zeros(size(Y,1),1);
v_h = zeros(size(Y,1),1);
v_Beta = zeros(size(Y,1),1);
CPnL=zeros(size(Y,1),1);
r_trade = zeros(size(Y,1),1);
hp_TH=44;
%% Calculate Z-residual

if M< size(Y,1)

   j=M;
   while j<=size(Y,1)
      NY1=[];
      NY2=[];
%       diff_NY1=diff(Y(j-M+1:j,:)); %diff log is log return
%       rtn_NY1=diff_NY1-repmat(mean(diff_NY1),M-1,1);
%       [~,~,~,~,reg2] = egcitest(rtn_NY1,'alpha',pADF_TH);
      
      switch beta_idx
          case 1
              NY1=Y(j-M+1:j,:);
          case 2
              NY1=Y(j-M+1:j,:)-repmat(mean(Y(j-M+1:j,:)),M,1);
          case 3
              NY1=zscore(Y(j-M+1:j,:));
      end
      [h,pValue,~,~,reg1] = egcitest(NY1,'alpha',pADF_TH);
      b=reg1.coeff(2:end);
      v_Beta(j:j+N-1)=b*ones(N,1);
%       v_Alpha(j:j+N-1)=reg1.coeff(1)*ones(N,1);
      v_pADF(j:j+N-1)=pValue*ones(N,1);
      v_h(j:j+N-1)=h*ones(N,1);
      if j<=size(Y,1)-N
         switch beta_idx
         case 1
              NY2=Y(j:j+N-1,:);
         case 2
              NY2=Y(j:j+N-1,:)-repmat(mean(Y(j:j+N-1,:)),N,1);
         case 3
              NY2=zscore(Y(j:j+N-1,:));
         end
         v_residual(j:j+N-1)=NY2*[1;-b]-reg1.coeff(1);
         zscr(j:j+N-1)=(v_residual(j:j+N-1)-mean(v_residual(j-M+1:j)))/reg1.RMSE;
                  
      else
          switch beta_idx
          case 1
              NY2=Y(j:end,:);
          case 2
              NY2=Y(j:end,:)-repmat(mean(Y(j:end,:)),size(Y,1)-j+1,1);
          case 3
              NY2=zscore(Y(j:end,:));
         end
         v_residual(j:end)=NY2*[1;-b]-reg1.coeff(1);
         zscr(j:end)=(v_residual(j:end)-mean(v_residual(j-M+1:j)))/reg1.RMSE; 
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
diff_cross=diff(v_cross);
avg_cross_elapsed=round(mean(diff_cross));
half_cross=round(0.5*avg_cross_elapsed);


%% Calculate performance statistics
trades=0;                          
is_open=0;
ret_v=[];
ret_adj_v=[];
adj_day=20;
hp_v=[];

if is_adf=='N'
   v_h = ones(size(Y,1),1);
end

for j=M:size(Y,1)
         if is_open~=0 %that means position opened  
            s(j,1)=s(j-1,1);
            s(j, 2) = -s(j, 1);
%             s(j, 2) = -v_Beta(j) * s(j, 1); 
            r_trade(entryIDX)=0;
            current_r=sum([0 0; s(entryIDX:j-1, :) .* diff(Y(entryIDX:j,:))] ,2);
            r_trade(j)= sum(current_r);
            cumul_r= sum([0 0; s(1:j-1, :) .* diff(Y(1:j,:))] ,2);
            CPnL(j)= sum(cumul_r);            
            %exit
            if (s(j,1)==-1 && zscr(j)<-0.25*Signal_TH) || (s(j,1)==1 && zscr(j)>0.25*Signal_TH) ...
                    || r_trade(j)<-0.15 || j-entryIDX > hp_TH ...
%                 || v_h(j) ==0
                trades=trades+1;
                is_open=0;
                ret_v=[ret_v;r_trade(j)];
                adj_ret=100*((r_trade(j)/100+1)^(adj_day/(j-entryIDX))-1);
                ret_adj_v=[ret_adj_v;adj_ret];
                hp_v=[hp_v;j-entryIDX];
            end
         else   %position not opened
         CPnL(j)= CPnL(j-1);
            if  s(j-1,1)==0 && zscr(j-1)>Signal_TH && zscr(j)<=Signal_TH && zscr(j)>=0.75*Signal_TH ...
%                 && sum(diff(zscr(j-avg_cross_elapsed-half_cross-1:j-avg_cross_elapsed-1)))<=0 ...
%                 && v_h(j)~=0
%             && sum(diff(zscr(j-half_cross-1:j-1)))>=0                
%             && z_spread(j)>0 
                s(j, 1) = -1;
                s(j, 2) = - s(j, 1);
%                 s(j, 2) = -v_Beta(j) * s(j, 1);
                entryIDX=j;
                is_open=1;

            elseif s(j-1,1)==0 && zscr(j)<-Signal_TH && zscr(j)>=-Signal_TH && zscr(j)<=-0.75*Signal_TH ...
%                    && sum(diff(zscr(j-avg_cross_elapsed-half_cross-1:j-avg_cross_elapsed-1)))>=0 ...
%                    && v_h(j)~=0
%             && sum(diff(zscr(j-half_cross-1:j-1)))<=0               
%             && z_spread(j)<0 
                s(j, 1) = 1;
                s(j, 2) = - s(j, 1);
%                 s(j, 2) = -v_Beta(j) .* s(j, 1);
                entryIDX=j;
                is_open=1;
            else
            end
         end
end

% sh = scaling*sharpe(r,0);
 
% if nargout == 0
%     %% Plot results
%     ax(1) = subplot(3,1,1);
%     plot(Y), grid on
%     legend('LCO','WTI')
%     title(['Pairs trading results, Sharpe Ratio = ',num2str(sh,3)])
%     ylabel('Price (USD)')
%    
%     ax(2) = subplot(3,1,2);
%     plot([indicate,spread*ones(size(indicate)),-spread*ones(size(indicate))])
%     grid on
%     legend(['Indicator'],'LCO: Over bought','LCO: Over sold',...
%         'Location','NorthWest')
%     title(['Pairs indicator: rebalance every ' num2str(N)...
%         ' minutes with previous ' num2str(M) ' minutes'' prices.'])
%     ylabel('Indicator')
%    
%     ax(3) = subplot(3,1,3);
%     plot([s,cumsum(r)]), grid on
%     legend('Position for LCO','Position for WTI','Cumulative Return',...
%         'Location', 'NorthWest')
%     title(['Final Return = ',num2str(sum(r),3),' (',num2str(sum(r)/mean(Y(1,:))*100,3),'%)'])
%     ylabel('Return (USD)')
%     xlabel('Serial time number')
%     linkaxes(ax,'x')
% else
%     %% Return values
%     %adj_ret,adj_vol,winp,hp,ntrades,ncross
%     for i = 1:nargout
%         switch i
%             case 1
%                 if trades>=1
% %                    varargout{1} =mean(ret_adj_v); 
%                    varargout{1} =mean(ret_v); 
%                 else
%                    varargout{1} =0; 
%                 end
%             case 2
%                 if trades>=1
% %                    varargout{2} =std(ret_adj_v); 
%                    varargout{2} =std(ret_v); 
%                 else
%                    varargout{2} =0; 
%                 end
%             case 3
%                 if trades>=1
% %                    wins=ret_adj_v(find(ret_adj_v>0));
%                    wins=ret_v(find(ret_v>0));
%                    nwins=size(wins,1);        
% %                    wins=size(find(ret_adj_v>0),1);
%                    varargout{3} =nwins/trades; 
%                 else
%                    varargout{3} =0; 
%                 end
%             case 4
%                 if trades>=1
%                    wins=ret_v(find(ret_v>0));
%                    loss=ret_v(find(ret_v<=0));
%                    omega=sum(wins)/(sum(wins)-sum(loss));
%                    varargout{4} =omega; 
%                 else
%                    varargout{4} =0; 
%                 end    
%             case 5
%                 if trades>=1
%                    varargout{5} = round(mean(hp_v));
%                 else
%                    varargout{5} =0;
%                 end   
%             case 6
% %                 adj_trades=round(trades/(size(Y,1)/adj_day));
%                 varargout{6} = trades;%ntrades per month
%             otherwise
%                 warning('PAIRS:OutputArg',...
%                     'Too many output arguments requested, ignoring last ones');
%         end
%     end
% end
