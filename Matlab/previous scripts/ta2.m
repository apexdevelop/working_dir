x=jpychol(1000:1300,2:5);
clc;
clear rtn;

clear win,
clear setup;
clear forecast;
clear rtn;

y=log(x);

rday=14;
regday=250;
deviate=2;

setup(rday,1)=y(rday,1);
setup(rday,2)=max(y(1:rday,2));
setup(rday,3)=min(y(1:rday,4));

for i=rday+1:size(y,1)-1
    setup(i,1)=y(i,1);
    setup(i,2)=max(y(i-rday+1:i,2));
    setup(i,3)=min(y(i-rday+1:i,4));
    rtn(i,1)=setup(i,1)-setup(i-1,1);
    rtn(i,2)=setup(i,2)-setup(i-1,2);
    rtn(i,3)=setup(i,3)-setup(i-1,3);
end

rtn(1,5)=999;
setup(:,4)=1;
rtn(:,4)=1;

z(regday,1)=0;

results=ols(setup(1:size(y,1)-regday-1,1),setup(1:size(y,1)-regday-1,2:4));
results2=ols(results.resid(2:end)-results.resid(1:end-1),results.resid(1:end-1));


%if abs(results2.tstat)<3
%    break
%end    


forecast(regday,1)=exp(setup(regday,1));
forecast(regday,2)=exp(setup(regday,1));

for i=regday:size(rtn,1)-1
    
    
clear mult

results=ols(setup(i-regday+1:i,1),setup(i-regday+1:i,2:4));
results2=ols(results.resid(2:end)-results.resid(1:end-1),results.resid(1:end-1));

mult(:,1:3)=rtn(i-regday+1:i,2:4);
mult(:,4)=results.resid;

results3=ols(rtn(i-regday+2:i+1,1),mult(:,1:4));

%estimation equation
%projected change in Y is equal to whatever
%rtn(i+1,5)=results3.beta(1)*rtn(i,2)+results3.beta(2)*rtn(i,3)+results3.beta(3)*rtn(i,4)+results3.beta(4)*mult(end,4);
rtn(i+1,5)=(results.beta(1))*rtn(i,2)+(results.beta(2))*rtn(i,3)+(results.beta(3))*rtn(i,4)+(results2.beta)*mult(end,4);
forecast(i+1,1)=forecast(i,1)*(1+rtn(i+1,1));
forecast(i+1,2)=forecast(i,2)*(1+rtn(i+1,5));
zscore=sqrt(results.sige);

%forecast(i+1,3)=forecast(i,2)*(1+rtn(i+1,5)+deviate*zscore);
%forecast(i+1,4)=forecast(i,2)*(1+rtn(i+1,5)-deviate*zscore);

betainfo(i+1,1)=results2.beta;
betainfo(i+1,2)=results2.tstat;
betainfo(i+1,3)=results3.rsqr;
betainfo(i+1,4)=results3.beta(4);
betainfo(i+1,5)=results3.tstat(4);
end


for i=regday+1:size(rtn,1)
    if rtn(i,5)<0  
        if rtn(i,1)<0
        win(i,1)=1;
        else
        win(i,1)=-1;
        end
    end
    if rtn(i,5)>0  
        if rtn(i,1)>0
        win(i,1)=1;
        else
        win(i,1)=-1;
        end
    end
    
end

plot(forecast(regday+1:end,:))
figure(2)
plot(betainfo(regday+1:end,3))