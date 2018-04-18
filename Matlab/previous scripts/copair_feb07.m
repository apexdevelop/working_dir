cd('C:\Documents and Settings\YChen\My Documents');


clear mtrade;
clear trade;
clear metrics;
clear adj;
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
clear q;
clear rsqr;
clear res_adf;
clear res_ols;
clear results;
clear res_rtn;
clear rtnres;
clear sec;
clear sumpair;
clear x;
clear y;
clear z;
clear zscr;
clear ym;
clear txt;
[txt dtxt px]=blp_simple('input_sector','infotech','a2:a51',1500); %import data set from bloomberg


n_stock=size(px,2)-1; %number of stocks
metrics=zeros(n_stock*(n_stock-1),12);
count=0;

stk1={''};
stk2={''};

for n=1:n_stock
    new_stk1=repmat(txt(n),1,n_stock-1);
    stk1=[stk1 new_stk1];
    for m=1:n_stock
        if m~=n
    stk2=[stk2 txt(m)];
        end
    end
end

for n=1:n_stock
    tday1=dtxt(:, n+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
    adjcls1=px(:, n+1); %ppp the last column contains the adjusted close prices.
    for m=1:n_stock
        if m~=n
        tday2=dtxt(:, m+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
        adjcls2=px(:, m+1); % PPP

        tday=union(tday1, tday2); % find all the days when either GLD or GDX has data.
        baddata1=find(any(tday));
        tday(baddata1)=[];
        [foo idx idx1]=intersect(tday, tday1); %foo=tday(idx,:),foo=tday1(idx1,:)
        adjcls=NaN(length(tday), 2); % combining the two price series,initialized by NaN matrix
        adjcls(idx, 1)=adjcls1(idx1);
        [foo idx idx2]=intersect(tday, tday2);
        adjcls(idx, 2)=adjcls2(idx2);
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
 M=300; %looking back
 N=30;  %the future estimate period
%  spread=0.75;
%  scaling=1;

% cost=0;

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
       
        s(i:i+N-1, 1) = (res/reg1.RMSE > spread) ...
            - (res/reg1.RMSE < -spread);
        s(i:i+N-1, 2) = -reg1.coeff(2) .* s(i:i+N-1, 1);
    end
end

        
        for div=1:1
        cross=0; 
        
        res_adf1=cadf(adjcls(1:end-30, 1), adjcls(1:end-30, 2), 0, 1); % run cointegration check using augmented Dickey-Fuller test
        res_adf2=cadf(adjcls(1:end-30, 1), adjcls(1:end-30, 2), 0, 2);
        res_adf3=cadf(adjcls(1:end-30, 1), adjcls(1:end-30, 2), 0, 3);
        res_adf4=cadf(adjcls(1:end-30, 1), adjcls(1:end-30, 2), 0, 4);
%         log1=log(adjcls(:, 1));
%         log2=log(adjcls(:, 2));
        res_ols=ols(adjcls(1:end-30, 1), adjcls(1:end-30, 2)); 
        hedgeRatio=res_ols.beta;
        
        rtnres = olsrtn(adjcls(1:end-30, 1), adjcls(1:end-30, 2));

% Profit and loss days from end-29 to end
        z=adjcls(end-29:end, 1)-hedgeRatio*adjcls(end-29:end, 2);
        zscr = (z(:,1)-mean(z))/std(z);
        %plot(zscr);
% Cross zero calcu
        
        
        pnlcalc_feb22; 
 
        sumpair(div,1)=buys+sells; %no  of trades
%         sumpair(div,2)=buydollar+selldollar; % Dollar P&L
        sumpair(div,2)=pnl;
        sumpair(div,3)=sumpair(div,2)/sumpair(div,1); % Average P&L
        sumpair(div,4)=daymkt/sumpair(div,1); %expected holding period
        sumpair(div,5)=win/sumpair(div,1);
        %sumpair(div,6)=rtnres.beta;
        sumpair(div,6)=res_ols.beta;
        [C I]=min([res_adf1.adf res_adf2.adf res_adf3.adf res_adf4.adf]);
        sumpair(div,7)=C;
        sumpair(div,8)=I;
        sumpair(div,9)=cross;
        sumpair(div,10)=res_ols.rsqr;
        %sumpair(div,10)=rtnres.rsqr;
        sumpair(div,11)=zscr(recs);
        sumpair(div,12)=abs(zscr(recs));
        end
        count=count+1;
        metrics(count,:)=sumpair(1,:);
        end
    end
    
end
stk1_col=reshape(stk1,n_stock*(n_stock-1)+1,1);
stk2_col=reshape(stk2,n_stock*(n_stock-1)+1,1);
xlswrite('coint_result_2013_0222',stk1_col,'Sheet2','b1');
xlswrite('coint_result_2013_0222',stk2_col,'Sheet2','c1');
xlswrite('coint_result_2013_0222',metrics,'Sheet2','d2');