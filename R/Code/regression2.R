library(zoo)            # Load the zoo package
setwd("C:/Users/ychen/Documents/R/Data")
# Read the CSV files into data frames
#
s = read.csv("8750jp.csv", stringsAsFactors=F)
i = read.csv("nky225.csv", stringsAsFactors=F)


# The first column contains dates.  The as.Date
# function can convert strings into Date objects.
#
N1=dim(s)[1]
N2=dim(i)[1]


# differentiate the time series
s_p=diff(s[,2])/s[1:(N1-1),2]
i_p=diff(i[,2])/i[1:(N2-1),2]
i_p2=i_p^2;


s_dates <- as.Date(s[,1],"%m/%d/%Y")
i_dates <- as.Date(i[,1],"%m/%d/%Y")
i_dates2<- as.Date(i[,1],"%m/%d/%Y")


s=zoo(s_p,s_dates[1:(N1-1)])
i=zoo(i_p,i_dates[1:(N2-1)])
i2=zoo(i_p2,i_dates2[1:(N2-1)])


# The merge function can combine two zoo objects,
# computing either their intersection (all=FALSE)
# or union (all=TRUE).
#
t.zoo <- merge(s, i, all=FALSE)
t.zoo <- merge(t.zoo, i2, all=FALSE)

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
fit <- lm(s ~ i+i2, data=t)
summary(fit)