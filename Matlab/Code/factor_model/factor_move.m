% how about calculating longterm correlation to decide negative or positive
% correlation
clear all;
cd('C:\Users\ychen\Documents\MATLAB');
javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar')
% shipping,utility,steel,coal,display,solar,bond,aluminum,exports,hitachi
shname='shipping';
[~,txt]=xlsread('factors.xlsx',shname,'a1:a39'); %factor

%% generate Data
startdate='2012/3/12';
enddate=today();
per={'daily','non_trading_weekdays','previous_value'};

c=blp;
for loop=1:size(txt,1)
        new=char(txt(loop));
        [d1, sec] = history(c, new,'CHG_PCT_1D',startdate,enddate,per);
        [d2, sec] = history(c, new,'Last_Price',startdate,enddate,per);
        [d3, sec] = history(c, new,'CHG_PCT_5D',startdate,enddate,per);
        fdates(1:size(d1,1),loop)=d1(1:size(d1,1),1);
        rtns_1d(1:size(d1,1),loop)=d1(1:size(d1,1),2);
        fprices(1:size(d2,1),loop)=d2(1:size(d2,1),2);
        rtns_5d(1:size(d3,1),loop)=d3(1:size(d3,1),2);
end;
close(c);

%% Initialize parameters
M=225;
N=20;
Metrics=[];

for n=1:size(txt,1) %factor
    tday=fdates(:, n); 
    rtn_1d=rtns_1d(:,n);
    px=fprices(:, n);
    rtn_5d=rtns_5d(:,n);
    
    tday(isnan(px))=[];
    rtn_1d(isnan(px))=[];
    rtn_5d(isnan(px))=[];
    px(isnan(px))=[];
    
    px(find(~tday))=[];
    rtn_1d(find(~tday))=[];
    rtn_5d(find(~tday))=[];
    tday(find(~tday))=[];
    
    
    zpx=zeros(size(px,1),1);
    zpx(1:M-1)=zscore(px(1:M-1));
    for i=M : size(px,1)
        temp_zpx=zscore(px(i-M+1:i,1));
        zpx(i,1)=temp_zpx(end);
    end
    
    z1d=zeros(size(rtn_1d,1),1);
    z1d(1:M-1)=zscore(rtn_1d(1:M-1));
    for i=M : size(rtn_1d,1)
        temp_z1d=zscore(rtn_1d(i-M+1:i,1));
        z1d(i,1)=temp_z1d(end);
    end
    
    z5d=zeros(size(rtn_5d,1),1);
    z5d(1:M-1)=zscore(rtn_5d(1:M-1));
    for i=M : size(rtn_5d,1)
        temp_z5d=zscore(rtn_5d(i-M+1:i,1));
        z5d(i,1)=temp_z5d(end);
    end
    
    rtn_1m=zeros(size(rtn_1d,1)-21,1);
    for i=22 : size(rtn_1d,1)
        rtn_1m(i-21,1)=sum(rtn_1d(i-21:i));
    end

    z1m=zeros(size(rtn_1m,1),1);
    z1m(1:M-1)=zscore(rtn_1m(1:M-1));
    for i=M : size(rtn_1m,1)
        temp_z1m=zscore(rtn_1m(i-M+1:i,1));
        z1m(i,1)=temp_z1m(end);
    end    
    
    new_metric=[rtn_1d(end) z1d(end) rtn_5d(end) z5d(end) rtn_1m(end) z1m(end) zpx(end)];
    Metrics=[Metrics;new_metric];    
end

