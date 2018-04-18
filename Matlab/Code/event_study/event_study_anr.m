% Yan Event Study  07/24/2014
% this piece try to extract event date from bloomberg directly. But the
% event date is in double, how to transform it into string?

% clear all;
% javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.6.1.0\lib\blpapi3.jar') % for using blp in function (blp_txt)
% cd('C:\Users\ychen\Documents\MATLAB\event_study');
% input_date={'09/16/2013';'12/03/2013';'10/16/2013';'12/16/2013'...
%     ;'06/04/2014';'10/28/2013';'08/22/2013'};
% input_window={3 7 20};
% input_ticker={'105560 KS Equity'};
% start_date={'03/01/2010'};
% flag=1;
function [m_ABRs,m_CARs,m_ABRt,m_CARt]=event_study_anr(input_ticker,input_date,input_window,start_date,flag)                  
         pre_e=cell2mat(input_window(1));
         post_e=cell2mat(input_window(2));
         event_window=pre_e+post_e+1;
         estimate_window=cell2mat(input_window(3));
         per='daily';

         [names,dates1,prices1]=blp_event(input_ticker,'Last_Price',char(start_date),per);
         [names,dates2,prices2]=blp_event(input_ticker,'Best_Target_Price',char(start_date),per);
         
         tday1=dates1(:, 2); 
         adjcls1=prices1(:, 2);  
         tday1(find(~tday1))=[];
         adjcls1(find(~adjcls1))=[];
         tday2=dates2(:, 2); 
         adjcls2=prices2(:, 2); 
         tday2(find(~tday2))=[];
         adjcls2(find(~adjcls2))=[];
         [foo,idx1,idx2]=intersect(tday1,tday2);
         
         v_price=adjcls1(idx1);
         v_target=adjcls2(idx2);
         tday=tday1(idx1);
         v_ratio=v_target./v_price*100;

         totsize=size(v_ratio,1);
         tday_str=datestr(tday); %transfter num date to string date

         event_date=[];
         for t = 1:length(input_date)
             numdate=datenum(input_date(t));
             event_date=[event_date;numdate]; % event_date is the array of event date in number format
         end    
         ascend_event_date=sortrows(event_date,1); 
         
         rtn_ratio=rtn(v_ratio);
         rtn_target=rtn(v_target);
         %spread
         ABR_s=[]; 
         CAR_s=[];
         %target
         ABR_t=[];
         CAR_t=[];
         for i=1:size(ascend_event_date,1)        
             e_ind=find(tday==ascend_event_date(i)); %find the index for the event date in tday
             if isempty(e_ind)==0
                event_begin=e_ind-pre_e;
%                 event_end=event_begin+event_window-1;
                results_spread=event_constant_mean(rtn_ratio,event_begin,event_window,estimate_window);
                ABR_s=[ABR_s results_spread.abr];
                CAR_s=[CAR_s results_spread.car];
                
                results_target=event_constant_mean(rtn_target,event_begin,event_window,estimate_window);
                ABR_t=[ABR_t results_target.abr];
                CAR_t=[CAR_t results_target.car];
             end
         end
    
         temp_ABRs=mean(ABR_s,2);
         m_ABRs=100*temp_ABRs;
         temp_CARs=mean(CAR_s,2);
         m_CARs=100*temp_CARs;
         
         temp_ABRt=mean(ABR_t,2);
         m_ABRt=100*temp_ABRt;
         temp_CARt=mean(CAR_t,2);
         m_CARt=100*temp_CARt;
         %variance of average abnormal return
         m_VARs=std(ABR_s,0,2);%0---unbiased
         m_SARs=temp_ABRs./sqrt(m_VARs);
         P=[];
         for q=0:1:event_window-1
             if flag==1
                newp = 1-tcdf(m_SARs(q+1),estimate_window-2); 
             elseif flag==-1
                newp = tcdf(m_SARs(q+1),estimate_window-2); %find large negtive
             else
             end
             P=[P; newp];
             m_VCARs(q+1,1)=sum(m_VARs(1:q+1));
         end
         m_SCARs=temp_CARs./sqrt(m_VCARs);   