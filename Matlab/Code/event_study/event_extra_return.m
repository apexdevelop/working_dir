function results=event_extra_return(adjcls,e_begin,e_end,estimate_window,event_window,upordown)

       
%upordown  1---down  2---up        
  vt_m = mean(adjcls(e_begin:e_end, 1));                    
% Then compute the abnormal return during the event window
         
  abr=zeros(event_window,1);
  sigma_abr=zeros(event_window,1);
  car=zeros(event_window,1);  %cumulative abnormal return 
  for j=0:1:event_window-1
      if e_end+1+j>size(adjcls,1)
            abr(j+1,1)=adjcls(end,1)-vt_m;
      else
            abr(j+1,1)=adjcls(e_end+1+j,1)-vt_m;
      end
      car(j+1)=sum(abr(1:j+1,1));
      sigma_abr(j+1,1)=std(abr(1:j+1,1));
           
  end

  sar=abr./sigma_abr; % t-stat of abnormal return
  p=[];
        
            
  % compute p-value 
        
  for j=0:1:event_window-1
      if upordown==2
         newp = 1-tcdf(sar(j+1),estimate_window-2); 
      else
         newp = tcdf(sar(j+1),estimate_window-2); %find large negtive
      end
         p=[p; newp];
            
  end
    
  p_matrix=reshape(p,event_window,1);
  
results.abr=abr;
results.pValue=p_matrix;
results.sar=sar;
results.car=car;