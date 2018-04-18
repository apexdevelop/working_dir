function v_R1=yan_right_tail(factor1,factor2,v_lag)

s1=length(factor1);
v_R1=zeros(length(v_lag),1);
for i= 1 : length(v_lag)
    X=zeros(s1-v_lag(i),2);
    X(:,1)=factor1(1:end-v_lag(i));
    X(:,2)=factor2(1+v_lag(i):end);
    U=zeros(s1-v_lag(i),2);

%% empirical marginal transformation
    for j=1:2    
        U(:,j)=tiedrank(X(:,j))/(s1-v_lag(i));    
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

    idx=find(U(:,1)>0.9);
    S=U(idx,1);
    T=U(idx,2);
%% Tail Dependence
    v_R1(i)=corr(S,T);
end
end


% x_axies=0:nlags-1;
% plot(x_axies,v_R1)
% title(['Tail Dependence between ',char(txt(1)),' and ',char(txt(2))])
% ylabel('Tail Correlation')
% xlabel('Daily Lag')