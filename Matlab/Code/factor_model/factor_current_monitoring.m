% how about calculating longterm correlation to decide negative or positive
% correlation
clear all;
cd('C:\Users\ychen\Documents\MATLAB');
javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar')

shname='current';
[~,txt2]=xlsread('factors.xlsx',shname,'b3:b140');  %factor
[~,txt1]=xlsread('factors.xlsx',shname,'a3:a140'); %equity
[~,txt3]=xlsread('factors.xlsx',shname,'c3:c140');  %benchmark
[v_enter_ret,~]=xlsread('factors.xlsx',shname,'d3:d140');  %enter signal
[v_enter_causal,~]=xlsread('factors.xlsx',shname,'e3:e140');  %enter causality

%% generate Data
% txt1={'015760 KS Equity';'USDKRW Curncy';'EWY Equity'};


startdate='2012/3/12';
per={'daily','non_trading_weekdays','previous_value'};
[~, fdates, fprices]=blp_test(txt2,startdate,per);
[~, edates, eprices]=blp_test(txt1,startdate,per);
[~, bdates, bprices]=blp_test(txt3,startdate,per);

%% Initialize parameters
M=225;
N=20;
%p is number of lag
p=2;
exit_causal=0.4;
Metrics=[];
Names=[];

%% loop for causality, zspread and backtesting
for m=1:size(txt1,1) %equity and market
    
        new_txt1=[txt1(m);txt2(m);txt3(m)];
        
        tday1=edates(:, m+1); 
        px1=eprices(:, m+1);
        tday1(isnan(px1))=[];
        px1(isnan(px1))=[];
        px1(find(~px1))=[];
        tday1(find(~tday1))=[];

        tday2=fdates(:, m+1); 
        px2=fprices(:, m+1);
        tday2(isnan(px2))=[];
        px2(isnan(px2))=[];
        px2(find(~px2))=[];
        tday2(find(~tday2))=[];
        [n1n2, idx1, idx2]=intersect(tday1, tday2);
        tday1=tday1(idx1);
        px1=px1(idx1);
        px2=px2(idx2);
        
        if ~strcmpi(char(txt2(m)),char(txt3(m)))
           n_dim=3;
           tday3=bdates(:, m+1); 
           px3=bprices(:, m+1);
           tday3(isnan(px3))=[];
           px3(isnan(px3))=[];
           px3(find(~px3))=[];
           tday3(find(~tday3))=[];
           [n1n3, idx1, idx3]=intersect(tday1, tday3);
           tday1=tday1(idx1);
           px1=px1(idx1);
           px2=px2(idx1);
           px3=px3(idx3);
           Px_Y=[px1 px2 px3];
           rtn_Y=zeros(size(Px_Y,1),n_dim);
           
        else
           n_dim=2;
           Px_Y=[px1 px2];
           rtn_Y=zeros(size(Px_Y,1),n_dim);
           
        end
        
        for i=1:n_dim
               rtn_Y(2:end,i)=diff(log(Px_Y(:,i)));
        end
        rtn_Y=rtn_Y(2:end,:);
        if ~strcmpi(char(txt2(m)),char(txt3(m)))
           v_rtn=[rtn_Y(M+1:end,1) rtn_Y(M+1:end,3)];
        else
           v_rtn=rtn_Y(M+1:end,:);
        end
        date=tday1(2:end);
        rho=corr(rtn_Y(:,1),rtn_Y(:,2));
%% VAR process
        
        Spec = vgxset('n',n_dim,'nAR',p);
        % SpecAR=vgxar(Spec); %convert a VARMA to a VAR

        
        Ymodel=zeros(size(rtn_Y,1),n_dim);
        temp_factor=zeros(size(rtn_Y,1),1);
        temp_causal=zeros(size(rtn_Y,1)-M,1);
        temp_kendall=zeros(size(rtn_Y,1),1);
        
        if size(rtn_Y,1)<M
           M=size(rtn_Y,1)-N;
        end
        
        Ymodel(1:M-1,:)=Px_Y(1:M-1,:);
        fr_row=reshape(rtn_Y(:,2),1,size(rtn_Y,1));
        temp_mov=tsmovavg(fr_row,'e',5);
        fr_mov=5*[fr_row(1:4) temp_mov(5:end)];
        temp_factor(1:M-1)=zscore(fr_mov(1:M-1));
        temp_kendall(1:M-1)=corr(rtn_Y(p+1:M,1),rtn_Y(1:M-p,2),'type','kendall')*ones(M-1,1);
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
                temp_factor(j:j+N)=(fr_mov(j:j+N)-mean(fr_mov(j-M+1:j)))/std(fr_mov(j-M+1:j));
                temp_kendall(j:j+N)=corr(rtn_Y(j-M+1:j,1),rtn_Y(j-M+1:j,2),'type','kendall')*ones(N+1,1);
             else
                n2end=size(rtn_Y,1)-j+1;
                T_pred=size(rtn_Y,1)-j;
               [rtn_FY,FYCov]=vgxpred(EstSpec,T_pred,[],Yest);
                reverse_diff=cumsum([log(Px_Y(end-T_pred,:));rtn_FY]);
                reverse_log=exp(reverse_diff);
                Ymodel(j:end,:)=reverse_log;
                temp_factor(j:end)=(fr_mov(j:end)-mean(fr_mov(j-M+1:j)))/std(fr_mov(j-M+1:j));
                temp_kendall(j:end)=corr(rtn_Y(j-M+1:j,1),rtn_Y(j-M+1:j,2),'type','kendall')*ones(n2end,1);
             end
      
             [F,c_v,p_F] =granger_cause(rtn_Y(j-M+p+1:j,1),rtn_Y(j-M+p+1:j,2),0.05,p);
             temp_causal(j-M+1:j-M+N)=p_F;
             j=j+N;
        end
        v_causal=temp_causal(1:size(rtn_Y,1)-M);
        v_kendall=temp_kendall(M+1:end);
        v_factor=temp_factor(M+1:end);
        
        spread=Px_Y(M+1:end,1)-Ymodel(M:end,1);
        Zspread=zscore(spread);
        
        newmetric=factor_backtest(v_rtn,Zspread,v_factor,v_enter_ret(m),v_causal,v_enter_causal(m),exit_causal,date(M+1:end),v_kendall);
        newmetric=[v_enter_ret(m) v_factor(end) v_enter_causal(m) v_causal(end) rho newmetric];
        Metrics=[Metrics; newmetric];
        Names=[Names; transpose(new_txt1)];

end
