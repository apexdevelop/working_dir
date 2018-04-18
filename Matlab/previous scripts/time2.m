% get data
inxdt={'HSCEI Index'};
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
rtn(1,4)=0;
minexp=0;
maxexp=50;
stpexp=5;


for z=2:size(rtn,1)
if rtn(z-1,1)>0.5 && rtn(z-1,1)<1 rtn(z,2)=min(max(minexp,rtn(z-1,2)-stpexp),maxexp); 
elseif rtn(z-1,1)>1 && rtn(z-1,1)<2.5 rtn(z,2)=min(max(minexp,rtn(z-1,2)-stpexp*1.5),maxexp); 
elseif rtn(z-1,1)>2.5 rtn(z,2)=min(max(minexp,rtn(z-1,2)-stpexp*2),maxexp);     
    
elseif rtn(z-1,1)<-0.5 && rtn(z-1,1)>-1 rtn(z,2)=min(max(minexp,rtn(z-1,2)+stpexp),maxexp); 
elseif rtn(z-1,1)<-1 && rtn(z-1,1)>-2.5 rtn(z,2)=min(max(minexp,rtn(z-1,2)+stpexp*1.5),maxexp); 
elseif rtn(z-1,1)<-2.5 rtn(z,2)=min(max(minexp,rtn(z-1,2)+stpexp*2),maxexp);
    
else rtn(z,2)= min(max(minexp,rtn(z-1,2)),maxexp);
end

  %  for z=2:size(rtn,1)
  % if rtn(z-1,1)>0.5 && rtn(z-1,1)<1 rtn(z,2)=min(max(minexp,rtn(z-1,2)+stpexp),maxexp); 
  %  elseif rtn(z-1,1)>1 && rtn(z-1,1)<2.5 rtn(z,2)=min(max(minexp,rtn(z-1,2)+stpexp*1.5),maxexp); 
  %  elseif rtn(z-1,1)>2.5 rtn(z,2)=min(max(minexp,rtn(z-1,2)+stpexp*2),maxexp);     

  %  elseif rtn(z-1,1)<-0.5 && rtn(z-1,1)>-1 rtn(z,2)=min(max(minexp,rtn(z-1,2)-stpexp),maxexp); 
  %  elseif rtn(z-1,1)<-1 && rtn(z-1,1)>-2.5 rtn(z,2)=min(max(minexp,rtn(z-1,2)-stpexp*1.5),maxexp); 
  %  elseif rtn(z-1,1)<-2.5 rtn(z,2)=min(max(minexp,rtn(z-1,2)-stpexp*2),maxexp);

  %  else rtn(z,2)= min(max(minexp,rtn(z-1,2)),maxexp);
  %  end


rtn(z,3)=rtn(z,2)*rtn(z,1)/100;
rtn(z,4)=rtn(z-1,4)+rtn(z,3);
end

totrtn=sum(rtn);
subplot(3,1,1); plot(rtn(:,2))
subplot(3,1,3); plot(rtn(:,4))
subplot(3,1,2); plot(adjcls)
% summary stats