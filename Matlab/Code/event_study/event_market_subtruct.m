function results=event_market_subtruct(adjcls,event_begin,event_window)
%          estimate_begin=event_begin-estimate_window;
%          estimate_end=event_begin-1;
         event_end=event_begin+event_window-1;
    
    % Then compute the abnormal return during the event window 
        abr=adjcls(event_begin:event_end,1)-adjcls(event_begin:event_end,2);
        car=zeros(event_window,1);
        for j=0:1:event_window-1
            car(j+1,1)=sum(abr(1:j+1,1));          
        end

results.abr=abr;
results.car=car;