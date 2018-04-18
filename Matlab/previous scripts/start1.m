% Dispersion Trader Oil Serive Stock Model, Punit, June 4 at 6:15 PM
%Historical Organizer

%store uniform
%Pairs trading and relationship identifier
days=30;

x=osxprice(:,2:end);
a=osximplied(:,2:end);
maxsize=max(size(a,1),size(x,1));
wt=osxweight;

for j=1:size(x,2)
    for i=2:size(x,1)
        y(i-1,j)=log(x(i,j))-log(x(i-1,j));
    end
end

% annualized vols
for j=1:size(y,2)
    for i=days+1:size(y,1)
        v(i-days,j)=std(y(i-days:i,j))*sqrt(365);
    end
end

% implied uniform calculator
for j=1:size(a,2)-1
    for i=1:size(a,2)-1
        if i==j
            z(i,j)=0;
            ne(i,j)=1;
        else 
            z(i,j)=1;
            ne(i,j)=0;
        end
    end
end

for i=1:size(a,1)
    irv=a(i,1:size(a,2)-1);
    iiv=(a(i,size(a,2)))^2;
    u=0.5;
    u = fminbnd(@d,-1,1, [], iiv,wt,irv,z,ne);
    uniform(i,2)=u;
end

% uniform calculator
for j=1:size(y,2)-1
    for i=1:size(y,2)-1
        if i==j
            z(i,j)=0;
            ne(i,j)=1;
        else 
            z(i,j)=1;
            ne(i,j)=0;
        end
    end
end

for i=1:size(v,1)
    rv=v(i,1:size(y,2)-1);
    iv=(v(i,size(y,2)))^2;
    u=0.5;
    u = fminbnd(@d,-1,1, [], iv,wt,rv,z,ne);
    uniform(i)=u;
end



clear x;
clear y;
clear v;
clear z;
clear ne;
clear irv;

clear plot;
plot(uniform)
%clear iform;
    
    