function pairoutput=copair_test(adjcls,M,N,v_spread,scaling,cost)
% PAIRS returns a trading signal for a simple pairs trading strategy
%% Process input args
if ~exist('scaling','var') 
    %exist('name','kind') if 'kind'='var',returns 1
    scaling = 1;
end
 
if ~exist('cost','var')
    cost = 0;
end
 
% if ~exist('spread', 'var')
%     spread = 1;
% end
 
if nargin == 1
    % default values
    M = 420;
    N = 60;
elseif nargin == 2
    error('PAIRS:NoRebalancePeriodDefined',...
        'When defining a lookback window, the rebalancing period must also be defined')
end

% Very often, the pairs will be convincingly cointegrated, or convincingly
% NOT cointegrated.  In these cases, a warning is issued not to read too
% much into the test statistic.  Since we don't use the test statistic, we
% can suppress these warnings.
warning('off', 'econ:adftest:LeftTailStatTooSmall')
warning('off', 'econ:adftest:LeftTailStatTooBig')
%% Sweep across the entire time series           
%Conduct Regression to calculate residual and compute ADF stat
residual=zeros(size(adjcls,1),1);
zscr=zeros(size(adjcls,1),1);
v_Beta=[];
v_Alpha=[];
v_lookback=[];
           
%Generate residual(zscr),beta,ADF
j=M;
while j<=size(adjcls,1)
      v_lookback=[v_lookback,j];
      [beta1,bint1,res1,rint1,stats1]=regress(adjcls(j-M+1:j,1),[ones(M,1) adjcls(j-M+1:j,2)]);
      [best_adf,best_P,best_lag]=test_cadf2(res1);
      v_Beta=[v_Beta,beta1(2)]; %Hedgeratio
      v_Alpha=[v_Alpha,beta1(1)]; 
      stdev=sqrt(stats1(4)); 
      Rsqr=stats1(1);
               
      if j<=size(adjcls,1)-N
         residual(j:j+N-1)=adjcls(j:j+N-1,1)-(beta1(1)+beta1(2)*adjcls(j:j+N-1,2));
         zscr(j:j+N-1)=residual(j:j+N-1)/stdev;
      else
         residual(j:end)=adjcls(j:end,1)-(beta1(1)+beta1(2)*adjcls(j:end,2));
         zscr(j:end)=residual(j:end)/stdev;
      end
               
      j=j+N;
end
           
% Sweep all possible Thresholds
v_totret=[];
v_s1=[];
v_s2=[];
v_r=[];
v_newspread=[];
v_isopen=zeros(size(v_spread));
for x=1:size(v_spread,2)
    s = zeros(size(adjcls));
    count=0;
    j=M;
    while j<=size(adjcls,1)
          count=count+1;
          if j<=size(adjcls,1)-N
             s(j:j+N-1, 2) = (zscr(j:j+N-1) > v_spread(x)) ...
             - (zscr(j:j+N-1) < -v_spread(x));
             s(j:j+N-1, 1) = -v_Beta(count) .* s(j:j+N-1, 2);                   
          else
             s(j:end, 2) = (zscr(j:end) > v_spread(x)) ...
             - (zscr(j:end) < -v_spread(x));
             s(j:end, 1) = -v_Beta(count) .* s(j:end, 2);  
          end
          j=j+N;
    end
    r  = sum([0 0; s(1:end-1, :) .* adjcls(1:end-1,:)- abs(diff(s))*cost/2],2);
    v_isopen(x)=1-isempty(find(r, 1)); %when empty, isempty=1
    if v_isopen(x)==1
       v_newspread=[v_newspread,v_spread(x)];
       v_s1=[v_s1 s(1:end,1)];
       v_s2=[v_s2 s(1:end,2)];
       v_r=[v_r r];
       v_totret=[v_totret,sum(r)];
    end
end 

%% Calculate performance statistics 
signal_l=zscr(end-1);
signal_c=zscr(end); %find the zscr today and decide whether to trade or not
totret=-1000;
av_ret=-1000;
hp=0;
trades=0;
winp=-1;
best_signal=1000;

if sum(v_isopen)~=0
   [C_totret, I_totret]=max(v_totret);
   totret=C_totret;
   best_signal=v_newspread(I_totret);
   best_s=[v_s1(1:end,I_totret) v_s2(1:end,I_totret)];
   best_r=v_r(1:end,I_totret);          
   sh = scaling*sharpe(best_r,0);          
                          
   Enter=[];
   Exit=[];
   for j=1:size(best_s,1)
       if ((j>1)&&(abs(best_s(j,2))==1) && (best_s(j-1,2)==0))||((j==1) && (abs(best_s(j,2))==1));
           enterpoint=j;
           Enter=[Enter;j];
       end
            
       if ((j<size(best_s,1))&&(abs(best_s(j,2))==1) && (best_s(j+1,2)==0))||((j==size(best_s,1)) && (abs(best_s(j,2))==1));                    
          exitpoint=j;
          Exit=[Exit;j];
       end          
   end        
   trades=size(Exit,1);
   hp_v=Exit-Enter+1;
   ret_v=[];
   for t=1:trades
       new_ret=sum(best_r(Enter(t):Exit(t)));
       ret_v=[ret_v;new_ret];
   end
   wins=size(find(ret_v>0),1);                       
   av_ret=mean(ret_v);
   hp=mean(hp_v);
   winp=wins/trades;   
end
pairoutput=[v_Beta(end),abs(v_Beta(end)),Rsqr,best_adf,best_lag,best_P,signal_l,signal_c,abs(signal_c),...
best_signal,totret,av_ret,hp,trades,winp];
end


