cd('C:\Documents and Settings\nthakkar.AC\My Documents');
clear adjcls;
clear adjcls1;
clear adjcls2;
clear sumlag;
clear metrics;
clear stk1;
clear stk2;
clear pks1;
clear pks2;
clear locs1;
clear locs2;
bbstk_blp;

n_stock=size(px,2)-1;
count=0;
metrics1=zeros(n_stock*(n_stock-1)/2,3);
metrics2=zeros(n_stock*(n_stock-1)/2,11);
num_smooth=5;

stk1={''};
stk2={''};


for n=1:(n_stock-1)
    new_stk1=repmat(txt(n),1,n_stock-n);
    stk1=[stk1 new_stk1];
    for m=(n+1):n_stock
    stk2=[stk2 txt(m)];
    end
end

for n=4:4
    tday1=dtxt(:, n+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
    adjcls1=px(:, n+1); %ppp the last column contains the adjusted close prices.
    
    for m=8:8
        tday2=dtxt(:, m+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
        adjcls2=px(:, m+1); % PPP
        tday=union(tday1, tday2); % find all the days when either GLD or GDX has data.
        baddata1=find(any(tday));
        tday(baddata1)=[];
        [foo idx idx1]=intersect(tday, tday1);
        adjcls=NaN(length(tday), 2); % combining the two price series
        adjcls(idx, 1)=adjcls1(idx1);
        [foo idx idx2]=intersect(tday, tday2);
        adjcls(idx, 2)=adjcls2(idx2);
        baddata=find(any(~isfinite(adjcls), 2)); % days where any one price is missing
        tday(baddata)=[];
        adjcls(baddata, :)=[];
        s=size(adjcls,1);
        adjcls=zscore(adjcls);
        
        adjcls1_row=reshape(adjcls(:,1),1,s);
        adjcls1_row=tsmovavg(adjcls1_row,'e',num_smooth);
        adjcls1_row=adjcls1_row(1,num_smooth:size(adjcls1_row,2));
        
        adjcls2_row=reshape(adjcls(:,2),1,s);
        adjcls2_row=tsmovavg(adjcls2_row,'e',num_smooth);
        adjcls2_row=adjcls2_row(1,num_smooth:size(adjcls2_row,2));
        
        x=1:s;
        [pks1,locs1]=findpeaks1(adjcls1_row,'MINPEAKHEIGHT',mean(adjcls1_row),'MINPEAKDISTANCE',1,'THRESHOLD',0.01);
        [pks2,locs2]=findpeaks1(adjcls2_row,'MINPEAKHEIGHT',mean(adjcls2_row),'MINPEAKDISTANCE',1,'THRESHOLD',0.01);
             
        subplot(2,1,1); plot(adjcls1_row);
        hold on; 
        plot(x(locs1(1,:)),pks1+0.05,'k^','markerfacecolor',[1 0 0]);
        subplot(2,1,2); plot(adjcls2_row);
        hold on; 
        plot(x(locs2(1,:)),pks2+0.05,'k^','markerfacecolor',[1 0 0]);   
           
        num1=size(locs1,2);
        num2=size(locs2,2);
        locs1_col=reshape(locs1,num1,1);
        locs2_col=reshape(locs2,num2,1);
        
        if (num1==num2)
           lag=locs1_col-locs2_col;
           corre=corr(locs1_col,locs2_col);
           avg_lag=mean(lag);
           stand=std(lag)/avg_lag;           
        end 
        
        if abs(num1-num2)==1
           if num2-num1==1
              head=abs(locs2_col(1)-locs1_col(1));
              tail=abs(locs2_col(num2)-locs1_col(num1));
              if head<tail
                  locs2_col(num2)=[];
              else
                  locs2_col(1)=[];
              end
           else 
              head=abs(locs1_col(1)-locs2_col(1));
              tail=abs(locs1_col(num1)-locs2_col(num2));
              if head<tail
                 locs1_col(num1)=[];
              else
                 locs1_col(1)=[];
              end
           end
          corre=corr(locs1_col,locs2_col);
          lag=locs1_col-locs2_col;
          avg_lag=mean(lag);
          stand=std(lag)/avg_lag;
        end
        
        if abs(num1-num2)>1
           corre=0; 
           stand=Inf;
           avg_lag=Inf;
        end 
        
        if avg_lag<Inf
       
           if avg_lag<0
               adjcls=[adjcls(:,2) adjcls(:,1)];
           end
        cross=0;    
        res_adf=cadf(adjcls(:, 1), adjcls(:, 2), 0, abs(floor(avg_lag))); % run cointegration check using augmented Dickey-Fuller test

        res_ols=ols(adjcls(:, 1), adjcls(:, 2)); 
        hedgeRatio=res_ols.beta;
        z=res_ols.resid;
        rtnres = olsrtn(adjcls(:, 1), adjcls(:, 2));

% Profit and loss 

        zscr = (z(:,1)-mean(z))/std(z);
        %plot(zscr);
% Cross zero calcu
        recs=size(adjcls,1);

        for ctr=2:recs
            if (zscr(ctr-1,1) > 0 && zscr(ctr,1) < 0)
               cross=cross+1; 
            elseif (zscr(ctr-1,1)<0 && zscr(ctr,1) >0)
               cross=cross+1;
            end
       
        end

        pnlcalc; 
        div=1;
        sumpair(div,1)=buy+sells; %no  of trades
        sumpair(div,2)=buydollar+selldollar; % Dollar P&L
        sumpair(div,3)=sumpair(div,2)/sumpair(div,1); % Average P&L
        sumpair(div,4)=daymkt/sumpair(div,1);
       % sumpair(div,7)= 0;%std(mtrade(:,5));
        sumpair(div,5)=win/sumpair(div,1);
        %sumpair(div,9)=0; %sumpair(div,4)/sumpair(div,7);
        %sumpair(div,6)=hedgeRatio*adjcls(end,2)/adjcls(end,1);%Beta
        sumpair(div,6)=rtnres.beta;
        sumpair(div,7)=res_adf.adf;
        sumpair(div,8)=cross;
        sumpair(div,9)=rtnres.rsqr;
        sumpair(div,10)=zscr(recs);
        sumpair(div,11)=abs(zscr(recs));
        end   
        
        sumlag=[corre avg_lag stand];        
        count=count+1;
        metrics1(count,:)=sumlag;
        metrics2(count,:)=sumpair(1,:);
    end 
        
end
new_stk1=reshape(stk1,n_stock*(n_stock-1)/2+1,1);
new_stk2=reshape(stk2,n_stock*(n_stock-1)/2+1,1);
%stand_col=reshape(stand,n_stock*(n_stock-1)/2,1);
%stand_col=abs(stand_col);
%xlswrite('coint_result',new_stk1,'shipper_lag','b1');
%xlswrite('coint_result',new_stk2,'shipper_lag','c1');
%xlswrite('coint_result',metrics1,'shipper_lag','d2');
%xlswrite('coint_result',metrics2,'shipper_lag','g2');