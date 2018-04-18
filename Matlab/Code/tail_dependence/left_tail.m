function v_R1=left_tail(factor1,factor2,v_lag)

s1=length(factor1);
v_R1=zeros(length(v_lag),1);

for i= 1 : length(v_lag)
    X=zeros(s1-v_lag(i),2);
    X(:,1)=factor1(1:end-v_lag(i));
    X(:,2)=factor2(1+v_lag(i):end);

    U=zeros(s1-v_lag(i),2);

%% empirical marginal transformation
    for j=1:2    
        U(:,j)=1-tiedrank(X(:,j))/(s1-v_lag(i));    
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

% Frechet Marginal
    S=-1./log(U(:,1));
    T=-1./log(U(:,2));
%% Tail Dependence

% Hill's Estimator
    Nu=ceil((s1-v_lag(i))*0.02);
    Z=min(S,T);
    Z_sort=sort(Z,'descend');
    iota=mean(log(Z_sort(1:Nu)/Z_sort(Nu+1)));
    R1=2*iota-1;
    var_R1=(R1+1)^2/Nu;
    CI_R1=R1+1.96*var_R1^0.5;

    if CI_R1>=1
       R2=Z_sort(Nu+1)*Nu/(s1-v_lag(i));
    elseif CI_R1>0 && CI_R1<1
       R2=0;
    else
       R2=-1;
    end
%     v_R1(i)=CI_R1;
    v_R1(i)=R1;
end