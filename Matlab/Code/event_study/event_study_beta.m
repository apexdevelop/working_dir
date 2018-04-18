% Yan Event Study  04/24/2017
% event_start_date is the start date of factor. after generating factor
% data and figuring out the triggered event dates, find the start date of
% equity

clearvars;
javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar'); % for using blp in function (blp_txt)
cd('Y:\working_directory\Matlab\event_study');
input_window={5 15 22};
filename='korea_study.xlsx';
shname1='factor_ret';
shname2='equity_ret';
[px_fts,date_fts]=xlsread(filename,shname1,'n3:o3432'); %factor
[px_ets,date_ets]=xlsread(filename,shname2,'v3:w3266'); %equity
% degree=0.6:0.2:3.0;
degree_p=[0.6,0.8,1,1.2,1.4,1.6,1.8,2.0,2.1,2.2,2.3,2.4,2.5,2.6,2.65,2.7,2.75,2.8,2.85,2.9];

n_degree=size(degree_p,2);
degree_n=zeros(1,n_degree);
for i=1:n_degree
    degree_n(n_degree-i+1)=-degree_p(i);
end
%event_start_date={'3/1/2010'};
idx=-1;

% function [c_idx,c_ABR, c_CAR, c_SAR, m_ABR,m_CAR,m_SAR,m_SCAR,m_VAR,m_VCAR,n_events,pstd,nstd]=event_study_ae_fp(fts,ets,input_window,idx,degree)         
         event_start_idx=30; %should be larger than estimate_window and pre_e
         pre_e=cell2mat(input_window(1));
         post_e=cell2mat(input_window(2));
         event_window=pre_e+post_e+1;
         estimate_window=cell2mat(input_window(3));
         z_window=estimate_window;
         
         c_date_fts=cellstr(datestr(date_fts));
         c_date_ets=cellstr(datestr(date_ets));
         t_fts=fints(c_date_fts,px_fts,'t_fts');
         t_ets=fints(c_date_ets,px_ets,'t_ets');
         newfints=merge(t_fts,t_ets,'DateSetMethod','Intersection');
         new_fts=fts2mat(newfints.t_fts);
         new_ets=fts2mat(newfints.t_ets);
         n_ob=size(new_fts,1);
         
         adj_fts=new_fts(event_start_idx:end);
         ret_fts = price2ret(new_fts);
         ret_ets = price2ret(new_ets);
         
         n_ob_z=size(adj_fts,1);
         
         z_fts=zeros(n_ob_z,1);
         z_fts(1:z_window)=zscore(new_fts(1:z_window));
         for i = (z_window+1) : n_ob_z
             temp_zfts=zscore(new_fts((i-z_window):i));
             z_fts(i,1)=temp_zfts(end);
         end

         m_beta=zeros(n_degree,1);
         mat_nevents=zeros(n_degree,1);
         if idx==1
             for i=1:n_degree
                 event_idx=find(z_fts>=degree_p(i));
                 n_events=size(event_idx,1);
                 mat_nevents(i,1)=n_events;
                 BETA=[];
                 for j=1:n_events
                     %find the equity return for the event date in ets,adding back the estimate window
                     %-2 not -1 is because adjustment for return series
                     e_ind=event_idx(j)+event_start_idx-2; 
                     event_begin=e_ind-pre_e;
                     if n_ob-e_ind<post_e
                        event_window=pre_e+n_ob-e_ind+1;
                     end
                     results=event_beta(ret_ets,ret_fts,event_begin,event_window,estimate_window,pre_e);
                     if n_ob-e_ind>=post_e
                        BETA=[BETA;results.beta];
                     end
                 end
                 m_beta(i)=mean(BETA);
             end
             plot(degree_p,m_beta);
         elseif idx==-1 
              for i=1:n_degree
                 event_idx=find(z_fts<=degree_n(i));
                 n_events=size(event_idx,1);
                 mat_nevents(i,1)=n_events;
                 BETA=[];
                 for j=1:n_events
                     %find the equity return for the event date in ets,adding back the estimate window
                     %-2 not -1 is because adjustment for return series
                     e_ind=event_idx(j)+event_start_idx-2; 
                     event_begin=e_ind-pre_e;
                     if n_ob-e_ind<post_e
                        event_window=pre_e+n_ob-e_ind+1;
                     end
                     results=event_beta(ret_ets,ret_fts,event_begin,event_window,estimate_window,pre_e);
                     if n_ob-e_ind>=post_e
                        BETA=[BETA;results.beta];
                     end
                 end
                 m_beta(i)=mean(BETA);
              end
              plot(degree_n,m_beta);
         else
         end
         