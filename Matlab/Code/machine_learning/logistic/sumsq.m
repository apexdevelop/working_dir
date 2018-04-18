function output = sumsq(input)
output=0;
for j=1:size(input,1)
    tempsq=input(j)^2;
    output=tempsq+output;
end