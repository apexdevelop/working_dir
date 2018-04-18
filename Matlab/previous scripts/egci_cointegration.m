cd('C:\Documents and Settings\YChen\My Documents');
clear H;
clear P;
clear S;
clear y;

[names date price]=blp_simple('input_ticker','proxy','a1:a3',365);
n_dim=size(price,2)-1;
n_obs=size(date,1);
price_c=zeros(n_obs,n_stock);
date_c=zeros(n_obs,n_stock);
for s1=1:n_stock
    pnc=[];
    pidx=[];
    cidx1=[];
    tmpprice1=[];
    price1=[];
    date1=[];
    cind1=0;
    crn1=char(crn(s1,1));
    for c1=1:size(carray,2)
    if crn1==char(carray(c1))
            cind1=c1;
    end
    end
    %intersect adr price date with currency price date
    datep=date(:,s1+1);
    zeroind1=find(~datep);
    datep(zeroind1)=[];
    
    datec=ct(:,cind1+1);
    zeroind2=find(~datec);
    datec(zeroind2)=[];
    
    [pnc pidx cidx1]=intersect(datep, datec);   
    tmpprice1=price(pidx,s1+1);
    tmpcpx1=cpx(cidx1,cind1+1);
    price1=tmpprice1./tmpcpx1;
    date1=datep(pidx);    
    price_c(1:size(price1,1),s1)=price1;
    date_c(1:size(date1,1),s1)=date1;
end


price_return=rtn(price(:,2:end));



date1=date(2:end,2);
zeroind1=find(~date1);
date1(zeroind1)=[];
    
date2=date(2:end,3);
zeroind2=find(~date2);
date2(zeroind2)=[];
    
[comind1 idx1 idx2]=intersect(date1, date2);   
tmpprice1=price_return(idx1,1);
tmpprice2=price_return(idx2,2);
    
comdate1=date1(idx1);  

date3=date(2:end,4);
zeroind3=find(~date3);
date3(zeroind3)=[];
    
[comind3 comidx2 idx3]=intersect(comdate1, date3);   
fprice1=tmpprice1(comidx2);
fprice2=tmpprice2(comidx2);
fprice3=price_return(idx3,3);
comdate2=comdate1(comidx2);
Y=[fprice1 fprice2 fprice3];

egci_ccn;

vec;
