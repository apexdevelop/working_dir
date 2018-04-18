clear;
clear data;
clear bbpx;
clear btxt;
clear dtxt;
clear px;
clear hkclsus;

s=400;
country=2;
h=11;
k=6;
t=0;
j=0;

startdate=today-800;
enddate=today();
cs=s+round(s/4);
load loadarb;

nystk=(stklist(1:11,1))';
hkstk=(stklist(1:11,2))';

shadr=(inshadr)';
indxdt= {'SPX Index', 'KOSPI2 Index',};
etfun={'FXI US Equity','FXIIV Index','EWY US Equity','EWYIV Index','EWT US Equity','EWTIV Index','EWJ US Equity','EWJIV Index'};
custun={'HKD Curncy','KRW Curncy','TWD Curncy','JPY Curncy'};

custk=custun(1,1:country);
etfdt=etfun(1,1:2*country);


field='Last_Price';

[dtxte pxe]= bbrun(indxdt,field,cs);
mday=union(dtxte(1:s,1), dtxte(1:s,2)); % create master date

[dtxtny pxny]= bbrun(nystk,field,cs);

[dtxtcu pxcu]= bbrun(custk,field,cs);
[dtxtet pxet]= bbrun(etfdt,field,cs);

field='Eqy_Weighted_Avg_Px';
[dtxthk pxhk]= bbrun(hkstk,field,cs);

nydt=NaN(length(mday), 3);
nycls=NaN(length(mday), size(nystk,2));
hkcls=NaN(length(mday), size(hkstk,2));
cucls=NaN(length(mday), size(custk,2));
etcls=NaN(length(mday), size(custk,2));

ectr2=0;
for ectr=1:size(etfdt,2)
    tday4=dtxtet(1:cs,ectr); adjcls4=pxet(1:cs,ectr); 
    [foo idx idx4]=intersect(mday, tday4);
    etcls(idx, ectr)=adjcls4(idx4);
    nydt(idx, 4)=tday4(idx4);
    
    if mod(ectr,2)== 0
        ectr2=ectr2+1;
        etpod(:,ectr2)=(etcls(:,ectr-1)./etcls(:,ectr)-1)*100;
     
        tday3=dtxtcu(1:cs,ectr2); adjcls3=pxcu(1:cs,ectr2); 
        [foo idx idx3]=intersect(mday, tday3);
        cucls(idx, ectr2)=adjcls3(idx3);
        nydt(idx, 3)=tday3(idx3);

    end
end


for i=1:size(nystk,2)
    
tday1=dtxtny(1:cs, i); adjcls1=pxny(1:cs, i); 
tday2=dtxthk(1:cs,i); adjcls2=pxhk(1:cs,i); 

[foo idx idx1]=intersect(mday, tday1);
nycls(idx, i)=adjcls1(idx1);
nydt(idx, 1)=tday1(idx1);

[foo idx idx2]=intersect(mday, tday2);
hkcls(idx, i)=adjcls2(idx2);
nydt(idx, 2)=tday1(idx2);

% hkclsus and nypod calculation
     if i<=h emrk=1; elseif i<=h+k emrk=2; elseif i<=h+k+t emrk=3; else emrk=4; end    
     hkclsus(:,i)=(hkcls(:,i)./cucls(:,emrk))*shadr(i);
     nypod(1,i)=(nycls(1,i)/hkclsus(1,i)-1)*100;

     for ctr=2:size(hkclsus,1)
        nypod(ctr,i)=(nycls(ctr,i)/hkclsus(ctr,i)-1)*100;
        hkpod(ctr,i)=(hkclsus(ctr,i)/nycls(ctr-1,i)-1)*100;
     end

  %nyhkrtn calculation
    for z=1:size(hkclsus,1)-1
    nyhkrtn(z,i)=(hkclsus(z+1,i)/nycls(z,i)-1)*100;
    end
    
    for ctr100=1:size(nyhkrtn(:,i))
    if isnan(nyhkrtn(ctr100,i))==1; nyhkrtn(ctr100,i)=0; end
    if isnan(nypod(ctr100,i))==1; nypod(ctr100,i)=0; end
    if i<=size(etpod(:,1),2) 
        if isnan(etpod(ctr100,i))==1; etpod(ctr100,i)=0; end  
    end
    end
           
    sketpod(:,i)=etpod(1:end,emrk);%nypod(1:end,i)-
    
    [results]=ols(nyhkrtn(:,i),nypod(1:end-1,i));
    out(i,1)=results.beta;
    out(i,2)=results.tstat;
    out(i,3)=results.rbar;
    [results]=ols(nyhkrtn(:,i),sketpod(1:end-1,i));
    out(i,5)=results.beta;
    out(i,6)=results.tstat;
    out(i,7)=results.rbar;
    
    olstemp(:,1)=nypod(1:end-1,i);
    olstemp(:,2)=sketpod(1:end-1,i);
    
    [results]=ols(nyhkrtn(:,i),olstemp);
    out(i,8)=results.beta(1);
    out(i,9)=results.tstat(1);
    out(i,10)=results.rbar;
    
clear olstemp
end

% Signal Generation


