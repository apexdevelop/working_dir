clear;
clear data;
clear bbpx;
clear btxt;
clear dtxt;
clear px;
clear hkclsus;

t=0;
j=0;

startdate=today-30;
enddate=today();
cs=s+round(s/4);
load cojapan2;

stk=(ticks(1:end,1));

field='Last_Price';

[dtxte pxe]= bbrun(stk,field,startdate,enddate);


