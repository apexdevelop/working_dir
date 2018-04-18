cd('C:\Documents and Settings\YChen\My Documents\Yan\ClarifI Xpress');
[num,txt]=xlsread('data source for data in clarifi','JGB','h2:k1445');
s=size(num,1);
%drawup=reshape(num(:,2),1,s);
drawdown=reshape(num(:,3),1,s);
x=1:s;

[pks1,locs1]=findvallys(drawdown,'MINPEAKHEIGHT',-0.8,'MINPEAKDISTANCE',floor(s/30),'THRESHOLD',0.00,'SORTSTR','none');

%[pks1,locs1]=findpeaks(drawup,'MINPEAKHEIGHT',0.8,'MINPEAKDISTANCE',floor(s/50),'THRESHOLD',0.00,'NPEAK',7,'SORTSTR','none');

subplot(2,1,1); plot(drawdown);
hold on; 
plot(x(locs1(1,:)),pks1+0.05,'k^','markerfacecolor',[1 0 0]);

%         if size(locs1)>size(locs2)
%         for t=1:size(locs2)
%             if abs(locs1(t)-locs2(t))>30 && abs(locs2(t)-locs1(t+1)<30)
%                 locs1(t)=[];
%             end
%         end
%         else
%             if abs(locs1(size(locs1,2))-locs2(size(locs2,2)))>30
%                 locs2(size(locs2,2))=[];
%             end
%             if  abs(locs1(1)-locs2(1))>30
%                 locs2(1)=[];
%             end
%         end

%new_stk1=reshape(stk1,n_stock*(n_stock-1)/2+1,1);
%new_stk2=reshape(stk2,n_stock*(n_stock-1)+1,1);
%xlswrite('coint_result',new_stk1,'jan11_apex','b1');
%xlswrite('coint_result',new_stk2,'jan11_apex','c1');
%xlswrite('coint_result',metrics,'jan11_apex','d2');
