function [s, ret_v,output]=general_backtest_v1(ex_rtn,Y,y_TH,date_backtest)
%% Calculate Performance statistics based on current spread
tday=date_backtest;
% exit_ratio=0.25;
trades=0;                          
Enter=[];
Exit=[];
Long=[];
Short=[];
ret_v=[];
hp_v=[];
is_open=0;
direction=0;
last_direction=0;
hp_TH=40;
s = zeros(size(ex_rtn,1),1);
r_trade = zeros(size(ex_rtn,1),1);
CPnL=zeros(size(ex_rtn,1),1);

for j=2:size(ex_rtn,1)
         if is_open~=0 %that means position opened  
            s(j)=s(j-1);
            r_trade(entryIDX)=0;
            current_r=[0;s(entryIDX:j) .* ex_rtn(entryIDX:j)];
            r_trade(j)= sum(current_r);
            cumul_r= [0; s(1:j) .* ex_rtn(1:j)];
            CPnL(j)= sum(cumul_r);
            
            %exit
            if (direction==1 && Y(j)<0) || r_trade(j)<-15 || j-entryIDX > hp_TH
                trades=trades+1;
                ret_v=[ret_v;r_trade(j)];
                hp_v=[hp_v;j-entryIDX];
                Exit=[Exit;j];
                is_open=0;
                direction=0;
            elseif (direction==-1 && Y(j)>0) || r_trade(j)<-15 || j-entryIDX > hp_TH
                trades=trades+1;
                ret_v=[ret_v;r_trade(j)];
                hp_v=[hp_v;j-entryIDX];
                Exit=[Exit;j];
                is_open=0;
                direction=0;
            else
            end
            
         else   %position not opened
            CPnL(j)= CPnL(j-1);
            if   Y(j)<= -y_TH
                s(j) = -1;
                entryIDX=j;
                is_open=1;
                direction=-1;
                Enter=[Enter;j];
                Short=[Short;j];
            elseif  Y(j)>= y_TH              
                s(j) = 1;
                entryIDX=j;
                is_open=1;
                direction=1;
                Enter=[Enter;j];
                Long=[Long;j];
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
      if isempty(Long)==0 && isempty(Short)==0
         if Long(end)>Short(end)
            last_direction=1;
         else
            last_direction=-1;
         end
      end
      wins=size(find(ret_v>0),1);                       
      av_ret=mean(ret_v);
      exp_vol=std(ret_v);
      hp=round(mean(hp_v));
      winp=wins/trades;
else
      last_exit=m2xdate(700000,0);
      av_ret=-100;
      exp_vol=-100;
      hp=-100;
      winp=-100;
      trades=-100; 
end
%% build output

output=[av_ret,exp_vol,winp,trades,hp,last_exit,last_enter,direction,last_direction];