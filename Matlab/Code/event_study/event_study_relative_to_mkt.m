% Yan Event Study for Toyota Motor  02/12/2013
%7/24/2013 Canon BuyBack
cd('C:\Documents and Settings\YChen\My Documents');
clear P;
[dtxt,px]=blp_event('event_input','LFC_predisclose','c1:c2');

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
   
 % Toyata Motor Price, use Market return Model
 
 
    adjcls=rtn(adjcls);%Turn price series into return series
    
    %calculate return relative to the market
    adjcls_relative=adjcls(:,1)-adjcls(:,2);
    tday=tday(2:end,1);
    %event_date={'01/30/2008','01/29/2010','02/28/2013'};
    event_date={'01/21/2009','03/06/2012','08/06/2012','10/17/2012'};
    estimate_window=40;
    pre_e=5;
    post_e=22;
    ew=pre_e+post_e+1;
    P=[];
    CAR=[];
    SAR=[];
    for i=1:size(event_date,2)        
        edn=datenum(event_date(i)); %tranform date from string value to integers
        e_ind=find(tday==edn); %find the index for the event date in tday
        e_begin=e_ind-pre_e-estimate_window;
        e_end=e_ind-pre_e-1;
        results=event_extra_return(adjcls_relative,e_begin,e_end,estimate_window,ew,2);
        new_colp=results.pValue;
        P=[P new_colp];
        CAR=[CAR results.car];
        SAR=[SAR results.sar];
   end
    
   m_P=mean(P,2);
   m_CAR=mean(CAR,2); 
   m_SAR=mean(SAR,2); 
   
   x=-pre_e:post_e;    
   plot(x,m_CAR,'blue')
   legend('CAR')
   xlabel('Date');
   ylabel('Price Return');
   title('LFC Predisclose Decrease Event Study')
   hold on;
   line([0 0],[m_CAR(6) max(m_CAR)],'LineStyle','--','LineWidth',2); 
     