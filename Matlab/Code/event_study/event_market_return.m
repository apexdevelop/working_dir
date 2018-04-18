function results=event_market_return(v_rtn,event_begin,estimate_window,event_window)
       
        estimate_begin=event_begin-estimate_window;
        estimate_end=event_begin-1;
        

            X=[ones(estimate_window,1) v_rtn(estimate_begin:estimate_end,2)];
            [b, ~, r, ~, stats]= regress(v_rtn(estimate_begin:estimate_end, 1), X);        
            alpha=b(1);
            beta=b(2);
            var_resid=stats(4); %Rsqr,F stat, p value,estimate of error variance

        
        m_rm=mean(v_rtn(estimate_begin:estimate_end, 2)); %mean of market return during pre-event period
    
    % Then compute the abnormal return during the event window
    
        rtm=zeros(event_window,1);
        rts=zeros(event_window,1);
        var_abr=zeros(event_window,1);
        var_car=zeros(event_window,1);
        
        var_bench_estimate=sum((v_rtn(estimate_begin:estimate_end, 2)-m_rm).^2);
        
        for j=0:1:event_window-1
            if event_begin+j>size(v_rtn,1)
               rtm(j+1,1)=v_rtn(end,2);
               rts(j+1,1)=v_rtn(end,1);
            else
               rtm(j+1,1)=v_rtn(event_begin+j,2);
               rts(j+1,1)=v_rtn(event_begin+j,1);
            end
            var_abr(j+1,1)=var_resid*(1+1/estimate_window+(rtm(j+1,1)-m_rm)^2/var_bench_estimate);
            var_car(j+1,1)=var_resid*(j+1);
        end

        abr=rts-alpha-beta*rtm;
        sabr=abr./sqrt(var_abr); % t-stat of abnormal return
        
        p=[];
        car=zeros(event_window,1);
        for j=0:1:event_window-1
            newp = 1-tcdf(sabr(j+1),estimate_window-2);   
            p=[p; newp];
            car(j+1)=sum(abr(1:j+1));
        end
        scar=car./sqrt(var_car);
        
         p_matrix=reshape(p,event_window,1);
         
         results.rts=rts;
         results.rtm=rtm;
         results.pValue=p_matrix;
         results.abr=abr;
         results.vabr=var_abr;
         results.car=car;
         results.scar=scar;
         results.sabr=sabr;