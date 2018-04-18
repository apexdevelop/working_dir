function results=event_constant_mean(adjcls,e_begin,event_window,estimate_window,pre_e)
% start and end date of estimate window
 e_start=e_begin-estimate_window;
 e_end=e_begin-1;      
%upordown  1---down  2---up        
 vt_m = mean(adjcls(e_start:e_end)); 
        
    
% Then compute the abnormal return during the event window      
 ret=zeros(event_window,1);
 abr=zeros(event_window,1);
 car=zeros(event_window,1);  %cumulative abnormal return 
 var_abr=zeros(event_window,1);
 var_car=zeros(event_window,1);
 for j=0:1:event_window-1
     if e_begin+j>size(adjcls,1) %if there is not enough data for event window
        ret(j+1,1)=adjcls(end,1);
        abr(j+1,1)=adjcls(end,1)-vt_m;
     else
        ret(j+1,1)=adjcls(e_begin+j,1);
        abr(j+1,1)=adjcls(e_begin+j,1)-vt_m;
     end
     car(j+1)=sum(abr(1:j+1,1));
 end 
 var_abr=repmat(var(abr),event_window,1);
 var_car=repmat(var(car),event_window,1);
 
 %adjust event-1 day CAR to 0
 adj_car=car-repmat(car(pre_e,1),event_window,1);
 
 sabr=abr./sqrt(var_abr); % t-stat of abnormal return
 scar=adj_car./sqrt(var_car);
 
 results.ret=ret;
 results.abr=abr;
 results.car=adj_car;
 results.vabr=var_abr;
 results.vcar=var_car;
 results.scar=scar;
 results.sabr=sabr;
