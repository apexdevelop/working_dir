% Yan Event Study  04/17/2017
% event_start_date is the start date of factor. after generating factor
% data and figuring out the triggered event dates, find the start date of
% equity

% clearvars;
% javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar'); % for using blp in function (blp_txt)
% cd('Y:\working_directory\Matlab\event_study');
% input_window={15 25 40};
% filename='korea_study.xlsx';
% shname1='factor_ret';
% shname2='equity_ret';
% [mat_fts,~]=xlsread(filename,shname1,'b3:b1158'); %factor return
% [mat_ets,~]=xlsread(filename,shname2,'d3:d1140'); %equity return
% 
% [~,c_date_fts]=xlsread(filename,shname1,'a3:a1158'); %factor dates
% [~,c_date_ets]=xlsread(filename,shname2,'c3:c1140'); %equity dates
% 
% degree=2;
% %event_start_date={'3/1/2010'};
% idx=-1;

function [c_idx,c_RET,c_ABR, c_CAR, c_SAR,RET, m_ABR,m_CAR,m_SAR,m_SCAR,m_VAR,m_VCAR,n_events,pstd,nstd,excel_dates,new_fts,z_fts,new_ets,event_idx,event_dates]=event_study_ae_fp(fts,ets,fdates,edates,input_window,idx,degree)         
         event_start_idx=60; %should be larger than estimate_window and pre_e
         pre_e=cell2mat(input_window(1));
         post_e=cell2mat(input_window(2));
         event_window=pre_e+post_e+1;
         estimate_window=cell2mat(input_window(3));
         
         mat_fts=cell2mat(fts);
         mat_ets=cell2mat(ets);
         
         c_date_fts=cellstr(datestr(fdates));
         c_date_ets=cellstr(datestr(edates));
         
         t_fts=fints(c_date_fts,mat_fts,'t_fts');
         t_ets=fints(c_date_ets,mat_ets,'t_ets');
         newfints=merge(t_fts,t_ets,'DateSetMethod','Intersection');
         new_fts=fts2mat(newfints.t_fts);
         new_ets=fts2mat(newfints.t_ets);
         
         %If you want to include the dates in the output matrix, provide a second input argument and set it to 1. This results in a matrix whose first column is a vector of serial date numbers:
         new_fullfts=fts2mat(newfints.t_fts,1);
         new_dates=new_fullfts(1:end,1);
         excel_dates=m2xdate(new_dates,0);
         
         n_ob=size(new_fts,1);
         
         adj_fts=new_fts(event_start_idx:end);
         avg_fts=mean(adj_fts);
         %avg_fts=0;
         z_fts=zeros(size(adj_fts,1),1);
         z_fts(1:estimate_window)=zscore(adj_fts(1:estimate_window));
         for i = estimate_window+1 : size(adj_fts,1)
             temp_zfts=zscore(adj_fts((i-estimate_window):i));
             z_fts(i,1)=temp_zfts(end);
         end
%          z_fts=zscore(adj_fts);
         
         mat_idx(1:n_ob,1:1)=1:n_ob;
         pidx=find(adj_fts>avg_fts);
         pts=adj_fts(pidx);
         pstd=std(pts);

         nidx=find(adj_fts<avg_fts);
         nts=adj_fts(nidx);
         nstd=std(nts);

         if idx==1
            event_idx=find(z_fts>=degree);
         elseif idx==-1 
            event_idx=find(z_fts<=-degree);
         else
         end
         
         event_fts=adj_fts(event_idx);
         event_dates=m2xdate(new_dates(event_idx+event_start_idx-1),0);
         n_events=size(event_fts,1);
         
         RET=[];
         ABR=[];
         CAR=[];
         VABR=[];
         VCAR=[];
         SABR=[];
         SCAR=[];
         for i=1:n_events       
             e_ind=event_idx(i)+event_start_idx-1; %find the equity return for the event date in ets,adding back the estimate window
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
         
         [C_max,I_max]=max(m_CAR);
         [C_min,I_min]=min(m_CAR);
         
         %Std of average abnormal return
         temp_VAR=std(ABR,0,2);
         m_VAR=temp_VAR*100;
         temp_VCAR=std(CAR,0,2);
         m_VCAR=temp_VCAR*100;

         event_window=pre_e+post_e+1;
         %m_VCAR=zeros(event_window,1);
%          P=[];
%          for q=0:1:event_window-1
%              if idx==1
%                 newp = 1-tcdf(m_SAR(q+1),estimate_window-2); 
%              elseif idx==-1
%                 newp = tcdf(m_SAR(q+1),estimate_window-2); %find large negtive
%              else
%              end
%              P=[P; newp];
%          end
            