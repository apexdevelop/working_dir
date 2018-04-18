function [names, btxt, bbpx]=blp_event(txt,field,startdate,per)
% clear all;
% cd('C:\Users\ychen\Documents\MATLAB');
% javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.6.1.0\lib\blpapi3.jar');
% txt={'BKCN Index';'TPX Index';'HSI Index'};
% window=1825; 
% per='daily';

if ~exist('startdate','var') && exist('window','var')
    %exist('name','kind') if 'kind'='var',returns 1
    startdate = today()-window;
end


enddate=today();

c=blp;

for loop=1:size(txt,1)
    new=char(txt(loop));
%     [d sec] = history(c, new,'Last_Price',startdate,enddate,[],'USD');
    [d sec] = history(c, new,field,startdate,enddate,per);
    btxt(1:size(d,1),loop+1)=d(1:size(d,1),1);
    bbpx(1:size(d,1),loop+1)=d(1:size(d,1),2);
    names(loop)=sec;
    
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

end