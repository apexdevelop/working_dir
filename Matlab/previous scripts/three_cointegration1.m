cd('C:\Documents and Settings\YChen\My Documents');
clear H;
clear P;
clear S;
clear y;

blp_simple;

n_stock=size(px,2)-1;
n_t=size(px,1);
for i=1:n_stock
    ts(:,i)=bbpx(:,i+1); % ts represent each of the three stocks
    [h p s]= adftest(ts(:,1));
    H(:,i)=h;    
    P(:,i)=p;
    S(:,i)=s;
    
    for d=2:n_t
    new_ts1(d-1)=ts(d,i)/ts(d-1,i)-1;    
    end
    new_ts1=trimr(new_ts1,0,1);
    ts1(:,i)=new_ts1;
    [h1 p1 s1]= adftest(ts1(:,i));
    H1(:,i)=h1;    
    P1(:,i)=p1;
    S1(:,i)=s1;
end


for nlag=0:2
    y=ts1(:,1);
x1=trimr(ts1(:,2),0,nlag);
x2=trimr(ts1(:,3),0,nlag);
X=[ones(size(x1,1),1) x1 x2];
y=trimr(y,nlag,0);
[b,bint,r,rint,stats] = regress(y,X);
b_col=reshape(b,3,1);
stats_col=reshape(stats,4,1);
B(:,nlag+1)=b_col;
STAT(:,nlag+1)=stats_col;
end

% [num,txt]=xlsread('input','sheet1');
% adjcls(:,1)=num(:,1);
% adjcls(:,2)=num(:,2);
% res_adf=cadf(adjcls(:, 1), adjcls(:, 2), 0, 2);
     