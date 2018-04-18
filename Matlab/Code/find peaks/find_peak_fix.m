cd('C:\Documents and Settings\nthakkar.AC\My Documents');

[num1,txt1]=xlsread('input_ticker','9104 jp');
[num2,txt2]=xlsread('input_ticker','9101 jp');

s1=size(txt1,1);  
tday1=txt1(2:s1, 1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
adjcls1=num1(1:(s1-1), 2); %ppp the last column contains the adjusted close prices.

tday1=datestr(datenum(tday1, 'mm/dd/yyyy'), 'yyyymmdd'); % convert the format into yyyymmdd.
tday1=str2double(cellstr(tday1)); % convert the date strings first into cell arrays and then into numeric format.

s2=size(txt2,1); 
tday2=txt2(2:s2, 1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
adjcls2=num2(1:(s2-1), 2); % PPP

tday2=datestr(datenum(tday2, 'mm/dd/yyyy'), 'yyyymmdd'); % convert the format into yyyymmdd.
tday2=str2double(cellstr(tday2)); % convert the date strings first into cell arrays and then into numeric format.


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

%xlswrite('coint_result',new_stk1,'jan11_apex','b1');
%xlswrite('coint_result',new_stk2,'jan11_apex','c1');
%xlswrite('coint_result',metrics,'jan11_apex','d2');
