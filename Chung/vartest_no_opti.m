%remember to clear trades on 'factor_result_unfilter.xlsx' and 'factor_result_filter.xlsx'
clearvars;
home_dir = getuserdir();
java_dir = strcat(home_dir,'/git/working_dir/Matlab/blpapi3.jar');
javaaddpath(java_dir);
data_dir = strcat(home_dir,'/git/working_dir/Matlab/Data/factor/single_factor');
start_sh_idx=1;
end_sh_idx=1;
%cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/factor/single_factor');
cd(data_dir);
filename1='factors_v2.xlsx';
filename2a='factor_result_unfilter.xlsx';
filename2b='factor_result_filter.xlsx';
filename3='factors_causal.xlsx';
filename4='factors_corr.xlsx';

% 1-oil,2-shipping,3-utility,4-hitachi,5-steel,6-coal,7-display,8-solar,9-jp_bond,10-kr_bond,11-aluminum1,12-aluminum2,13-aluminum3,14-machinery,15-fullfactor
v_shnames={'oil','shipping','utility','hitachi','steel','coal','display','solar','jp_bond','kr_bond','aluminum1','aluminum2','aluminum3','machinery','fullfactor'};
e_ranges={'d1:s1','d1:n1','d1:j1','d1:d1','d1:m1','d1:f1','d1:i1','d1:h1','d1:p1','d1:g1','d1:e1','d1:e1','d1:d1','d1:h1','d1:cm1'};
b_ranges={'d2:s2','d2:n2','d2:j2','d2:d2','d2:m2','d2:f2','d2:i2','d2:h2','d2:p2','d2:g2','d2:e2','d2:e2','d2:d2','d2:h2','d2:cm2'};
d_ranges={'d5:s51','d5:n39','d5:j31','d5:d18','d5:m41','d5:i28','d5:i33','d5:h24','d5:p28','d5:g23','d5:e31','d5:e32','d5:d31','d5:h24','d5:cm190'};
fchg_ranges={'u5:y51','q5:u39','l5:p31','g5:k18','o5:s41','h5:l27','k5:o33','j5:n24','r5:v28','i5:m23','h5:k31','h5:l32','h5:l31','j5:n19'};

%% Initialize parameters

mov_window=3;
startdate='2017/12/31';
% enddate='2017/11/30';
enddate=today();
%javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');
per={'daily','non_trading_weekdays','previous_value'};
curr=[];
field1='LAST_PRICE';
field2='CHG_PCT_1D';

M=225;
N=20;
v_enter_fret=1:0.5:2.5;
v_enter_causal=[0.05,0.10,0.15,0.20];
range= {v_enter_fret,v_enter_causal};
%p is number of lag
p=2;
exit_causal=0.4;
z_window=40;

for sh_idx=start_sh_idx:end_sh_idx
shname=char(v_shnames(sh_idx));
[~,txt2]=xlsread(filename1,shname,'b5:b100'); %factor
[~,txt1]=xlsread(filename1,shname,char(e_ranges(sh_idx)));  %equity
[~,txt3]=xlsread(filename1,shname,char(b_ranges(sh_idx)));  %benchmark
[effect,~]=xlsread(filename1,shname,char(d_ranges(sh_idx)));  %effect


%% generate Data

disp('pulling data time');
tic
[~, edates, eprices]=blp_data(transpose(txt1),field1,startdate,enddate,per,curr);
[~, ~, ertns]=blp_data(transpose(txt1),field2,startdate,enddate,per,curr);
[~, fdates, fprices]=blp_data(txt2,field1,startdate,enddate,per,curr);
[~, ~, frtns]=blp_data(txt2,field2,startdate,enddate,per,curr);
[~, bdates, bprices]=blp_data(transpose(txt3),field1,startdate,enddate,per,curr);
[~, ~, brtns]=blp_data(transpose(txt3),field2,startdate,enddate,per,curr);
toc

