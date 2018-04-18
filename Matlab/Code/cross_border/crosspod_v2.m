% Yan 2013 Feb 21 try to find auto correlation in pod.
% has been normolized
% reference: tsdateinterval timeseries tsdemo

clearvars;
cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data');
filename='pod_universe.xlsx';
shname='Universe';
[~,txt1]=xlsread(filename,shname,'a2:a63'); %ADR stock
[~,txt2]=xlsread(filename,shname,'b2:b63'); %Local stock
[~,txt3]=xlsread(filename,shname,'e2:e63'); %ADR Bench
[~,txt4]=xlsread(filename,shname,'f2:f63'); %Local Bench
[~,txt5]=xlsread(filename,shname,'d2:d63'); %Currency
[adr_ratio,]=xlsread(filename,shname,'c2:c63'); %adr ratio

npair=size(txt1,1);
c_repod=cell(npair,1);
c_movpod=cell(npair,1);
c_anbpx=cell(npair,1);
c_onbpx=cell(npair,1);
c_date=cell(npair,1);

window=365; %window is all the calendar days
mov_window=5;%number of days used to conduct the moving average
% txt1={'HSI Index';'914 HK Equity'};
% txt2={'SHASHR Index';'600585 CH Equity'};
% txt3={'CNY Curncy';'HKD Curncy'};
fields={'last_price','volume_avg_30d'};

% function [A Am B Bm C Cm]=crosspod(window,lookback,txt1,txt2,txt3,txt4,fields)

javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');
enddate=today();
startdate=enddate-window;
per='daily';

% fields(1) is last price, fields(2) is volume_avg_30d
[~, ats, apxs]=blp_data(txt1,fields(1),startdate,enddate,per,[]);
[~, ots, opxs]=blp_data(txt2,fields(1),startdate,enddate,per,[]);
[~, abts, abpxs]=blp_data(txt3,fields(1),startdate,enddate,per,[]);
[~, obts, obpxs]=blp_data(txt4,fields(1),startdate,enddate,per,[]);
[~, cts, cpxs]=blp_data(txt5,fields(1),startdate,enddate,per,[]);

%align data
for i=1:npair
    c_dates1=cellstr(datestr(ats(:,i+1)));
    c_dates2=cellstr(datestr(ots(:,i+1)));
    c_dates3=cellstr(datestr(abts(:,i+1)));
    c_dates4=cellstr(datestr(obts(:,i+1)));
    c_dates5=cellstr(datestr(cts(:,i+1)));
    
    t1=fints(c_dates1,apxs(:,i+1),'t1');
    t2=fints(c_dates2,opxs(:,i+1),'t2');
    t3=fints(c_dates3,abpxs(:,i+1),'t3');
    t4=fints(c_dates4,obpxs(:,i+1),'t4');
    t5=fints(c_dates5,cpxs(:,i+1),'t5');
    newfts=merge(t1,t2,t3,t4,t5,'DateSetMethod','Intersection');
    adatenpx=fts2mat(newfts.t1,1);
    tday=adatenpx(:,1);
    apx=adatenpx(:,2);
    opx=fts2mat(newfts.t2);
    abpx=fts2mat(newfts.t3);
    obpx=fts2mat(newfts.t4);
    cpx=fts2mat(newfts.t5);
    c_date{i,1}=tday;
    c_anbpx{i,1}=[apx abpx];
    c_onbpx{i,1}=[opx obpx];
    
    bpod=abpx./obpx;
    stockpod=(apx.*cpx)./(opx*adr_ratio(i));
    repod=stockpod./bpod;
    c_repod{i,1}=repod;
    
    %calculate 5d_moving average
    repod_row=reshape(repod,1,size(repod,1));
    repod_row=tsmovavg(repod_row,'e',mov_window);
    repod_row=[reshape(repod(1:(mov_window-1)),1,(mov_window-1)) repod_row(mov_window:end)];
    repod_mov=reshape(repod_row,size(repod_row,2),1);
    c_movpod{i,1}=repod_mov;
end
% ex_tday=m2xdate(tday,0);
cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/ML');
save (strcat('c_repod', '_autocorr_',datestr(enddate)), 'c_repod');
save (strcat('c_movpod', '_autocorr_',datestr(enddate)), 'c_movpod');
save (strcat('c_anbpx', '_autocorr_',datestr(enddate)), 'c_anbpx');
save (strcat('c_onbpx', '_autocorr_',datestr(enddate)), 'c_onbpx');
save (strcat('c_date', '_autocorr_',datestr(enddate)), 'c_date');


