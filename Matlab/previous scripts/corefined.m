clear sref;
clear sref1;
clear ref;

ctr=1;
for j=1:size(summ,1)
if (summ(j,9)> .75 && summ(j,9) < 1.25) 
    if summ(j,15)> 1 || summ(j,15) < -1
    sref(ctr,:)= summ(j,:);
    ctr=ctr+1;
    end
end
end
sref=sortrows(sref,-15);

clear sref1;
ctr=1;
for j=1:size(summ1,1)
if (summ1(j,9)> .75 && summ1(j,9) < 1.25) 
    if summ1(j,15)> 1 || summ1(j,15) < -1
    sref1(ctr,:)= summ1(j,:);
    ctr=ctr+1;
    end
end
end
sref1=sortrows(sref1,-15);

ctr=1;
for j=1:(size(sref,1)+size(sref1,1))+1
    if j <= size(sref,1)
        ref(j,:)=sref(ctr,:);
    elseif j==size(sref,1)+1
        ref(j,:)=0;
        ctr=0;
    else
        ref(j,:)=sref1(ctr,:);
    end
ctr=ctr+1;
    end



