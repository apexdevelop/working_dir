% how about calculating longterm correlation to decide negative or positive
% correlation line 203 enter_factor=0.5;
clearvars;
cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/factor/single_factor');
javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');
% 1-oil,2-shipping,3-utility,4-steel,5-coal,6-solar,7-display,8-insurance,9-bond,10-aluminum,11-auto
v_shnames={'oil','shipping','utility','steel','coal','solar','display','insurance','bond','aluminum','auto'};
e_ranges={'c1:g1','c1:m1','c1:h1','c1:h1','c1:f1','c1:h1','c1:h1','c1:f1','c1:h1','c1:s1','c1:d1','c1:f1'};
b_ranges={'c2:g2','c2:m2','c2:h2','c2:h2','c2:f2','c2:h2','c2:h2','c2:f2','c2:h2','c2:s2','c2:d2','c2:f2'};
filename1='factors_weekly.xlsx';
filename2='factor_result_weekly.xlsx';
% shname='shipping';
start_sh_idx=1;
end_sh_idx=11;
mat_rtn=[];
mat_zrtn=[];
mat_factor_names=[];

for sh_idx=start_sh_idx:end_sh_idx
shname=char(v_shnames(sh_idx));    
[~,txt1]=xlsread(filename1,shname,char(e_ranges(sh_idx)));  %equity
[~,txt2]=xlsread(filename1,shname,'a3:a100'); %factor
[~,txt3]=xlsread(filename1,shname,char(b_ranges(sh_idx)));  %benchmark

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
    raw_date_5d=[];
    raw_rtn_5d=[];
    raw_fpx=[];
    
    c=blp;
    new=char(txt2(n));
    [d1, sec] = history(c, new,'CHG_PCT_1D',startdate,enddate,per_n);
    [d2, sec] = history(c, new,'Last_Price',startdate,enddate,per_p);
    raw_date_5d(1:size(d1,1),1)=d1(1:size(d1,1),1);
    raw_rtn_5d(1:size(d1,1),1)=d1(1:size(d1,1),2);
    raw_fpx(1:size(d2,1),1)=d2(1:size(d2,1),2);
    close(c);
    
    v_idx_nemp=find(~isnan(raw_rtn_5d));        
    rtn_5d_forz=raw_rtn_5d(v_idx_nemp);
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
    raw_re_rtn_5d=zeros(size(raw_rtn_5d,1),1);
    raw_re_z5d=zeros(size(raw_rtn_5d,1),1);
    raw_long_z5d=zeros(size(raw_rtn_5d,1),1);
    raw_long_z5d(v_idx_nemp)=short_z5d;
    d0=floor(mean(diff(v_idx_nemp)));
    v_d=[d0;diff(v_idx_nemp)];
    idx=1;
    for j=1:v_idx_nemp(end)
        if j<=v_idx_nemp(idx+1)           
           raw_re_rtn_5d(j)=raw_rtn_5d(v_idx_nemp(idx));
           raw_re_z5d(j)=raw_long_z5d(v_idx_nemp(idx));
        else
           idx=idx+1;
           raw_re_rtn_5d(j)=raw_rtn_5d(v_idx_nemp(idx));
           raw_re_z5d(j)=raw_long_z5d(v_idx_nemp(idx));           
        end
    end
    
    for j=v_idx_nemp(end):size(raw_rtn_5d,1)
        raw_re_rtn_5d(j)=raw_rtn_5d(v_idx_nemp(end));
        raw_re_z5d(j)=raw_long_z5d(v_idx_nemp(end));
    end    
        
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
               
        date_5d=raw_date_5d(v_idx_nemp(1):end);   
        rtn_5d=raw_rtn_5d(v_idx_nemp(1):end);
        fpx=raw_fpx(v_idx_nemp(1):end);
        re_rtn_5d=raw_re_rtn_5d(v_idx_nemp(1):end);
        re_z5d=raw_re_z5d(v_idx_nemp(1):end);
        long_z5d=raw_long_z5d(v_idx_nemp(1):end);
        
        min_fpx=min(fpx);
        if min_fpx<=1 && min_fpx>0  
           fpx=exp(fpx);
        end
        
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
        Px_Y(Px_Y<=1)=1.01;
        rtn_Y=[rtn1 rtn2 rtn3];
        
        temp_factor=re_z5d;
        v_factor=temp_factor(M:end);
        v_date=tday1(M:end);
        v_rtn=[rtn_Y(M:end,1) rtn_Y(M:end,3)]; % equity and market return        
        zpx=zscore(Px_Y(M:end,1));
        zrtn=zscore(v_rtn(:,1)-v_rtn(:,2));
        
        rho=corr(rtn_Y(:,1),rtn_Y(:,2));
        
%% backtesting process
        temp_causal=zeros(size(rtn_Y,1)-M+1,1);
        v_residual=zeros(size(Px_Y,1)-M+1,1);
        Zspread=zeros(size(Px_Y,1)-M+1,1);
        mat_coint_b=[];
        j=M;
        while j<size(rtn_Y,1)
             log_XY1=log(Px_Y(j-M+1:j,:));
             [h,coint_p,~,~,reg] = egcitest(log_XY1,'test','t2');
             coint_b=[1;-reg.coeff(2:end)];
             mat_coint_b=[mat_coint_b coint_b]; 
             [F,c_v,p_F] =granger_cause(rtn_Y(j-M+p+1:j,1),rtn_Y(j-M+p+1:j,2),0.05,p);
             if j<=size(rtn_Y,1)-N
                log_XY2=log(Px_Y(j:j+N-1,:));
                v_residual(j-M+1:j-M+N)=log_XY2*coint_b-reg.coeff(1);
                Zspread(j-M+1:j-M+N)=(v_residual(j-M+1:j-M+N)-mean(reg.res))/reg.RMSE;
                temp_causal(j-M+1:j-M+N)=p_F;
             else
                log_XY2=log(Px_Y(j:end,:));
                v_residual(j-M+1:end)=log_XY2*coint_b-reg.coeff(1);
                Zspread(j-M+1:end)=(v_residual(j-M+1:end)-mean(reg.res))/reg.RMSE;
                temp_causal(j-M+1:end)=p_F;
             end
             j=j+N;
        
        end
        v_causal=temp_causal;

        enter_factor=0.5;
%         for q=0:3
%             enter_factor=1+q*0.5;
            for q1=1:4
                enter_causality=0.05*q1;
                [newmetric,r_trade]=wfactor_backtest2(v_rtn,Zspread,v_factor,enter_factor,v_causal,enter_causality,exit_causal,v_date);
                   Metrics=[Metrics; newmetric];
                   Names=[Names; transpose(new_txt1)];
            end
%         end
    end
    mat_rtn=[mat_rtn;rtn_5d_forz(end)];
    mat_zrtn=[mat_zrtn;short_z5d(end)];
end

cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/factor/single_factor');

xlswrite(filename2,Names,shname,'a2'); %Names
xlswrite(filename2,Metrics,shname,'d2'); %trades


mat_factor_names=[mat_factor_names;txt2];
end
output_rtn=[mat_rtn mat_zrtn];
% xlswrite(filename1,fchg_mat,shname,char(fchg_ranges(sh_idx))); %factor change