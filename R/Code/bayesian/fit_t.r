#install.packages("R2WinBUGS")
#install.packages("Ecdat")
#model.file="C:/Users/YChen/Documents/git/working_dir/R/Tbrate_t.bug"
library(R2WinBUGS)
data(CRSPmon,package="Ecdat")
ibm = CRSPmon[,2]
y = as.numeric(ibm)
N = length(y)
ibm_data=list("y","N")
inits=function(){ list(mu=rnorm(1,0,.3),tau=runif(1,1,10),
                       nu=runif(1,1,30)) }

univt.mcmc = bugs(ibm_data,inits,
                  model.file="Tbrate_t.bug.txt",
                  parameters=c("mu","tau","nu","sigma"),
                  n.chains = 3,n.iter=2600,n.burnin=100,
                  n.thin=1,
                  bugs.directory="c:/WinBUGS14/",
                  codaPkg=F,bugs.seed=5640,debug=TRUE)
print(univt.mcmc,digits=4)
plot(univt.mcmc)