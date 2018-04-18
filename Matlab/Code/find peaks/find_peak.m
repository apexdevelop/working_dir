javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar')
cd('C:\Users\ychen\Documents\MATLAB');
clear all;
bbstk_blp;

s=size(dtxt,1);
n_stock=size(px,2)-1;


stk1={''};
stk2={''};

for n=1:(n_stock-1)
    new_stk1=repmat(txt(n),1,n_stock-n);
    stk1=[stk1 new_stk1];
    for m=(n+1):n_stock
    stk2=[stk2 txt(m)];
    end
end

for n=1:(n_stock-1)
    tday1=dtxt(1:s, n+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
    adjcls1=px(1:s, n+1); %ppp the last column contains the adjusted close prices.
    
    for m=(n+1):n_stock
        tday2=dtxt(1:s, m+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
        adjcls2=px(1:s, m+1); % PPP
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
        adjcls1_row=tsmovavg(adjcls1_row,'e',5);
        adjcls1_row=adjcls1_row(1,5:size(adjcls1_row,2));
        
        adjcls2_row=reshape(adjcls(:,2),1,s);
        adjcls2_row=tsmovavg(adjcls2_row,'e',5);
        adjcls2_row=adjcls2_row(1,5:size(adjcls2_row,2));
        
        x=1:s;
        [pks1,locs1]=findpeaks(adjcls1_row,'MINPEAKHEIGHT',0,'MINPEAKDISTANCE',floor(s/9),'THRESHOLD',0.01,'SORTSTR','none');
        [pks2,locs2]=findpeaks(adjcls2_row,'MINPEAKHEIGHT',0,'MINPEAKDISTANCE',floor(s/9),'THRESHOLD',0.01,'SORTSTR','none');
        %if size(locs1,2)<size(locs2,2)
         %   locs2=locs2(1,1:size(locs1,2));
          %  pks2=pks2(1,1:size(locs1,2));
        %else
         %   locs1=locs1(1,1:size(locs2,2));
          %  pks1=pks1(1,1:size(locs2,2));
        %end
        %adj=adjcls;
        subplot(2,1,1); plot(adjcls1_row);
        hold on; 
        plot(x(locs1(1,:)),pks1+0.05,'k^','markerfacecolor',[1 0 0]);
        subplot(2,1,2); plot(adjcls2_row);
        hold on; 
        plot(x(locs2(1,:)),pks2+0.05,'k^','markerfacecolor',[1 0 0]);
        if size(locs1)>size(locs2)
        for t=1:size(locs2)
            if abs(locs1(t)-locs2(t))>30 && abs(locs2(t)-locs1(t+1)<30)
                locs1(t)=[];
            end
        end
        else
            if abs(locs1(size(locs1,2))-locs2(size(locs2,2)))>30
                locs2(size(locs2,2))=[];
            end
            if  abs(locs1(1)-locs2(1))>30
                locs2(1)=[];
            end
        end
   end
end

