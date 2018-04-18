function rtnts = rtn(a)
ctra=size(a);

for d=2:ctra(:,1)
    for col=1:size(a,2)
    rtnts(d-1,col)=a(d,col)/a(d-1,col)-1;
    end
end
