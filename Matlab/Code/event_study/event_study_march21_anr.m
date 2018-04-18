% Yan Event Study  03/21/2013

% this piece try to extract event date from bloomberg directly. But the
% event date is in double, how to transform it into string?
cd('C:\Documents and Settings\YChen\My Documents');
clear P;
clear ABR;
clear CAR;
clear event_date;
clear raw_event_date;
clear ascend_event_date;

upordown=2;
pre_e=5;
post_e=4;
ew=pre_e+post_e+1;
estimate_window=30;
%extract the whole price and date
[btxt,bbpx]=blp_event_v('event_input','anr','a1','px_volume',1500,0,0);
tday=btxt(:, 2); 
adjcls=bbpx(:, 2);  
baddata1=find(any(tday));
tday(baddata1)=[];
adjcls(baddata1)=[];
adjcls=rtn(adjcls); %transform price series into return series
totsize=size(adjcls,1);
tday=tday(2:end,1);
tday_str=datestr(tday); %transfter num date to string date

%set event rules----build array of event date in number format
[num,raw_event_date]=xlsread('event_input','anr','w2:w8');

event_date=[];
for t = 1:size(raw_event_date,1)
    numdate=datenum(raw_event_date(t));
    event_date=[event_date;numdate]; % event_date is the array of event date in number format
end    
ascend_event_date=sortrows(event_date,1);
 
    
    ABR=[];
    CAR=[];
    for i=1:size(ascend_event_date,1)        
        e_ind=find(tday==ascend_event_date(i)); %find the index for the event date in tday
        j=0;
        while isempty(e_ind)
              j=j+1;
              e_ind=find(tday==ascend_event_date(i)+j); %find the index for the event date in tday
        end
        e_begin=e_ind-pre_e;
        results=event_constant_mean(adjcls,e_begin,ew,totsize);
        ABR=[ABR results.abr];
        CAR=[CAR results.car]; 
   end
    
   m_ABR=mean(ABR,2);
   m_CAR=mean(CAR,2);
   SIG=std(ABR,0,2); %0---divided by n-1, 2--by column
   m_SAR=m_ABR./SIG;
   
   P=[];
        
            
   % compute p-value 
        
   for q=0:1:ew-1
       if upordown==2
          newp = 1-tcdf(m_SAR(q+1),totsize-2); 
       else
          newp = tcdf(m_SAR(q+1),totsize-2); %find large negtive
       end
       P=[P; newp];
   end
   
   
   x=-pre_e:post_e;    
   plot(x,m_ABR,'blue')
   hold on;
   plot(x,m_CAR,'green')
   legend('ABR','CAR')
   xlabel('Date');
   ylabel('Return');
   title('ABR and CAR for Sinopec Shanghai Petrochemical Upgrade')
   hold on;
   line([0 0],[-0.4 max(m_ABR(6),m_CAR(6))],'LineStyle','--','LineWidth',2);
 
    