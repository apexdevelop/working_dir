cd('C:\Documents and Settings\nthakkar.AC\My Documents');
clear adjcls;
clear adjcls1;
clear adjcls2;
bbstk2;

n_stock=size(px,2)-1;

stk1={''};
stk2={''};

dif_num=[]; % initial value of different number of peaks between series
corre=[];
stand=[];
for n=1:1
    new_stk1=repmat(txt(n),1,n_stock-n);
    stk1=[stk1 new_stk1];
    for m=4:4
    stk2=[stk2 txt(m)];
    end
end

for n=2:2
    tday1=dtxt(:, n+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
    adjcls1=px(:, n+1); %ppp the last column contains the adjusted close prices.
    
    for m=5:5
        tday2=dtxt(:, m+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
        adjcls2=px(:, m+1); % PPP
        tday=union(tday1, tday2); % find all the days when either GLD or GDX has data.
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
        %adjcls1_row=tsmovavg(adjcls1_row,'e',5);
        %adjcls1_row=adjcls1_row(1,5:size(adjcls1_row,2));
        
        adjcls2_row=reshape(adjcls(:,2),1,s);
        %adjcls2_row=tsmovavg(adjcls2_row,'e',5);
        %adjcls2_row=adjcls2_row(1,5:size(adjcls2_row,2));
        
        x=1:s;
        [pks1,locs1]=findpeaks(adjcls1_row,'MINPEAKHEIGHT',0,'MINPEAKDISTANCE',floor(s/9),'THRESHOLD',0.01,'SORTSTR','none');
        [pks2,locs2]=findpeaks(adjcls2_row,'MINPEAKHEIGHT',0,'MINPEAKDISTANCE',floor(s/9),'THRESHOLD',0.01,'SORTSTR','none');
        num1=size(locs1,2);
        num2=size(locs2,2);
           locs1_col=reshape(locs1,num1,1);
           locs2_col=reshape(locs2,num2,1);
        
        if (num1==num2)
           new_lag=locs1_col-locs2_col;
           newcorre=corr(locs1_col,locs2_col);
           new_stand=std(new_lag)/mean(new_lag);
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
          newcorre=corr(locs1_col,locs2_col);
          new_lag=locs1_col-locs2_col;
          new_stand=std(new_lag)/mean(new_lag);
        end
        
        if abs(num1-num2)>1
           newcorre=0; 
           new_stand=Inf;
        end 
        
        newdif=abs(size(locs1,2)-size(locs2,2));
        dif=[dif newdif];
        corre=[corre newcorre];
        stand=[stand new_stand];
    end 
end
        subplot(2,1,1); plot(adjcls1_row);
        hold on; 
        plot(x(locs1(1,:)),pks1+0.05,'k^','markerfacecolor',[1 0 0]);
        subplot(2,1,2); plot(adjcls2_row);
        hold on; 
        plot(x(locs2(1,:)),pks2+0.05,'k^','markerfacecolor',[1 0 0]);

%new_stk1=reshape(stk1,n_stock*(n_stock-1)/2+1,1);
%new_stk2=reshape(stk2,n_stock*(n_stock-1)/2+1,1);
%stand_col=reshape(stand,n_stock*(n_stock-1)/2,1);
%stand_col=abs(stand_col);
stand=abs(stand);
stand
%xlswrite('lag',new_stk1,'sheet3','b1');
%xlswrite('lag',new_stk2,'sheet3','c1');
%xlswrite('lag',stand_col,'sheet3','d2');