cd('C:\Documents and Settings\nthakkar.AC\My Documents');
i=1;
j=2;
%s=500;
band=1.5;


clear mtrade;
clear trade;
%bbstk;
tottrade=0;
r=1;
cross=1;
sl=5;
sg=10;
do=10;



[status_input,sheets_input]=xlsfinfo('shipper');
metrics=zeros(45,15);

count=0;

for n=1:9
sheets_input_char1=char(sheets_input(n+2));
[num1,txt1]=xlsread('shipper',sheets_input_char1);
for m=(n+1):10
sheets_input_char2=char(sheets_input(m+2));
[num2,txt2]=xlsread('shipper',sheets_input_char2);  
s1=size(txt1,1);  
tday1=txt1(2:s1, 1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
adjcls1=num1(1:(s1-1), 1); %ppp the last column contains the adjusted close prices.

tday1=datestr(datenum(tday1, 'mm/dd/yyyy'), 'yyyymmdd'); % convert the format into yyyymmdd.
tday1=str2double(cellstr(tday1)); % convert the date strings first into cell arrays and then into numeric format.

s2=size(txt2,1); 
tday2=txt2(2:s2, 1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
adjcls2=num2(1:(s2-1), 1); % PPP

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

adj=adjcls;
for div=1:1
cross=0;    
res=cadf(adjcls(:, 1), adjcls(:, 2), 0, 2); % run cointegration check using augmented Dickey-Fuller test

results=ols(adjcls(:, 1), adjcls(:, 2)); 

hedgeRatio=results.beta;
z=results.resid;
rtnres = olsrtn(adjcls(:, 1), adjcls(:, 2));

% Profit and loss 

zscr = (z(:,1)-mean(z))/std(z);
plot(zscr);
% Cross zero calcu
recs=size(adjcls,1);

for ctr=2:recs
   if (zscr(ctr-1,1) > 0 && zscr(ctr,1) < 0)
       cross=cross+1; 
   elseif (zscr(ctr-1,1)<0 && zscr(ctr,1) >0)
       cross=cross+1;
   end
       
end

pnlcalc; 
 
sumpair(div,1)=i;
sumpair(div,2)=j;
sumpair(div,3)=buy+sells; %no  of trades
sumpair(div,4)=buydollar+selldollar; % Dollar P&L
sumpair(div,5)=sumpair(div,4)/sumpair(div,3); % Average P&L
sumpair(div,6)=264/sumpair(div,3);
%sumpair(div,6)=daymkt/sumpair(div,3);
%sumpair(div,7)= 0;%std(mtrade(:,5));
sumpair(div,7)=win/sumpair(div,3);
sumpair(div,8)=hedgeRatio*adjcls(end,2)/adjcls(end,1); %Beta
sumpair(div,9)=res.adf;
sumpair(div,10)=cross;
sumpair(div,11)=results.rsqr;
sumpair(div,12)=rtnres.rsqr;
sumpair(div,13)=zscr(recs);

%test=zscr;
%test(:,2)=band;
%test(:,3)=-1*band;
%test(:,4)=0;
%subplot(2,1,1); plot(log(adjcls))
%subplot(2,1,2); plot(test)

%sammid=floor(length(tday)/2);

%if div==1 adjcls=adj(1:sammid,:); end
%if div==2 adjcls=adj(sammid:end,:); end
end
count=count+1;
metrics(count,:)=sumpair(1,:);
end
end
xlswrite('shipper_result',metrics,'9104 jp','b2');