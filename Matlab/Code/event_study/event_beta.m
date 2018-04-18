function results=event_beta(ret_ets,ret_fts,e_begin,event_window,estimate_window,pre_e)
% start and end date of estimate window
 e_start=e_begin-estimate_window;
 e_end=e_begin-1;      
%upordown  1---down  2---up        
 m_e = mean(ret_ets(e_start:e_end)); 
 m_f = mean(ret_fts(e_start:e_end));
        
    
% Then compute the abnormal return during the event window      
 abr_e=zeros(event_window,1);
 car_e=zeros(event_window,1);  %cumulative abnormal return 
 abr_f=zeros(event_window,1);
 car_f=zeros(event_window,1);  %cumulative abnormal return 
 
 for j=0:1:event_window-1
     if e_begin+j>size(ret_ets,1) %if there is not enough data for event window
        abr_e(j+1,1)=ret_ets(end,1)-m_e;
        abr_f(j+1,1)=ret_fts(end,1)-m_f;
     else
        abr_e(j+1,1)=ret_ets(e_begin+j,1)-m_e;
        abr_f(j+1,1)=ret_fts(e_begin+j,1)-m_f;
     end
     car_e(j+1)=sum(abr_e(1:j+1,1));
     car_f(j+1)=sum(abr_f(1:j+1,1));
 end
 X = [ones(event_window,1) abr_f];
 b=regress(abr_e,X);
 results.beta=b(2);
