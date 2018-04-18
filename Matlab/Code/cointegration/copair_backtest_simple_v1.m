function pairoutput=copair_backtest_simple_v1(beta_idx,Y,M,N,Signal_TH,pADF_TH,hp_TH,scaling,cost,tday,min_spread,max_pADF)
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
zscr_mov=[zscr_row(1:4) temp_mov(5:end)];

signal_l2=zscr(end-2);
signal_l=zscr(end-1);
signal_c=zscr(end); %find the zscr today and decide whether to trade or not
max_signal=max(abs(zscr(end-2:end)));


Signal_TH=roundn(max_signal,-1);


if pADF_TH > mean(v_pADF)
   pADF_TH=mean(v_pADF);
end

pairoutput=[pADF_TH, pValue,last_zspread,signal_l2,signal_l,signal_c,Signal_TH,lt_pADF];

