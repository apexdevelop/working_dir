%C:\Documents and Settings\nthakkar.AC\My Documents\MATLAB\bbtictest.m


%1. Bloomberg Connection to MATLAB
  % A. Use c=bloomberg.


clear data;
clear bbpx;
clear btxt;
clear dtxt;
clear px;

startdate=today-800;
enddate=today();
stocks = {'8306 JP Equity','8411 JP Equity'} %, '8411 JP Equity','8316 JP Equity','8591 JP Equity'}

% GET DATA
c = bloomberg(8194);%,'172.16.1.92')

for loop=1:size(stocks,2)
    data = fetch(c, stocks(loop), 'HISTORY', 'Last_Price',startdate,enddate)
    btxt(1:size(data,1),loop+1)=data(1:size(data,1),1);
    bbpx(1:size(data,1),loop+1)=data(1:size(data,1),2);
    
end;
close(c);
bbctrstk=0;
for bbctrstk=1:size(btxt,1)
    btxt(bbctrstk,1)=bbctrstk;
end
bbctrstk2=0;
for bbctrstk2=1:size(bbpx,1)
    bbpx(bbctrstk2,1)=bbctrstk2;
end

dtxt=sortrows(btxt,-1);
px=sortrows(bbpx,-1);