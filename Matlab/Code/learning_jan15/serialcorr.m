n = 200; k = 3; evec = randn(n,1);
xmat = [ones(n,1) randn(n,k)]; y = zeros(n,1); u = zeros(n,1);
beta = ones(k+1,1); beta(1,1) = 10.0; % constant term
for i=2:n; % generate a model with 1st order serial correlation
    u(i,1) = 0.4*u(i-1,1) + evec(i,1);
    y(i,1) = xmat(i,:)*beta + u(i,1);
end;
% truncate 1st 100 observations for startup
yt = y(101:n,1); xt = xmat(101:n,:);
n = n-100; % reset n to reflect truncation
Vnames = strvcat('y','cterm','x2','x3');
result = regress(yt,xt); 
% prt(result,Vnames);
plot(result);