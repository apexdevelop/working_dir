function [names, btxt, bbpx]=blp_fix_relative(txt,cell_char,cell_num)
% clear all;
% cd('C:\Users\ychen\Documents\MATLAB');
% javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.6.1.0\lib\blpapi3.jar');
% txt={'BKCN Index';'TPX Index';'HSI Index'};
% cell_char={'rel';'01/04/2009';'daily'}; % parameter {fix or rel;startdate;per}
% cell_num={1825}; % parameter {window}

enddate=today();
per=char(cell_char(3));
idx=char(cell_char(1));

if strcmp('rel',idx)==1
    startdate=enddate-cell2mat(cell_num);
elseif strcmp('fix',idx)==1
    startdate=char(cell_char(2));
end

c=blp;

for loop=1:length(txt)
    new=char(txt(loop));
%     [d sec] = history(c, new,'Last_Price',startdate,enddate,[],'USD');
    [d sec] = history(c, new,'Last_Price',startdate,enddate,per);
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
