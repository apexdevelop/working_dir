clear all;
cd('C:\Users\ychen\Documents\MATLAB');
javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.6.1.0\lib\blpapi3.jar')
txt={'4/30/2009';'7201 JP Equity';'7203 JP Equity'};

enddate=today();
startdate=char(txt(1));
c=blp;
for loop=2:size(txt,1)
    new=char(txt(loop));
    [d sec] = history(c, new,'Last_Price',startdate,enddate);
    date(1:size(d,1),loop)=d(1:size(d,1),1);
    price(1:size(d,1),loop)=d(1:size(d,1),2);
    
end;
close(c);
for n_time=1:size(date,1)
    date(n_time,1)=n_time;
end

for n_stk=1:size(price,1)
    price(n_stk,1)=n_stk;
end
n_ob=size(date,1);

%% resample stock1 and stock2
tday1=date(:, 2); 
adjcls1=price(:, 2);
tday1(find(~tday1))=[];
adjcls1(find(~adjcls1))=[];
    
tday2=date(:, 3); 
adjcls2=price(:, 3);                 
[n1n2, idx1, idx2]=intersect(tday1, tday2); 
           
tday=tday2(idx2);
baddata=find(~tday);
tday(baddata)=[];


adjcls=zeros(size(n1n2,1),2);
adjcls(:,1)=adjcls1(idx1);%stock1
adjcls(:,2)=adjcls2(idx2);%stock2
           
%convert to log prices
adjcls=log(adjcls);%include index


i=1;
j=2;
tog=0;
buys=0;
sells=0;
buydollar=0;
selldollar=0;
win=0;
daymkt=0;

tottrade=0;
r=1;
cross=1;
sl=5;
sg=10;
do=10;
band=1.5*std(zscr);

recs=size(adjcls,1); % recs will also be used in pnlcal


        
for ctr=1:recs
   if adjcls(ctr,2)>0 && adjcls(ctr,1)>0  
    if (zscr(ctr, 1)>band && tog==0)
        tog=1;
        trade(ctr,3)=100/(adjcls(ctr,1));  %short the first one
        trade(ctr,2)=(hedgeRatio*trade(ctr,3)); %buy the second one
        trade(ctr,4)=trade(ctr,2)*adjcls(ctr,2)-100;
        sells=sells+1;
        bctr=ctr;
     else if (zscr(ctr, 1) < -1*band && tog==0)
        tog=2;
        trade(ctr,2)=100/adjcls(ctr,1);
        trade(ctr,3)=(hedgeRatio*trade(ctr,2));
        trade(ctr,4)=100-trade(ctr,3)*adjcls(ctr,2);
        buys=buys+1;
        sctr=ctr;
        end
    end

    trade(ctr,1)=tog;
    if tog==1 pnl=(adjcls(ctr,2)*trade(bctr,2)- adjcls(ctr,1)*trade(bctr,3))-trade(bctr,4); trade(ctr,7)=pnl;end

    if tog==1 
        if (zscr(ctr, 1)<0 || ctr==recs || pnl<-1*sl || pnl>sg || ctr-bctr>do)
  
            tog=0;

            trade(ctr,5)=pnl;
            selldollar=selldollar+trade(ctr,5);
            trade(ctr,3)=adjcls(ctr,1)*trade(bctr,2);
            trade(ctr,2)=trade(bctr,3)*adjcls(ctr,2);
            trade(ctr, 6)=ctr-bctr;
            daymkt=daymkt+trade(ctr,6);

            tottrade=tottrade+1;    
            mtrade(tottrade,1)=i;
            mtrade(tottrade,2)=j;
            mtrade(tottrade,3)=tday(ctr);
            mtrade(tottrade,4)=1;
            mtrade(tottrade,5)=trade(ctr,5);
            mtrade(tottrade,6)=ctr-bctr;
            mtrade(tottrade,7)= tottrade;
        
            if trade(ctr,5)>0, win=win+1; end
        end  
    end

    if tog==2 pnl=(adjcls(ctr,1)*trade(sctr,2)-adjcls(ctr,2)*trade(sctr,3))-trade(sctr,4); trade(ctr,7)=pnl; end
    
    if  (tog==2) 
             if ((zscr(ctr, 1)> 0) || ctr==recs || pnl<-1*sl || pnl>sg || ctr-sctr>do)
            tog=0;
            trade(ctr,5)=pnl;
            buydollar=buydollar+trade(ctr,5);
            trade(ctr,3)=adjcls(ctr,1)*trade(sctr,2);
            trade(ctr,2)=trade(sctr,3)*adjcls(ctr,2);
            trade(ctr,6)=ctr-sctr;
            daymkt=daymkt+trade(ctr,6);

            tottrade=tottrade+1;
            mtrade(tottrade,1)=i;
            mtrade(tottrade,2)=j;
            mtrade(tottrade,3)=tday(ctr);
            mtrade(tottrade,4)=2;
            mtrade(tottrade,5)=trade(ctr,5);
            mtrade(tottrade,6)=ctr-sctr;
            mtrade(tottrade,7)=tottrade;
           
         
        if trade(ctr,5)>0, win=win+1; end
         end
      end
    ctr=ctr+1;
    pnl=0;
   end
  
end