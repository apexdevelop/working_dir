% Yan 2013 Feb 21 try to find auto correlation in pod.
% has been normolized
% reference: tsdateinterval timeseries tsdemo

clearvars;
cd('Y:/working_directory/Matlab/Data');
filename='pod_universe.xlsx';
shname='Univese';
[~,txt1]=xlsread(filename,shname,'a2:a63'); %ADR stock
[~,txt2]=xlsread(filename,shname,'b2:b63'); %Local stock
[~,txt3]=xlsread(filename,shname,'e2:e63'); %ADR Bench
[~,txt4]=xlsread(filename,shname,'f2:f63'); %Local Bench
[~,txt5]=xlsread(filename,shname,'d2:d63'); %Currency

window=365; %window is all the calendar days
lookback=10;%number of days used to conduct the moving average
% txt1={'HSI Index';'914 HK Equity'};
% txt2={'SHASHR Index';'600585 CH Equity'};
% txt3={'CNY Curncy';'HKD Curncy'};
% fields={'last_price','volume_avg_30d'};

% function [A Am B Bm C Cm]=crosspod(window,lookback,txt1,txt2,txt3,txt4,fields)

javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');
startdate=today()-window;
per='daily';
enddate=today();
% fields(1) is last price, fields(2) is volume_avg_30d
% import H-share price data(including benchmark come first)
[~, ht, hpx]=blp_data(txt1,fields(1),startdate,enddate,per,[]);
% import A-share price data(including benchmark come first)
[~, at, apx]=blp_data(txt2,fields(1),startdate,enddate,per,[]);
%import currency data
[~, ct, cpx]=blp_data(txt3,fields(1),startdate,enddate,per,[]);


% define the weight array
w=[];
theta=0.96;
for e=lookback:-1:1
    neww=theta^e;
    w=[w; neww];    
end
w=w/sum(w);


%intersect H-share market index date A-share market index
hbt=ht(:, 2); 
hbpx=hpx(:, 2);
hbt(find(~hbt))=[];
hbpx(find(~hbpx))=[];
    
abt=at(:, 2); 
abpx=apx(:, 2);
abt(find(~abt))=[];
abpx(find(~abpx))=[];
    
[hna, idh, ida]=intersect(hbt, abt); 
   
tday=m2xdate(abt(ida),0);
Y=zeros(size(hna,1),2);
Y(:,1)=hbpx(idh);%H-index
Y(:,2)=abpx(ida);%A-index
bpod=Y(:,1)./Y(:,2); % H/A market Pod


for i=2:size(txt1,1)
    hpx1=hpx(idh,i+1);%H-share
    apx1=apx(ida,i+1);%A-share
%     finalapx=newapx.*newcpx/spa(i,1);  %adjust for foreign currency and adr ratio
    pod=hpx1./apx1; % H/A Pod before removing market impact
    %empod is ma of relative pod
    empod=[];
    for n=1:size(pod,1)-lookback+1       
        new_empod=sum(pod(n:n+lookback-1).*w); 
        empod=[empod;new_empod];
    end
    %normalize
    empod_n=(empod-mean(empod))/std(empod);
    empod_n=reshape(empod_n,1,size(empod_n,1));
    expod=[zeros(1,lookback-1) empod_n]; %change the display format,remove the percent
    colpod=reshape(expod,size(expod,2),1);
    curpod=colpod(end);
%     clear test;
%     test(:,1)=colpod;
%     test(:,2)=mean(colpod(10:end))+1.25*std(colpod(10:end));
%     test(:,3)=mean(colpod(10:end))-1.25*std(colpod(10:end));
%     dates=cellstr(eninpstr); %convert string to cell string,because ts object require cell string date
%     secname=[char(lnames(i)) ' pod'];
%     ts1=timeseries(test,dates,'name',secname);
%     ts1.TimeInfo.StartDate=eninpstr(1,:); %must be string
%     ts1.TimeInfo.Format='mmm yy';
%     plot(ts1,'LineWidth',2)
%     xlabel('Time')
%     ylabel('pod')
%     axis tight
%     grid on
end
