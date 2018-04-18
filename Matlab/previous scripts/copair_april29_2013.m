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
clear crn;

%number 10
sheetnames={'consumerd','consumers','energy','financial','healthc','industrials','infotech','materials','telecom','utility','test'};
ranges={'b2:b23','b2:b8','b2:b10','b2:b33','b2:b7','b2:b22','b2:b52','b2:b22','b2:b13','b2:b6','a2:a16'};
ranges2={'c2:c23','c2:c8','c2:c10','c2:c33','c2:c7','c2:c22','c2:c52','c2:c22','c2:c13','c2:c6','b2:b16'};

index=11;
lookback=365;
inputs=char(sheetnames(index));
inputr=char(ranges(index));
inputr2=char(ranges2(index));

[names date price]=blp_complex('input_factor_sector_small',inputs,inputr,lookback,' Equity'); %import data set from bloomberg

% import local ticker currency
[num,crn]=xlsread('input_factor_sector_small',inputs,inputr2);


%import currency data
[ct,cpx,cnames]=importdata('input_ticker','curncy','a1:a7','last_price',lookback,1);
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
new_stk2=repmat(names(1),1,n_stock-1);
stk2=[stk2 new_stk2];
for n=2:n_stock
    stk1=[stk1  names(n)];               
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

tday2=date_c(:, 1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
adjcls2=price_c(:, 1); % PPP    

for n=2:n_stock
    tday1=date_c(:, n); 
    adjcls1=price_c(:, n);            
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
       
stk1_col=reshape(stk1,n_stock,1);
stk2_col=reshape(stk2,n_stock,1);
xlswrite('coint_solar_2013_0618',stk1_col,inputs,'b1');
xlswrite('coint_solar_2013_0618',stk2_col,inputs,'c1');
xlswrite('coint_solar_2013_0618',[NUM_T TR AR HP WinP B abs(B) RSQR STAT L SL SC abs(SC)],inputs,'d2');
% ACT_col=reshape(ACT,n_stock*(n_stock-1)+1,1);
% xlswrite('coint_result_2013_0304',ACT,'materials','n2');

