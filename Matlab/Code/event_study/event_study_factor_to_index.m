% Yan Event Study  07/24/2014
% this piece try to extract event date from bloomberg directly. But the
% event date is in double, how to transform it into string?

% clear all;
% javaaddpath('C:\blp\ServerAPI\APIv3\JavaAPI\v3.4.5.5\lib\blpapi3.jar') % for using blp in function (blp_txt)
% cd('C:\Users\ychen\Documents\MATLAB\event_study');
% input_date={'12/08/2012';'02/16/2013';'06/14/2013';'10/18/2013';'11/1/2013';'9/17/2014'};
% input_window={5 20 20};
% input_ticker={'6301 JP equity';'TPX Index'};
% start_date={'09/30/2011'};
% idx=1;
function [m_ABR,m_CAR]=event_study_factor_to_index(adjcls,disp_date,event_date,input_window,start_date)                  
         pre_e=cell2mat(input_window(1));
         post_e=cell2mat(input_window(2));
         event_window=pre_e+post_e+1;
         estimate_window=cell2mat(input_window(3));

         v_rtn=rtn(adjcls); %transform price series into return series      
         ascend_event_date=sortrows(event_date,1); 
         
         ABR=[];
         CAR=[];         
         for i=1:size(ascend_event_date,1)        
             e_ind=find(disp_date==ascend_event_date(i)); %find the index for the event date in tday
             if isempty(e_ind)==0
                e_begin=e_ind-pre_e;
                results=event_constant_mean(v_rtn,e_begin,event_window,estimate_window);
                ABR=[ABR results.abr];
                CAR=[CAR results.car];                
             end
         end
    
         temp_ABR=mean(ABR,2);
         m_ABR=100*temp_ABR;
         temp_CAR=mean(CAR,2);
         m_CAR=100*temp_CAR;