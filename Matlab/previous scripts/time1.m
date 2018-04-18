% get data
inxdt={'SPY Equity'};
field='Last_Price';
cs=240;
[dtxt px]= bbrun(inxdt,field,cs);

field='Px_Open';
[dtxtop pxop]= bbrun(inxdt,field,cs);

tday=union(dtxt,dtxt);
[foo idx idx1]=intersect(tday, dtxt);
adjcls(idx1, 1)=px(idx);

upday=0;
uprtn=0;
for z=1:size(px,1)-1
rtn(z,1)=(adjcls(z+1,1)/adjcls(z,1)-1)*100;
if rtn(z,1)> 0, upday=upday+1; uprtn=uprtn+rtn(z,1); end 
end


rtn(1,2)=0;
minexp=0;
stpexp=5;




for z=2:size(rtn,1)-1
if rtn(z-1,1)>0 rtn(z,2)=max(minexp,rtn(z-1,2)+stpexp); 
elseif rtn(z-1,1)<0 rtn(z,2)=max(minexp,rtn(z-1,2)-stpexp); 
else rtn(z,2)= max(minexp,rtn(z-1,2));
end

rtn(z,3)=rtn(z,2)*rtn(z,1)/100;
end

totrtn=sum(rtn);

% summary stats