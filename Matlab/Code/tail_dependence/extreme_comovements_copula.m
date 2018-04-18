clear all;
cd('C:\Users\ychen\Documents\MATLAB');
txt={'HSCEI Index';'CNH Curncy';'CNY Curncy'};
javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.6.1.0\lib\blpapi3.jar')

%% GET Bloomberg DATA
totcd=1825;
startdate=today()-totcd;
per='weekly';

lag=2;

[names, btxt, bbpx]=blp_test(txt,startdate,per);


%% resample factor 1 and factor 2
tday1=btxt(:,3);
factor1=bbpx(:,3);
baddata1=find(~tday1);
tday1(baddata1)=[];
factor1(baddata1)=[];

tday2=btxt(:,4);
factor2=bbpx(:,4);
baddata2=find(~tday2);
tday2(baddata2)=[];
factor2(baddata2)=[];

[~, idx1, idx2]=intersect(tday1, tday2);
tday1=tday1(idx1);
tday2=tday2(idx2);
factor1=factor1(idx1);
factor2=factor2(idx2);    
tday=tday2;

%calculate spread
% spread=factor1(1:end)./factor2(1:end)*100;
spread=factor1(1:end)-factor2(1:end);  
%% get index price and resample again
tday0=btxt(:,2);
index=bbpx(:,2);
baddata0=find(~tday0); % days where any one price is missing
tday0(baddata0)=[];
index(baddata0)=[];
[foo, idx0, idx]=intersect(tday0, tday);

index=index(idx0);
tday0=tday0(idx0);
tday_index=cellstr(datestr(tday0));

spread=spread(idx);
tday=tday(idx);
s1=length(spread);
tday_spread=cellstr(datestr(tday));


X=zeros(size(foo,1)-lag,2);

X(:,1)=spread(1:end-lag);
X(:,2)=index(1+lag:end);

U=zeros(s1-lag,2);
%% t Copula Calculation
% empirical marginal transformation
for j=1:2    
    U(:,j)=tiedrank(X(:,j))/(s1-lag);    
end

[r1,c1,v1]=find(U==1);
[r0,c0,v0]=find(~U);

%adjust rank 0 and 1
if isempty(r1)==0
    for c=1:length(c1)
        U(r1(c),c1(c))=1-0.00001;
    end
end

if isempty(r0)==0
    for c=1:length(c0)
        U(r0(c),c0(c))=0.00001;
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
for i=min_nu:max_nu
    ratio=2*(respmax-resp(i-min_nu+1));
    T(i-min_nu+1)=ratio/1.1;
    P(i-min_nu+1)=chi2cdf(T(i-min_nu+1),1);
end

% plot(v_nu,P);
[C,I]=min(P);
opti_dof=v_nu(I)
