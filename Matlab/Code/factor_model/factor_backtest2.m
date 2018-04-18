function [s, ret_v,output]=factor_backtest2(v_rtn,Zspread,f_ret,z_fpx,enter_fret,v_causal,enter_causal,exit_causal,tday,effect)
%% Calculate Performance statistics based on current spread
exit_ratio=0.25;
trades=0;                          
Enter=[];
Exit=[];
Long=[];
Short=[];
ret_v=[];
hp_v=[];
is_open=0;
direction=0;
hp_TH=40;
s = zeros(size(f_ret,1),size(f_ret,2));
r_trade = zeros(size(f_ret,1),1);
CPnL=zeros(size(f_ret,1),1);

for j=2:size(f_ret,1)
         if is_open~=0 %that means position opened  
            s(j,1)=s(j-1,1);
            s(j,2) = - s(j, 1);
            r_trade(entryIDX)=0;
            current_r=sum([0 0; s(entryIDX:j, :) .* v_rtn(entryIDX:j,:)] ,2);
            r_trade(j)= sum(current_r);
            cumul_r= sum([0 0; s(1:j, :) .* v_rtn(1:j,:)] ,2);
            CPnL(j)= sum(cumul_r);
            
            %exit
            if (direction==1 && (effect==1 && f_ret(j)<-exit_ratio*enter_fret || effect==-1 && f_ret(j)>exit_ratio*enter_fret)) || v_causal(j) > exit_causal || r_trade(j)<-15 || j-entryIDX > hp_TH
                trades=trades+1;
                ret_v=[ret_v;r_trade(j)];
                hp_v=[hp_v;j-entryIDX];
                Exit=[Exit;j];
                is_open=0;
                direction=0;
            elseif (direction==-1 && (effect==1 && f_ret(j)>exit_ratio*enter_fret || effect==-1 && f_ret(j)<-exit_ratio*enter_fret)) || v_causal(j) > exit_causal || r_trade(j)<-15 || j-entryIDX > hp_TH
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
            if   (effect==1 && f_ret(j)<= -enter_fret || effect==-1 && f_ret(j)>= enter_fret) && v_causal(j) <= enter_causal ...
                    && Zspread(j)>-0.5
                s(j, 1) = -1;
                s(j,2) = - s(j, 1);
                entryIDX=j;
                is_open=1;
                direction=-1;
                Enter=[Enter;j];
                Short=[Short;j];
                enter_fpx=z_fpx(j);
            elseif  (effect==-1 && f_ret(j)<= -enter_fret || effect==1 && f_ret(j)>= enter_fret) && v_causal(j) <= enter_causal ...
                    && Zspread(j)<0.5
                s(j, 1) = 1;
                s(j,2) = - s(j, 1);
                entryIDX=j;
                is_open=1;
                direction=1;
                Enter=[Enter;j];
                Long=[Long;j];
                enter_fpx=z_fpx(j);
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