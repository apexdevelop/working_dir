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
clear ediff;
clear zscr;
clear txt;
names date price]=blp_simple('input_sector','materials','a2:a21',1500); %import data set from bloomberg
% import local ticker currency
[num,crn]=xlsread('input_sector','materials','b2:b21');


%import currency data
[ct,cpx,cnames]=importdata('input_ticker','curncy','a1:a7','last_price',1500,1);
carray={'KRW','JPY','HKD','TWD','USD','AUD','INR'};
% 1---KRW  2---JPY 3--HKD 4---TWD 5---USD 6---AUD 7---INR

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
 ACT={''};
 RSQR=[];
for n=1:n_stock
    tday1=date(:, n+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
    adjcls1=price(:, n+1); %ppp the last column contains the adjusted close prices.
    crn1=char(crn(n,1));
    
    for s1=1:size(carray,2)
    if crn1==char(carray(s1))
            cind1=s1;
    end
    end
    
%     tday1str=datestr(tday1);
%     ctstr=datestr(ct(:,cind+1));
    %intersect adr price date with currency price date
    [anc aidx cidx1]=intersect(tday1, ct(:,cind1+1));   
    tmpprice1=adjcls1(aidx);
    tmpcpx1=cpx(cidx1,cind1+1);
    price1=tmpprice1./tmpcpx1;
%     ancstr=datestr(anc);  
    tday1=tday1(aidx);
    
    
    for m=1:n_stock
        if m~=n
        tday2=date(:, m+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
        adjcls2=price(:, m+1); % PPP
        crn2=char(crn(m,1));
    
        for s2=1:size(carray,2)
            if crn2==char(carray(s2))
               cind2=s2;
            end
        end
 
    %intersect adr price date with currency price date
    [bnc bidx cidx2]=intersect(tday2, ct(:,cind2+1));   
    tmpprice2=adjcls2(bidx);
    tmpcpx2=cpx(cidx2,cind2+1);
    price2=tmpprice2./tmpcpx2;
    tday2=tday2(bidx);    
        
        
        
        tday=union(tday1, tday2); % find all the days when either GLD or GDX has data.
        baddata1=find(any(tday));
        tday(baddata1)=[];
        [foo idx idx1]=intersect(tday, tday1); %foo=tday(idx,:),foo=tday1(idx1,:)
        adjcls=NaN(length(tday), 2); % combining the two price series,initialized by NaN matrix
        adjcls(idx, 1)=price1(idx1);
        [foo idx idx2]=intersect(tday, tday2);
        adjcls(idx, 2)=price2(idx2);
        baddata=find(any(~isfinite(adjcls), 2)); % days where any one price is missing,isfinite()=0 if NaN
        tday(baddata)=[];
        adjcls(baddata, :)=[];
        tday_str=datestr(tday); %transfter num date to string date
        
%% Sweep across the entire time series
% Every N periods, we use the previous M periods' worth of information to
% estimate the cointegrating relationship (if it exists).
%
% We then use this estimated relationship to identify trading opportunities
% until the next rebalancing date.
 M=1000; %looking back
 N=30;  %the future estimate period
 spread=0.5;
 scaling=1;

cost=0;

s = zeros(size(adjcls));
indicate = zeros(length(adjcls),1);
count=0; 
for i = max(M,N) : N : length(s)-N
    % Calibrate cointegration model by looking back.
    [h1,pValue1,stat1,cValue1,reg1] = egcitest(adjcls(i-M+1:i,:),'test','t1');
    adf1=stat1;
   
    if h1 ~= 0
        count = count +1;
        % Only engage in trading if we reject the null hypothesis that no
        % cointegrating relationship exists.
       
        % The strategy:
        % 1. Compute residuals over next N days
        res = adjcls(i:i+N-1, 1) ...
            - (reg1.coeff(1) + reg1.coeff(2).*adjcls(i:i+N-1, 2));
       
        % 2. If the residuals are large and positive, then the first series
        % is likely to decline vs. the second series.  Short the first
        % series by a scaled number of shares and long the second series by
        % 1 share.  If the residuals are large and negative, do the
        % opposite.
        indicate(i:i+N-1) = res/reg1.RMSE;
        s(i:i+N-1, 2) = (res/reg1.RMSE > spread) ...
            - (res/reg1.RMSE < -spread);
        s(i:i+N-1, 1) = -reg1.coeff(2) .* s(i:i+N-1, 2);
    end
end

%% Calculate performance statistics
 
r  = sum([0 0; s(1:end-1, :) .* adjcls(1:end-1,:) - abs(diff(s))*cost/2] ,2);
sh = scaling*sharpe(r,0);
        end
    end
end
       
% stk1_col=reshape(stk1,n_stock*(n_stock-1)+1,1);
% stk2_col=reshape(stk2,n_stock*(n_stock-1)+1,1);
% xlswrite('coint_result_2013_0222',stk1_col,'Sheet2','b1');
% xlswrite('coint_result_2013_0222',stk2_col,'Sheet2','c1');
% xlswrite('coint_result_2013_0222',metrics,'Sheet2','d2');