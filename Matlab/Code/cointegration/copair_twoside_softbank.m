function [pairoutput,zscr,s]=copair_twoside_softbank(rtn_Y,Y,M,N,Signal_TH,hp_TH,tday)
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
v_h = zeros(size(Y,1),1);         
v_residual=zeros(size(Y,1),1);
r_trade = zeros(size(Y,1),1);
CPnL=zeros(size(Y,1),1);
v_Beta = zeros(size(Y,1),3);
v_pADF = zeros(size(Y,1),1);
%% Calculate Z-residual

%calculate rolling pADF and Beta
[~,p_e,~,~,reg1] = egcitest(Y(1:M-1,:),'test','t2');
head_residual=Y(1:M-1,:)*[1;-reg1.coeff(2:end)]-reg1.coeff(1);
temp_beta=repmat(transpose([1;-reg1.coeff(2:end)]),M-1,1);
v_pADF(1:M-1)=p_e*ones(M-1,1);


v_residual(1:M-1)=head_residual;
zscr(1:M-1)=zscore(head_residual);
v_Beta(1:M-1,:)=temp_beta;

j=M;

while j<=size(Y,1)
      % regression on return is for hedge ratio
      diff_NY1=diff(Y(j-M+1:j,:)); %diff log is log return
      rtn_NY1=diff_NY1-repmat(mean(diff_NY1),M-1,1);
      [~,~,~,~,reg2] = egcitest(rtn_NY1);
      
      % regression on log price is for cointegration
      NY1=Y(j-M+1:j,:);
         [h,p_e,~,~,reg1] = egcitest(NY1,'test','t2');
         b=[1;-reg1.coeff(2:end)];
         v_Beta(j:j+N-1,:)=repmat(transpose(b),N,1);
         v_h(j:j+N-1)=h*ones(N,1);
         v_pADF(j:j+N-1)=p_e*ones(N,1);
         
         if j<=size(Y,1)-N
            NY2=Y(j:j+N-1,:);
            v_residual(j:j+N-1)=NY2*b-reg1.coeff(1);
            zscr(j:j+N-1)=(v_residual(j:j+N-1)-mean(v_residual(j-M+1:j)))/reg1.RMSE;
         else
            NY2=Y(j:end,:);
            v_residual(j:end)=NY2*b-reg1.coeff(1);
            zscr(j:end)=(v_residual(j:end)-mean(v_residual(j-M+1:j)))/reg1.RMSE;
         end
      j=j+N;
end 


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

v_cross=diff(v_cross);
avg_cross_elapsed=round(mean(v_cross));
%annual number of cross
yr_cross=round(cross/(size(Y,1)/225));



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

   for j=M:size(Y,1)
         if is_open~=0 %that means position opened  
            s(j,1)=s(j-1,1);
            s(j,2) = - s(j, 1);            
            r_trade(entryIDX)=0;
            current_r=sum([0 0;s(entryIDX:j-1, :) .* rtn_Y(entryIDX:j-1,:)],2);
            r_trade(j)= sum(current_r);
            cumul_r= sum([0 0 ; s(1:j-1, :) .* rtn_Y(1:j-1,:)],2);
            CPnL(j)= sum(cumul_r);
            
            %exit
            if (s(j,1)==-1 && zscr(j)<-0.25) || (s(j,1)==1 && zscr(j)>0.25) ...
                    || r_trade(j)<-0.15 || j-entryIDX > hp_TH
                trades=trades+1;
                ret_v=[ret_v;r_trade(j)];
                hp_v=[hp_v;j-entryIDX];
                Exit=[Exit;j];
                is_open=0;
                direction=0;
            end
         else   %position not opened
            CPnL(j)= CPnL(j-1);

            if  s(j-1,1)==0 && zscr(j-1)>=Signal_TH && zscr(j)<Signal_TH ...
                ...
%                 && z_spread(j)>0
                s(j, 1) = -1;
                s(j,2) = - s(j, 1);
                entryIDX=j;
                is_open=1;
                direction=-1;
                Enter=[Enter;j];
                Short=[Short;j];

%             if s(j-1,1)==0 && zscr(j-1)<=Signal_TH && zscr(j)>Signal_TH ...
%                  ...
%                 && z_spread(j)<0
%                 s(j, 1) = 1;
%                 s(j,2) = - s(j, 1);
%                 entryIDX=j;
%                 is_open=1;
%                 direction=1;
%                 Enter=[Enter;j];
%                 Long=[Long;j];
            else
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
      if trades>1 
          vol_ret=std(ret_v);
      else
          vol_ret=0;
      end
      hp=round(mean(hp_v));
      winp=wins/trades;
      yr_trades=round(trades/(size(Y,1)/260));
else
      last_exit=m2xdate(700000,0);
      av_ret=-100;
      vol_ret=-100;
      hp=-100;
      winp=-100;
      trades=-100;
      yr_trades=-100;
      cumul_r=-100;
end


%% build output
   pairoutput=[Signal_TH,p_e,signal_l2,signal_l,signal_c,av_ret,vol_ret,winp,reg2.coeff(2),reg2.coeff(3),reg1.RSq,...
   hp,avg_cross_elapsed,yr_trades,yr_cross,is_open,direction,last_exit,last_enter];

