% how about calculating longterm correlation to decide negative or positive
% correlation
clear all;
cd('C:\Users\ychen\Documents\MATLAB');
javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar')
% shipping,utility,steel,coal,display,solar,bond,aluminum,exports,hitachi
shname='shipping';
[~,txt1]=xlsread('factors_weekly.xlsx',shname,'c1:zz1');  %equity
[~,txt2]=xlsread('factors_weekly.xlsx',shname,'a3:a9'); %factor
[~,txt3]=xlsread('factors_weekly.xlsx',shname,'c2:zz2');  %benchmark

%% generate Data
% txt1={'015760 KS Equity';'USDKRW Curncy';'EWY Equity'};

startdate='2012/3/12';
enddate=today();
per_n={'daily','non_trading_weekdays','nil_value'};
per_p={'daily','non_trading_weekdays','previous_value'};

c=blp;
for loop=1:size(txt1,2)
    new=char(txt1(loop));
    [d1, sec] = history(c, new,'CHG_PCT_1D',startdate,enddate,per_p);
    [d2, sec] = history(c, new,'Last_Price',startdate,enddate,per_p);
    edates(1:size(d1,1),loop)=d1(1:size(d1,1),1);
    ertns(1:size(d1,1),loop)=d1(1:size(d1,1),2);
    eprices(1:size(d2,1),loop)=d2(1:size(d2,1),2);
end;
close(c);

c=blp;
for loop=1:size(txt3,2)
    new=char(txt3(loop));
    [d1, sec] = history(c, new,'CHG_PCT_1D',startdate,enddate,per_p);
    [d2, sec] = history(c, new,'Last_Price',startdate,enddate,per_p);
    bdates(1:size(d1,1),loop)=d1(1:size(d1,1),1);
    brtns(1:size(d1,1),loop)=d1(1:size(d1,1),2);
    bprices(1:size(d2,1),loop)=d2(1:size(d2,1),2);
end;
close(c);


%% Initialize parameters
Metrics=[];
Names=[];
n_dim=3;
M=125;
N=10;
%p is number of lag
p=2;
exit_causal=0.4;
%% loop for causality, zspread and backtesting

for n=1:size(txt2,1) %factor
    %pull out factor data
    c=blp;
    new=char(txt2(n));
    [d1, sec] = history(c, new,'CHG_PCT_1D',startdate,enddate,per_n);
    [d2, sec] = history(c, new,'Last_Price',startdate,enddate,per_p);
    date_5d(1:size(d1,1),1)=d1(1:size(d1,1),1);
    rtn_5d(1:size(d1,1),1)=d1(1:size(d1,1),2);
    fpx(1:size(d2,1),1)=d2(1:size(d2,1),2);
    close(c);
    
    v_idx_nemp=find(~isnan(rtn_5d));        
    rtn_5d_forz=rtn_5d(v_idx_nemp);
    window=26;
    
    if window<size(rtn_5d_forz,1)
       z_window=window;
    else
       z_window=size(rtn_5d_forz,1);
    end
    
    short_z5d=zeros(size(rtn_5d_forz,1),1);
    short_z5d(1:z_window-1)=zscore(rtn_5d_forz(1:z_window-1));
    for i=z_window : size(rtn_5d_forz,1)
        temp_z5d=zscore(rtn_5d_forz(i-z_window+1:i,1));
        short_z5d(i,1)=temp_z5d(end);
    end    
    
    %resample return, zscore for factor
    re_rtn_5d=zeros(size(rtn_5d,1),1);
    re_z5d=zeros(size(rtn_5d,1),1);
    long_z5d=zeros(size(rtn_5d,1),1);
    long_z5d(v_idx_nemp)=short_z5d;
    d0=floor(mean(diff(v_idx_nemp)));
    v_d=[d0;diff(v_idx_nemp)];
    idx=1;
    for j=1:v_idx_nemp(end)
        if j<=v_idx_nemp(idx+1)           
           re_rtn_5d(j)=rtn_5d(v_idx_nemp(idx))/v_d(idx);
           re_z5d(j)=long_z5d(v_idx_nemp(idx));
        else
           idx=idx+1;
           re_rtn_5d(j)=rtn_5d(v_idx_nemp(idx))/v_d(idx);
           re_z5d(j)=long_z5d(v_idx_nemp(idx));           
        end
    end
    
    for j=v_idx_nemp(end):size(rtn_5d,1)
        re_rtn_5d(j)=rtn_5d(v_idx_nemp(end))/v_d(end);
        re_z5d(j)=long_z5d(v_idx_nemp(end));
    end
    %     rtn_5d(isnan(rtn_5d))=0;    
    

    for m=1:size(txt1,2) %equity and market
        new_txt1=[txt1(m);txt2(n);txt3(m)];
        
        tday1=edates(:, m); 
        px1=eprices(:, m);
        rtn1=ertns(:,m);
        tday1(isnan(px1))=[];
        rtn1(isnan(px1))=[];
        px1(isnan(px1))=[];
        px1(find(~tday1))=[];
        rtn1(find(~tday1))=[];
        tday1(find(~tday1))=[];

        tday3=bdates(:, m); 
        px3=bprices(:, m);
        rtn3=brtns(:,m);
        tday3(isnan(px3))=[];
        px3(isnan(px3))=[];
        px3(find(~tday3))=[];
        rtn3(find(~tday3))=[];
        tday3(find(~tday3))=[];
                
        [n1n3, idx1, idx3]=intersect(tday1, tday3);
        tday1=tday1(idx1);
        px1=px1(idx1);
        rtn1=rtn1(idx1);
        px3=px3(idx3);
        rtn3=rtn3(idx3);
        
        [n1nf, idx1, idxf]=intersect(tday1, date_5d);
        tday1=tday1(idx1);
        px1=px1(idx1);
        rtn1=rtn1(idx1);
        px3=px3(idx1);
        rtn3=rtn3(idx1);
        px2=fpx(idxf);
        rtn2=re_rtn_5d(idxf);
        re_z5d=re_z5d(idxf);

        Px_Y=[px1 px2 px3]; %[equity, factor, benchmark]
        rtn_Y=[rtn1 rtn2 rtn3];
        
        temp_factor=re_z5d;
        v_factor=temp_factor(M+1:end);
        v_date=tday1(M+1:end);
        v_rtn=[rtn_Y(M+1:end,1) rtn_Y(M+1:end,3)]; % equity and market return        
        zpx=zscore(Px_Y(M+1:end,1));
        zrtn=zscore(v_rtn(:,1)-v_rtn(:,2));
        
        rho=corr(rtn_Y(:,1),rtn_Y(:,2));
        
