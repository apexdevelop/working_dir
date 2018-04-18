hurstApprox=function(x){
  tau=vector()
  lagvec=vector()
  x=as.numeric(x)
  
  #step through different lags
  for(lag in seq(1,3,1)){
    #produce price difference with lags
    pp=x[(lag+1):length(x)]-x[1:(length(x)-lag)]
    
  #write the difference lags into a vector
  lagvec=c(lagvec,lag)
  
  #calculate the variance of the difference vector
  tau=c(tau,sqrt(sd(pp)))
  }
  
  #linear fit to double-log graph (gives power)
  m=polyfit(x=log10(lagvec),y=log10(tau),n=1)
  hurst=m[1]*2
  return(hurst)
}

