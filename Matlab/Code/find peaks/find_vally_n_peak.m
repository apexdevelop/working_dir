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

%------------------pnl calculation parameters-----------------
sl=5;
sg=10;
do=10;
band=1.5;
tottrade=0;
%-------------------------------------------------------------
n_stock=size(px,2)-1;
count=0;
metrics1=zeros(n_stock*(n_stock-1),2);
metrics2=zeros(n_stock*(n_stock-1),11);
num_smooth=5;


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
        
        [pks1,locs_p1]=findpeaks(adjcls1_row,'MINPEAKHEIGHT',mean(adjcls1_row),'MINPEAKDISTANCE',20,'THRESHOLD',0.01);
        [pks2,locs_p2]=findpeaks(adjcls2_row,'MINPEAKHEIGHT',mean(adjcls2_row),'MINPEAKDISTANCE',20,'THRESHOLD',0.01);
    
        [vls1,locs_v1]=findvallys(adjcls1_row,'MINPEAKHEIGHT',mean(adjcls1_row),'MINPEAKDISTANCE',20,'THRESHOLD',0.01);
        [vls2,locs_v2]=findvallys(adjcls2_row,'MINPEAKHEIGHT',mean(adjcls2_row),'MINPEAKDISTANCE',20,'THRESHOLD',0.01);
        
        pks1_col=reshape(pks1,size(pks1,2),1);
        locs_p1_col=reshape(locs_p1,size(locs_p1,2),1);
        pks2_col=reshape(pks2,size(pks2,2),1);
        locs_p2_col=reshape(locs_p2,size(locs_p2,2),1);
        
        vls1_col=reshape(vls1,size(vls1,2),1);
        locs_v1_col=reshape(locs_v1,size(locs_v1,2),1);
        vls2_col=reshape(vls2,size(vls2,2),1);
        locs_v2_col=reshape(locs_v2,size(locs_v2,2),1);
        
%         p1=[locs_p1_col pks1_col];
%         p2=[locs_p2_col pks2_col];
%         v1=[locs_v1_col vls1_col];
%         v2=[locs_v2_col vls2_col];
%         
%         pv1=[transpose(p1) transpose(v1)];
%         pv2=[transpose(p2) transpose(v2)];
%         
%         t_pv1=transpose(pv1);
%         t_pv2=transpose(pv2);
%         t_pv1=sortrows(t_pv1,1);
%         t_pv2=sortrows(t_pv2,1);
%         
        
%         
%         subplot(2,1,1); plot(adjcls1_row);
%         hold on; 
%         plot(t_pv1(:,1),t_pv1(:,2)+0.05,'k^','markerfacecolor',[1 0 0]);
%         subplot(2,1,2); plot(adjcls2_row);
%         hold on; 
%         plot(t_pv2(:,1),t_pv2(:,2)+0.05,'k^','markerfacecolor',[1 0 0]);   
          
% dealing with peak loction vectors------------------------------        
        num_p1=size(locs_p1_col,1);
        num_p2=size(locs_p2_col,1);
        
        if (num_p1==num_p2)
           lag_p=locs_p1_col(:,1)-locs_p2_col(:,1);
           %corre_p=corr(locs_p1_col(:,1),locs_p2_col(:,1));
           avg_lag_p=mean(lag_p);
           stand_p=std(lag_p)/avg_lag_p;           
        end 
        
        if abs(num_p1-num_p2)==1
           if num_p2-num_p1==1
              head=abs(locs_p1_col(1,1)-locs_p2_col(1,1));
              tail=abs(locs_p1_col(num_p1,1)-locs_p2_col(num_p2,1));
              if head<tail
                  locs_p2_col(num_p2,:)=[];
                  pks2_col(num_p2,:)=[];
              else
                  locs_p2_col(1,:)=[];
                  pks2_col(num_p2,:)=[];
              end
           else 
              head=abs(locs_p1_col(1,1)-locs_p2_col(1,1));
              tail=abs(locs_p1_col(num_p1,1)-locs_p2_col(num_p2,1));
              if head<tail
                 locs_p1_col(num_p1,:)=[];
                 pks1_col(num_p1,:)=[];
              else
                 locs_p1_col(1,:)=[];
                 pks1_col(num_p1,:)=[];
              end
           end
        %corre=corr(locs_p1_col(:,1),locs_p2_col(:,1));
          lag_p=locs_p1_col(:,1)-locs_p2_col(:,1);
           avg_lag_p=mean(lag_p);
           stand_p=std(lag_p)/avg_lag_p;           
        end
        
        if abs(num_p1-num_p2)>1
           %corre=0; 
           stand_p=Inf;
           avg_lag_p=Inf;
        end 
