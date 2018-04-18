clear all;
cd('C:\Users\ychen\Documents\MATLAB');
javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar')

%% generate Data
txt1={'6502 JP Equity';'105560 KS Equity';'2628 HK Equity';'2409 TT Equity'};
startdate='2012/11/14';
per={'daily','non_trading_weekdays','previous_value'};
enddate=today();
c=blp;
    for loop=1:size(txt1,1)
        new=char(txt1(loop));
        [d1, sec1] = history(c, new,'CHG_PCT_1D',startdate,enddate,per);
        [d2, sec2] = history(c, new,'Last_Price',startdate,enddate,per);
        dates(1:size(d1,1),loop)=d1(1:size(d1,1),1);
        rtns(1:size(d1,1),loop)=d1(1:size(d1,1),2);
        prices(1:size(d2,1),loop)=d2(1:size(d2,1),2);
        
    end;
close(c);
n_dim=size(rtns,2);

c_dates1=cellstr(datestr(dates(:,1)));
c_dates2=cellstr(datestr(dates(:,2)));
c_dates3=cellstr(datestr(dates(:,3)));
c_dates4=cellstr(datestr(dates(:,4)));

t1=fints(c_dates1,prices(:,1),'t1');
t2=fints(c_dates2,prices(:,2),'t2');
t3=fints(c_dates3,prices(:,3),'t3');
t4=fints(c_dates4,prices(:,4),'t4');

newfts=merge(t1,t2,t3,t4,'DateSetMethod','Intersection');

%If you want to include the dates in the output matrix, provide a second input argument and set it to 1. This results in a matrix whose first column is a vector of serial date numbers:
new_t1=fts2mat(newfts.t1,1);
