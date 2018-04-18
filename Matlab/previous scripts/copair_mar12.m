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

sheetnames={'telecom','consumerd','consumers','energy','financial','healthc','industrials','infotech','materials','utility'};
ranges={'a2:a12','a2:a23','a2:a7','a3:a10','a2:a32','a2:a6','a2:a21','a2:a51','a2:a21','a2:a5'};
ranges2={'b2:b12','b2:b23','b2:b7','b3:b10','b2:b32','b2:b6','b2:b21','b2:b51','b2:b21','b2:b5'};

inputs=char(sheetnames(10));
inputr=char(ranges(10));
inputr2=char(ranges2(10));

[names date price]=blp_simple('input_sector',inputs,inputr,500); %import data set from bloomberg
% import local ticker currency
[num,crn]=xlsread('input_sector',inputs,inputr2);


%import currency data
[ct,cpx,cnames]=importdata('input_ticker','curncy','a1:a7','last_price',500,1);
carray={'KRW','JPY','HKD','TWD','USD','AUD','INR'};
% 1---KRW  2---JPY 3--HKD 4---TWD 5---USD 6---AUD 7---INR

n_stock=size(price,2)-1; %number of stocks
% metrics=zeros(n_stock*(n_stock-1),12);

price_c=zeros(size(date,1),n_stock);
date_c=zeros(size(date,1),n_stock);
for s1=1:n_stock
    pnc=[];
    pidx=[];
    cidx1=[];
    tmpprice1=[];
    price1=[];
    date1=[];
    cind1=0;
    crn1=char(crn(s1,1));
    for c1=1:size(carray,2)
    if crn1==char(carray(c1))
            cind1=c1;
    end
    end
    %intersect adr price date with currency price date
    datep=date(:,s1+1);
    zeroind1=find(~datep);
    datep(zeroind1)=[];
    
    datec=ct(:,cind1+1);
    zeroind2=find(~datec);
    datec(zeroind2)=[];
    
    [pnc pidx cidx1]=intersect(datep, datec);   
    tmpprice1=price(pidx,s1+1);
    tmpcpx1=cpx(cidx1,cind1+1);
    price1=tmpprice1./tmpcpx1;
    date1=datep(pidx);    
    price_c(1:size(price1,1),s1)=price1;
    date_c(1:size(date1,1),s1)=date1;
end

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
 
for n=1:n_stock
    tday1=date_c(:, n); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
    adjcls1=price_c(:, n); %ppp the last column contains the adjusted close prices.       
    for m=1:n_stock
        if m~=n
           tday2=date_c(:, m); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
           adjcls2=price_c(:, m); % PPP                
           [foo idx1 idx2]=intersect(tday1, tday2); 
           tday=tday1(idx1);
           baddata=find(~tday);
           tday(baddata)=[];
           adjcls=NaN(length(tday), 2); % combining the two price series,initialized by NaN matrix
           if idx1(1)==1
               adjcls(:, 1)=adjcls1(idx1);               
           else
               adjcls(:, 1)=adjcls1(idx1(2:end));               
           end
           
           if idx2(1)==1
               adjcls(:, 2)=adjcls2(idx2);               
           else
               adjcls(:, 2)=adjcls2(idx2(2:end));               
           end
           
           %convert to log prices
           adjcls1_log=log(adjcls(:,1));
           adjcls2_log=log(adjcls(:,2));
           adjcls=[adjcls1_log adjcls2_log];
           tday_str=datestr(tday); %transfter num date to string date        
%% Sweep across the entire time series
           spread=1;
           scaling=1;
           cost=0;
           s = zeros(size(adjcls));
           count=0; 

% h1=adftest(diff(adjcls(:,1)));
% h2=adftest(diff(adjcls(:,2)));
           %[h0,pValue0,stat0,cValue0,reg0] = egcitest(adjcls,'test','t1','creg','ct');
           %Conduct Regression to calculate residual and compute ADF stat
           test_cadf1;
           ratio=reg0.coeff(3); %Hedgeratio
           residual=reg0.res;
           stdev=reg0.RMSE;
           finaladf=stat0;
           Rsqr=reg0.RSq;
           lags=0;

           for p=0:10
               [h,pValue,stat,cValue,reg] = egcitest(adjcls,'test','t1','creg','ct','lags',p); 
               if stat<finaladf
                  finaladf=stat;
                  lags=p;
                  ratio=reg.coeff(3);
                  residual=reg.res;
                  stdev=reg.RMSE;
                  Rsqr=reg.RSq;
               end
           end
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
xlswrite('coint_result_2013_0329',stk1_col,inputs,'b1');
xlswrite('coint_result_2013_0329',stk2_col,inputs,'c1');
xlswrite('coint_result_2013_0329',[NUM_T TR AR HP WinP B STAT L SL SC],inputs,'d2');
% ACT_col=reshape(ACT,n_stock*(n_stock-1)+1,1);
% xlswrite('coint_result_2013_0304',ACT,'materials','n2');