n_ab=0; % number of abnormal returns which have to be calcualted from prices
% for steel factor CDSPDRAV and CDSPHRAV, for shipping BDIY,BIDY
if n_ab>0
   frtns(1,(end-n_ab+1):end)=0;
   frtns(2:end-1,(end-n_ab+1):end)=(fprices(2:end-1,(end-n_ab+1):end)./fprices(1:end-2,(end-n_ab+1):end)-1)*100;
end
%% loop for causality, zspread and backtesting
Metrics=[];
Names=[];
filter_idx=[];%row idx for qualified trades
mat_casal=ones(size(txt2,1),size(txt1,2));
mat_kendall=zeros(size(txt2,1),size(txt1,2));
mat_frtn=zeros(size(txt2,1),1);
mat_zfrtn=zeros(size(txt2,1),1);
mat_zfpx=zeros(size(txt2,1),1);
mat_factor=zeros(size(txt2,1),1); %5day mov rtn
mat_zfactor=zeros(size(txt2,1),1); %zscore 5day mov rtn

cd(data_dir);
S_signal=load(strcat('op_signal', num2str(sh_idx)));
S_causal=load(strcat('op_causal', num2str(sh_idx)));
S_ret=load(strcat('op_ret', num2str(sh_idx)));
S_modeldata=load(strcat('modeldata', num2str(sh_idx)));
S_date=load(strcat('date', num2str(sh_idx)));
S_rtnY=load(strcat('rtnY', num2str(sh_idx)));
S_PxY=load(strcat('PxY', num2str(sh_idx)));
S_Ymodel=load(strcat('Ymodel', num2str(sh_idx)));
c_op_signal=S_signal.c_opti_zfactor;
c_op_causal=S_causal.c_opti_causal;
c_op_ret=S_ret.c_opti_ret;
c_modeldata=S_modeldata.c_modeldata;
c_date=S_date.c_date;
c_rtnY=S_rtnY.c_rtnY;
c_PxY=S_PxY.c_PxY;
c_Ymodel=S_Ymodel.c_Ymodel;

disp('time of predicting and backtesting');
tic
for m=1:size(txt1,2) %equity and market
    for n=1:size(txt2,1) %factor
        if effect(n,m)~=0
        new_txt1=[txt1(m);txt2(n);txt3(m)];
        
        tday1=edates(:, m+1);
        px1=eprices(:, m+1);
        rtn1=ertns(:, m+1);
        tday1(isnan(px1))=[];
        rtn1(isnan(px1))=[];
        px1(isnan(px1))=[];
        rtn1(isnan(rtn1))=0;
        rtn1(find(~tday1))=[];
        px1(find(~tday1))=[];
        tday1(find(~tday1))=[];

        tday2=fdates(:, n+1); 
        px2=fprices(:, n+1);
        rtn2=frtns(:, n+1);
        tday2(isnan(px2))=[];
        rtn2(isnan(px2))=[];
        px2(isnan(px2))=[];
        rtn2(isnan(rtn2))=0;
        rtn2(find(~tday2))=[];
        px2(find(~tday2))=[];
        tday2(find(~tday2))=[];
                
        [n1n2, idx1, idx2]=intersect(tday1, tday2);
        tday1=tday1(idx1);
        px1=px1(idx1);
        px2=px2(idx2);
        rtn1=rtn1(idx1);
        rtn2=rtn2(idx2);
        
        if ~isempty(rtn1)
        if ~strcmpi(char(txt2(n)),char(txt3(m))) && ~strcmpi(char(txt1(m)),char(txt2(n)))
           n_dim=3;
           tday3=bdates(:, m+1); 
           px3=bprices(:, m+1);
           rtn3=brtns(:, m+1);
           tday3(isnan(px3))=[];
           rtn3(isnan(px3))=[];
           px3(isnan(px3))=[];
           px3(find(~tday3))=[];
           rtn3(find(~tday3))=[];
           tday3(find(~tday3))=[];
           [n1n3, idx1, idx3]=intersect(tday1, tday3);
           tday1=tday1(idx1);
           px1=px1(idx1);
           px2=px2(idx1);
           rtn1=rtn1(idx1);
           rtn2=rtn2(idx1);
           px3=px3(idx3);
           rtn3=rtn3(idx3);
           Px_Y=[px1 px2 px3]; %[equity, factor, benchmark]
           rtn_Y=[rtn1 rtn2 rtn3];

        elseif strcmpi(char(txt2(n)),char(txt3(m)))
           n_dim=2;
           Px_Y=[px1 px2]; %[equity, factor(benchmark)]
           rtn_Y=[rtn1 rtn2];

        elseif strcmpi(char(txt1(m)),char(txt2(n)))
           n_dim=2;
           tday3=bdates(:, m+1); 
           px3=bprices(:, m+1);
           rtn3=brtns(:, m+1);
           tday3(isnan(px3))=[];
           rtn3(isnan(px3))=[];
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
           Px_Y=[px1 px3]; %[equity, factor(benchmark)]
           rtn_Y=[rtn1 rtn3];

        else
        end
        date=tday1;
        rho=corr(rtn_Y(:,1),rtn_Y(:,2));

