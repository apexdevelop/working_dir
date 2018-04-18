function [output,r_trade]=wfactor_backtest2(v_rtn,Zspread,f_ret,enter_fret,v_causal,enter_causal,exit_causal,tday)
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
hp_TH=40;
s = zeros(size(f_ret,1),size(f_ret,2));
r_trade = zeros(size(f_ret,1),1);
CPnL=zeros(size(f_ret,1),1);

%long
if enter_fret>=0.5
for j=2:size(f_ret,1)
         if is_open~=0 %that means position opened  
            s(j,1)=s(j-1,1);
            s(j,2) = - s(j, 1);
            r_trade(entryIDX)=0;
            current_r=sum([0 0; s(entryIDX:j-1, :) .* diff(v_rtn(entryIDX:j,:))] ,2);
            r_trade(j)= sum(current_r);
            cumul_r= sum([0 0; s(1:j-1, :) .* diff(v_rtn(1:j,:))] ,2);
            CPnL(j)= sum(cumul_r);
            
            %exit
            if (direction==1 && f_ret(j)<-0.25*enter_fret) || v_causal(j) > exit_causal || r_trade(j)<-15 || j-entryIDX > hp_TH
                trades=trades+1;
                ret_v=[ret_v;r_trade(j)];
                hp_v=[hp_v;j-entryIDX];
                Exit=[Exit;j];
                is_open=0;
                direction=0;
            end
            
         else   %position not opened
            CPnL(j)= CPnL(j-1);

            if  f_ret(j)>= enter_fret && v_causal(j) <= enter_causal && Zspread(j)<=0.5
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
end

%short
if enter_fret<=-0.5
for j=2:size(f_ret,1)
         if is_open~=0 %that means position opened  
            s(j,1)=s(j-1,1);
            s(j,2) = - s(j, 1);
            r_trade(entryIDX)=0;
            current_r=sum([0 0; s(entryIDX:j-1, :) .* diff(v_rtn(entryIDX:j,:))] ,2);
            r_trade(j)= sum(current_r);
            cumul_r= sum([0 0; s(1:j-1, :) .* diff(v_rtn(1:j,:))] ,2);
            CPnL(j)= sum(cumul_r);
            
            %exit
            if (direction==-1 && f_ret(j)>-0.25*enter_fret) || v_causal(j) > exit_causal || r_trade(j)<-15 || j-entryIDX > hp_TH
                trades=trades+1;
                ret_v=[ret_v;r_trade(j)];
                hp_v=[hp_v;j-entryIDX];
                Exit=[Exit;j];
                is_open=0;
                direction=0;
            end
            
         else   %position not opened
            CPnL(j)= CPnL(j-1);
            if   f_ret(j)<= enter_fret  && v_causal(j) <= enter_causal && Zspread(j)>=-0.5
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
      exp_vol=std(ret_v);
      hp=round(mean(hp_v));
      winp=wins/trades;
else
      last_exit=m2xdate(700000,0);
      av_ret=-100;
      exp_vol=-100;
      hp=-1;
      winp=-1;
      trades=-1; 
end
%% build output

output=[enter_fret,f_ret(end),enter_causal, v_causal(end),Zspread(end),av_ret,exp_vol,winp,trades,hp,last_exit,last_enter,direction];