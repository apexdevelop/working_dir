% clear all;
% cd('C:\Users\ychen\Documents\MATLAB');
% javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar');
% % txt={'BKCN Index';'TPX Index';'HSI Index'};
% txt={'MXJP0CD Index'};
% 
% window=1825; 
% per='daily';

function [names, btxt, bbpx]=blp_test(txt,startdate,per)

if ~exist('startdate','var') && exist('window','var')
    %exist('name','kind') if 'kind'='var',returns 1
    startdate = today()-window;
end


enddate=today();

c=blp;

for loop=1:size(txt,1)
    new=char(txt(loop));
    [d sec] = history(c, new,'Last_Price',startdate,enddate,per,'USD');
%     [d, sec] = history(c, new,'Last_Price',startdate,enddate,per,[]);
    btxt(1:size(d,1),loop+1)=d(1:size(d,1),1);
    bbpx(1:size(d,1),loop+1)=d(1:size(d,1),2);
    names(loop)=sec;
    
end;
close(c);

for bbctrstk=1:size(btxt,1)
    btxt(bbctrstk,1)=bbctrstk;
end

for bbctrstk2=1:size(bbpx,1)
    bbpx(bbctrstk2,1)=bbctrstk2;
end