
library(zoo)            # Load the zoo package
setwd("C:/Users/ychen/Documents/R/Data")
# Read the CSV files into data frames
#
s = read.csv("8750jp.csv", stringsAsFactors=F)
i = read.csv("nky225.csv", stringsAsFactors=F)
g = read.csv("jgb.csv")

# The first column contains dates.  The as.Date
# function can convert strings into Date objects.
#
N1=dim(s)[1]
N2=dim(i)[1]
N3=dim(g)[1]

# differentiate the time series
s_p=diff(s[,2])/s[1:(N1-1),2]
i_p=diff(i[,2])/i[1:(N2-1),2]
g_p=diff(g[,2])/g[1:(N3-1),2]


s_dates <- as.Date(s[,1],"%m/%d/%Y")
i_dates <- as.Date(i[,1],"%m/%d/%Y")
g_dates <- as.Date(g[,1],"%m/%d/%Y")


s=zoo(s_p,s_dates[1:(N1-1)])
i=zoo(i_p,i_dates[1:(N2-1)])
g=zoo(g_p,g_dates[1:(N3-1)])


# The merge function can combine two zoo objects,
# computing either their intersection (all=FALSE)
# or union (all=TRUE).
#
t.zoo <- merge(s, i, all=FALSE)
t.zoo <- merge(t.zoo,g, all=FALSE)

# At this point, t.zoo is a zoo object with three columns: 8750jp,nky225 and jgb.
# Most statistical functions expect a data frame for input,
# so we create a data frame here.
#
t <- as.data.frame(t.zoo)

# Tell the user what dates are spanned by the data.
#
cat("Date range is", format(start(t.zoo)), "to", format(end(t.zoo)), "\n")

# The lm function builds linear regression models using OLS.
# We build the linear model, m, forcing a zero intercept,
# then we extract the model's first regression coefficient.
#
fit <- lm(s ~ i + g, data=t)
summary(fit)
# diagnostic plots 
layout(matrix(c(1,2,3,4),2,2)) # optional 4 graphs/page 
plot(fit)

alpha=coef(fit)[1]
beta_i=coef(fit)[2]
beta_g=coef(fit)[3]
predicted <- beta_i*t$i + beta_g*t$g+alpha
x=1:length(predicted)
plot(x, predicted, col="blue", type="l", ylim=c(0,0.1), 
     main = 'Regression', ylab="")
lines(x, t$s, col="red")
grid()
legend("topright",c('"Predicted"','"Actual"'),col=c("blue","red"),lty=c(1,1))


#########cointegration test###########################
library(tseries)            # Load the tseries package
res=predicted-t$s
# Setting alternative="stationary" chooses the appropriate test.
# Setting k=0 forces a basic (not augmented) test.  See the
# documentation for its full meaning.
#

write.csv(predicted,"predicted.csv")
write.csv(t$s,"s.csv")

ht <- adf.test(res, alternative="stationary", k=4)
cat("ADF p-value is", ht$p-value, "\n")