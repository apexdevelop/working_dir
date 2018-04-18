
function [v_DF,rho] = find_dof(X1,X2,v_lag)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
         s1=size(X1,1);
         v_DF=zeros(length(v_lag),1);
         minP=zeros(length(v_lag),1);
         for i= 1 : length(v_lag)
             X=zeros(s1-v_lag(i),2);
             X(:,1)=X1(1:end-v_lag(i));
             X(:,2)=X2(1+v_lag(i):end);
             U=zeros(s1-v_lag(i),2);
%% t Copula Calculation
% empirical marginal transformation
             for m=1:2    
                 U(:,m)=tiedrank(X(:,m))/(s1-v_lag(i));    
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
             v_nu=min_nu:max_nu;
             range={v_nu};

             pfun=@(x)ml_t_copula(U,rho,x);
             [respmax,param,resp] = parameterSweep(pfun,range);
        % plot(v_nu,resp);
             diff_ML=diff(resp);
        % plot(diff_ML);

             T=zeros(1,max_nu-min_nu+1);
             P=zeros(1,max_nu-min_nu+1);
             for n=min_nu:max_nu
                 ratio=2*(respmax-resp(n-min_nu+1));
                 T(n-min_nu+1)=ratio/1.1;
                 P(n-min_nu+1)=chi2cdf(T(n-min_nu+1),1);
             end
             [C,I]=min(P);
             v_DF(i)=v_nu(I);
             minP(i)=C;
         end


