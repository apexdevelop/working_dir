
adf=zeros(10,1);
 y=adjcls(:,1);
 x=adjcls(:,2);
  %y=adjcls_lookback(:,1);
  %x=adjcls_lookback(:,2);
  nobs    = rows(x);
  [beta1,bint1,r1,rint1,stats1]=regress(y,[ones(nobs,1) x]); 
  r1_tdiff     = tdiff(r1,1); %produce matrix differences
  dep0 = trimr(r1_tdiff,1,0); %RETURNS: z = x(n1+1:n-n2,:)
  
  lag1_r=lag(r1,1);
  lag1_r_trimr = trimr(lag1_r,1,0) ;
  p=0;
  crit = rztcrit(nobs,cols(x),p);
  nvar = cols(x);
  meth = 'cadf';
for l=1:10 
    k = 0  ;
     delta=zeros(size(lag1_r_trimr,1),l);
     while (k <= l-1)
           k = k + 1 ;
           delta(:,k)=lag(dep0,k);
     end;
     z0 = [lag1_r_trimr delta]; 
     z       = trimr(z0,l,0) ;     
     tt=l+1:nobs-1;
     tt=reshape(tt,nobs-l-1,1);
     z=[z tt];
     zplusu=[ones(nobs-l-1,1) z];
     dep     = trimr(dep0,l,0) ;
     [beta2,bint2,res2,rint2,stats2]=regress(dep,zplusu);
     so      = (res2'*res2)/(rows(dep)-cols(zplusu));
     var_cov = so*inv(zplusu'*zplusu) ;     
     se_gama=sqrt(var_cov(2,2));
     gama = beta2(2);%gama is the coefficient of y(t-1)
     adf(l) = (gama/se_gama);     
     nlag = l;     
end
 [best_adf,best_ind]=min(adf);