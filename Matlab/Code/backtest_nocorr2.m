function output=backtest_nocorr2(v_rtn,Y,enter_disp,exit_disp,tday)
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
s = zeros(size(Y,1),size(Y,2));
r_trade = zeros(size(Y,1),1);
CPnL=zeros(size(Y,1),1);

if enter_disp>0
     for j=3:size(Y,1)
         if is_open~=0 %that means position opened  
            s(j,1)=s(j-1,1);
                        
            r_trade(entryIDX)=0;
            current_r=[0;s(entryIDX:j-1, :) .* v_rtn(entryIDX:j-1,:)];
            r_trade(j)= sum(current_r);
            cumul_r= [0;s(1:j-1, :) .* v_rtn(1:j-1,:)];
            CPnL(j)= sum(cumul_r);
            
            %exit
            if (direction==1 && Y(j)<exit_disp) || r_trade(j)<-15 || j-entryIDX > hp_TH
                trades=trades+1;
                ret_v=[ret_v;r_trade(j)];
                hp_v=[hp_v;j-entryIDX];
                Exit=[Exit;j];
                is_open=0;
                direction=0;
            end
            
         else   %position not opened
            CPnL(j)= CPnL(j-1);
            if  Y(j)>= enter_disp
                s(j, 1) = 1;
                entryIDX=j;
                is_open=1;
                direction=1;
                Enter=[Enter;j];
                Long=[Long;j];
            end
         end
     end
else
    for j=3:size(Y,1)
         if is_open~=0 %that means position opened  
            s(j,1)=s(j-1,1);
                        
            r_trade(entryIDX)=0;
            current_r=[0;s(entryIDX:j-1, :) .* v_rtn(entryIDX:j-1,:)];
            r_trade(j)= sum(current_r);
            cumul_r= [0;s(1:j-1, :) .* v_rtn(1:j-1,:)];
            CPnL(j)= sum(cumul_r);
            
            %exit
            if (direction==-1 && Y(j)>exit_disp) || r_trade(j)<-15 || j-entryIDX > hp_TH
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
            if  Y(j)<= enter_disp
                s(j, 1) = -1;
                entryIDX=j;
                is_open=1;
                direction=-1;
                Enter=[Enter;j];
                Short=[Short;j];
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
      wins=size(find(ret_v>0),1);                       
      av_ret=mean(ret_v);
      hp=round(mean(hp_v));
      winp=wins/trades;
else
      last_exit=m2xdate(700000,0);
      av_ret=-100;
      stdev=0;
      hp=-100;
      winp=-100;
      trades=-100; 
end
%% build output

output=[enter_disp,exit_disp,av_ret,stdev,trades,hp,winp,last_exit,last_enter];