%---------------------------------------------------------     


%------- dealing with vally loction vectors------------------------------        
        num_v1=size(locs_v1_col,1);
        num_v2=size(locs_v2_col,1);
        
        if (num_v1==num_v2)
           lag_v=locs_v1_col(:,1)-locs_v2_col(:,1);
           %corre=corr(locs_p1_col(:,1),locs_p2_col(:,1));
           avg_lag_v=mean(lag_v);
           stand_v=std(lag_v)/avg_lag_v;           
        end 
        
        if abs(num_v1-num_v2)==1
           if num_v2-num_v1==1
              head=abs(locs_v1_col(1,1)-locs_v2_col(1,1));
              tail=abs(locs_v1_col(num_v1,1)-locs_v2_col(num_v2,1));
              if head<tail
                  locs_v2_col(num_v2,:)=[];
                  vls2_col(num_v2,:)=[];
              else
                  locs_v2_col(1,:)=[];
                   vls2_col(1,:)=[];
              end
           else 
              head=abs(locs_v1_col(1,1)-locs_v2_col(1,1));
              tail=abs(locs_v1_col(num_v1,1)-locs_v2_col(num_v2,1));
              if head<tail
                 locs_v1_col(num_v1,:)=[];
                 vls1_col(num_v1,:)=[];
              else
                 locs_v1_col(1,:)=[];
                 vls1_col(1,:)=[];
              end
           end
        lag_v=locs_v1_col(:,1)-locs_v2_col(:,1);
           %corre=corr(locs_p1_col(:,1),locs_p2_col(:,1));
           avg_lag_v=mean(lag_v);
           stand_v=std(lag_v)/avg_lag_v;           
        end
        
        if abs(num_v1-num_v2)>1
           %corre=0; 
           stand_v=Inf;
           avg_lag_v=Inf;
        end 
%--------------------------------------------------------- 
        avg_lag=(avg_lag_p+avg_lag_v)/2;
        stand=(stand_p+stand_v)/2;       
           if avg_lag<0
               adjcls=[adjcls(:,2) adjcls(:,1)];
           end
        cross=0;   
 %-----------------determine #of lags in adf calculation----------       
        if avg_lag<Inf
            nlag=2;
        else
            nlag=abs(floor(avg_lag));
        end
 %------------------------------------------------------------------
        res_adf=cadf(adjcls(:, 1), adjcls(:, 2), 0, nlag); % run cointegration check using augmented Dickey-Fuller test

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
        sumpair(div,5)=win/sumpair(div,1);
        sumpair(div,6)=rtnres.beta;
        sumpair(div,7)=res_adf.adf;
        sumpair(div,8)=cross;
        sumpair(div,9)=rtnres.rsqr;
        sumpair(div,10)=zscr(recs);
        sumpair(div,11)=abs(zscr(recs));   
        
        sumlag=[avg_lag stand];        
        count=count+1;
        metrics1(count,:)=sumlag;
        metrics2(count,:)=sumpair(1,:);
        end    
    end
end

new_stk1=reshape(stk1,n_stock*(n_stock-1)+1,1);
new_stk2=reshape(stk2,n_stock*(n_stock-1)+1,1);
xlswrite('coint_result',new_stk1,'shipper_lag','b1');
xlswrite('coint_result',new_stk2,'shipper_lag','c1');
xlswrite('coint_result',metrics1,'shipper_lag','d2');
xlswrite('coint_result',metrics2,'shipper_lag','g2');