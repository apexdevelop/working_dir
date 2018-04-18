function rtnres = olsrtn(a,b)
ctra=size(a);

for d=2:ctra(:,1)-1
    rtna(d-1,1)=a(d,1)/a(d-1,1)-1;
    rtna(d-1,2)=b(d,1)/b(d-1,1)-1;
end

rtnres=ols(rtna(:, 1), rtna(:, 2)); 