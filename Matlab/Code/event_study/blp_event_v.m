function [btxt,bbpx]=blp_event_v(file,sheet,range,field,window,f_add,f_type)
cd('C:\Documents and Settings\YChen\My Documents');
clear d;
clear bbpx;
clear btxt;
clear dtxt;
clear px;
clear c;
clear sec;

enddate=today();
%startdate=today()-window;
startdate='2008/01/01';
[num,txt]=xlsread(file,sheet,range);
% [num,txt]=xlsread('input_ticker','apex','a1');

% GET DATA
c=blp;

if f_add==1
      new=char(txt(1));
elseif f_add==0
    new=[char(txt(1)),' Equity'];
end


if f_type==1
    [d sec] = history(c,new,field,startdate,enddate,' o'); % what does ' o' mean?
elseif f_type==0
    [d sec] = history(c,new,field,startdate,enddate);  %
end
    btxt(1:size(d,1),2)=d(1:size(d,1),1);
    bbpx(1:size(d,1),2)=d(1:size(d,1),2);
    
close(c);
n_time=0;
for n_time=1:size(btxt,1)
    btxt(n_time,1)=n_time;
end

n_stk=0;
for n_stk=1:size(bbpx,1)
    bbpx(n_stk,1)=n_stk;
end

dtxt=sortrows(btxt,-1);
px=sortrows(bbpx,-1);
end