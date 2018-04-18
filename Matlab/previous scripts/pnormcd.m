function p = fun(x,mu,sigma)


p = 0.5 * erfc(-(x-mu)./(sqrt(2)*sigma));
