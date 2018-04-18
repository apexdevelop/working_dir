%% Get data
clear;

load apexuni 
%%
%%chfin, topix30 
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
s=750;
volterm=60;

%startdate=today-800;
enddate=today();
cs=s+round(s/2);
startdate=enddate-cs;

stk=(ticks(b:h,1))';

field='Last_Price';

[txt num]= bbrun(stk,field,startdate,enddate);

save codata