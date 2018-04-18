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
metrics=zeros(n_stock*(n_stock-1)/2,3);
num_smooth=5;

stk1={''};
stk2={''};

%dif=[]; % initial value of different number of peaks between series
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
        
    
        [pks1,locs1]=findpeaks1(adjcls1_row,'MINPEAKHEIGHT',mean(adjcls1_row),'MINPEAKDISTANCE',20,'THRESHOLD',0.01);
        [pks2,locs2]=findpeaks1(adjcls2_row,'MINPEAKHEIGHT',mean(adjcls2_row),'MINPEAKDISTANCE',20,'THRESHOLD',0.01);
             
        subplot(2,1,1); plot(adjcls1_row);
        hold on; 
        plot(x(locs1(1,:)),pks1+0.05,'k^','markerfacecolor',[1 0 0]);
        subplot(2,1,2); plot(adjcls2_row);
        hold on; 
        plot(x(locs2(1,:)),pks2+0.05,'k^','markerfacecolor',[1 0 0]);   
          
        
    end
end