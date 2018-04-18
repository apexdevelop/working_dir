function [rel_Y]=extract_country(Y1,Y2,input_idx)
% Y1=equity_Y;
% Y2=index_Y;
% input_idx=3;
%% arguments explanation
         % first column of Y1 is log price of stock1
         % first column of Y2 is log price of index1
         % second column of Y1 is log price of stock2
         % second column of Y2 is log price of index2
         
         %input_idx=1 percent return
         %input_idx=2 price difference
         %input_idx=3 price
         %input_idx=4 log price
         %input_idx=5 log return
   
         %output_idx the same
%%
         
         if input_idx==4
            final_Y1=diff(Y1);
            final_Y2=diff(Y2);         
                     
         elseif input_idx==3
             final_Y1=rtn(Y1);
             final_Y2=rtn(Y2);
         elseif input_idx==1
             final_Y1=Y1;
             final_Y2=Y2;
         else
            
         end
         
         newY1=zeros(size(Y1,1),1);
         newY2=zeros(size(Y1,1),1);
        
         [beta1,bint1,r1,rint1,stats1]=regress(final_Y1(:,1),[ones(size(final_Y1,1),1) final_Y2(:,1)]); 
         [beta2,bint2,r2,rint2,stats2]=regress(final_Y1(:,2),[ones(size(final_Y1,1),1) final_Y2(:,2)]);
         
         if input_idx==4
            sum_r1=0;
            sum_r2=0;
            newY1(1,1)=Y1(1,1);
            newY2(1,1)=Y1(1,2);
            for i= 1:size(final_Y1,1)
                sum_r1=sum_r1+r1(i);
                newY1(i+1,1)=Y1(1,1)+sum_r1;
                sum_r2=sum_r2+r2(i);
                newY2(i+1,1)=Y1(1,2)+sum_r2;
            end
            
         elseif input_idx==3
            newY1(1,1)=Y1(1,1);
            newY2(1,1)=Y1(1,2);
            for i= 1:size(final_Y1,1)                
                newY1(i+1,1)=newY1(i,1)*(1+r1(i));
                newY2(i+1,1)=newY2(i,1)*(1+r2(i));
            end
         elseif input_idx==1                   
                newY1=r1;
                newY2=r2; 
         else
         
         end
                  
         rel_Y=[newY1 newY2];
         
end