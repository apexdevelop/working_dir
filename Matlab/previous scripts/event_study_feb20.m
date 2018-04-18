% Yan Event Study for Toyota Motor  05/15/2013

% this piece manages to extract event date from bloomberg directly. 

%argument
%pre_e
%post_e
%estimate_window
%event_rule(bloomberg field or customized event rule)
cd('C:\Documents and Settings\YChen\My Documents');
clear P;
pre_e=5;
post_e=4;
ew=pre_e+post_e+1; %ew is event window
estimate_window=30;

%extract the whole price and date
% [btxt,bbpx]=blp_event_v('event_input','20130506','a15','px_last',1500,0,0);
[btxt,bbpx]=blp_event_v('event_input','20130506','a15','px_volume',1500,0,0);
tday=btxt(:, 2); 
adjcls=bbpx(:, 2);  
baddata1=find(any(tday));
tday(baddata1)=[];
adjcls(baddata1)=[];
adjcls=rtn(adjcls); %transform price series into return series
tday=tday(2:end,1);
tday_str=datestr(tday); %transfter num date to string date

%set event rules----build array of event date in number format
[reflect_date,raw_event_date]=blp_event_v('event_input','20130506','a15','announcement_dt',1000,0,1);%1000 instead of 1500 to leave space for estimate window
unique_date=unique(raw_event_date(:,2));
event_date=[];
for t = 1:size(unique_date,1)
    e_date_str=num2str(unique_date(t,:));
    yr=strcat(e_date_str(1:4),'/');
    mm=strcat(e_date_str(5:6),'/');
    dd=e_date_str(7:8);
    ynm=strcat(yr,mm);
    codate=strcat(ynm,dd);
    numdate=datenum(codate);
    event_date=[event_date;numdate]; % event_date is the array of event date in number format
end    

 
    P=[];
    ABR=[];
    CAR=[];
   
    upordown=2;
    for i=1:size(event_date,1)        
        e_ind=find(tday==event_date(i)); %find the index for the event date in tday
        while isempty(e_ind)
        event_date(i)=event_date(i)+1;
        e_ind=find(tday==event_date(i)); 
        end
        e_begin=e_ind-pre_e-estimate_window;
        e_end=e_ind-pre_e-1;
        results=event_extra_return(adjcls,e_begin,e_end,ew,estimate_window,upordown);
        ABR=[ABR results.abr];
        CAR=[CAR results.car];
        P=[P results.pValue];    
   end
    
   m_ABR=mean(ABR,2);
   m_CAR=mean(CAR,2);
   m_P=mean(P,2);
   x=-pre_e:post_e;
   
   plot(x,m_ABR,'blue')
   hold on;
   plot(x,m_CAR,'green')
%    hold on; 
%    plot(x,adjcls(e_end+1:e_ind+post_e),'red') 
   legend('ABR','CAR')
   xlabel('Date');
   ylabel('Volume Return');
   title('ABR and CAR for Toyota Report')
   hold on;
   line([0 0],[-0.04 max(m_ABR(6),m_CAR(6))],'LineStyle','--','LineWidth',2);