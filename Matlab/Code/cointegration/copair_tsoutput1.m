function [metric,v_Alpha,v_Beta,v_Beta2,v_spread,z_spread,v_residual,z_signal,v_pADF,signal_long,signal_short,signal_exit,r_trade,CPnL]=copair_tsoutput1(is_adf,beta_idx,Y,M,N,Signal_TH,pADF_TH,hp_TH,scaling,cost,tday,biret)
% Y=rel_logY;
% M=param1(1);
% N=param1(2);
% spread=param1(3);
% p_ADF_TH=param1(4);

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

z_spread(1:M-1)=zscore(v_spread(1:M-1));

for j=M : size(Y,1)
    temp_z=zscore(v_spread(j-M+1:j));
    z_spread(j)=temp_z(M);
end

zscr=zeros(size(Y,1),1);
v_residual=zeros(size(Y,1),1);
s = zeros(size(Y,1),2);
v_pADF = zeros(size(Y,1),1);
v_h = zeros(size(Y,1),1);
v_Beta = zeros(size(Y,1),1);
v_Beta2 = zeros(size(Y,1),1);
v_Alpha = zeros(size(Y,1),1);
r_trade = zeros(size(Y,1),1);
CPnL=zeros(size(Y,1),1);
%% Calculate Z-residual

j=M;

while j<=size(Y,1)
      NY1=[];
      NY2=[];
      diff_NY1=diff(Y(j-M+1:j,:)); %diff log is log return
      rtn_NY1=diff_NY1-repmat(mean(diff_NY1),M-1,1);
      [~,~,~,~,reg2] = egcitest(rtn_NY1,'alpha',pADF_TH);
      v_Beta2(j:j+N-1)=reg2.coeff(2)*ones(N,1);
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
      v_Alpha(j:j+N-1)=reg1.coeff(1)*ones(N,1);
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

v_cross=diff(v_cross);
avg_cross_elapsed=round(mean(v_cross));

 %% Calculate Performance statistics based on current spread       
trades=0;                          
Enter=[];
Exit=[];
Long=[];
Short=[];
ret_v=[];
hp_v=[];
is_open=0;

if is_adf=='N'
   v_h = ones(size(Y,1),1);
end

for j=M:size(Y,1)
         if is_open~=0 %that means position opened  
            s(j,2)=s(j-1,2);
            s(j, 1) =  -s(j, 2);
%             s(j, 1) = -v_Beta(j) * s(j, 2); 
            r_trade(entryIDX)=0;
            current_r=sum([0 0; s(entryIDX:j-1, :) .* diff(Y(entryIDX:j,:))] ,2);
            r_trade(j)= sum(current_r);
            cumul_r= sum([0 0; s(1:j-1, :) .* diff(Y(1:j,:))] ,2);
            CPnL(j)= sum(cumul_r);
            
            %exit
            if (s(j,2)==1 && zscr(j)<-0.25*Signal_TH) || (s(j,2)==-1 && zscr(j)>0.25*Signal_TH) ...
                    || r_trade(j)<-0.15 || j-entryIDX > hp_TH
%                 || v_ADF(j) ==0
                trades=trades+1;
                ret_v=[ret_v;r_trade(j)];
                hp_v=[hp_v;j-entryIDX];
                Exit=[Exit;j];
                is_open=0;
            end
         else   %position not opened
            CPnL(j)= CPnL(j-1);
            if  s(j-1,2)==0 && zscr(j-1)>Signal_TH && zscr(j)<Signal_TH && zscr(j)>0.50*zscr(j-1) ... 
                && v_h(j)~=0
%                 && z_spread(j)>0 
                s(j, 2) = 1;
                s(j, 1) = - s(j, 2);
%                 s(j, 1) = -v_Beta(j) * s(j, 2);
                entryIDX=j;
                is_open=1;
                Enter=[Enter;j];
                Short=[Short;j];
            elseif s(j-1,2)==0 && zscr(j-1)<-Signal_TH && zscr(j)>-Signal_TH && zscr(j)<0.50*zscr(j-1) ...
                && v_h(j)~=0
%                 && z_spread(j)<0 
                s(j, 2) = -1;
                s(j, 1) = - s(j, 2);
%                 s(j, 1) = -v_Beta(j) .* s(j, 2);
                entryIDX=j;
                is_open=1;
                Enter=[Enter;j];
                Long=[Long;j];
            else
            end
         end
end

if isempty(Enter)==0 && isempty(Exit)==0
      last_enter=m2xdate(tday(Enter(end)),0);
      last_exit=m2xdate(tday(Exit(end)),0);
         
      wins=size(find(ret_v>0),1);                       
      av_ret=mean(ret_v);
      hp=round(mean(hp_v));
      winp=wins/trades;
else
      last_enter=m2xdate(700000,0);
      last_exit=m2xdate(700000,0);
      totret=-100;
      av_ret=-100;
      hp=-100;
      winp=-100;
      trades=-100; 
end
%% build output

signal_long=NaN(size(s,1),1);
signal_short=NaN(size(s,1),1);
signal_long(Long)=zscr(Long);
signal_short(Short)=zscr(Short);

signal_exit=NaN(size(s,1),1);
signal_exit(Exit)=zscr(Exit);

v_Alpha=v_Alpha(M:end);
v_Beta=v_Beta(M:end);
v_Beta2=v_Beta2(M:end);
v_spread=v_spread(M:end);
z_spread=z_spread(M:end);

v_residual=v_residual(M:end);
z_signal=zscr(M:end);
signal_long=signal_long(M:end);
signal_short=signal_short(M:end);
signal_exit=signal_exit(M:end);


v_pADF=v_pADF(M:end);
CPnL=CPnL(M:end);
r_trade=r_trade(M:end);
s=s(M:end,:);

if abs(signal_c)>=1
   signal_idx=round((abs(signal_c)-1)/0.1)+1;
   exp_ret=biret(signal_idx,3);
end

metric=[reg2.coeff(2),reg1.RSq,pValue,signal_l,signal_c,...
exp_ret,av_ret,hp,avg_cross_elapsed,trades,cross,winp,last_exit,last_enter];

end


