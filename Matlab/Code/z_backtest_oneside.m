function [pairoutput,s,ret_v,r_trade,r]=z_backtest_oneside(status,rtn_Y,zscr,Signal_TH,hp_TH,tday)

%% Sweep across the entire time series           

scale=0.50;

s = zeros(size(zscr,1),2);  
r_trade = zeros(size(zscr,1),1);
CPnL=zeros(size(zscr,1),1);

if status==0
   Signal_TH=zscr(end);
end

signal_l2=zscr(end-2);
signal_l=zscr(end-1);
signal_c=zscr(end); %find the zscr today and decide whether to trade or not

%Calculating # of times spread cross 0 line
cross=0;
v_cross=[];
for ctr=2:size(zscr,1)
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
% trade_window=5;
trade_window=round(1*avg_cross_elapsed);
%annual number of cross
yr_cross=round(cross/(size(zscr,1)/225));

  %% Calculate Performance statistics based on current spread
trades=0;                          
Enter=[];
Exit=[];
Long=[];
Short=[];
ret_v=[];
r=[];
hp_v=[];
is_open=0;
direction=0;


if Signal_TH<=-0.5
   for j=2:size(zscr,1)
         if is_open~=0 %that means position opened  
            s(j,1)=s(j-1,1);
            s(j,2) = - s(j, 1);            
            r_trade(entryIDX)=0;
            current_r=sum([0 0;s(entryIDX:j-1, :) .* rtn_Y(entryIDX:j-1,:)],2);
            r_trade(j)= sum(current_r);
            cumul_r= sum([0 0 ; s(1:j-1, :) .* rtn_Y(1:j-1,:)],2);
            CPnL(j)= sum(cumul_r);
            
            %exit
            if (s(j,1)==1 && zscr(j)>Signal_TH*(-0.25) && zscr(j-1)>Signal_TH*(-0.25)) ...
                    || r_trade(j)<-15 || j-entryIDX > hp_TH
                trades=trades+1;
                ret_v=[ret_v;r_trade(j)];
                hp_v=[hp_v;j-entryIDX];
                Exit=[Exit;j];
                is_open=0;
                direction=0;
            end
         else   %position not opened
            CPnL(j)= CPnL(j-1);
            if s(j-1,1)==0 && zscr(j-1)<Signal_TH && zscr(j)>=Signal_TH && zscr(j)<=scale*zscr(j-1)
%             if s(j-1,1)==0 && zscr(j-1)<Signal_TH && zscr(j)>=Signal_TH
%             if s(j-1,1)==0 && zscr(j)<=Signal_TH
                s(j, 1) = 1;
                s(j,2) = - s(j, 1);
                entryIDX=j;
                is_open=1;
                direction=1;
                Enter=[Enter;j];
                Long=[Long;j];
            end
         end
   end

elseif Signal_TH>=0.5

   for j=2:size(zscr,1)
         if is_open~=0 %that means position opened  
            s(j,1)=s(j-1,1);
            s(j,2) = - s(j, 1);            
            r_trade(entryIDX)=0;
            current_r=sum([0 0;s(entryIDX:j-1, :) .* rtn_Y(entryIDX:j-1,:)],2);
            r_trade(j)= sum(current_r);
            cumul_r= sum([0 0 ; s(1:j-1, :) .* rtn_Y(1:j-1,:)],2);
            CPnL(j)= sum(cumul_r);
            
            %exit
            if (s(j,1)==-1 && zscr(j)<-0.25*Signal_TH && zscr(j-1)<-0.25*Signal_TH) ...
                    || r_trade(j)<-15 || j-entryIDX > hp_TH
                trades=trades+1;
                ret_v=[ret_v;r_trade(j)];
                hp_v=[hp_v;j-entryIDX];
                Exit=[Exit;j];
                is_open=0;
                direction=0;
            end
         else   %position not opened
            CPnL(j)= CPnL(j-1);
            if  s(j-1,1)==0 && zscr(j-1)>Signal_TH && zscr(j)<=Signal_TH && zscr(j)>=scale*zscr(j-1)
%             if  s(j-1,1)==0 && zscr(j-1)>Signal_TH && zscr(j)<=Signal_TH
%             if  s(j-1,1)==0 && zscr(j)>=Signal_TH
                s(j, 1) = -1;
                s(j,2) = - s(j, 1);
                entryIDX=j;
                is_open=1;
                direction=-1;
                Enter=[Enter;j];
                Short=[Short;j];
            end
         end
   end
else
    is_open=0;
    direction=0;
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
      yr_trades=round(trades/(size(zscr,1)/211));
else
      last_exit=m2xdate(700000,0);
      av_ret=0;
      vol_ret=0;
      hp=5;
      winp=0.5;
      trades=0;
      yr_trades=0;
      cumul_r=0;
end

r  = sum([0 0; s(1:end, :) .* rtn_Y] ,2);
%% build output
   pairoutput=[Signal_TH,signal_l2,signal_l,signal_c,av_ret,vol_ret,winp,...
   yr_trades,hp,avg_cross_elapsed,yr_cross,is_open,direction,last_exit,last_enter];

