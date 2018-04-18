% Yan 2013 Feb 21 try to find auto correlation in pod.
% has been normolized
% reference: tsdateinterval timeseries tsdemo
javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.6.1.0\lib\blpapi3.jar')
cd('C:\Users\ychen\Documents');

clear all;

window=7000; %window is all the calendar days

%import currency data
[ct,cpx,cnames]=importdata('input_ticker','curncy','a1:a5','last_price',window,1);
carray={'KRW','JPY','HKD','TWD','USD'};
% 1---KRW  2---JPY 3--HKD 4---TWD 5---USD

% import adr price data
[at,apx,anames]=importdata('input_ticker','pod','a2:a2','last_price',window,2);

% import local price data
[lt,lpx,lnames]=importdata('input_ticker','pod','b2:b2','last_price',window,2);
% import shares per adr
[spa,txt]=xlsread('input_ticker','pod','c2:c2');
% import local ticker currency
[num,crn]=xlsread('input_ticker','pod','d2:d2');

% define the weight array
w=[];
for e=lookback:-1:1
    neww=0.96^e;
    w=[w; neww];    
end
w=w/sum(w);

A=[];%store all the absolute pod;
Am=[];
B=[]; %store all the market pod;
Bm=[];
C=[]; %store all the current pod;
Cm=[];

 for i=1:size(crn,1)
    for s=1:size(carray,2)
        if char(crn(i,1))==char(carray(s))
            cind=s;
        end
    end
    atstr=datestr(at(:,i+1));
    ctstr=datestr(ct(:,cind+1));
    %intersect adr price date with currency price date
    [anc, aidx, cidx]=intersect(at(:,i+1), ct(:,cind+1));   
    tmpapx=apx(aidx,i+1);
    tmpcpx=cpx(cidx,cind+1);
    ancstr=datestr(anc);
    %Then intersect with local price date
    ltstr=datestr(lt(:,i+1));
    [ancnl, ancidx, lidx]=intersect(anc, lt(:,i+1));
    ancnlstr=datestr(ancnl);
    newapx=tmpapx(ancidx);
    newcpx=tmpcpx(ancidx);
    newlpx=lpx(lidx,i+1);
    finalapx=newapx.*newcpx/spa(i,1);
    pod=finalapx./newlpx; % This is the absolute pod of each stock
    
    %import market bench market etf
    [et,epx,enames]=importdata('input_ticker','curncy','c1:c5','last_price',window,3);
    %import market bench market index
    [it,ipx,inames]=importdata('input_ticker','curncy','d1:d5','last_price',window,3);
    %compute the weighted moving average
    
    %intersect corresponding market eft date with market index date
    [eni eidx iidx]=intersect(et(:,cind+1), it(:,cind+1));   
    tmpepx=epx(eidx,cind+1);
    tmpipx=ipx(iidx,cind+1);
    enistr=datestr(eni);
    %calculate market benchmark pod
    bpod=tmpepx./tmpipx;
    
    tday1=ancnl;
    tday2=eni;
    adjcls1=pod;
    adjcls2=bpod;
    tday=union(tday1, tday2); 
    baddata1=find(any(tday));
    tday(baddata1)=[];
    [~, idx, idx1]=intersect(tday, tday1); %foo=tday(idx,:),foo=tday1(idx1,:)
    adjcls=NaN(length(tday), 2); % combining the two price series,initialized by NaN matrix
    adjcls(idx, 1)=adjcls1(idx1);
    [foo, idx, idx2]=intersect(tday, tday2);
    adjcls(idx, 2)=adjcls2(idx2);
    baddata=find(any(~isfinite(adjcls), 2)); % days where any one price is missing,isfinite()=0 if NaN
    tday(baddata)=[];
    adjcls(baddata, :)=[];
    tday_str=datestr(tday); %transfter num date to string date
    
    adjcls=rtn(adjcls); %Turn price series into return series
    tday=tday(2:end,1);
    event_date={'02/03/2003','02/07/2008'}; % negative surprise
    estimate_window=40;
    pre_e=5;
    post_e=22;
    ew=pre_e+post_e+1;
    
     P=[];
    CAR=[];
    for i=1:size(event_date,2)        
        edn=datenum(event_date(i)); %tranform date from string value to integers
        e_ind=find(tday==edn); %find the index for the event date in tday
        e_begin=e_ind-pre_e-estimate_window;
        e_end=e_ind-pre_e-1;
        results=event_market_return(adjcls,e_begin,e_end,estimate_window,ew);
        new_colp=results.pValue;
        P=[P new_colp];
        CAR=[CAR results.car];
   end
    
   m_P=mean(P,2);
   m_CAR=mean(CAR,2); 
 end
