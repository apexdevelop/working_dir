% clear all;
% cd('C:\Users\ychen\Documents\MATLAB');
% javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar');
% txt=txt2;
% per={'daily','non_trading_weekdays','previous_value'};
% startdate='2017/4/22';
% curr=[];
% field='Last_Price';

function [names, btxt, bbpx]=blp_data(txt,field,startdate,enddate,per,curr)

if ~exist('startdate','var') && exist('window','var')
    %exist('name','kind') if 'kind'='var',returns 1
    startdate = today()-window;
end

% enddate=today();

c=blp;

for loop=1:size(txt,1)
    new=char(txt(loop));
    [d sec] = history(c, new,field,startdate,enddate,per,curr);
%     [d sec] = history(c, new,field,startdate,enddate,per,[]);
    if ~isempty(d)
       btxt(1:size(d,1),loop+1)=d(1:size(d,1),1);
       bbpx(1:size(d,1),loop+1)=d(1:size(d,1),2);
    else
       % not stable, hoping last security has dates and data
       btxt(:,loop+1)=btxt(:,loop);
    end
%     names(loop)=txt(loop);
    names(loop)=sec;
end;
close(c);


   for bbctrstk=1:size(btxt,1)
    btxt(bbctrstk,1)=bbctrstk;
   end


   for bbctrstk2=1:size(bbpx,1)
    bbpx(bbctrstk2,1)=bbctrstk2;
   end
