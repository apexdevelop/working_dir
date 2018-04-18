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


%telecom a2:a12
%consumerd a2:a23
%consumers a2:a7
%energy   a2:a9
%financial a2:a32
%healthc a2:a6
%industrials a2:a21
%infotech a2:a51
%materials a2:a21
%utility a2:a5



[names date price]=blp_simple('input_sector','telecom','a2:a12',500); %import data set from bloomberg
% import local ticker currency
[num,crn]=xlsread('input_sector','telecom','b2:b12');


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
 ACT={''};
 RSQR=[];
 
for n=2:2
    tday1=date_c(:, n); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
    adjcls1=price_c(:, n); %ppp the last column contains the adjusted close prices.       
    for m=3:3
        if m~=n
        tday2=date_c(:, m); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
        adjcls2=price_c(:, m); % PPP                
    [foo idx1 idx2]=intersect(tday1, tday2); 
    tday=tday1(idx1);
    baddata1=find(~tday);
    tday(baddata1)=[];
    adjcls=NaN(length(tday), 2); % combining the two price series,initialized by NaN matrix
    adjcls(:, 1)=adjcls1(idx1(2:end));
    adjcls(:, 2)=adjcls2(idx2(2:end));
    tday_str=datestr(tday); %transfter num date to string date
  
        
%% Sweep across the entire time series
 
     spread=1;
     scaling=1;
     cost=0;

     s = zeros(size(adjcls));
     count=0; 

% h1=adftest(diff(adjcls(:,1)));
% h2=adftest(diff(adjcls(:,2)));
     [h0,pValue0,stat0,cValue0,reg0] = egcitest(adjcls,'test','t1','creg','ct'); 
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
%      signal_l=zscr(end-1);
%      SL=[SL;signal_l]; %find the zscr last day to check the status
%      signal_c=zscr(end); %find the zscr today and decide whether to trade or not
%      SC=[SC;signal_c];
%      
%      
%      if (signal_l>2 && signal_l<2) 
%          action='short';
%      elseif (signal_l<-2 && signal_c>-2)
%          action='long';
%      elseif (signal_l<0 && signal_c>0) || (signal_l>0 && signal_c<0)
%          action='exit';
%      else
%          action='hold';
%      end
%      ACT=[ACT action];
     
        r  = sum([0 0; s(1:end-1, :) .* adjcls(1:end-1,:) - abs(diff(s))*cost/2] ,2);
        totret=sum(r);
        sh = scaling*sharpe(r,0);   
        TR=[TR;totret];
        trades=0;
        wins=0;
        av_ret_v=[];
        hp_v=[];
        for j=1:size(s,1)-1
            if ((j>1)&&(abs(s(j,2))==1) && (s(j-1,2)==0))||((j==1) && (abs(s(j,2))==1));
            enterpoint=j;
            exitpoint=j;
            while (abs(s(exitpoint,2))==1)
                  if exitpoint<size(s,1)
                  exitpoint=exitpoint+1;
                  end
            end
            trades=trades+1;
            new_hp=exitpoint-enterpoint;
            hp_v=[hp_v;new_hp];
            new_ret=sum(r(enterpoint:exitpoint-1));
            if new_ret>0
              wins=wins+1;
            end
            av_ret_v=[av_ret_v;new_ret];           
            end
        end
        av_ret=mean(av_ret_v);
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
% xlswrite('coint_result_2013_0305',stk1_col,'telecom','b1');
% xlswrite('coint_result_2013_0305',stk2_col,'telecom','c1');
% xlswrite('coint_result_2013_0305',[NUM_T TR AR HP WinP B STAT L SL SC],'telecom','d2');
% ACT_col=reshape(ACT,n_stock*(n_stock-1)+1,1);
% xlswrite('coint_result_2013_0304',ACT,'materials','n2');

