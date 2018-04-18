% how about calculating longterm correlation to decide negative or positive
% correlation
clear all;
cd('C:\Users\ychen\Documents\MATLAB');
javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar')
% shipping,utility,steel,coal,display,solar,bond,aluminum,exports,hitachi
shname='exports';
[~,txt1]=xlsread('factors.xlsx',shname,'a3:a100'); %factor
[~,txt2]=xlsread('factors.xlsx',shname,'c1:zz1');  %equity
[~,txt3]=xlsread('factors.xlsx',shname,'c2:zz2');  %benchmark

% shname='current';
% [~,txt1]=xlsread('factors.xlsx',shname,'a17'); %factor
% [~,txt2]=xlsread('factors.xlsx',shname,'b17');  %equity
% [~,txt3]=xlsread('factors.xlsx',shname,'c17');  %benchmark

%% generate Data
% txt1={'015760 KS Equity';'USDKRW Curncy';'EWY Equity'};


startdate='2012/3/12';
per={'daily','non_trading_weekdays','previous_value'};
[~, fdates, fprices]=blp_test(txt1,startdate,per);
[~, edates, eprices]=blp_test(transpose(txt2),startdate,per);
[~, bdates, bprices]=blp_test(transpose(txt3),startdate,per);

%% Initialize parameters
M=225;
N=20;
enter_fret=1:0.5:2.5;
enter_causal=[0.05,0.10,0.15,0.20];
range= {enter_fret,enter_causal};
%p is number of lag
p=2;
% enter_fret=1;
% enter_causal=0.1;
exit_causal=0.4;
Metrics=[];
Names=[];

%% loop for causality, zspread and backtesting
for m=1:size(txt2,2) %equity and market
    for n=1:size(txt1,1) %factor
        new_txt1=[txt2(m);txt1(n);txt3(m)];
        
        tday1=edates(:, m+1); 
        px1=eprices(:, m+1);
        tday1(isnan(px1))=[];
        px1(isnan(px1))=[];
        px1(find(~px1))=[];
        tday1(find(~tday1))=[];

        tday2=fdates(:, n+1); 
        px2=fprices(:, n+1);
        tday2(isnan(px2))=[];
        px2(isnan(px2))=[];
        px2(find(~px2))=[];
        tday2(find(~tday2))=[];
        [n1n2, idx1, idx2]=intersect(tday1, tday2);
        tday1=tday1(idx1);
        px1=px1(idx1);
        px2=px2(idx2);
        
        if ~strcmpi(char(txt1(n)),char(txt3(m)))
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
%             h = pptest(Px_Y(:,i));
%             if h==0 
               rtn_Y(2:end,i)=diff(log(Px_Y(:,i)));
%             else
%                rtn_Y(:,i)=Px_Y(:,i);
%             end
        end
        rtn_Y=rtn_Y(2:end,:);
        if ~strcmpi(char(txt1(n)),char(txt3(m)))
           v_rtn=[rtn_Y(M+1:end,1) rtn_Y(M+1:end,3)];
        else
           v_rtn=rtn_Y(M+1:end,:);
        end
        date=tday1(2:end);

%% VAR process
        v_causal=zeros(size(rtn_Y,1)-M+1,1);
        Ymodel=zeros(size(rtn_Y,1),n_dim);
        
        if size(rtn_Y,1)<M
           M=size(rtn_Y,1)-N;
        end
        
        Spec = vgxset('n',n_dim,'nAR',p);
        % SpecAR=vgxar(Spec); %convert a VARMA to a VAR

        Ymodel(1:M-1,:)=Px_Y(1:M-1,:);
        j=M;

        while j<size(rtn_Y,1)
              Ypre=rtn_Y(j-M+1:j-M+p,:);
              Yest=rtn_Y(j-M+p+1:j,:);
             [EstSpec,EstStdErrors,LLF,W] = vgxvarx(Spec,Yest,[],Ypre);
             %       [NumParam,NumActive] = vgxcount(Spec);
             %         reject1 = lratiotest(LLF4,LLF1,n4p - n1p);
             %         AIC = aicbic([LLF1 LLF2 LLF3 LLF4],[n1p n2p n3p n4p]);
             %       [isStable,isInvertible] = vgxqual(EstSpec);
             % OLS1 = [EstSpec.AR{1},EstSpec.AR{2}]';
             % OLS2 = [Y1(2:end-1,:),Y1(1:end-2,:)] \ Y1(3:end,:);

             if j<=size(rtn_Y,1)-N
                [rtn_FY,FYCov]=vgxpred(EstSpec,N,[],Yest);
                reverse_diff=cumsum([log(Px_Y(j+1,:));rtn_FY]);
                reverse_log=exp(reverse_diff);
                Ymodel(j:j+N,:)=reverse_log;
                %       date_est=date(p+1:end-Tpred);
                %       date_pred=date(end-Tpred)+1:date(end-N)+N;
             else
                T_pred=size(rtn_Y,1)-j;
               [rtn_FY,FYCov]=vgxpred(EstSpec,T_pred,[],Yest);
                reverse_diff=cumsum([log(Px_Y(end-T_pred,:));rtn_FY]);
                reverse_log=exp(reverse_diff);
                Ymodel(j:end,:)=reverse_log; 
             end
      
             [F,c_v,p_F] =granger_cause(rtn_Y(j-M+p+1:j,1),rtn_Y(j-M+p+1:j,2),0.05,p);
             v_causal(j-M+1:j-M+1+N)=p_F;
             j=j+N;
        end
        v_causal=v_causal(1:size(rtn_Y,1)-M+1);

        spread=Px_Y(M+1:end,1)-Ymodel(M:end,1);
        Zspread=zscore(spread);

        
        v_factor=zscore(rtn_Y(M+1:end,2));
        
        pfun = @(x) factorFun(v_rtn,Zspread,v_factor,x,v_causal,exit_causal,date(M+1:end));
        [respmax,param,resp] = parameterSweep(pfun,range);
        
        for q=0:3
            enter_factor=1+q*0.5;
            for q1=1:4
                enter_causality=0.05*q1;
                newmetric=factor_backtest(v_rtn,Zspread,v_factor,enter_factor,v_causal,enter_causality,exit_causal,date(M+1:end));
                if newmetric(1)>0 % only include positive exp ret
                   newmetric=[param(1) enter_factor v_factor(end) param(2) enter_causality v_causal(end) respmax newmetric];
                   Metrics=[Metrics; newmetric];
                   Names=[Names; transpose(new_txt1)];
                end
            end
        end
        % plot(1:size(Ymodel,1),Ymodel(:,1),'--r')
        % hold on
        % plot(1:size(Px_Y,1)-1,Px_Y(2:end,1),'k')
 
        % error=Y(end-9:end,:)-FY;
        % SSerror=error(:)'*error(:);
        % 
        % Ysim=vgxsim(EstSpec,10,[],Yest,[],2000);

        % [isStable,isInvertible]=vgxqual(EstSpec);
        % vgxplot(EstSpec,Yest,FY,FYCov);
    end
end
