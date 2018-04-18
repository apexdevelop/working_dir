function ML=ml_t_copula(U,rho,x)
   
   ML=zeros(size(x,1),1);
   parfor i = 1:size(x,1)
          Y=copulapdf('t',U,rho,x(i));
          ML(i)=sum(log(Y));
   end
end