% unit root tester
function ur1(series)

results=ols(series(2:end,1),series(1:end-1,1));
if results.beta-2*results.sige>0
cf(2)=reuslts.beta+2*results.sige