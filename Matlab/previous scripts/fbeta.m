clear;

load cojapan2;
%%load cojsector;
b=1;
h=size(ticks,1);

clear data;
clear bbpx;
clear btxt;
clear dtxt;
clear px;
clear hkclsus;

s=30;


%startdate=today-800;
enddate=today();
cs=s+round(s/2);
startdate=enddate-cs;

stk=(ticks(1:end,1))';
indxdt= {'NKY Index', 'SPY Equity'};

field='Last_Price';
[txt num]= bbrunA(stk,field,startdate,enddate);
[txt2 num2]= bbrunA(indxdt,field,startdate,enddate);

for d=1:size(num,2)
    rtnres = olsrtn(num(1:30, d), num2(1:30, 1));
    beta(d,1)=rtnres.beta;
    rtnres = olsrtn(num(1:30, d),num2(1:30, 2));
    beta(d,2)=rtnres.beta;
end

save jpbeta