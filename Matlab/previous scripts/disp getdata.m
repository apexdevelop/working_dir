%% Get data
clear;

load chfin
%%load coch1;
%%load cojapan3;
%%load cona1;
%%load cojsector;
%%load coindia;


b=1;
h=size(ticks,1);

clear data;
clear bbpx;
clear btxt;
clear dtxt;
clear px;
clear hkclsus;
%% S is number of days 
s=200;
volterm=30;

%startdate=today-800;
enddate=today();
cs=s+round(s/2);
startdate=enddate-cs;

stk=(ticks(b:h,1))';

field='Last_Price';

[txt num]= bbrun(stk,field,startdate,enddate);

save codata