function [names, btxt, bbpx]=blp_txt(file,window)
cd('C:\Users\ychen\Documents\MATLAB');


enddate=today();
startdate=enddate-window;

fileID=fopen(file,'r');
T=textscan(fileID,'%s','Delimiter','\n');
txt=T{1,1};

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