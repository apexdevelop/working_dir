% Yan Event Study  10/10/2017
% change function name to event_study_fe_ap at some point
% this program manually read in event dates
% clear all;
% javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.8.8.2\lib\blpapi3.jar'); % for using blp in function (blp_txt)
% cd('C:\Users\ychen\Documents\MATLAB\event_study');
% input_date={'01/24/2001';'02/12/2002';'02/01/2003';'01/22/2004';'02/09/2005';'01/29/2006';'02/18/2007';'02/07/2008';'01/26/2009';'02/14/2010';'02/03/2011';'01/23/2012';'02/10/2013';'01/31/2014';'02/19/2015';'02/08/2016'};
% input_window={5 5 40};
% input_ticker={'9101 JP equity';'9104 JP equity';'9107 JP equity'};
% start_date={'1/1/2000'};
% idx=1;

function [metric,m_ABR,m_CAR,m_SAR,m_SCAR,C_max,I_max,C_min,I_min]=event_study_revenue_surprise(input_ticker,input_date,input_window,start_date,idx)                  
         pre_e=cell2mat(input_window(1));
         post_e=cell2mat(input_window(2));
         event_window=pre_e+post_e+1;
         estimate_window=cell2mat(input_window(3));

         
         per='daily';

         [names,dates,prices]=blp_event(input_ticker,'Last_Price',char(start_date),per);

         tday1=dates(:, 2); 
         adjcls1=prices(:, 2);  
         tday1(find(~tday1))=[];
         adjcls1(find(~adjcls1))=[];
         
         if size(dates,2)>2
            tday2=dates(:, 3); 
            adjcls2=prices(:, 3); 
            tday2(find(~tday2))=[];
            adjcls2(find(~adjcls2))=[];
            [foo,idx1,idx2]=intersect(tday1,tday2);
            adjcls=zeros(size(foo,1),2);
            adjcls(:,1)=adjcls1(idx1);
            adjcls(:,2)=adjcls2(idx2);
            tday=tday1(idx1);
            v_rtn=[rtn(adjcls(:,1)) rtn(adjcls(:,2))];
            totsize=size(adjcls,1);
            tday=tday(2:end,1);
         else
            v_rtn=rtn(adjcls1);
            tday=tday1(2:end,1);
         end
         
         tday_str=datestr(tday); %transfter num date to string date

         event_date=[];
         for t = 1:length(input_date)
             numdate=datenum(input_date(t));
             event_date=[event_date;numdate]; % event_date is the array of event date in number format
         end    
         ascend_event_date=sortrows(event_date,1); 
         
         ABR=[];
         CAR=[];
         VABR=[];
         is_regress=0;
         for i=1:size(ascend_event_date,1)        
             e_ind=find(tday==ascend_event_date(i)); %find the index for the event date in tday
             if isempty(e_ind)==0
                event_begin=e_ind-pre_e;
                if size(dates,2)<=2
                   results=event_constant_mean(v_rtn,event_begin,event_window,estimate_window);
                else
                   if is_regress==1
                      results=event_market_return(v_rtn,event_begin,estimate_window,event_window);
                   else
                      results=event_market_subtruct(v_rtn,event_begin,event_window);
                   end
                end
                ABR=[ABR results.abr];
                CAR=[CAR results.car];
                VABR=[VABR results.vabr];
                
             end
         end
         
         temp_ABR=mean(ABR,2);
         m_ABR=100*temp_ABR;
         temp_CAR=mean(CAR,2);
         m_CAR=100*temp_CAR;
         
         
         %variance of average abnormal return
         m_VAR=sum(VABR,2)/size(ascend_event_date,1)^2;
         m_SAR=temp_ABR./sqrt(m_VAR);
         
         m_VCAR=zeros(event_window,1);
         
         P=[];
         for q=0:1:event_window-1
             if idx==1
                newp = 1-tcdf(m_SAR(q+1),estimate_window-2); 
             elseif idx==-1
                newp = tcdf(m_SAR(q+1),estimate_window-2); %find large negtive
             else
             end
             P=[P; newp];
             m_VCAR(q+1,1)=sum(m_VAR(1:q+1));
         end
         m_SCAR=temp_CAR./sqrt(m_VCAR);
         
         n_event=size(ABR,2);
         pre_CAR=CAR(pre_e,:);
         m_pre_CAR=mean(pre_CAR);
         sd_pre_CAR=std(pre_CAR);
         event_ABR=ABR(pre_e+1,:);
         m_event_ABR=mean(event_ABR);
         sd_event_ABR=std(event_ABR);
         post_CAR=sum(ABR(pre_e+2:end,:),1);
         m_post_CAR=mean(post_CAR);
         sd_post_CAR=std(post_CAR);
         metric=[n_event,pre_e,m_pre_CAR,sd_pre_CAR,post_e,m_post_CAR,sd_post_CAR,m_event_ABR,sd_event_ABR];
         
         
         %adjust event-1 day CAR to 0
         m_CAR=m_CAR-repmat(m_CAR(pre_e,1),size(m_CAR,1),1);
         [C_max,I_max]=max(m_CAR);
         [C_min,I_min]=min(m_CAR);