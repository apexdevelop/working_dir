clear all;
cd('C:\Users\ychen\Documents\MATLAB');
javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar');
shname='shipping';
[~,txt_f]=xlsread('factors_pval.xlsx',shname,'b35:b36'); %weekly factor
startdate='2012/01/04';
enddate=today();
per_n={'daily','non_trading_weekdays','nil_value'};
per_p={'daily','non_trading_weekdays','previous_value'};
field1='Last_Price';
field2='CHG_PCT_1D';

c=blp;
for loop=1:size(txt_f,1)
    new=char(txt_f(loop));
    [d1, sec] = history(c, new,field2,startdate,enddate,per_n);
    [d2, sec] = history(c, new,field1,startdate,enddate,per_p);

    dates_5d(1:size(d1,1),loop)=d1(1:size(d1,1),1);
    rtns_5d(1:size(d1,1),loop)=d1(1:size(d1,1),2);
    fpxs(1:size(d2,1),loop)=d2(1:size(d2,1),2);
end
close(c);
d0=5;
re_rtns_5d=zeros(size(rtns_5d,1),size(txt_f,1));

for loop=1:size(txt_f,1)
    v_idx_nemp=find(~isnan(rtns_5d(:,loop)));
    v_d=[d0;diff(v_idx_nemp)];
    idx=1;
    for j=1:v_idx_nemp(end)
        if j<=v_idx_nemp(idx)
           re_rtns_5d(j,loop)=rtns_5d(v_idx_nemp(idx),loop)/v_d(idx);
        else
           idx=idx+1;
           re_rtns_5d(j,loop)=rtns_5d(v_idx_nemp(idx),loop)/v_d(idx);
        end
    end 
end