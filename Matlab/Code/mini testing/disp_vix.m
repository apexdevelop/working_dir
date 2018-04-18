clearvars;
cd('C:/Users/ychen/Documents/git/working_dir/matlab/data/dispersion');
[excel_date,~]=xlsread('dispersion_matlab_v2.xls','oex_disp','a2:a1288');
[oex_disp,~]=xlsread('dispersion_matlab_v2.xls','oex_disp','b2:b1288');

matlab_date=x2mdate(excel_date);
c_dates1=cellstr(datestr(matlab_date));
%% generate Data
javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar')
txt1={'VIX Index'};
startdate='2012/10/4';
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
nob_vix=size(prices,1);

z_window=60;
z_vix=zeros(nob_vix,1);
z_vix(1:z_window-1)=zscore(prices(1:z_window-1));
for j=z_window:nob_vix
        tempz=zscore(prices(j-z_window+1:j,1));
        z_vix(j)=tempz(end);
end
c_dates2=cellstr(datestr(dates));


t1=fints(c_dates1,oex_disp,'t1');
t2=fints(c_dates2,z_vix,'t2');
newfts=merge(t1,t2,'DateSetMethod','Intersection');

accts=tsaccel(newfts);

%If you want to include the dates in the output matrix, provide a second input argument and set it to 1. This results in a matrix whose first column is a vector of serial date numbers:
new_t1=fts2mat(newfts.t1,1);
new_t2=fts2mat(newfts.t2,1);
new_excel_date=m2xdate(new_t1(:,1));
% 
% t1_rtn=fints(c_dates1,rtns(:,1),'t1_rtn');
% t2_rtn=fints(c_dates2,rtns(:,2),'t2_rtn');
% newfts_rtn=merge(t1_rtn,t2_rtn,'DateSetMethod','Intersection');
% 
% new_t1_rtn=fts2mat(newfts_rtn.t1_rtn,1);
% new_t2_rtn=fts2mat(newfts_rtn.t2_rtn,1);
% excel_date_rtn=m2xdate(new_t1_rtn(:,1));