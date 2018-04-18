clearvars;
% cd('C:\Users\ychen\Documents\MATLAB');
javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar')

%% generate Data
txt1={'AWC AU Equity';'2600 HK Equity'};
startdate='2011/12/22';
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


t1=fints(c_dates1,prices(:,1),'t1');
t2=fints(c_dates2,prices(:,2),'t2');
newfts=merge(t1,t2,'DateSetMethod','Intersection');

accts=tsaccel(newfts);

%If you want to include the dates in the output matrix, provide a second input argument and set it to 1. This results in a matrix whose first column is a vector of serial date numbers:
% new_t1=fts2mat(newfts.t1,1);
% new_t2=fts2mat(newfts.t2,1);
% excel_date=m2xdate(new_t1(:,1));
% 
% t1_rtn=fints(c_dates1,rtns(:,1),'t1_rtn');
% t2_rtn=fints(c_dates2,rtns(:,2),'t2_rtn');
% newfts_rtn=merge(t1_rtn,t2_rtn,'DateSetMethod','Intersection');
% 
% new_t1_rtn=fts2mat(newfts_rtn.t1_rtn,1);
% new_t2_rtn=fts2mat(newfts_rtn.t2_rtn,1);
% excel_date_rtn=m2xdate(new_t1_rtn(:,1));