%Post pair identification, Punit Pujara 09/15/03
%file input needs all data filled
clc;
clear u;
u(:,1)=f(:,25);
u(:,1)=f(:,25)
clear stats;
clear coint;
clear uniroot;
clear y;

width=size(u,2);

for j=1:size(u,2)
    for i=2:size(u,1)
        y(i-1,j)=log(u(i,j))-log(u(i-1,j));
    end
end

for i=1:size(y,2)-1
    for d=i:size(y,2)-i
       results=ols(y(1:end,i),y(1:end,d+1));
       stats(i,d,1)=results.beta;
       stats(i,d,2)=results.rsqr;
       stats(i,d,3)=i;
   end   
end
[temp3 temp4]=sort(stats(:,:,2));

break

lg=log(u);   
for i=1:size(lg,2)-1
       results=ols(lg(1:end,i),lg(1:end,i+1));
       
        for d=2:size(results.resid,1)
        temp(d-1,1)=results.resid(d,1)-results.resid(d-1,1);
        temp(d-1,2)=results.resid(d-1,1);
        end
        
       coint=ols(temp(:,1), temp(:,2));
       uniroot(i,1)=coint.beta(1,1);
       uniroot(i,2)=coint.beta(1,1)+2*coint.sige(1,1);
       uniroot(i,3)=coint.beta(1,1)-2*coint.sige(1,1);
       uniroot(i,4)=coint.tstat(1,1);
end
subplot(1,2,1), plot(uniroot(:,4)), subplot(1,2,2), plot(uniroot(:,1))