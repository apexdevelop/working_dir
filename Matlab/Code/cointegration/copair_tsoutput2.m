function [metric,v_Alpha,v_Beta,v_residual,z_signal,v_pADF,signal_long,signal_short,signal_exit,r,CPnL]=copair_tsoutput2(beta_idx,Y,M,N,Signal_TH,p_ADF_TH,hp_TH,scaling,cost,tday)
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

zscr=zeros(size(Y,1),1);
s = zeros(size(Y,1),2);
v_residual=zeros(size(Y,1),1);
v_pADF=zeros(size(Y,1),1);

v_Beta = zeros(size(Y,1),1);
v_Alpha = zeros(size(Y,1),1);
%% Calculate Performance statistics based on current spread

j=M;
long_day=0;
short_day=0;

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
      [h,pValue,~,~,reg1] = egcitest(NY1,'alpha',p_ADF_TH);
      b=reg1.coeff(2:end);
      v_pADF(j:j+N-1)=pValue*ones(N,1);
      v_Beta(j:j+N-1)=b*ones(N,1);
      v_Alpha(j:j+N-1)=reg1.coeff(1)*ones(N,1);
      
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
         
         for t=j:j+N-1
             if h~=0
                if (s(t-1,2)==-1 && zscr(t)<0.25*Signal_TH)|| (s(t-1,2)==0 && zscr(t-1)<-Signal_TH&& zscr(t)>-Signal_TH && zscr(j)<0.70*zscr(j-1))
                   s(t,2)=-1;
                   % count most recent buy trading days
                   if s(t-1,2)==0
                      long_day=0;
                   elseif s(t-1,2)==-1;
                       long_day=long_day+1;
                   end
                   %breach holding perioud TH
                   if long_day>hp_TH
                       s(t,2)=0;
                   end
                   
                   current_s=s(t-long_day:t,:);
                   current_Y=Y(t-long_day:t,:);
                   
                   if long_day>=1
                      current_r  = sum([0 0; current_s(1:end-1, :) .* diff(current_Y) - abs(diff(current_s))*cost/2] ,2);
                      current_rtn=sum(current_r);
                      if current_rtn<=-0.15; s(t,2)=0;  end

                   end
                   
                elseif (s(t-1,2)==1 && zscr(t)>-0.25*Signal_TH)|| (s(t-1,2)==0 && zscr(t-1)>Signal_TH&& zscr(t)<Signal_TH && zscr(j)>0.70*zscr(j-1))
                   s(t,2)=1;
                   % count most recent sell trading days
                   if s(t-1,2)==0
                      short_day=0;
                   elseif s(t-1,2)==1;
                       short_day=short_day+1;
                   end
                   %breach holding perioud TH
                   if short_day>hp_TH
                       s(t,2)=0;
                   end
                   
                   current_s=s(t-short_day:t,:);
                   current_Y=Y(t-short_day:t,:);
                   
                   if short_day>=1
                      current_r  = sum([0 0; current_s(1:end-1, :) .* diff(current_Y) - abs(diff(current_s))*cost/2] ,2);
                      current_rtn=sum(current_r);
                      if current_rtn<=-0.15; s(t,2)=0;  end

                   end
                else
                end
             end
         end
         s(j:j+N-1, 1) = -s(j:j+N-1, 2);
