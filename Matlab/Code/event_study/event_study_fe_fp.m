% Yan Event Study  04/17/2017
% event_start_date is the start date of factor. after generating factor
% data and figuring out the triggered event dates, find the start date of
% equity

% clearvars;
% javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar'); % for using blp in function (blp_txt)
% cd('Y:\working_directory\Matlab\event_study');
% input_window={15 25 40};
% % fdates={'09/01/2008';'10/06/2008';'11/11/2008';'01/26/2009';'02/25/2009';'09/26/2011'};
% filename='korea_study2.xlsx';
% shname1='factor_ret';
% shname2='equity_ret';
% [new_ets,~]=xlsread(filename,shname2,'x2:x2527'); %equity return
% [~,edates]=xlsread(filename,shname2,'v2:v2527'); %equity dates
% [~,fdates]=xlsread(filename,shname1,'e2:e7'); %event dates


function [c_idx,c_RET,c_ABR, c_CAR, c_SAR,RET, m_ABR,m_CAR,m_SAR,m_SCAR,m_VAR,m_VCAR,n_event]=event_study_fe_fp(ets,fdates,edates,input_window)         
         pre_e=cell2mat(input_window(1));
         post_e=cell2mat(input_window(2));
         event_window=pre_e+post_e+1;
         estimate_window=cell2mat(input_window(3));
         
         new_ets=cell2mat(ets);
         edates_num=datenum(edates);
         event_date=[];
         for t = 1:length(fdates)
             numdate=datenum(fdates(t));
             event_date=[event_date;numdate]; % event_date is the array of event date in number format
         end    
         ascend_event_date=sortrows(event_date,1); 
         n_ob=size(new_ets,1);
         mat_idx(1:n_ob,1:1)=1:n_ob;
         
         RET=[];
         ABR=[];
         CAR=[];
         VABR=[];
         VCAR=[];
         SABR=[];
         SCAR=[];
         n_event=0;
         for i=1:size(ascend_event_date,1)       
             e_ind=find(edates_num==ascend_event_date(i)); %find the equity return for the event date in ets,adding back the estimate window
                if isempty(e_ind)==0
                n_event=n_event+1;
                event_begin=e_ind-pre_e;
                if n_ob-e_ind<post_e
                   event_window=pre_e+n_ob-e_ind+1;
                end
                if size(new_ets,2)<=2
                   results=event_constant_mean(new_ets,event_begin,event_window,estimate_window,pre_e);
                else
                   results=event_market_return(new_ets,event_begin,estimate_window,event_window);
                end
                if n_ob-e_ind>=post_e
                   RET=[RET results.ret];
                   ABR=[ABR results.abr];
                   CAR=[CAR results.car];
                   SABR=[SABR results.sabr];
                   SCAR=[SCAR results.scar];
                   VABR=[VABR results.vabr];
                   VCAR=[VCAR results.vcar];
                end
                
                c_RET=100*results.ret;
                c_ABR=100*results.abr;
                c_CAR=100*results.car;
                c_VABR=results.vabr;
                c_SAR=results.sabr;
                c_idx=mat_idx(event_begin:event_begin+event_window-1);
                end
         end
    
         temp_ABR=mean(ABR,2);
         m_ABR=100*temp_ABR;
         temp_CAR=mean(CAR,2);
         m_CAR=100*temp_CAR;
         
         temp_SABR=mean(SABR,2);
         m_SAR=temp_SABR;
         temp_SCAR=mean(SCAR,2);
         m_SCAR=temp_SCAR;
         
         %adjust event-1 day CAR to 0
%          m_CAR=m_CAR-repmat(m_CAR(pre_e,1),size(m_CAR,1),1);
         
         %Std of average abnormal return
         temp_VAR=std(ABR,0,2);
         m_VAR=temp_VAR*100;
         temp_VCAR=std(CAR,0,2);
         m_VCAR=temp_VCAR*100;
            