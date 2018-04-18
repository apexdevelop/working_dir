        trend1 = sign(diff(adjcls1_row));
idx1 = find(trend1==0); % Find flats
N1 = length(trend1);
for i=length(idx1):-1:1,
    % Back-propagate trend for flats
    if trend1(min(idx1(i)+1,N1))>=0,
        trend1(idx1(i)) = 1; 
    else
        trend1(idx1(i)) = -1; % Flat peak
    end
end
        
locs1  = find(diff(trend1)==-2)+1;  % Get all the peaks
pks1  = adjcls1_row(locs1);
        
        trend2 = sign(diff(adjcls2_row));
idx2 = find(trend2==0); % Find flats
N2 = length(trend2);
for i=length(idx2):-1:1,
    % Back-propagate trend for flats
    if trend2(min(idx2(i)+1,N2))>=0,
        trend2(idx2(i)) = 1; 
    else
        trend2(idx2(i)) = -1; % Flat peak
    end
end
        
locs2  = find(diff(trend2)==-2)+1;  % Get all the peaks
pks2  = adjcls2_row(locs2);    