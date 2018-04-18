% Yan Event Study  02/19/2013

% this piece try to do event study on volume
cd('C:\Documents and Settings\YChen\My Documents');
clear P;
[btxt,bbpx]=blp_event('input_ticker','event','a2','px_volume');

    tday=btxt(:, 2); 
    adjcls=bbpx(:, 2);  
    baddata1=find(any(tday));
    tday(baddata1)=[];
    adjcls(baddata1)=[];
    tday_str=datestr(tday); %transfter num date to string date
   
    %Turn price series into return series
    adjcls=rtn(adjcls); 
    tday=tday(2:end,1);
    event_date={'01/30/2003','02/15/2007','03/08/2007','07/31/2007','08/23/2007','09/14/2007','09/16/2008','10/30/2008','09/09/2010','05/25/2011','08/11/2011','02/02/2012','06/04/2012','07/30/2012'};
    estimate_window=30;
    pre_e=5;
    post_e=9;
    ew=pre_e+post_e+1;
    P=zeros(ew,1);
    
    for i=1:size(event_date,2)        
        edn=datenum(event_date(i)); %tranform date from string value to integers
        e_ind=find(tday==edn); %find the index for the event date in tday
        e_begin=e_ind-pre_e-estimate_window;
        e_end=e_ind-pre_e-1;
        results=event_extra_return(adjcls,e_begin,e_end,estimate_window,ew,2);
        new_colp=results.pValue;
        P=[P new_colp];    
   end
    
   t=1:ew;
   
   plot(t,results.abr,'blue')
   hold on;
   plot(t,results.car,'green')
   hold on; 
   plot(t,adjcls(e_end+1:e_ind+post_e),'red')
  
    