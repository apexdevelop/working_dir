cd('C:\Documents and Settings\YChen\My Documents');

clear names1;
clear dates1;
clear prices1;
clear names2;
clear dates2;
clear prices2;
clear names3;
clear dates3;
clear prices3;
clear dates;
clear prices;

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


sheetnames={'apparel'};
ranges1={'a2:a16'};
ranges2={'c2:c16'};
ranges3={'e2:e16'};

inputs=char(sheetnames(1));
inputr1=char(ranges1(1));
inputr2=char(ranges2(1));
inputr3=char(ranges3(1));

[names1 dates1 prices1]=blp_simple('input_industry_compact',inputs,inputr1,500,' Equity');
[names2 dates2 prices2]=blp_simple('input_industry_compact',inputs,inputr2,500,' Curncy');
[names3 dates3 prices3]=blp_simple('input_industry_compact',inputs,inputr3,500,' Index');

n_stock=size(prices1,2)-1;


% metrics=zeros(n_stock*(n_stock-1),12);

stk1={''};
stk2={''};

for n=1:n_stock
    new_stk1=repmat(names1(n),1,n_stock-1);
    stk1=[stk1  new_stk1];
    for m=1:n_stock
        if m~=n
    stk2=[stk2  names1(m)];
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
    [tday1 adjcls1]=factor_coint(n,dates1,dates2,dates3,prices1,prices2,prices3);    
    for m=1:n_stock
        if m~=n
           [tday2 adjcls2]=factor_coint(m,dates1,dates2,dates3,prices1,prices2,prices3); 
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
%            adjcls1_log=log(adjcls(:,1));
%            adjcls2_log=log(adjcls(:,2));
%            adjcls=[adjcls1_log adjcls2_log];
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
       
% stk1_col=reshape(stk1,n_stock*(n_stock-1)+1,1);
% stk2_col=reshape(stk2,n_stock*(n_stock-1)+1,1);
% xlswrite('coint_result_2013_0409',stk1_col,inputs,'b1');
% xlswrite('coint_result_2013_0409',stk2_col,inputs,'c1');
% xlswrite('coint_result_2013_0409',[NUM_T TR AR HP WinP B RSQR STAT L SL SC],inputs,'d2');
% ACT_col=reshape(ACT,n_stock*(n_stock-1)+1,1);
% xlswrite('coint_result_2013_0304',ACT,'materials','n2');

