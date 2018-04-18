clear all;
cd('C:\Users\ychen\Documents\MATLAB');
javaaddpath('C:\blp\ServerAPI\APIv3\JavaAPI\v3.4.5.5\lib\blpapi3.jar')
txt1={'015760 KS Equity';'EWY Equity';'USDKRW Curncy';'NLR Equity'};
startdate='2014/7/14';
enddate=today();
per={'daily','non_trading_weekdays','previous_value'};
c=blp;
for loop=1:size(txt1,1)
    new=char(txt1(loop));
    [d sec] = history(c, new,'CHG_PCT_1D',startdate,enddate,per);
    date1(1:size(d,1),loop+1)=d(1:size(d,1),1);
    rtn1(1:size(d,1),loop+1)=d(1:size(d,1),2);
    
end;
close(c);
for n_time=1:size(date1,1)
    date1(n_time,1)=n_time;
end
for n_stk=1:size(rtn1,1)
    rtn1(n_stk,1)=n_stk;
end

Y=rtn1(:,2);
X=rtn1(:,3:end);
[b,se,pval,inmodel,stats,nextstep,history]=stepwisefit(X,Y,'penter',0.10,'premove',0.20);