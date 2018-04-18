% v_rtn=rtn_Y(corr_window:end,1);
% Y=z_disp_mov(corr_window:end);
% v_corr=z_corr;
% tday=tday1(corr_window:end);

function [Long_longvector,Short_longvector,Exit_longvector,output]=disp_backtest_corr(v_rtn,Y,enter_disp,exit_disp,v_corr,enter_corr,exit_corr,tday)
%% Calculate Performance statistics based on current spread
trades=0;                          
Enter=[];
Exit = [];
% Exit_longvector=zeros(size(Y,1),1);
Exit_longvector=cell(size(Y,1),1);
Long=[];
Long_longvector=cell(size(Y,1),1);
Short=[];
Short_longvector=cell(size(Y,1),1);
ret_v=[];
hp_v=[];
is_open=0;
direction=0;
hp_TH=40;
pnL_TH=-1000;
s = zeros(size(Y,1),size(Y,2));
r_trade = zeros(size(Y,1),1);
CPnL=zeros(size(Y,1),1);

if enter_disp>0
     for j=2:size(Y,1)
         if is_open~=0 %that means position opened  
            s(j,1)=s(j-1,1);
                        
            r_trade(entryIDX)=0;
            current_r=[0;s(entryIDX:j-1, :) .* v_rtn(entryIDX:j-1,:)];
            r_trade(j)= sum(current_r);
            cumul_r= [0;s(1:j-1, :) .* v_rtn(1:j-1,:)];
            CPnL(j)= sum(cumul_r);
            
            %exit
            if (direction==1 && Y(j)<exit_disp + 0.05) || v_corr(j) > exit_corr || r_trade(j)<pnL_TH || j-entryIDX > hp_TH
                trades=trades+1;
                ret_v=[ret_v;r_trade(j)];
                hp_v=[hp_v;j-entryIDX];
                Exit=[Exit;j];
                Exit_longvector{j,1}=Y(j);
                is_open=0;
                direction=0;
            end
            
         else   %position not opened
            CPnL(j)= CPnL(j-1);
            if  Y(j)>= enter_disp && v_corr(j) <= enter_corr
                s(j, 1) = 1;
                entryIDX=j;
                is_open=1;
                direction=1;
                Enter=[Enter;j];
                Long=[Long;j];
                Long_longvector{j,1}=Y(j);
            end
         end
     end
else
    for j=2:size(Y,1)
         if is_open~=0 %that means position opened  
            s(j,1)=s(j-1,1);
                        
            r_trade(entryIDX)=0;
            current_r=[0;s(entryIDX:j-1, :) .* v_rtn(entryIDX:j-1,:)];
            r_trade(j)= sum(current_r);
            cumul_r= [0;s(1:j-1, :) .* v_rtn(1:j-1,:)];
            CPnL(j)= sum(cumul_r);
            
            %exit
            if (direction==-1 && Y(j)>exit_disp - 0.05) || v_corr(j) > exit_corr || r_trade(j)<pnL_TH || j-entryIDX > hp_TH
                trades=trades+1;
                ret_v=[ret_v;r_trade(j)];
                hp_v=[hp_v;j-entryIDX];
                Exit=[Exit;j];
                Exit_longvector{j,1}=Y(j);
                is_open=0;
                direction=0;
            else
            end
            
         else   %position not opened
            CPnL(j)= CPnL(j-1);
            if   Y(j)<= enter_disp && v_corr(j) <= enter_corr
                s(j, 1) = -1;
                entryIDX=j;
                is_open=1;
                direction=-1;
                Enter=[Enter;j];
                Short=[Short;j];
                Short_longvector{j,1}=Y(j);
            else
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
      if size(Enter,1)>=1
          stdev=std(ret_v);
      end
      last_exit=m2xdate(tday(Exit(end)),0);         
      nwins=size(find(ret_v>0),1);
      v_win=ret_v(ret_v>0);
      winPnL=sum(v_win);
      v_loss=ret_v(ret_v<=0);
      lossPnL=sum(v_loss);
      av_ret=mean(ret_v);
      hp=round(mean(hp_v));
      omega=winPnL/(abs(lossPnL)+winPnL);
      winp=nwins/trades;
      yr_trades=round(trades/(size(Y,1)/250));
else
      last_exit=NaN;
      av_ret=NaN;
      stdev=NaN;
      hp=NaN;
      winp=NaN;
      omega=NaN;
      trades = NaN;
      yr_trades=NaN; 
end
%% build output

output=[enter_disp,exit_disp,enter_corr,exit_corr,av_ret,stdev,trades,hp,omega,winp,last_exit,last_enter];