cd('C:\Documents and Settings\nthakkar.AC\My Documents');


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
bbstk_blp;

% tottrade=0;
% r=1;
% cross=1;
% sl=5;
% sg=10;
% do=10;
% band=1.5;

n_stock=size(px,2)-1; %number of stocks
metrics=zeros(n_stock*(n_stock-1),12);
count=0;

stk1={''};
stk2={''};

for n=1:n_stock-1
    new_stk1=repmat(txt(n),1,n_stock-1);
    stk1=[stk1 new_stk1];
    for m=1:n_stock
        if m~=n
    stk2=[stk2 txt(m)];
        end
    end
end

for n=1:n_stock-1
    tday1=dtxt(:, n+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
    adjcls1=px(:, n+1); %ppp the last column contains the adjusted close prices.
    for m=1:n_stock
        if m~=n
        tday2=dtxt(:, m+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
        adjcls2=px(:, m+1); % PPP

        %tday=union(tday1, tday2); % find all the days when either GLD or GDX has data.
%         baddata1=find(any(tday));
%         tday(baddata1)=[];
        [foo idx1 idx2]=intersect(tday1, tday2); %foo=tday(idx,:),foo=tday1(idx1,:)
%         adjcls=NaN(length(tday), 2); % combining the two price series,initialized by NaN matrix
%         adjcls(idx, 1)=adjcls1(idx1);
%         adjcls(idx, 2)=adjcls2(idx2);
        tday=tday1(idx1);
        adjcls1p=adjcls1(idx1);
        adjcls2p=adjcls2(idx2);
        adjcls=[adjcls1p adjcls2p];
        baddata=find(any(~isfinite(adjcls), 2)); % days where any one price is missing,isfinite()=0 if NaN
        tday(baddata)=[];
        adjcls(baddata, :)=[];
        adjcls1_log=log(adjcls(:,1));
        adjcls2_log=log(adjcls(:,2));
        adjcls_log=[adjcls1_log adjcls2_log];
        tday_str=datestr(tday); %transfter num date to string date
        
        
        cross=0; 
       
        res_adf1=cadf(adjcls1_log, adjcls2_log, 0, 1); % run cointegration check using augmented Dickey-Fuller test
        %res_adf2=cadf(adjcls1_log, adjcls2_log, 0, 2);
        %res_adf3=cadf(adjcls1_log, adjcls2_log, 0, 3);
        %res_adf4=cadf(adjcls1_log, adjcls2_log, 0, 4);
%         res_ols=ols(adjcls1_log, adjcls2_log); 
%         hedgeRatio=res_ols.beta;
%         z=res_ols.resid;
%         rtnres = olsrtn(adjcls1_log, adjcls2_log);
        %rtnres = olsrtn(adjcls(:, 1), adjcls(:, 2));

% Profit and loss 

%         zscr = (z(:,1)-mean(z))/std(z);
        %plot(zscr);
% Cross zero calcu
%         recs=size(adjcls_log,1);
% 
%         for ctr=2:recs
%             if (zscr(ctr-1,1) > 0 && zscr(ctr,1) < 0)
%                cross=cross+1; 
%             elseif (zscr(ctr-1,1)<0 && zscr(ctr,1) >0)
%                cross=cross+1;
%             end
%        
%         end
% 
%         pnlcalc; 
%  
%         sumpair(1,1)=buy+sells; %no  of trades
%         sumpair(1,2)=buydollar+selldollar; % Dollar P&L
%         sumpair(1,3)=sumpair(div,2)/sumpair(div,1); % Average P&L
%         sumpair(1,4)=daymkt/sumpair(div,1);
%         sumpair(1,5)=win/sumpair(div,1);
%         %sumpair(1,6)=rtnres.beta;
%         sumpair(1,6)=res_ols.beta;
%         [C I]=min([res_adf1.adf res_adf2.adf res_adf3.adf res_adf4.adf]);
%         sumpair(1,7)=C;
%         sumpair(1,8)=I;
%         sumpair(1,9)=cross;
%         sumpair(1,10)=res_ols.rsqr;
%         %sumpair(1,10)=rtnres.rsqr;
%         sumpair(1,11)=zscr(recs);
%         sumpair(1,12)=abs(zscr(recs));
%         
%         count=count+1;
%         metrics(count,:)=sumpair(1,:);
        end
    end
    
end
% stk1_col=reshape(stk1,n_stock*(n_stock-1)/2+1,1);
% stk2_col=reshape(stk2,n_stock*(n_stock-1)/2+1,1);
% xlswrite('coint_result_2013_0206',stk1_col,'Sheet2','b1');
% xlswrite('coint_result_2013_0206',stk2_col,'Sheet2','c1');
% xlswrite('coint_result_2013_0206',metrics,'Sheet2','d2');