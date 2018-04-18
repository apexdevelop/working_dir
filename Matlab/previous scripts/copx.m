clear;
load bafuniv;

b=1;
h=size(ticks,1);

clear data;
clear bbpx;
clear btxt;
clear dtxt;
clear px;
clear hkclsus;

s=500;


%startdate=today-800;
enddate=today();
cs=s+round(s/2);
startdate=enddate-cs;

stk=(ticks(b:h,1))';

field='Last_Price';

[txt num]= bbrun(stk,field,startdate,enddate);

save codata