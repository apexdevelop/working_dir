% Yan Event Study for Toyota Motor  02/12/2013
%7/24/2013 Canon BuyBack
%8/1/2013 LFC Predisclose
%1/6/2014 Fast Retailing Earnings Surprise

javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.6.1.0\lib\blpapi3.jar')
cd('C:\Users\ychen\Documents');
clear P;

% obtain price series of stock and benchmark
[dtxt,px]=blp_event('event_input','surp','a1:a2');

tday1=dtxt(:, 2); 
adjcls1=px(:, 2);  
tday2=dtxt(:, 3); 
adjcls2=px(:, 3); 

tday=union(tday1, tday2); 
baddata1=find(any(tday));
tday(baddata1)=[];
[~, idx idx1]=intersect(tday, tday1); %foo=tday(idx,:),foo=tday1(idx1,:)
adjcls=NaN(length(tday), 2); % combining the two price series,initialized by NaN matrix
adjcls(idx, 1)=adjcls1(idx1);
[foo idx idx2]=intersect(tday, tday2);
adjcls(idx, 2)=adjcls2(idx2);
baddata=find(any(~isfinite(adjcls), 2)); % days where any one price is missing,isfinite()=0 if NaN
tday(baddata)=[];
adjcls(baddata, :)=[];
tday_str=datestr(tday); %transfter num date to string date
   
 
 
adjcls=rtn(adjcls); %Turn price series into return series
tday=tday(2:end,1);

% event_date={'04/10/2008','01/08/2010','01/13/2011','01/10/2013','04/11/2013','10/10/2013'}; %positive surprise
%event_date={'10/11/2007','04/07/2011','11/25/2011'}; % negative surprise

[raw_surp,txt]=xlsread('event_input','surp','j6:j36');
[num,raw_event_date]=xlsread('event_input','surp','l6:l36');

event_date=[];
for t = 1:size(raw_surp,1)
    if raw_surp(t)>3       
       numdate=datenum(raw_event_date(t));
       event_date=[event_date;numdate]; % event_date is the array of event date in number format
    end
end    
eday_str=datestr(event_date);

estimate_window=40;
pre_e=5;
post_e=22;
ew=pre_e+post_e+1;
P=[];
CAR=[];
for i=1:size(event_date,2)        
    edn=datenum(event_date(i)); %tranform date from string value to integers
    e_ind=find(tday==edn); %find the index for the event date in tday
    e_begin=e_ind-pre_e-estimate_window;
    e_end=e_ind-pre_e-1;
    results=event_market_return(adjcls,e_begin,e_end,estimate_window,ew);
    new_colp=results.pValue;
    P=[P new_colp];
    CAR=[CAR results.car];
end
    
m_P=mean(P,2);
m_CAR=mean(CAR,2); 
    
x=-pre_e:post_e;    
plot(x,m_CAR,'blue')
legend('CAR')
xlabel('Date');
ylabel('Price Return');
title('Fast Retailing EE Surprise Event Study')
hold on;
line([0 0],[0.2*m_CAR(6) 1.2*m_CAR(6)],'LineStyle','--','LineWidth',2); 
     