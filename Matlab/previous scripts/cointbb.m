  
function cointbb(i,j,s,band)

c1=bloomberg(8194,'172.16.1.92');

% make sure previously defined variables are erased.
clear mtrade;
clear trade;

r=1;
cross=1;
sl=100000;
sg=100000;
do=5000;

[num, txt]=xlsread('inco'); %PPP read a spreadsheet named "GLD.xls" into MATLAB. 
%[num2, txt2]=xlsread('inco'); % read a spreadsheet named "GDX.xls" into MATLAB.

y=size(num);

s=266;    
tday1=txt(2:s, 1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
 
tday1=datestr(datenum(tday1, 'mm/dd/yyyy'), 'yyyymmdd'); % convert the format into yyyymmdd.
 
tday1=str2double(cellstr(tday1)); % convert the date strings first into cell arrays and then into numeric format.
 
adjcls1=num(1:(s-1), 1); %ppp the last column contains the adjusted close prices.


 
tday2=txt(2:s, 1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.

 
tday2=datestr(datenum(tday2, 'mm/dd/yyyy'), 'yyyymmdd'); % convert the format into yyyymmdd.
 
tday2=str2double(cellstr(tday2)); % convert the date strings first into cell arrays and then into numeric format.

adjcls2=num2(1:(s-1), 2); % PPP

tday=union(tday1, tday2); % find all the days when either GLD or GDX has data.

[foo idx idx1]=intersect(tday, tday1);

adjcls=NaN(length(tday), 2); % combining the two price series

adjcls(idx, 1)=adjcls1(idx1);

[foo idx idx2]=intersect(tday, tday2);

adjcls(idx, 2)=adjcls2(idx2);

baddata=find(any(~isfinite(adjcls), 2)); % days where any one price is missing

tday(baddata)=[];

adjcls(baddata, :)=[];

vnames=strvcat('GLD', 'GDX');

res=cadf(adjcls(:, 1), adjcls(:, 2), 0, 2); % run cointegration check using augmented Dickey-Fuller test

prt(res, vnames); 

results=ols(adjcls(:, 1), adjcls(:, 2)); 

hedgeRatio=results.beta;
z=results.resid;
rtnres = olsrtn(adjcls(:, 1), adjcls(:, 2));

output(r,1)= i; output(r,2)= j; output(r,3)= res.adf ; output(r,4)= results.beta; output(r,5)=results.rsqr;

% Profit and loss 

zscr = (z(:,1)-mean(z))/std(z);
plot(zscr);
% Cross zero calcu
for ctr=2:s-1
   if (zscr(ctr-1,1) > 0 && zscr(ctr,1) < 0)
       cross=cross+1; 
   elseif (zscr(ctr-1,1)<0 && zscr(ctr,1) >0)
       cross=cross+1;
   end
       
end


tog=0;
buy=0;
sells=0;
buydollar=0;
selldollar=0;
win=0;
daymkt=0
tottrade=0

for ctr=1:s-2
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
        if (zscr(ctr, 1)<-1 || ctr==s-2 || pnl<-1*sl || pnl>sg || ctr-bctr>do)
  
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
            mtrade(tottrade,6)=daymkt;
            mtrade(tottrade,7)= tottrade;
        
            if trade(ctr,5)>0, win=win+1; end
        end  
    end

    if tog==2 pnl=(adjcls(ctr,1)*trade(sctr,2)-adjcls(ctr,2)*trade(sctr,3))-trade(sctr,4); trade(ctr,7)=pnl; end
    
    if  (tog==2) 
             if ((zscr(ctr, 1)> 1) || ctr==s-2 || pnl<-1*sl || pnl>sg || ctr-sctr>do)
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
            mtrade(tottrade,6)=daymkt;
            mtrade(tottrade,7)=tottrade;
           
         
        if trade(ctr,5)>0, win=win+1; end
         end
      end
    ctr=ctr+1;
    pnl=0;
   end
end    
 
summary(1,1)=i;
summary(1,2)=j;
summary(1,3)=buy+sells; %no  of trades
summary(1,4)=buydollar+selldollar; % Dollar P&L
summary(1,5)=summary(1,4)/summary(1,3); % Average P&L
summary(1,6)=daymkt/summary(1,3);
summary(1,7)= std(mtrade(:,5));
summary(1,8)=win/summary(1,3);
summary(1,9)=summary(1,4)/summary(1,7);
summary(1,10)=hedgeRatio;
summary(1,11)=res.adf;
summary(1,12)=cross;
summary(1,13)=results.rsqr;
summary(1,15)=zscr(s-1);
summary(1,14)=rtnres.rsqr;
summ=sortrows(summary,11)
subplot(2,1,1); plot(log(adjcls))
test=zscr;
test(:,2)=band;
test(:,3)=-1*band;
test(:,4)=0;
subplot(2,1,2); plot(test)

ans
