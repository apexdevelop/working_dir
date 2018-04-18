cd('C:\Documents and Settings\YChen\My Documents');

clear adjcls;
clear adjcls1;
clear adjcls2;
clear baddata;
clear foo;
clear idx;
clear idx1;
clear idx2;
clear stk1_col;
clear stk2_col;
clear stk1;
clear stk2;
clear zscr;
clear txt;

sheetnames={'telecom','consumerd','consumers','energy','financial','healthc','industrials','infotech','materials','utility','test'};
ranges={'a2:a12','a2:a23','a2:a7','a3:a10','a2:a32','a2:a6','a2:a21','a2:a51','a2:a21','a2:a5','a2:a3'};
ranges2={'b2:b12','b2:b23','b2:b7','b3:b10','b2:b32','b2:b6','b2:b21','b2:b51','b2:b21','b2:b5','b2:b3'};

inputs=char(sheetnames(10));
inputr=char(ranges(10));
inputr2=char(ranges2(10));

[names date price]=blp_simple('input_sector',inputs,inputr,500); %import data set from bloomberg

n_stock=size(price,2)-1; %number of stocks
% metrics=zeros(n_stock*(n_stock-1),12);

stk1={''};
stk2={''};

for n=1:n_stock
    new_stk1=repmat(names(n),1,n_stock-1);
    stk1=[stk1  new_stk1];
    for m=1:n_stock
        if m~=n
    stk2=[stk2  names(m)];
        end
    end
end
TR=[];
AR=[];
STAT=[]; %vector of ADF
HP=[]; %expected holding period
L=[]; %lags
NUM_T=[];
WinP=[];
SL=[];
SC=[];
B=[];
% ACT={''};
RSQR=[];
spread=1;
scaling=1; 
for n=1:n_stock
    tday1=date(:, n+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
    adjcls1=price(:, n+1); %ppp the last column contains the adjusted close prices.       
    for m=1:n_stock
        if m~=n
           tday2=date(:, m+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
           adjcls2=price(:, m+1); % PPP                
           [foo idx1 idx2]=intersect(tday1, tday2);
           
           if foo(1)~=0
               adjcls=NaN(length(foo), 2); % combining the two price series,initialized by NaN matrix
               adjcls(:, 1)=adjcls1(idx1);
               adjcls(:, 2)=adjcls2(idx2);
           else
               adjcls=NaN(length(foo)-1, 2); % combining the two price series,initialized by NaN matrix
               adjcls(:, 1)=adjcls1(idx1(2:end)); 
               adjcls(:, 2)=adjcls2(idx2(2:end));
           end
           
           tday=tday1(idx1);
           baddata=find(~tday);
           tday(baddata)=[];
           
           
           
           %convert to log prices
           adjcls1_log=log(adjcls(:,1));
           adjcls2_log=log(adjcls(:,2));
           adjcls=[adjcls1_log adjcls2_log];
           tday_str=datestr(tday); %transfter num date to string date        
%% Sweep across the entire time series
 
           cost=0;
           s = zeros(size(adjcls));
           count=0; 

% h1=adftest(diff(adjcls(:,1)));
% h2=adftest(diff(adjcls(:,2)));
           %[h0,pValue0,stat0,cValue0,reg0] = egcitest(adjcls,'test','t1','creg','ct');
           %Conduct Regression to calculate residual and compute ADF stat
           test_cadf1;
           ratio=beta1(2); %Hedgeratio
           residual=r1;
           stdev=sqrt(stats1(4));
           Rsqr=stats1(1);
           finaladf=best_adf;
           lags=best_ind;
           STAT=[STAT;finaladf];
           L=[L;lags];
           RSQR=[RSQR;Rsqr];
%% Calculate performance statistics
 % The strategy:       
        % If the residuals are large and positive, then the first series
        % is likely to decline vs. the second series.  Short the first
        % series by a scaled number of shares and long the second series by
        % 1 share.  If the residuals are large and negative, do the
        % opposite.
           zscr=residual/stdev;
           s(:, 2) = (zscr > spread) ...
                   - (zscr < -spread);
           s(:, 1) = -ratio .* s(:, 2);
           B=[B;ratio];
           signal_l=zscr(end-1);
           SL=[SL;signal_l]; %find the zscr last day to check the status
           signal_c=zscr(end); %find the zscr today and decide whether to trade or not
           SC=[SC;signal_c];
     
     
%            if (signal_l>2 && signal_l<2) 
%               action='short';
%            elseif (signal_l<-2 && signal_c>-2)
%               action='long';
%            elseif (signal_l<0 && signal_c>0) || (signal_l>0 && signal_c<0)
%               action='exit';
%            else
%               action='hold';
%            end
%               ACT=[ACT action];
     
              r  = sum(s(1:end, :) .* adjcls(1:end,:),2);
              totret=sum(r);
              sh = scaling*sharpe(r,0);   
              TR=[TR;totret];
              trades=0;
              wins=0;
              av_ret_v=[];
              hp_v=[];
              Enter=[];
              Exit=[];
              for j=1:size(s,1)
                  if ((j>1)&&(abs(s(j,2))==1) && (s(j-1,2)==0))||((j==1) && (abs(s(j,2))==1));
                  enterpoint=j;
                  Enter=[Enter;j];
                  end
            
                  if ((j<size(s,1))&&(abs(s(j,2))==1) && (s(j+1,2)==0))||((j==size(s,1)) && (abs(s(j,2))==1));                    
                     exitpoint=j;
                     Exit=[Exit;j];
                  end          
              end
        
              trades=size(Exit,1);
              hp_v=Exit-Enter+1;
              ret_v=[];
              for t=1:trades
                  new_ret=sum(r(Enter(t):Exit(t)));
                  ret_v=[ret_v;new_ret];
              end
        
              wins=size(find(ret_v>0),1);          
              av_ret=mean(ret_v);
              AR=[AR;av_ret];
              hp=mean(hp_v);
              HP=[HP;hp];      
              NUM_T=[NUM_T;trades];
              winp=wins/trades;
              WinP=[WinP;winp];
       
        
        end
    end
end
       
stk1_col=reshape(stk1,n_stock*(n_stock-1)+1,1);
stk2_col=reshape(stk2,n_stock*(n_stock-1)+1,1);
xlswrite('coint_result_2013_0409',stk1_col,inputs,'b1');
xlswrite('coint_result_2013_0409',stk2_col,inputs,'c1');
xlswrite('coint_result_2013_0409',[NUM_T TR AR HP WinP B RSQR STAT L SL SC],inputs,'d2');
% ACT_col=reshape(ACT,n_stock*(n_stock-1)+1,1);
% xlswrite('coint_result_2013_0304',ACT,'materials','n2');

