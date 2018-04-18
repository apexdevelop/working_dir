function [btxt,bbpx,names]=importdata(file,sheet,range,field,window,f_type)

%  f_type = 1  Curncy
%         = 2  ADR
%         = 3  Local Ticker
%         = 4  Shares per adr

enddate=today();
startdate=enddate-window;

% [num,txt]=xlsread('input_ticker','curncy','a1:a5');

[num,txt]=xlsread(file,sheet,range);

% GET DATA
c=blp;


for loop=1:size(txt,1)
    if f_type==1
        new=[char(txt(loop)),' Curncy'];
    elseif f_type==2
        new=[char(txt(loop)),' Equity'];
    else
        new=char(txt(loop));
    end
    [d, sec] = history(c,new,field,startdate,enddate);
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
bbctrstk3=0;
% for bbctrstk3=1:size(names,2)
%     names(2,bbctrstk3)=bbctrstk3;
% end
dtxt=sortrows(btxt,-1);
px=sortrows(bbpx,-1);
end