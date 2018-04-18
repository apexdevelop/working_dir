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
for n=1:1
    new_stk1=repmat(txt(n),1,n_stock-n);
    stk1=[stk1 new_stk1];
    for m=(n+1):2
    stk2=[stk2 txt(m)];
    end
end

for n=1:1
    tday1=dtxt(:, n+1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
    adjcls1=px(:, n+1); %ppp the last column contains the adjusted close prices.
    
    for m=(n+1):2
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
    end
end
        x=1:s;
        trend1 = sign(diff(adjcls1_row));
idxp1 = find(trend1==0); % Find flats
N1 = length(trend1);
for i=length(idxp1):-1:1,
    % Back-propagate trend for flats
    if trend1(min(idxp1(i)+1,N1))>=0,
        trend1(idxp1(i)) = 1; 
    else
        trend1(idxp1(i)) = -1; % Flat peak
    end
end
        
loc1  = find(diff(trend1)==-2)+1;  % Get all the peaks
%loc1 = intersect(Indx,idxp1);      % Keep peaks above MinPeakHeight
pk1  = adjcls1_row(loc1);

        trend2 = sign(diff(adjcls2_row));
idxp2 = find(trend2==0); % Find flats
N2 = length(trend2);
for i=length(idxp2):-1:1,
    % Back-propagate trend for flats
    if trend2(min(idxp2(i)+1,N2))>=0,
        trend2(idxp2(i)) = 1; 
    else
        trend2(idxp2(i)) = -1; % Flat peak
    end
end
        
loc2  = find(diff(trend2)==-2)+1;  % Get all the peaks
%loc2 = intersect(Indx,idxp2);      % Keep peaks above MinPeakHeight
pk2 = adjcls2_row(loc2);


%--------------------------------------------------------------------------
Pd=30;
Ph=0.3;
% Start with the larger peaks to make sure we don't accidentally keep a
% small peak and remove a large peak in its neighborhood. 

if isempty(pk1) || Pd==1,
    return
end

% Order peaks from large to small
[pks1, idxs1] = sort(pk1,'descend');
locs1 = loc1(idxs1);

idelete1 = ones(size(locs1))<0;
for i = 1:length(locs1),
    if ~idelete1(i),
        % If the peak is not in the neighborhood of a larger peak, find
        % secondary peaks to eliminate.
        
        idelete1 = idelete1 | (locs1>=locs1(i)-Pd)&(locs1<=locs1(i)+Pd)&(pks1>=pks1(i)-Ph)&(pks1<=pks1(i)+Ph); 
        idelete1(i) = 0; % Keep current peak
    end
end
pksd1=pks1;
pksd1(idelete1) = [];
locsd1=locs1;
locsd1(idelete1) = [];

%--------------------------------------------------------------------------


%--------------------------------------------------------------------------

% Start with the larger peaks to make sure we don't accidentally keep a
% small peak and remove a large peak in its neighborhood. 

if isempty(pk2) || Pd==1,
    return
end

% Order peaks from large to small
[pks2, idxs2] = sort(pk2,'descend');
locs2 = loc2(idxs2);

idelete2 = ones(size(locs2))<0;
for i = 1:length(locs2),
    if ~idelete2(i),
        % If the peak is not in the neighborhood of a larger peak, find
        % secondary peaks to eliminate.
        idelete2 = idelete2 | (locs2>=locs2(i)-Pd)&(locs2<=locs2(i)+Pd)&(pks2>=pks2(i)-Ph)&(pks2<=pks2(i)+Ph); 
        idelete2(i) = 0; % Keep current peak
    end
end
pksd2=pks2;
pksd2(idelete2) = [];
locsd2=locs2;
locsd2(idelete2) = [];

%--------------------------------------------------------------------------


        subplot(2,1,1); plot(adjcls1_row);
        hold on; 
        plot(x(locsd1(1,:)),pksd1+0.05,'k^','markerfacecolor',[1 0 0]);
        subplot(2,1,2); plot(adjcls2_row);
        hold on; 
        plot(x(locsd2(1,:)),pksd2+0.05,'k^','markerfacecolor',[1 0 0]);   
           
           
        %sumlag=[corre avg_lag stand];        
        %count=count+1;
        %metrics(count,:)=sumlag;

%new_stk1=reshape(stk1,n_stock*(n_stock-1)/2+1,1);
%new_stk2=reshape(stk2,n_stock*(n_stock-1)/2+1,1);
%stand_col=reshape(stand,n_stock*(n_stock-1)/2,1);
%stand_col=abs(stand_col);
%xlswrite('lag',new_stk1,'sheet4','b1');
%xlswrite('lag',new_stk2,'sheet4','c1');
%xlswrite('lag',metrics,'sheet4','d2');