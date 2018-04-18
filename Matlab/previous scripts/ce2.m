function ce2(s,k,sig,r,div,t)

b = r - div;
d1 = (log(s / k) + (b + sig ^ 2 / 2) * t) / (sig * sqrt(t));
d2 = d1 - sig * sqrt(t);
nd1 = pnormcdf(d1);
nd2 = pnormcdf(d2);
ce2 = s * exp((b - r) * t) * nd1 - k * exp(-r * t) * nd2