%          s(j:j+N-1, 1) = -reg1.coeff(2) .* s(j:j+N-1, 2);
         
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
         
         for t=j:size(Y,1)
             if  (s(t-1,2)==-1 && zscr(t)<0.25*Signal_TH)|| (s(t-1,2)==0 && zscr(t-1)<-Signal_TH&& zscr(t)>-Signal_TH && zscr(j)<0.70*zscr(j-1))
                 s(t,2)=-1;
                   % count most recent buy trading days
                 if s(t-1,2)==0
                      long_day=0;
                 elseif s(t-1,2)==-1;
                       long_day=long_day+1;
                 end
                   %breach holding perioud TH
                 if long_day>hp_TH
                       s(t,2)=0;
                 end
                   
                 current_s=s(t-long_day:t,:);
                 current_Y=Y(t-long_day:t,:);
                   
                 if long_day>=1
                    current_r  = sum([0 0; current_s(1:end-1, :) .* diff(current_Y) - abs(diff(current_s))*cost/2] ,2);
                    current_rtn=sum(current_r);
                    if current_rtn<=-0.15; s(t,2)=0;  end
                 end
                                      
             elseif (s(t-1,2)==1 && zscr(t)>-0.25*Signal_TH)|| (s(t-1,2)==0 && zscr(t-1)>Signal_TH&& zscr(t)<Signal_TH && zscr(j)>0.70*zscr(j-1))
                 s(t,2)=1;
                   % count most recent sell trading days
                 if s(t-1,2)==0
                      short_day=0;
                 elseif s(t-1,2)==1;
                       short_day=short_day+1;
                 end
                   %breach holding perioud TH
                 if short_day>hp_TH
                       s(t,2)=0;
                 end
                   
                 current_s=s(t-short_day:t,:);
                 current_Y=Y(t-short_day:t,:);
                   
                 if short_day>=1
                    current_r  = sum([0 0; current_s(1:end-1, :) .* diff(current_Y) - abs(diff(current_s))*cost/2] ,2);
                    current_rtn=sum(current_r);
                    if current_rtn<=-0.15; s(t,2)=0;  end
                 end
             else
             end
         end
         s(j:end, 1) = -s(j:end, 2);
%          s(j:end, 1) = -reg1.coeff(2) .* s(j:end, 2);  
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


   %% Calculate performance statistics 
   r  = sum([0 0; s(1:end-1, :) .* diff(Y) - abs(diff(s))*cost/2] ,2);
   totret=sum(r);
   sh = scaling*sharpe(r,0);          
                          
   Enter=[];
   Exit=[];
   Long=[];
   Short=[];
   for j=1:size(s,1)
       if ((j>1)&&(abs(s(j,2))==1) && (s(j-1,2)==0))||((j==1) && (abs(s(j,2))==1));
           enterpoint=j;
           Enter=[Enter;j];           
           if s(j,2)==-1
              Long=[Long;j];
           else
              Short=[Short;j];
           end
       end
            
       if (j<size(s,1))&&(abs(s(j,2))==1) && (s(j+1,2)==0);
          exitpoint=j;
          Exit=[Exit;j];
       end          
   end 
   
   if isempty(Enter)==0
      trades=size(Exit,1);
   
      last_enter=m2xdate(tday(Enter(end)),0);
      last_exit=m2xdate(tday(Exit(end)),0);
   
      if size(Exit,1)<size(Enter,1);   
         hp_v=Exit-Enter(1:size(Exit,1))+1;
      elseif size(Exit,1)>=size(Enter,1);
         hp_v=Exit(1:size(Enter,1))-Enter+1;
      else
      end
   
      ret_v=[];
      for m=1:trades
%           r  = sum([0 0; s(Enter(m):Exit(m)-1, :) .* diff(Y(Enter(m):Exit(m)))] ,2);
          new_ret=sum(r(Enter(m):Exit(m)));
          ret_v=[ret_v;new_ret];
      end
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
metric=[reg1.coeff(2),reg1.RSq,pValue,signal_l,signal_c,...
av_ret,hp,avg_cross_elapsed,trades,cross,winp,last_exit,last_enter];

signal_long=NaN(size(s,1),1);
signal_short=NaN(size(s,1),1);
signal_long(Long)=zscr(Long);
signal_short(Short)=zscr(Short);

signal_exit=NaN(size(s,1),1);
signal_exit(Exit)=zscr(Exit);

v_Alpha=v_Alpha(M:end);
v_Beta=v_Beta(M:end);
v_residual=v_residual(M:end);
z_signal=zscr(M:end);
signal_long=signal_long(M:end);
signal_short=signal_short(M:end);
signal_exit=signal_exit(M:end);

v_pADF=v_pADF(M:end);
CPnL=zeros(size(r,1),1);

for i=1:size(r,1)
    CPnL(i)=sum(r(1:i));
end
CPnL=CPnL(M:end);
r=r(M:end);
s=s(M:end,:);
end


