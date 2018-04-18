function [ABR,CAR]=event_study_snapshot(input_ticker,input_date,input_window,start_date)                  
         pre_e=cell2mat(input_window(1));
         post_e=cell2mat(input_window(2));
         event_window=pre_e+post_e+1;
         estimate_window=cell2mat(input_window(3));

         
         per='daily';

         [names,dates,prices]=blp_event(input_ticker,'Last_Price',char(start_date),per);

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

         event_date=[];
         for t = 1:length(input_date)
             numdate=datenum(input_date(t));
             event_date=[event_date;numdate]; % event_date is the array of event date in number format
         end    
         ascend_event_date=sortrows(event_date,1); 
         
         ABR=[];
         CAR=[];
         
         for i=1:size(ascend_event_date,1)        
             e_ind=find(tday==ascend_event_date(i)); %find the index for the event date in tday
             if isempty(e_ind)==0
                event_begin=e_ind-pre_e;
                if size(dates,2)<=2
                   results=event_constant_mean(v_rtn,event_begin,event_window,estimate_window);
                else
                   results=event_market_return(v_rtn,event_begin,estimate_window,event_window);
                end
                ABR=[ABR results.abr];
                CAR=[CAR results.car];
             end
         end
         
         ABR=100.*ABR;
         CAR=100.*CAR;
         
         for i=1:size(ascend_event_date,1)
             CAR(1:end,i)=CAR(1:end,i)-repmat(CAR(pre_e,i),size(CAR,1),1);
         end