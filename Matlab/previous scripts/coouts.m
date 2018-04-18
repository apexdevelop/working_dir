 % make sure previously defined variables are erased.
clear summ2, 
clear summary1;
clear mtrade;
clear trade;

r=1;  
tottrade=0;

y=25;
band=1;
s=240;
sl=5
sg=7.5;
do=10;

for i = 1:y
    
 
tday1=txt(5:s, summ1(i,1)*2-1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
adjcls1=num(1:s,summ1(i,1)*2-1); %ppp the last column contains the adjusted close prices.

tday1=datestr(datenum(tday1, 'mm/dd/yyyy'), 'yyyymmdd'); % convert the format into yyyymmdd.
tday1=str2double(cellstr(tday1)); % convert the date strings first into cell arrays and then into numeric format.

tday2=txt(5:s, summ1(i,2)*2-1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
adjcls2=num(1:s, summ1(i,2)*2-1); % PPP

tday2=datestr(datenum(tday2, 'mm/dd/yyyy'), 'yyyymmdd'); % convert the format into yyyymmdd.
tday2=str2double(cellstr(tday2)); % convert the date strings first into cell arrays and then into numeric format.


tday=union(tday1, tday2); % find all the days when either GLD or GDX has data.
[foo idx idx1]=intersect(tday, tday1);
adjcls=NaN(length(tday), 2); % combining the two price series
adjcls(idx, 1)=adjcls1(idx1);
[foo idx idx2]=intersect(tday, tday2);
adjcls(idx, 2)=adjcls2(idx2);
baddata=find(any(~isfinite(adjcls), 2)); % days where any one price is missing
tday(baddata)=[];
adjcls(baddata, :)=[];

res=cadf(adjcls(:, 1), adjcls(:, 2), 0, 2); % run cointegration check using augmented Dickey-Fuller test

% prt(res, vnames); 


results=ols(adjcls(:, 1), adjcls(:, 2)); 

hedgeRatio=results.beta;
z=results.resid;
rtnres = olsrtn(adjcls(:, 1), adjcls(:, 2));

output(r,1)= i; output(r,2)= j; output(r,3)= res.adf ;
output(r,4)= results.beta; output(r,5)=results.rsqr;

% A hedgeRatio of 1.6766 was found. I.e. GLD=1.6766*GDX + z, where z can be interpreted as the
% spread GLD-1.6766*GDX and should be stationary.

zscr = (z(:,1)-mean(z))/std(z);

% Cross zero calcu
cross=0;
for ctr=2:size(adjcls,2)
   if (zscr(ctr-1,1) > 0 && zscr(ctr,1) < 0)
       cross=cross+1; 
   elseif (zscr(ctr-1,1)<0 && zscr(ctr,1) >0)
       cross=cross+1;
   end
       
end


hedgeRatio=(summ1(i,10)+hedgeRatio)/2; % VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVv

%%%%%if hedgeRatio > 0.5 && hedgeRatio < 2.5 && cross > 3 && results.rsqr>abs(0.4)&& rtnres.rsqr>abs(0.3)&& res.adf<-2.5
    
tog=0;
buy=0;
sells=0;
buydollar=0;
selldollar=0;
win=0;
daymkt=0;

recs=size(adjcls,1);

for ctr=1:recs
   if adjcls(ctr,2)>0 && adjcls(ctr,1)>0  
    if (zscr(ctr, 1)>band && tog==0)
        tog=1;
        trade(ctr,3)=100/(adjcls(ctr,1));
        trade(ctr,2)=(hedgeRatio*trade(ctr,3));
        trade(ctr,4)=trade(ctr,2)*adjcls(ctr,2)-100;
        sells=sells+1;
        bctr=ctr;
     else if (zscr(ctr, 1) < -1*band && tog==0)
        tog=2;
        trade(ctr,2)=100/adjcls(ctr,1);
        trade(ctr,3)=(hedgeRatio*trade(ctr,2));
        trade(ctr,4)=100-trade(ctr,3)*adjcls(ctr,2);
        sells=sells+1;
        sctr=ctr;
        end
    end

    trade(ctr,1)=tog;
    if tog==1 pnl=(adjcls(ctr,2)*trade(bctr,2)- adjcls(ctr,1)*trade(bctr,3))-trade(bctr,4); trade(ctr,7)=pnl;end

    if tog==1 
        if (zscr(ctr, 1)<-1 || ctr==recs || pnl<-1*sl || pnl>sg || ctr-bctr>do)
  
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
             if ((zscr(ctr, 1)> 1) || ctr==recs || pnl<-1*sl || pnl>sg || ctr-sctr>do)
            tog=0;
            trade(ctr,5)=pnl;
            buydollar=buydollar+trade(ctr,5);
            trade(ctr,3)=adjcls(ctr,1)*trade(sctr,2);
            trade(ctr,2)=trade(sctr,3)*adjcls(ctr,2);
            trade(ctr, 6)=ctr-sctr;
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
summary2(r,1)=summ1(i,1);
summary2(r,2)=summ1(i,2);
summary2(r,3)=buy+sells; %no  of trades
summary2(r,4)=buydollar+selldollar; % Dollar P&L
summary2(r,5)=summary2(r,4)/summary2(r,3); % Average P&L
summary2(r,6)=daymkt/summary2(r,3);
summary2(r,8)=win/summary2(r,3);
summary2(r,7)= std(mtrade(:,5));
summary2(r,9)=summary2(r,4)/summary2(r,7);
summary2(r,10)=hedgeRatio;
summary2(r,11)=res.adf;
summary2(r,12)=cross;
summary2(r,13)=results.rsqr;
summary2(r,15)=zscr(recs);
summary2(r,14)=rtnres.rsqr;
%%%end

plot(zscr);

r=r+1;
i=i+1;
end

summ2=sortrows(summary2,11);
% plot(z); % This should produce a chart similar to 
