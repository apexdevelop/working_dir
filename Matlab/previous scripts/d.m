function d = d(u,iv,wt,rv,z,ne)
d=(iv-transpose(wt)*(transpose(rv)*rv.*(u*z+ne))*wt)^2;
end