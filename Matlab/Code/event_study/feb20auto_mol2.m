% Yan 2013 Feb 21 try to find auto correlation in pod.
% has been normolized
% reference: tsdateinterval timeseries tsdemo
javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.8.8.2\lib\blpapi3.jar');
cd('C:\Users\ychen\Documents\data');
clear apx;
clear at;
clear ancidx;
clear ancnl;
clear ancnlstr;
clear ancstr;
clear cidx;
clear cind;
clear cpx;
clear crn;
clear ct;
clear foo;
clear finalapx;
clear lidx;
clear lpx;
clear lt;
clear num;
clear spa;
clear tmpcpx;
clear tmplpx;
clear tmpapx;
clear eni;
clear eniidx;
clear eninp;
clear eninpstr;

window=150; %window is all the calendar days

lookback=5;%number of days used to conduct the moving average


%import currency data
[ct,cpx,cnames]=importdata('input_ticker','curncy','a1:a5','last_price',window,1);
carray={'KRW','JPY','HKD','TWD','USD'};
% 1---KRW  2---JPY 3--HKD 4---TWD 5---USD

% import adr price data
[at,apx,anames]=importdata('input_ticker','pod','a2:a47','last_price',window,2);

% import local vwap price data
[lt,lpx,lnames]=importdata('input_ticker','pod','b2:b47','vwap',window,3);
% import shares per adr
[spa,txt]=xlsread('input_ticker','pod','c2:c47');
% import local ticker currency
[num,crn]=xlsread('input_ticker','pod','d2:d47');

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
    [anc aidx cidx]=intersect(at(:,i+1), ct(:,cind+1));   
    tmpapx=apx(aidx,i+1);
    tmpcpx=cpx(cidx,cind+1);
    ancstr=datestr(anc);
    %Then intersect with local price date
    ltstr=datestr(lt(:,i+1));
    [ancnl ancidx lidx]=intersect(anc, lt(:,i+1));
    ancnlstr=datestr(ancnl);
    newapx=tmpapx(ancidx);
    newcpx=tmpcpx(ancidx);
    newlpx=lpx(lidx,i+1);
    finalapx=newapx.*newcpx/spa(i,1);
    pod=finalapx./newlpx; % This is the absolute pod of each stock
    
    
    
    %import market bench market etf_adr
    [et,epx,enames]=importdata('input_ticker','curncy','c1:c5','last_price',window,3);
    %import market bench market index vwap
    [it,ipx,inames]=importdata('input_ticker','curncy','d1:d5','vwap',window,3);
    %compute the weighted moving average
    
    %intersect corresponding market eft date with market index date
    [eni eidx iidx]=intersect(et(:,cind+1), it(:,cind+1));   
    tmpepx=epx(eidx,cind+1);
    tmpipx=ipx(iidx,cind+1);
    enistr=datestr(eni);
    %then intersect with pod date
    [eninp eniidx pidx]=intersect(eni, ancnl);
    eninpstr=datestr(eninp);
    newepx=tmpepx(eniidx);  
    newipx=tmpipx(eniidx);
    newp=pod(pidx);
    
    A=[A;100*(newp(end)-1)];
    %ema is ma of absolute pod
    ema=[];
    for n=1:size(newp,1)-lookback+1       
        new_ema=sum(newp(n:n+lookback-1).*w); 
        ema=[ema;new_ema];
    end
    Am=[Am;100*(ema(end)-1)];
    %calculate market benchmark pod
    bpod=newepx./newipx;
    B=[B;100*(bpod(end)-1)];
    %emb is ma of benchmark pod
    emb=[];
    for n=1:size(bpod,1)-lookback+1       
        new_emb=sum(bpod(n:n+lookback-1).*w); 
        emb=[emb;new_emb];
    end
     Bm=[Bm;100*(emb(end)-1)];
    
    zpod=newp./bpod;
    C=[C;(zpod(end)-1)];
    clear empod;
    for n=1:size(zpod,1)-lookback+1       
        empod(n)=sum(zpod(n:n+lookback-1).*w);        
    end
    
    %normalize
    empod_n=(empod-mean(empod))/std(empod);
    expod=[zeros(1,lookback-1) empod_n-1]; %change the display format,remove the percent
    colpod=reshape(expod,size(expod,2),1);
    curpod=colpod(end);
    Cm=[Cm;curpod];
%     clear test;
%     test(:,1)=colpod;
%     test(:,2)=mean(colpod(10:end))+1.25*std(colpod(10:end));
%     test(:,3)=mean(colpod(10:end))-1.25*std(colpod(10:end));
%     dates=cellstr(eninpstr); %convert string to cell string,because ts object require cell string date
%     secname=[char(lnames(i)) ' pod'];
%     ts1=timeseries(test,dates,'name',secname);
%     ts1.TimeInfo.StartDate=eninpstr(1,:); %must be string
%     ts1.TimeInfo.Format='mmm yy';
%     plot(ts1,'LineWidth',2)
%     xlabel('Time')
%     ylabel('pod')
%     axis tight
%     grid on

 end
% xlswrite('ipod result 20130304',[A Am B Bm C Cm],'Sheet3','c2');
