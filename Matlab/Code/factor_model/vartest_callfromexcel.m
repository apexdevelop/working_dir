% how about calculating longterm correlation to decide negative or positive
% correlation
% mov_window=3
% z_window=40
% M=225
% clearvars;
% cd('Y:/working_directory/Matlab');
% javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');
% filename='factors.xlsx';
% % oil,shipping,utility,hitachi,steel,coal,display,solar,jp_bond,kr_bond,aluminum,machinery
% v_shnames={'oil','shipping','utility','hitachi','steel','coal','display','solar','jp_bond','kr_bond','aluminum1','aluminum2','machinery','semi','sugar','aapl','shenzhou'};
% e_ranges={'d1:s1','d1:n1','d1:j1','d1:d1','d1:m1','d1:f1','d1:i1','d1:h1','d1:p1','d1:g1','d1:e1','d1:e1','d1:h1','d1:h1','d1:g1','d1:o1','d1:d1'};
% b_ranges={'d2:s2','d2:n2','d2:j2','d2:d2','d2:m2','d2:f2','d2:i2','d2:h2','d2:p2','d2:g2','d2:e2','d2:e2','d2:h2','d2:h2','d2:g2','d2:o2','d2:d2'};
% d_ranges={'d5:s51','d5:n39','d5:j31','d5:d18','d5:m38','d5:i28','d5:i32','d5:h30','d5:p29','d5:g23','d5:e27','d5:e27','d5:h24','d5:h15','d5:g19','d5:o5','d5:d9'};
% sh_idx=6;
% shname=char(v_shnames(sh_idx));
% [~,txt2]=xlsread(filename,shname,'b5:b100'); %factor
% [~,txt1]=xlsread(filename,shname,char(e_ranges(sh_idx)));  %equity
% [~,txt3]=xlsread(filename,shname,char(b_ranges(sh_idx)));  %benchmark
% [effect,~]=xlsread(filename,shname,char(d_ranges(sh_idx)));  %effect

function [Names,Metrics,output_mat]= vartest_callfromexcel(txt1,txt2,txt3,excel_effect,input_param)
%% generate Data
mov_window=3;
% startdate='2012/3/12';
startdate=char(input_param(1));
enddate=char(input_param(2));
% enddate=today();
per={'daily','non_trading_weekdays','previous_value'};
curr=[];
field1='LAST_PRICE';
field2='CHG_PCT_1D';
[~, edates, eprices]=blp_data(transpose(txt1),field1,startdate,enddate,per,curr);
[~, ~, ertns]=blp_data(transpose(txt1),field2,startdate,enddate,per,curr);
[~, fdates, fprices]=blp_data(txt2,field1,startdate,enddate,per,curr);
[~, ~, frtns]=blp_data(txt2,field2,startdate,enddate,per,curr);
[~, bdates, bprices]=blp_data(transpose(txt3),field1,startdate,enddate,per,curr);
[~, ~, brtns]=blp_data(transpose(txt3),field2,startdate,enddate,per,curr);

%% Initialize parameters
effect=cell2mat(excel_effect);
M=225;
N=20;
v_enter_fret=1:0.5:2.5;
v_enter_causal=[0.05,0.10,0.15,0.20];
range= {v_enter_fret,v_enter_causal};
%p is number of lag
p=2;
exit_causal=0.4;
Metrics=[];
Names=[];
z_window=40;

n_ab=0; % number of abnormal returns which have to be calcualted from prices
% for steel factor CDSPDRAV and CDSPHRAV, for shipping BDIY,BIDY
if n_ab>0
   frtns(1,(end-n_ab+1):end)=0;
   frtns(2:end-1,(end-n_ab+1):end)=(fprices(2:end-1,(end-n_ab+1):end)./fprices(1:end-2,(end-n_ab+1):end)-1)*100;
end
%% loop for causality, zspread and backtesting

mat_casal=ones(size(txt2,1),size(txt1,2));
mat_frtn=zeros(size(txt2,1),1);
mat_zfrtn=zeros(size(txt2,1),1);
mat_zfpx=zeros(size(txt2,1),1);
mat_factor=zeros(size(txt2,1),1); %5day mov rtn
mat_zfactor=zeros(size(txt2,1),1); %zscore 5day mov rtn

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
        
        mat_frtn(n)=rtn2(end);
        temp_zfrtn=zscore(rtn2(end-z_window:end));
        mat_zfrtn(n)=temp_zfrtn(end);
        temp_zfpx=zscore(px2(end-z_window:end));
        mat_zfpx(n)=temp_zfpx(end);
        
        [n1n2, idx1, idx2]=intersect(tday1, tday2);
        tday1=tday1(idx1);
        px1=px1(idx1);
        px2=px2(idx2);
        rtn1=rtn1(idx1);
        rtn2=rtn2(idx2);
        
        
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
           v_rtn=[rtn_Y(M+1:end,1) rtn_Y(M+1:end,3)];
        elseif strcmpi(char(txt2(n)),char(txt3(m)))
           n_dim=2;
           Px_Y=[px1 px2]; %[equity, factor(benchmark)]
           rtn_Y=[rtn1 rtn2];
           v_rtn=rtn_Y(M+1:end,:);% rnt_Y(:,2)=rtn_Y(:,3)
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
           v_rtn=rtn_Y(M+1:end,:);% rnt_Y(:,1)=rtn_Y(:,2)
        else
        end
        
%         if ~strcmpi(char(txt2(n)),char(txt3(m)))
%            v_rtn=[rtn_Y(M+1:end,1) rtn_Y(M+1:end,3)]; 
%         else
%            v_rtn=rtn_Y(M+1:end,:);% rnt_Y(:,2)=rtn_Y(:,3)
%         end
        date=tday1;
        rho=corr(rtn_Y(:,1),rtn_Y(:,2));
        

