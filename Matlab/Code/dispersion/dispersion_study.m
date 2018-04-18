clear all;
cd('C:\Users\ychen\Documents\data');
% file='adr98_disp.txt';
% file='adr_ch55bn_disp.txt';
file='adr62_disp.txt';
fileID=fopen(file,'r');
formatSpec='%f';
D=fscanf(fileID,formatSpec);
fclose(fileID);
startdate='10/27/2009';
enddate=today();
% txt={'CH55BN Index';'HSI Index';'HSCCI Index';'HSCEI Index';'FXI Equity';'EWH Equity';'SHCOMP Index';'SHASHR Index'};
txt={'HSI Index';'HSCCI Index';'HSCEI Index';'FXI Equity';'EWH Equity';'SHASHR Index'};

min_window=5;
max_window=40;
step=5;
window=min_window:step:max_window;
adf_window=250;
chart_idx=5; %choose one window to chart signal
v_lag=2:30;

cd('C:\Users\ychen\Documents\MATLAB');
javaaddpath('C:\blp\ServerAPI\APIv3\JavaAPI\v3.4.5.5\lib\blpapi3.jar')

per={'daily','non_trading_weekdays','previous_value'};
c=blp;
for loop=1:size(txt,1)
    new=char(txt(loop));
    [d sec] = history(c, new,'Last_Price',startdate,enddate,per);
    date(1:size(d,1),loop+1)=d(1:size(d,1),1);
    price(1:size(d,1),loop+1)=d(1:size(d,1),2);
    
end;
close(c);

n_ob=size(D,1);
D_row=reshape(D,1,n_ob);
n_iteration=size(window,2);
v_Pvalue=zeros(n_iteration,size(txt,1));
best_window=zeros(1,size(txt,1));
best_P=zeros(1,size(txt,1));
v_Signal=zeros(n_iteration,size(txt,1));
v_DF=zeros(n_iteration,size(txt,1));
v_leftR=zeros(n_iteration,size(txt,1));
v_rightR=zeros(n_iteration,size(txt,1));

chart_signal=[];
for j=1:n_iteration
    temp_window=min_window+step*(j-1);
    D_ma=tsmovavg(D_row,'s',temp_window);
    D_new=reshape(D_ma(temp_window:end),n_ob-temp_window+1,1);    
    for i=1:size(txt,1)
        raw_Y=[D_new price(temp_window:end,i+1)];
        Y = log(raw_Y);
        [h,pValue,stat,~,reg] = egcitest(Y(end-adf_window+1:end,:),'test','t2');
        v_Pvalue(j,i)=pValue;        
        temp_signal=zscore(reg.res);
        v_Signal(j,i)=temp_signal(end);
        
%         if j==chart_idx && i==1
%             chart_signal=[chart_signal temp_signal];
%         end
        temp_DF=find_dof(D_new,price(temp_window:end,i+1),v_lag);
        temp_leftR=left_tail(D_new,price(temp_window:end,i+1),v_lag);
        temp_rightR=right_tail(D_new,price(temp_window:end,i+1),v_lag);
        v_leftR(j,i)=mean(temp_leftR);
        v_rightR(j,i)=mean(temp_rightR);
        v_DF(j,i)=mean(temp_DF);
    end
end

% for i=1:size(txt,1)
%     [C,I]=min(v_Pvalue(:,i));
%     best_window(i)=min_window+step*(I-1);
%     best_P(i)=C;
% end

% dates_str=datestr(date(end-adf_window+1:end,2));
% dates_cell=cellstr(dates_str);
% secname=[char(txt(1)) ' Z_signal'];
% ts1=timeseries(chart_signal,dates_cell,'name',secname);
% ts1.TimeInfo.StartDate=dates_str(1,:); %must be string
% ts1.TimeInfo.Format='mmm yy';
% plot(ts1,'LineWidth',2)
% xlabel('Time')
% ylabel('Z_signal')
% axis tight
% grid on