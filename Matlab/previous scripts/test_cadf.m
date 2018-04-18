  %adf=zeros(3,1);
  y=adjcls1_log;
  x=adjcls2_log;
  nobs    = rows(x);
  [beta1,bint1,residuals1,rint1,stats1]=regress(y,[ones(nobs,1) x]);
  
  y_de       = detrend(y,p);
  x_de       = detrend(x,p);
  b = inv(x_de'*x_de)*x_de'*y_de;
  r       = y_de - x_de*b;
  r_tdiff     = tdiff(r,1); %produce matrix differences
  dep0 = trimr(r_tdiff,1,0); %RETURNS: z = x(n1+1:n-n2,:)
  k       = 0     ;
  lag1_r=lag(r,1);
  lag1_r_trimr = trimr(lag1_r,1,0) ;
  
for l=1:1     
     delta=zeros(size(lag1_r_trimr,1),l);
     while (k <= l-1)
           k = k + 1 ;
           delta(:,k)=lag(dep0,k);
     end;
     z0 = [lag1_r_trimr delta]; 
     z       = trimr(z0,l,0) ;     
     tt=2:nobs-1;
     tt=reshape(tt,nobs-2,1);
     z=[z tt];
     zplusu=[ones(nobs-2,1) z];
     dep     = trimr(dep0,l,0) ;
     [beta,bint,residuals,rint,stats]=regress(dep,zplusu);
     
     res=residuals;
     %res     = dep - z*beta(2:end) ;
     so      = (res'*res)/(rows(dep)-cols(zplusu));
     var_cov = so*inv(zplusu'*zplusu) ;
     
     gama = beta(2);%gama is the coefficient of y(t-1)
     se_gama=sqrt(var_cov(2,2));
     adf(l) = (gama/se_gama);
     crit = rztcrit(nobs,cols(x),p);
     nlag = l;
     nvar = cols(x);
     meth = 'cadf';
 end