%% backtesting process
        
        temp_causal=zeros(size(rtn_Y,1)-M,1);
        Ymodel=zeros(size(rtn_Y,1),n_dim);
        temp_kendall=zeros(size(rtn_Y,1),1);

        if size(rtn_Y,1)<M
           M=size(rtn_Y,1)-N;
        end
        
        Spec = vgxset('n',n_dim,'nAR',p);
        Ymodel(1:M-1,:)=Px_Y(1:M-1,:);
%         temp_kendall(1:M-1)=corr(rtn_Y(p+1:M,1),rtn_Y(1:M-p,2),'type','kendall')*ones(M-1,1);
        j=M;
        while j<size(rtn_Y,1)
              Ypre=rtn_Y(j-M+1:j-M+p,:);
              Yest=rtn_Y(j-M+p+1:j,:);
             [EstSpec,EstStdErrors,LLF,W] = vgxvarx(Spec,Yest,[],Ypre);
             if j<=size(rtn_Y,1)-N
                [rtn_FY,FYCov]=vgxpred(EstSpec,N,[],Yest);
                reverse_diff=cumsum([log(Px_Y(j+1,:));rtn_FY]);
                reverse_log=exp(reverse_diff);
                Ymodel(j:j+N,:)=reverse_log;
%                 temp_kendall(j:j+N)=corr(rtn_Y(j-M+1:j,1),rtn_Y(j-M+1:j,2),'type','kendall')*ones(N+1,1);
             else
                n2end=size(rtn_Y,1)-j+1;
                T_pred=size(rtn_Y,1)-j;
               [rtn_FY,FYCov]=vgxpred(EstSpec,T_pred,[],Yest);
                reverse_diff=cumsum([log(Px_Y(end-T_pred,:));rtn_FY]);
                reverse_log=exp(reverse_diff);
                Ymodel(j:end,:)=reverse_log;
%                 temp_kendall(j:end)=corr(rtn_Y(j-M+1:j,1),rtn_Y(j-M+1:j,2),'type','kendall')*ones(n2end,1);
             end
             [F,c_v,p_F] =granger_cause(rtn_Y(j-M+p+1:j,1),rtn_Y(j-M+p+1:j,2),0.05,p);
             temp_causal(j-M+1:j-M+N)=p_F;
             j=j+N;
        
        end
        v_causal=temp_causal;
%         v_kendall=temp_kendall(M+1:end);
        
        spread=Px_Y(M+1:end,1)-Ymodel(M+1:end,1);
        Zspread=zscore(spread); 
        enter_factor=v_factor(end);
%         for q=0:3
%             enter_factor=1+q*0.5;
            for q1=1:4
                enter_causality=0.05*q1;
                newmetric=wfactor_backtest(v_rtn,Zspread,v_factor,enter_factor,v_causal,enter_causality,exit_causal,v_date);
                   Metrics=[Metrics; newmetric];
                   Names=[Names; transpose(new_txt1)];
            end
%         end
    end
end