%% VAR process        
        
        old_ob=size(c_date{m,n},1);
        last_date=c_date{m,n}(old_ob);
        idx_append=find(date==last_date)+1;
        date_test=[c_date{m,n};date(idx_append:end)];
        rtn_test=[c_rtnY{m,n};rtn_Y(idx_append:end,:)];
        px_test=[c_PxY{m,n};Px_Y(idx_append:end,:)];        
        ymodel_test=[c_Ymodel{m,n};zeros(size(rtn_Y,1)-idx_append+1,size(c_Ymodel{m,n},2))];
        
        fr_row=reshape(rtn_test(:,2),1,size(rtn_test,1));
        temp_mov=tsmovavg(fr_row,'e',mov_window);
        fr_mov=mov_window*[fr_row(1:(mov_window-1)) temp_mov(mov_window:end)];
        
        factor_test=[c_modeldata{m,n}(:,1);zeros(size(rtn_Y,1)-idx_append+1,1)];
        kendall_test=[c_modeldata{m,n}(:,2);zeros(size(rtn_Y,1)-idx_append+1,1)];
        causal_test=[c_modeldata{m,n}(:,3);ones(size(rtn_Y,1)-idx_append+1,1)];
        
        spread_test=[c_modeldata{m,n}(:,4);zeros(size(rtn_Y,1)-idx_append+1,1)];
        Zspread_test=[c_modeldata{m,n}(:,5);zeros(size(rtn_Y,1)-idx_append+1,1)];
        z_fpx_test=[c_modeldata{m,n}(:,6);zeros(size(rtn_Y,1)-idx_append+1,1)];        
        Spec = vgxset('n',n_dim,'nAR',p);
        j=old_ob;
        
        if M>old_ob
           M=old_ob;
        end
        while j<size(rtn_test,1)
              Ypre=rtn_test(j-M+1:j-M+p,:);
              Yest=rtn_test(j-M+p+1:j,:);
             [EstSpec,EstStdErrors,LLF,W] = vgxvarx(Spec,Yest,[],Ypre);
             [~,~,p_F] =granger_cause(rtn_test(j-M+p+1:j,1),rtn_test(j-M+p+1:j,2),0.05,p);
             if j<size(rtn_test,1)-N
                [rtn_FY,FYCov]=vgxpred(EstSpec,N,[],Yest);
                reverse_diff=cumsum([log(px_test(j,:));rtn_FY]);
                reverse_log=exp(reverse_diff);
                ymodel_test(j:j+N,:)=reverse_log;
                
                spread_test(j:j+N)=px_test(j:j+N,1)-ymodel_test(j:j+N,1);
                for j1=j : j+N
                    temp_zspread=zscore(spread_test(j1-z_window+1:j1));
                    temp_zfpx=zscore(px_test(j1-z_window+1:j1,2));
                    Zspread_test(j1)=temp_zspread(end);
                    z_fpx_test(j1)=temp_zfpx(end);
                end
                
                factor_test(j:j+N)=(fr_mov(j:j+N)-mean(fr_mov(j-M+1:j)))/std(fr_mov(j-M+1:j));
                kendall_test(j:j+N)=corr(rtn_test(j-M+1:j,1),rtn_test(j-M+1:j,2),'type','kendall')*ones(N+1,1);
                causal_test(j-M+1:j-M+N)=p_F;
             else
                n2end=size(rtn_test,1)-j+1;
                T_pred=size(rtn_test,1)-j;
               [rtn_FY,FYCov]=vgxpred(EstSpec,T_pred,[],Yest);
                reverse_diff=cumsum([log(px_test(end-T_pred-1,:));rtn_FY]);
                reverse_log=exp(reverse_diff);
                ymodel_test(j:end,:)=reverse_log;
                
                spread_test(j:end)=px_test(j:end,1)-ymodel_test(j:end,1);
                for j1=j : size(rtn_test,1)
                    temp_zspread=zscore(spread_test(j1-z_window+1:j1));
                    temp_zfpx=zscore(px_test(j1-z_window+1:j1,2));
                    Zspread_test(j1)=temp_zspread(end);
                    z_fpx_test(j1)=temp_zfpx(end);
                end
                
                factor_test(j:end)=(fr_mov(j:end)-mean(fr_mov(j-M+1:j)))/std(fr_mov(j-M+1:j));
                kendall_test(j:end)=corr(rtn_test(j-M+1:j,1),rtn_test(j-M+1:j,2),'type','kendall')*ones(n2end,1);
                causal_test(j-M+1:end)=p_F;
             end
             j=j+N;
        end
        
        mat_frtn(n)=rtn_Y(end,2);
        temp_zfrtn=zscore(rtn_test(end-z_window:end,2));
        mat_zfrtn(n)=temp_zfrtn(end);
        mat_zfpx(n)=z_fpx_test(end);
        
        mat_kendall(n,m)=kendall_test(end);
        mat_casal(n,m)=p_F;
        mat_factor(n)=fr_mov(end);
        mat_zfactor(n)=factor_test(end);
        
        if ~strcmpi(char(txt2(n)),char(txt3(m))) && ~strcmpi(char(txt1(m)),char(txt2(n)))
           v_rtn=[rtn_test(:,1) rtn_test(:,3)];
        else
           v_rtn=rtn_test;
        end
        %backtesting starts
        for q=0:0
            enter_factor=1+q*0.5;
            for q1=4:4
                enter_causal=0.05*q1;
                [s,ret_v,daily_r,newmetric]=factor_backtest3(v_rtn,Zspread_test,factor_test,z_fpx_test,enter_factor,causal_test,enter_causal,exit_causal,date_test,effect(n,m));
                   newmetric=[factor_test(end) z_fpx_test(end) enter_factor  c_op_signal{m,n} causal_test(end) enter_causal c_op_causal{m,n} effect(n,m) kendall_test(end) Zspread_test(end) c_op_ret{m,n} newmetric];
                   Metrics=[Metrics; newmetric];
                   Names=[Names; transpose(new_txt1)];
                   %filtering
                   if newmetric(12)>0 && newmetric(14)>0.59
                      filter_idx=[filter_idx;size(Metrics,1)];
                   end
            end
        end
        end
        end
    end
end
toc
excel_date=m2xdate(date(M+1:end));
fchg_mat=[mat_frtn mat_zfrtn mat_factor mat_zfactor mat_zfpx];

cd(data_dir);
xlswrite(filename1,fchg_mat,shname,char(fchg_ranges(sh_idx))); %factor change
xlswrite(filename2a,Names,shname,'a2'); %Names
xlswrite(filename2a,Metrics,shname,'d2'); %trades

filtered_M=Metrics(filter_idx,:);
filtered_Names=Names(filter_idx,:);
xlswrite(filename2b,filtered_Names,shname,'a2'); %filtered Names
xlswrite(filename2b,filtered_M,shname,'d2'); %filtered trades
xlswrite(filename3,mat_casal,shname,char(d_ranges(sh_idx))); %causality
xlswrite(filename4,mat_kendall,shname,char(d_ranges(sh_idx))); %correlation
end