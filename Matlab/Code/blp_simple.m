function [names, btxt, bbpx]=blp_simple(file,sheet,range,window)
cd('C:\Users\ychen\Documents\MATLAB');
% clear d;
% clear bbpx;
% clear btxt;
% clear dtxt;
% clear px;


% enddate='2013/06/11';
% startdate='2011/06/11';
enddate=today();
startdate=enddate-window;

[~,txt]=xlsread(file,sheet,range);



% GET DATA
c=blp;
for loop=1:size(txt,1)
    new=char(txt(loop));
    %names=[names new];
    [d sec] = history(c, new,'Last_Price',startdate,enddate,[],'USD');
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

dtxt=sortrows(btxt,-1);
px=sortrows(bbpx,-1);
end