%% VAR process
        temp_causal=zeros(size(rtn_Y,1)-M,1);
        Ymodel=zeros(size(rtn_Y,1),n_dim);
        
        temp_factor=zeros(size(rtn_Y,1),1);
        temp_kendall=zeros(size(rtn_Y,1),1);
        
        if size(rtn_Y,1)<M
           M=size(rtn_Y,1)-N;
        end
        
        Spec = vgxset('n',n_dim,'nAR',p);
        Ymodel(1:M-1,:)=Px_Y(1:M-1,:);
        
        fr_row=reshape(rtn_Y(:,2),1,size(rtn_Y,1));
        temp_mov=tsmovavg(fr_row,'e',mov_window);
        fr_mov=mov_window*[fr_row(1:(mov_window-1)) temp_mov(mov_window:end)];
        temp_factor(1:M-1)=zscore(fr_mov(1:M-1));
        
        temp_kendall(1:M-1)=corr(rtn_Y(p+1:M,1),rtn_Y(1:M-p,2),'type','kendall')*ones(M-1,1);
        j=M;

        while j<size(rtn_Y,1)
              Ypre=rtn_Y(j-M+1:j-M+p,:);
              Yest=rtn_Y(j-M+p+1:j,:);
             [EstSpec,EstStdErrors,LLF,W] = vgxvarx(Spec,Yest,[],Ypre);
             [F,c_v,p_F] =granger_cause(rtn_Y(j-M+p+1:j,1),rtn_Y(j-M+p+1:j,2),0.05,p);
             if j<=size(rtn_Y,1)-N
                [rtn_FY,FYCov]=vgxpred(EstSpec,N,[],Yest);
                reverse_diff=cumsum([log(Px_Y(j,:));rtn_FY]);
                reverse_log=exp(reverse_diff);
                Ymodel(j:j+N,:)=reverse_log;
                
                temp_factor(j:j+N)=(fr_mov(j:j+N)-mean(fr_mov(j-M+1:j)))/std(fr_mov(j-M+1:j));
                temp_kendall(j:j+N)=corr(rtn_Y(j-M+1:j,1),rtn_Y(j-M+1:j,2),'type','kendall')*ones(N+1,1);
                temp_causal(j-M+1:j-M+N)=p_F;
             else
                n2end=size(rtn_Y,1)-j+1;
                T_pred=size(rtn_Y,1)-j;
               [rtn_FY,FYCov]=vgxpred(EstSpec,T_pred,[],Yest);
                reverse_diff=cumsum([log(Px_Y(end-T_pred-1,:));rtn_FY]);
                reverse_log=exp(reverse_diff);
                Ymodel(j:end,:)=reverse_log;
                
                temp_factor(j:end)=(fr_mov(j:end)-mean(fr_mov(j-M+1:j)))/std(fr_mov(j-M+1:j));
                temp_kendall(j:end)=corr(rtn_Y(j-M+1:j,1),rtn_Y(j-M+1:j,2),'type','kendall')*ones(n2end,1);
                temp_causal(j-M+1:end)=p_F;
             end
             j=j+N;
        
        end
        
        mat_casal(n,m)=p_F;
        mat_factor(n)=fr_mov(end);
        mat_zfactor(n)=temp_factor(end);
        v_causal=temp_causal(1:size(rtn_Y,1)-M);
        v_factor=temp_factor(M+1:end);
        v_kendall=temp_kendall(M+1:end);
        
        spread=Px_Y(M+1:end,1)-Ymodel(M+1:end,1);
        Zspread=zeros(size(rtn_Y,1)-M,1);
        z_fpx=zeros(size(Px_Y,1)-M,1);
        
        if z_window>=size(spread,1)
           z_window=size(spread,1);
           Zspread=zscore(spread);
           z_fpx=zscore(Px_Y(:,2));
        else
           Zspread(1:z_window-1)=zscore(spread(1:z_window-1));
           z_fpx(1:z_window-1)=zscore(Px_Y(M+1:M+z_window-1,2));
           for j=z_window : size(spread,1)
               temp_zspread=zscore(spread(j-z_window+1:j));
               temp_zfpx=zscore(Px_Y(M+j-z_window+1:M+j,2));
               Zspread(j)=temp_zspread(end);
               z_fpx(j)=temp_zfpx(end);
           end
        end
                
        zpx=zscore(Px_Y(M+1:end,1));
        zrtn=zscore(v_rtn(:,1)-v_rtn(:,2));
        
        pfun = @(x) factorFun(v_rtn,Zspread,v_factor,x,v_causal,exit_causal,date(M+1:end),effect(n,m));
        [respmax,param,resp] = parameterSweep(pfun,range);
        
        for q=0:0
            enter_factor=1+q*0.5;
            for q1=4:4
                enter_causal=0.05*q1;
                [s,ret_v,newmetric]=factor_backtest3(v_rtn,Zspread,v_factor,z_fpx,enter_factor,v_causal,enter_causal,exit_causal,date(M+1:end),effect(n,m));
                   newmetric=[v_factor(end) z_fpx(end) enter_factor  param(1) v_causal(end) enter_causal param(2) effect(n,m) v_kendall(end) Zspread(end) respmax newmetric];
                   Metrics=[Metrics; newmetric];
                   Names=[Names; transpose(new_txt1)];
            end
        end
        end
    end
end
excel_date=m2xdate(date(M+1:end));
output_mat=[mat_frtn mat_zfrtn mat_factor mat_zfactor mat_zfpx];