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
[names date price]=blp_simple('input_sector','infotech','a2:a51',1500); %import data set from bloomberg


n_stock=size(price,2)-1; %number of stocks
% metrics=zeros(n_stock*(n_stock-1),12);

stk1={''};
stk2={''};

for n=1:n_stock
    new_stk1=repmat(names(n),1,n_stock-1);
    stk1=[stk1 new_stk1];
    for m=1:n_stock
        if m~=n
    stk2=[stk2 names(m)];
        end
    end
end
STAT=[];
R=[];
H=[];
for n=1:n_stock
    tday1=date(:, n+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
    adjcls1=price(:, n+1); %ppp the last column contains the adjusted close prices.
    for m=1:n_stock
        if m~=n
        tday2=date(:, m+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
        adjcls2=price(:, m+1); % PPP

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
 
 spread=0.7;
 scaling=1;

cost=0;

s = zeros(size(adjcls));

count=0; 


h1=adftest(diff(adjcls(:,1)));
h2=adftest(diff(adjcls(:,2)));
[h,pValue,stat,cValue,reg] = egcitest(adjcls,'test','t1'); 
STAT=[STAT;stat];
    if h1*h2*h == 0
    ret=0;
    
    else
        % Only engage in trading if we reject the null hypothesis that no
        % cointegrating relationship exists.
       
        % The strategy:       
        % If the residuals are large and positive, then the first series
        % is likely to decline vs. the second series.  Short the first
        % series by a scaled number of shares and long the second series by
        % 1 share.  If the residuals are large and negative, do the
        % opposite.
        
     s(:, 2) = (reg.res/reg.RMSE > spread) ...
            - (reg.res/reg.RMSE < -spread);
     s(:, 1) = -reg.coeff(2) .* s(:, 2);


%% Calculate performance statistics
 
        r  = sum([0 0; s(1:end-1, :) .* adjcls(1:end-1,:) - abs(diff(s))*cost/2] ,2);
        sh = scaling*sharpe(r,0);
        ret=sum(r);
        
        
    end
     R=[R;ret];
   end
  end
end
       
% stk1_col=reshape(stk1,n_stock*(n_stock-1)+1,1);
% stk2_col=reshape(stk2,n_stock*(n_stock-1)+1,1);
% xlswrite('coint_result_2013_0222',stk1_col,'Sheet2','b1');
% xlswrite('coint_result_2013_0222',stk2_col,'Sheet2','c1');
% xlswrite('coint_result_2013_0222',metrics,'Sheet2','d2');