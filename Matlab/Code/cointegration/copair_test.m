function [pairoutput,v_pADF,zscr]=copair_test(method,Y,M,N,Signal_TH,pADF_TH,hp_TH,tday)
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

%calculate rolling pADF and Beta

if strcmp(method,'engle')
%    [~,p_e,~,~,reg1] = egcitest(Y(1:M-1,:),'alpha',pADF_TH,'creg','ct','test','t2');
   [~,p_e,~,~,reg1] = egcitest(Y(1:M-1,:),'alpha',pADF_TH,'creg','c','test','t2');
   head_residual=Y(1:M-1,:)*[1;-reg1.coeff(2)]-reg1.coeff(1);
   temp_beta=reg1.coeff(2)*ones(M-1,1);
   v_pADF(1:M-1)=p_e*ones(M-1,1);
elseif strcmp(method,'johansen')
   [~,p_j,~,~,mles] = jcitest(Y(1:M-1,:),'model','H1','display','off');
   BJ = mles.r1.paramVals.B;
   c0J = mles.r1.paramVals.c0;
   BJ1n = BJ(:,1)/BJ(1,1);
   c0J1n = c0J(1)/BJ(1,1);
   head_residual=Y(1:M-1,:)*BJ1n+c0J1n;
   temp_beta=-BJ1n(2)*ones(M-1,1);
   v_pADF(1:M-1)=p_j.r0*ones(M-1,1);
else
end

v_residual(1:M-1)=head_residual;
zscr(1:M-1)=zscore(head_residual);
v_Beta(1:M-1)=temp_beta;

j=M;

while j<=size(Y,1)
      % regression on return is for hedge ratio
      diff_NY1=diff(Y(j-M+1:j,:)); %diff log is log return
      rtn_NY1=diff_NY1-repmat(mean(diff_NY1),M-1,1);
      [~,~,~,~,reg2] = egcitest(rtn_NY1,'alpha',pADF_TH);
      
      % regression on log price is for cointegration
      NY1=Y(j-M+1:j,:);
      if strcmp(method,'engle')
%          [h,p_e,~,~,reg1] = egcitest(NY1,'alpha',pADF_TH,'creg','ct','test','t2');
         [h,p_e,~,~,reg1] = egcitest(NY1,'alpha',pADF_TH,'creg','c','test','t2');
%          b=reg1.coeff(2:end);
         b=reg1.coeff(end);
         v_Beta(j:j+N-1)=b*ones(N,1);
         v_h(j:j+N-1)=h*ones(N,1);
         v_pADF(j:j+N-1)=p_e*ones(N,1);
         
         if j<=size(Y,1)-N
            NY2=Y(j:j+N-1,:);
            v_residual(j:j+N-1)=NY2*[1;-b]-reg1.coeff(1);
            zscr(j:j+N-1)=(v_residual(j:j+N-1)-mean(v_residual(j-M+1:j)))/reg1.RMSE;
         else
            NY2=Y(j:end,:);
            v_residual(j:end)=NY2*[1;-b]-reg1.coeff(1);
            zscr(j:end)=(v_residual(j:end)-mean(v_residual(j-M+1:j)))/reg1.RMSE;
         end
         
      elseif strcmp(method,'johansen')
         [h,p_j,~,~,mles] = jcitest(NY1,'model','H1','display','off');
         BJ = mles.r1.paramVals.B;
         c0J = mles.r1.paramVals.c0;
         BJ1n = BJ(:,1)/BJ(1,1);
         c0J1n = c0J(1)/BJ(1,1);
         
         v_Beta(j:j+N-1)=-BJ1n(2)*ones(N,1);
         v_h(j:j+N-1)=h.r0*ones(N,1);
         v_pADF(j:j+N-1)=p_j.r0*ones(N,1);
         
         if j<=size(Y,1)-N
            NY2=Y(j:j+N-1,:);
            v_residual(j:j+N-1)=NY2*BJ1n+c0J1n;
            zscr(j:j+N-1)=(v_residual(j:j+N-1)-mean(v_residual(j-M+1:j)))/std(v_residual(j-M+1:j));
         else
            NY2=Y(j:end,:);
            v_residual(j:end)=NY2*BJ1n+c0J1n;
            zscr(j:end)=(v_residual(j:end)-mean(v_residual(j-M+1:j)))/std(v_residual(j-M+1:j));
         end
      else
      end
      
      j=j+N;
end 

% moving average
% zscr_row=reshape(zscr,1,size(zscr,1));
% zscr_mov=tsmovavg(zscr_row,'e',5);
% zscr_mov=[zscr_row(1:4) zscr_mov(5:end)];

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


% if abs(zscr(end))>=0.5*min_spread && pValue<=2*max_pADF
%    Signal_TH=abs(zscr(end));
%    pADF_TH=pValue;
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
            if (s(j,1)==-1 && zscr(j)<-0.25*Signal_TH) || (s(j,1)==1 && zscr(j)>0.25*Signal_TH) ...
                    || r_trade(j)<-0.15 || j-entryIDX > hp_TH || v_pADF(j)>pADF_TH
                trades=trades+1;
                ret_v=[ret_v;r_trade(j)];
                hp_v=[hp_v;j-entryIDX];
                Exit=[Exit;j];
                is_open=0;
                direction=0;
            end
         else   %position not opened
            CPnL(j)= CPnL(j-1);
%             if  s(j-1,1)==0 && zscr(j-1)>Signal_TH && zscr(j)<Signal_TH && zscr(j)>0.70*zscr(j-1) ...
            if  s(j-1,1)==0 && zscr(j-1)>Signal_TH && zscr(j)<Signal_TH && zscr(j)>0.30*zscr(j-1)...
                && v_pADF(j)<=pADF_TH ...
%                 && z_spread(j)>0
                s(j, 1) = -1;
                for col=2:size(Y,2)
                    s(j,col) = - s(j, 1);
                end
                entryIDX=j;
                is_open=1;
                direction=-1;
                Enter=[Enter;j];
                Short=[Short;j];
%             elseif s(j-1,1)==0 && zscr(j-1)<-Signal_TH && zscr(j)>-Signal_TH && zscr(j)<0.70*zscr(j-1) ...
            elseif s(j-1,1)==0 && zscr(j-1)<-Signal_TH && zscr(j)>-Signal_TH && zscr(j)<0.30*zscr(j-1)...
                && v_pADF(j)<=pADF_TH ...
%                 && z_spread(j)<0
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
% end

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
      yr_trades=round(trades/(size(Y,1)/260));
else
      last_exit=m2xdate(700000,0);
      av_ret=-100;
      hp=-100;
      winp=-100;
      trades=-100;
      yr_trades=-100;
      cumul_r=-100;
end


%% build output
% v_Beta=v_Beta(M:end);
% v_pADF=v_pADF(M:end);
% m_Beta=mean(v_Beta);
% m_pADF=mean(v_pADF);
if strcmp(method,'engle')
   pairoutput=[p_e,last_zspread,signal_l2,signal_l,signal_c,av_ret,winp,reg2.coeff(2),reg1.RSq,...
   hp,avg_cross_elapsed,yr_trades,yr_cross,is_open,direction,last_exit,last_enter];
elseif strcmp(method,'johansen')
   pairoutput=[p_j.r0,last_zspread,signal_l2,signal_l,signal_c,av_ret,winp,-BJ1n(2),mles.r0.eigVal,...
   hp,avg_cross_elapsed,yr_trades,yr_cross,is_open,direction,last_exit,last_enter]; 
else
end
