function rho= copulas_corr(X1,X2,lag)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
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
