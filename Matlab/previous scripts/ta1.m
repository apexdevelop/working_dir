x=jpychol(1:end,2:5);
clc;

clear win,
clear setup;
clear forecast;

y=log(x);

rday=14;
regday=200;

for i=rday:size(y,1)
    setup(i,1)=y(i,1);
    setup(i+1,2)=max(y(i-rday+1:i,2));
    setup(i+1,3)=min(y(i-rday+1:i,4));
end

setup(:,4)=1;

z(regday,1)=0;


results=ols(setup(1:size(y,1)-regday,1),setup(1:size(y,1)-regday,2:4));
results2=ols(results.resid(2:end)-results.resid(1:end-1),results.resid(1:end-1));

setup(regday,5)=setup(regday,1)+results.resid(end)

for i=regday:size(y,1)

setup(i+1,5)=results.beta(1)*setup(i+1,2)+results.beta(2)*setup(i+1,3)+results.beta(3)*setup(i+1,4)+results2.beta(1)*(setup(i,5)-setup(i,1));


    if setup(i+1,5)-setup(i,1)<0
        if setup(i+1,1)-setup(i,1)<0
        win(i,1)=1;
        else
        win(i,1)=-1;
        end
    end
    

    if setup(i+1,5)-setup(i,1)>0
        if setup(i+1,1)-setup(i,1)>0
        win(i,1)=1;
        else
        win(i,1)=-1;
        end
    end

z(i+1,1)=(setup(i+1,1)-setup(i+1,5))/(results.sige);
setup(i+1,6)=exp(setup(i+1,5))-exp(setup(i+1,1));

end
forecast(:,1)=exp(setup(:,1));
forecast(:,2)=exp(setup(:,5));
forecast(:,3)=forecast(:,2)-forecast(:,1);

plot(forecast(:,1:2))