cd('C:\Documents and Settings\YChen\My Documents');

gamma=2.22;
a=(1+gamma)/2;
b=(1-gamma)/2;
F=@(x)exp(-0.045*x)./(a^2+x).*exp(-(1./(b^2+x).*(b*log(sqrt(a^2+x)./gamma)+sqrt(x).*atan(sqrt(x)/a)))).*sin(1./(b^2+x).*(b*log(sqrt(a^2+x)./gamma)-b*atan(sqrt(x)/a)));
Q=quadgk(F,0,inf,'MaxIntervalCount',728)
% syms x;
% result=int(exp(-0.1*x)/x*exp(x)*sin(x),x,0,1e10)