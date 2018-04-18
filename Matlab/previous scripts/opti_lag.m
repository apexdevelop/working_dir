
function [best_choice]=opti_lag(adjcls1_row,adjcls2_row,tries)
        metrics3=zeros(tries,1);
        count3=0;
        
        f_lable=zeros(4,1);
        for d1=15:2:30
            for t1=0.01:0.01:0.05
                [pks1,locs1]=findpeaks1(adjcls1_row,'MINPEAKHEIGHT',mean(adjcls1_row),'MINPEAKDISTANCE',d1,'THRESHOLD',t1);
                for d2=15:2:30
                    for t2=0.01:0.01:0.05
                    lable =[];
                    lable=[lable d1 t1 d2 t2];
                    lable_col=reshape(lable,4,1);
                    f_lable=[f_lable lable_col];
                    [pks2,locs2]=findpeaks1(adjcls2_row,'MINPEAKHEIGHT',mean(adjcls2_row),'MINPEAKDISTANCE',d2,'THRESHOLD',t2);
                    
           
        num1=size(locs1,2);
        num2=size(locs2,2);
        locs1_col=reshape(locs1,num1,1);
        locs2_col=reshape(locs2,num2,1);
        
        if (num1==num2)
           lag=locs1_col-locs2_col;
           e_lag=sum(lag.^2);
        end 
        
        if abs(num1-num2)==1
           if num2-num1==1
              head=abs(locs2_col(1)-locs1_col(1));
              tail=abs(locs2_col(num2)-locs1_col(num1));
              if head<tail
                  locs2_col(num2)=[];
              else
                  locs2_col(1)=[];
              end
           else 
              head=abs(locs1_col(1)-locs2_col(1));
              tail=abs(locs1_col(num1)-locs2_col(num2));
              if head<tail
                 locs1_col(num1)=[];
              else
                 locs1_col(1)=[];
              end
           end
          lag=locs1_col-locs2_col;
          e_lag=sum(lag.^2);
        end
        
        if abs(num1-num2)>1
           e_lag=Inf;
        end 
        count3=count3+1;
        metrics3(count3,:)=e_lag;

        end 
        end
        end
        end
        [C I]=min(metrics3);
        best_choice=f_lable(:,I+1);
end