function pairoutput=copair_sweep_optimize(beta_idx,Y,M,N,pADF_TH,biret,signal_step,status)
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
v_residual=zeros(size(Y,1),1);
v_Beta = zeros(size(Y,1),1);
v_pADF = zeros(size(Y,1),1);
%% Calculate Z-residual

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
      [~,pValue,~,~,reg1_log] = egcitest(NY1,'alpha',pADF_TH);
      b=reg1_log.coeff(2:end);
      v_Beta(j:j+N-1)=b*ones(N,1);
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
   
   [~,pValue,~,~,reg1_log] = egcitest(Y,'alpha',pADF_TH);
   b=reg1_log.coeff(2:end);
   v_Beta(1:end)=b*ones(size(Y,1),1);
   v_pADF(1:end)=pValue*ones(size(Y,1),1);
   v_residual=reg1_log.res;
   zscr=zscore(v_residual);
end    

% moving average
zscr_row=reshape(zscr,1,size(zscr,1));
zscr_mov=[zscr_row(1:4) tsmovavg(zscr_row,'e',5)];

signal_l2=zscr(end-2);
signal_l=zscr(end-1);
signal_c=zscr(end); %find the zscr today and decide whether to trade or not
max_signal=max(abs(zscr(end-2:end)));
% max_signal=abs(signal_c);
signal_idx=round((max_signal-1)/signal_step)+1;

if max_signal>=1 && max_signal<=3
   exp_ret=biret(signal_idx,4);
else
   exp_ret=NaN;
end

across_ret=zeros(1,size(biret,2));
for j=1:size(biret,2)
    temp_biret=biret(:,j);
    temp_biret(isnan(temp_biret))=[];
    across_ret(j)=mean(temp_biret);
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
   last_extreme=0.01;
   last_distance=-10;
   last_elapsed=-10;
end



%% build output


pairoutput=[pValue,last_zspread,signal_l2,signal_l,signal_c,reg1_log.coeff(2),reg1_log.RSq,...
   avg_cross_elapsed,yr_cross,last_elapsed,last_distance,last_extreme,exp_ret,across_ret,mean(v_pADF)];

