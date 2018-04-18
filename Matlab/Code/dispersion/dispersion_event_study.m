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
txt={'HSI Index'};

TH=2;

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

min_window=60;
max_window=60;
step=20;
window=min_window:step:max_window;
n_iteration=size(window,2);

%window for event study
input_window={20 5 40};
pre_e=cell2mat(input_window(1));
post_e=cell2mat(input_window(2));
event_window=pre_e+post_e+1;
estimate_window=cell2mat(input_window(3));

disp_date=date(:,2);
for i=1:n_iteration
    temp_window=min_window+step*(i-1);
    ma_z=zeros(size(price,1)-temp_window+1,1);
    temp_date=date(temp_window:end,2);
    event_date=[];
    %calcualting z_dispersion
    for j=temp_window:size(D,1)
        temp_z=zscore(price(j-temp_window+1:j,2));
        ma_z(j-temp_window+1,1)=temp_z(end,1);
        if j>temp_window
           if ma_z(j-temp_window+1,1)>TH && ma_z(j-temp_window,1)<TH
              event_date=[event_date ;temp_date(j-temp_window+1,1)];
           end
        end
    end
    
    new_event_date=event_date(1:end,1);
    
    if size(new_event_date,1)>2
       cd('C:\Users\ychen\Documents\MATLAB\event_study');
       event_study_start_date=new_event_date(1,1)-pre_e-estimate_window-100;
       [m_ABR,m_CAR]=event_study_factor_to_index(D,disp_date,new_event_date,input_window,event_study_start_date);
    end
    x=-pre_e:post_e;    
    plot(x,m_CAR,'blue')
    legend('CAR')
    xlabel('Date');
    ylabel('Price Return');
    title(cat(2,char(txt),' Dispersion Surge Event Study'))
    hold on;
    line([0 0],[m_CAR(pre_e+1) max(m_CAR)],'LineStyle','--','LineWidth',2); 
end