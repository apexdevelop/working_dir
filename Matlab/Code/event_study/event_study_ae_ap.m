% Yan Event Study  04/17/2017
% event_start_date is the start date of factor. after generating factor
% data and figuring out the triggered event dates, find the start date of
% equity

% clear all;
% javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar'); % for using blp in function (blp_txt)
% cd('C:\Users\ychen\Documents\MATLAB\event_study');
% input_window={5 15 22};
% input_ticker={'3800 HK equity';'HSI Index'};
% degree=0.02;
% event_start_date={'1/1/2011'};
% idx=-1;
% f_ticker='SOLRAMUL Index';

function [c_date,c_ABR, c_CAR, c_SAR, m_ABR,m_CAR,m_SAR,m_SCAR,n_events,f_lastchg,pstd,nstd]=event_study_ae_ap(input_ticker,f_ticker,input_window,event_start_date,idx,degree)                  
         
         c=blp;
         end_date=today();
         per_f={'monthly','active_days_only'};
%          per_f={'monthly','all_calendar_days'};
%          per_f={'monthly','non_trading_weekdays'};
         char_ticker=char(f_ticker);
         char_date=char(event_start_date);
         [d, sec] = history(c, char_ticker,'CHG_PCT_1D',char_date,end_date,per_f);
         %[d, sec] = history(c, 'CHPACHIN Index','CHG_PCT_1D',char_date,end_date,per_f);
         ftxt(1:size(d,1),1)=d(1:size(d,1),1);
         fts(1:size(d,1),1)=d(1:size(d,1),2);

         close(c);
         
         f_lastchg=fts(end);
         
         fdate_excel=m2xdate(ftxt,0);

         pidx=find(fts>0);
         pts=fts(pidx);
         pstd=std(pts);

         nidx=find(fts<0);
         nts=fts(nidx);
         nstd=std(nts);

         if idx==1
            event_idx=find(fts>=degree*pstd);
         elseif idx==-1 
            event_idx=find(fts<=-degree*nstd);
         else
         end

         event_date=ftxt(event_idx);
         ascend_event_date=sortrows(event_date,1);
         n_events=size(event_date,1);
         
         pre_e=cell2mat(input_window(1));
         post_e=cell2mat(input_window(2));
         event_window=pre_e+post_e+1;
         estimate_window=cell2mat(input_window(3));
         
         data_start_date=datestr(event_date(1)-(estimate_window+pre_e)*2,'mm/dd/yyyy');
         
         per='daily';

         [names,dates,prices]=blp_event(input_ticker,'Last_Price',data_start_date,per);

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
  
         ABR=[];
         CAR=[];
         VABR=[];
         
         for i=1:size(ascend_event_date,1)        
             e_ind=find(tday==ascend_event_date(i)); %find the index for the event date in tday
             if isempty(e_ind)==0
                event_begin=e_ind-pre_e;
                if size(tday,1)-e_ind<post_e
                   event_window=pre_e+size(tday,1)-e_ind+1;
                end
                if size(dates,2)<=2
                   results=event_constant_mean(v_rtn,event_begin,event_window,estimate_window);
                else
                   results=event_market_return(v_rtn,event_begin,estimate_window,event_window);
                end
                if size(tday,1)-e_ind>=post_e
                   ABR=[ABR results.abr];
                   CAR=[CAR results.car];
                   VABR=[VABR results.vabr];
                end
                
                c_ABR=100*results.abr;
                c_CAR=100*results.car;
                c_VABR=results.vabr;
                c_SAR=results.sar;
                c_date=m2xdate(tday(event_begin:event_begin+event_window-1),0);
             end
         end
    
         temp_ABR=mean(ABR,2);
         m_ABR=100*temp_ABR;
         temp_CAR=mean(CAR,2);
         m_CAR=100*temp_CAR;
         
         %adjust event-1 day CAR to 0
         m_CAR=m_CAR-repmat(m_CAR(pre_e,1),size(m_CAR,1),1);
         
         [C_max,I_max]=max(m_CAR);
         [C_min,I_min]=min(m_CAR);
         %variance of average abnormal return
         m_VAR=sum(VABR,2)/size(ascend_event_date,1)^2;
         m_SAR=temp_ABR./sqrt(m_VAR);
         
         event_window=pre_e+post_e+1;
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