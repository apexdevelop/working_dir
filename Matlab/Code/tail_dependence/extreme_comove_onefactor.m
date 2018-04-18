
clearvars;
% txt1={'2501 JP Equity';'2502 JP Equity';'2503 JP equity';'3659 JP Equity';'4901 JP Equity';'6301 JP Equity';'6501 JP Equity'};
javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');
txt_s={'2501 JP Equity'}; %stock ticker
txt_f={'AUDJPY Curncy'};  %factor ticker
cell_char={'rel';'01/04/2009';'daily'}; % parameter {fix or rel;startdate;per}
window=1825;
cell_num={window}; 

% function DF=extreme_comove_onefactor(txt_s,txt_f,cell_char,cell_num)
%% GET Bloomberg DATA
[names1, date1, price1]=blp_fix_relative(txt_s,cell_char,cell_num);
[names2, date2, price2]=blp_fix_relative(txt_f,cell_char,cell_num);

lag=0;
DF=zeros(size(date1,2)-1,size(date2,2)-1);
minP=zeros(size(date1,2)-1,size(date2,2)-1);

for i=1:size(date1,2)-1
    for j=1:size(date2,2)-1
%% resample
        tday1=date1(:,i+1);
        px1=price1(:,i+1);
        baddata1=find(~tday1);
        tday1(baddata1)=[];
        px1(baddata1)=[];

        tday2=date2(:,j+1);
        px2=price2(:,j+1);
        baddata2=find(~tday2);
        tday2(baddata2)=[];
        px2(baddata2)=[];

        [foo, idx1, idx2]=intersect(tday1, tday2);
        tday=tday1(idx1);
        tday_output=cellstr(datestr(tday));
        
        px1=px1(idx1);
        px2=px2(idx2);    
                
%         rt1=rtn(px1);
%         rt2=rtn(px2);
%         
%         rel_px1=zeros(size(px1,1),1);
%         rel_px1(1,1)=px1(1,1);
%         p=1;
%         while p<=size(px1,1)
%               [beta1,bint1,res1,rint1,stats1]=regress(rt1,[ones(size(rt1,1),1) rt2]);
%               for t= 1 : size(rt1,1)
%                   rel_px1(t+1,1)=px1(t,1)*(1+res1(t));            
%               end
%               p=p+M;
%         end
        
        X1=px1;
        X2=px2;
        
        s1=size(X1,1);
        
        X=zeros(s1-lag,2);

        X(:,1)=X1(1:end-lag);
        X(:,2)=X2(1+lag:end);

        U=zeros(s1-lag,2);
%% t Copula Calculation
% empirical marginal transformation
        for m=1:2    
            U(:,m)=tiedrank(X(:,m))/(s1-lag);    
        end

        [r1,c1,v1]=find(U==1);
        [r0,c0,v0]=find(~U);

        %adjust rank 0 and 1
        if isempty(r1)==0
           for c=1:length(c1)
               U(r1(c),c1(c))=1-0.0001;
           end
        end

        if isempty(r0)==0
           for c=1:length(c0)
               U(r0(c),c0(c))=0.0001;
           end
        end
        % Calculate Correlation Matrix---Kendall's tau(nonparametric)
        rho=corr(X(:,1),X(:,2),'type','kendall');
        min_nu=3;
        max_nu=40;
        % Degree of freedom
        v_nu=min_nu:max_nu;
        range={v_nu};

        pfun=@(x)ml_t_copula(U,rho,x);
        [respmax,param,resp] = parameterSweep(pfun,range);
        diff_ML=diff(resp);


        T=zeros(1,max_nu-min_nu+1);
        P=zeros(1,max_nu-min_nu+1);
        for n=min_nu:max_nu
            ratio=2*(respmax-resp(n-min_nu+1));
            T(n-min_nu+1)=ratio/1.1;
            P(n-min_nu+1)=chi2cdf(T(n-min_nu+1),1);
        end

        [C,I]=min(P);
        DF(i,j)=v_nu(I);
        minP(i,j)=C;
        
        subplot(3,1,1); plot(v_nu,resp);
        subplot(3,1,2); plot(diff_ML);
        subplot(3,1,3); plot(v_nu,P);
    end
end