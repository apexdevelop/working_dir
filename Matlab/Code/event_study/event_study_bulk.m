% Yan Event Study  1/11/2017

% clear all;
% javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.8.8.2\lib\blpapi3.jar'); 
% cd('C:\Users\ychen\Documents\MATLAB\event_study');
% % input_date={'01/24/2001';'02/12/2002';'02/01/2003';'01/22/2004';'02/09/2005';'01/29/2006';'02/18/2007';'02/07/2008';'01/26/2009';'02/14/2010';'02/03/2011';'01/23/2012';'02/10/2013';'01/31/2014';'02/19/2015';'02/08/2016'};
% input_date={'01/23/2001';'02/11/2002';'01/30/2003';'01/21/2004';'02/08/2005';'01/27/2006';'02/16/2007';'02/06/2008';'01/23/2009';'02/12/2010';'02/02/2011';'01/20/2012';'02/08/2013';'01/30/2014';'02/18/2015';'02/05/2016'};
% input_window={5 10 40};
% equity_ticker={'2628 HK Equity';'2318 HK Equity'};
% benchmark_ticker={'HSI Index';'HSI Index'};
% start_date={'1/1/2000'};
% idx=1;
function [v_mABR,v_mCAR,v_mSAR,v_mSCAR,v_Cmax,v_Imax,v_Cmin,v_Imin]=event_study_bulk(equity_ticker,benchmark_ticker,input_date,input_window,start_date,idx)                  
         pre_e=cell2mat(input_window(1));
         post_e=cell2mat(input_window(2));
         event_window=pre_e+post_e+1;
         estimate_window=cell2mat(input_window(3));

         per='daily';

         [e_names,e_dates,e_prices]=blp_event(equity_ticker,'Last_Price',char(start_date),per);
         [b_names,b_dates,b_prices]=blp_event(benchmark_ticker,'Last_Price',char(start_date),per);
         
         n_pair=size(e_prices,2)-1;
         
         
         %event date
         event_date=[];
         for t = 1:length(input_date)
             numdate=datenum(input_date(t));
             event_date=[event_date;numdate]; % event_date is the array of event date in number format
         end    
         ascend_event_date=sortrows(event_date,1); 
         
         v_mABR=[];
         v_mCAR=[];
         v_mSAR=[];
         v_mSCAR=[];
         
         v_Cmax=[];
         v_Imax=[];
         v_Cmin=[];
         v_Imin=[];
         
         for j=1:n_pair
             tday1=e_dates(:, j+1); 
             adjcls1=e_prices(:, j+1); 
             tday1(find(~tday1))=[];
             adjcls1(find(~adjcls1))=[];
             %market index
             tday2=b_dates(:, j+1); 
             adjcls2=b_prices(:, j+1);  
             tday2(find(~tday2))=[];
             adjcls2(find(~adjcls2))=[];
             
             [foo,idx1,idx2]=intersect(tday1,tday2);
             adjcls=zeros(size(foo,1),2);
             adjcls(:,1)=adjcls1(idx1);
             adjcls(:,2)=adjcls2(idx2);
             tday=tday1(idx1);

             v_rtn=[rtn(adjcls(:,1)) rtn(adjcls(:,2))]; %transform price series into return series
             totsize=size(adjcls,1);
             tday=tday(2:end,1);
             tday_str=datestr(tday); %transfter num date to string date
             ABR=[];
             CAR=[];
             VABR=[];
         
             for i=1:size(ascend_event_date,1)        
                 e_ind=find(tday==ascend_event_date(i)); %find the index for the event date in tday
                 if isempty(e_ind)==0
                    event_begin=e_ind-pre_e;
                    estimate_begin = event_begin - estimate_window;
                    if estimate_begin>0
                    results=event_market_return(v_rtn,event_begin,estimate_window,event_window);
                    ABR=[ABR results.abr];
                    CAR=[CAR results.car];
                    VABR=[VABR results.vabr];
                    end
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
             
             v_Cmax=[v_Cmax C_max];
             v_Imax=[v_Imax I_max];
             v_Cmin=[v_Cmin C_min];
             v_Imin=[v_Imin I_min];
             
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
             
             if j==1
                v_mABR=[v_mABR m_ABR];
                v_mCAR=[v_mCAR m_CAR];
                v_mSAR=[v_mSAR m_SAR];
                v_mSCAR=[v_mSCAR m_SCAR];
             else
                v_mABR=supervertcat2(v_mABR,m_ABR);
                v_mCAR=supervertcat2(v_mCAR,m_CAR);
                v_mSAR=supervertcat2(v_mSAR,m_SAR);
                v_mSCAR=supervertcat2(v_mSCAR,m_SCAR);
             end
         end