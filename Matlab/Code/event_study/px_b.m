javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.6.1.0\lib\blpapi3.jar')
cd('C:\Users\ychen\Documents');
clear d;
clear bbpx;
clear btxt;
clear dtxt;
clear px;
window=3600;
enddate=today();
startdate=today()-window;
[~,txt]=xlsread('input_ticker','pxtob','c2:c92');

% GET DATA
c=blp;

for loop=1:size(txt,1)
    new=[char(txt(loop)),' Equity'];    
%     [d sec] = history(c, new,'PX_TO_BOOK_RATIO',startdate,enddate);
      [d sec] = history(c, new,'PX_TO_BOOK_RATIO',startdate,enddate,'monthly');
%      [d sec] = history(c, new,'BS_CASH_NEAR_CASH_ITEM',startdate,enddate,'monthly');
%     [d sec] = history(c, new,'PX_TO_TANG_BV_PER_SH',startdate,enddate,'monthly');
    btxt(1:size(d,1),loop+1)=d(1:size(d,1),1);
    bbpx(1:size(d,1),loop+1)=d(1:size(d,1),2);
    names(loop)=sec;    
end;
close(c);

n_time=0;
for n_time=1:size(btxt,1)
    btxt(n_time,1)=n_time;
end

n_stk=0;
for n_stk=1:size(bbpx,1)
    bbpx(n_stk,1)=n_stk;
end

% dtxt=sortrows(btxt,-1);
% ddpx=sortrows(bbpx,-1);


Z=[];
P=[];
ST=[];%start date
ET=[];%end date
C=[];%store data points
for i=1 : size(bbpx,2)-1
px=bbpx(:,i+1);
t=btxt(:,i+1);
baddata_p=find(~px);
px(baddata_p)=[];
P=[P; px(end)];
z_px=(px-mean(px))/std(px);
Z=[Z; z_px(end)];
baddata_t=find(~t);
t(baddata_t)=[];
count=length(t);
C=[C; count];
ST=[ST; t(1)];
ET=[ET; t(end)];
end

ST_str=datestr(ST);
ST_cell=cellstr(ST_str);
ET_str=datestr(ET);
ET_cell=cellstr(ET_str);
 %convert string to cell string,because ts object require cell string date
% xlswrite('px_to_book_0514',Z(1,:),'sheet1','b2');
% xlswrite('px_to_book_0514',D(1,:),'sheet1','c2');
% xlswrite('px_to_book_0514',dates_cell,'sheet1','a2');
% xlswrite('px_to_book_0514',names,'sheet1','b1');
% index=1;
% test(:,1)=Z(:,index);
% test(:,2)=mean(Z(:,index))+2*std(Z(:,index));
% test(:,3)=mean(Z(:,index))-2*std(Z(:,index));

% secname=[char(names(index)) ' p/b ratio'];
% ts1=timeseries(test,dates_cell,'name',secname);
% ts1.TimeInfo.StartDate=dates_str(1,:); %must be string
% ts1.TimeInfo.Format='mmm yy';
% plot(ts1,'LineWidth',2)
% xlabel('Time')
% ylabel('p/b ratio')
% axis tight
% grid on
