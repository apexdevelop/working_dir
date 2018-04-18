getAnywhere('adf.test')

A single object matching ‘adf.test’ was found
It was found in the following places
  package:tseries
  namespace:tseries
with value
function (x, alternative = c("stationary", "explosive"), k = trunc((length(x) - 
    1)^(1/3))) 
{

library(tseries)
residual = read.csv("test_adf.csv", stringsAsFactors=F)
x=as.matrix(residual)
alternative = "stationary"

    if (NCOL(x) > 1) 
        stop("x is not a vector or univariate time series")
    if (any(is.na(x))) 
        stop("NAs in x")
    if (k < 0) 
        stop("k negative")
    alternative <- match.arg(alternative)
    DNAME <- deparse(substitute(x))
    k=1
    k <- k + 1
    y <- diff(x)
    n <- length(y)
    z <- embed(y, k)
    yt <- z[, 1]
    xt1 <- x[k:n]
    tt <- k:n
    if (k > 1) {
        yt1 <- z[, 2:k]
        yt2 <- union(0,z[1:(n-2),2])
        res <- lm(yt ~ 1 + xt1 + yt1)
        res <- lm(yt ~ 1+ xt1 + yt1+ tt)
    }
    else res <- lm(yt ~ xt1 + 1 + tt)
    res.sum <- summary(res)
    STAT <- res.sum$coefficients[2, 1]/res.sum$coefficients[2, 
        2]
    table <- cbind(c(4.38, 4.15, 4.04, 3.99, 3.98, 3.96), c(3.95, 
        3.8, 3.73, 3.69, 3.68, 3.66), c(3.6, 3.5, 3.45, 3.43, 
        3.42, 3.41), c(3.24, 3.18, 3.15, 3.13, 3.13, 3.12), c(1.14, 
        1.19, 1.22, 1.23, 1.24, 1.25), c(0.8, 0.87, 0.9, 0.92, 
        0.93, 0.94), c(0.5, 0.58, 0.62, 0.64, 0.65, 0.66), c(0.15, 
        0.24, 0.28, 0.31, 0.32, 0.33))
    table <- -table
    tablen <- dim(table)[2]
    tableT <- c(25, 50, 100, 250, 500, 1e+05)
    tablep <- c(0.01, 0.025, 0.05, 0.1, 0.9, 0.95, 0.975, 0.99)
    tableipl <- numeric(tablen)
    for (i in (1:tablen)) tableipl[i] <- approx(tableT, table[, 
        i], n, rule = 2)$y
    interpol <- approx(tableipl, tablep, STAT, rule = 2)$y
    if (is.na(approx(tableipl, tablep, STAT, rule = 1)$y)) 
        if (interpol == min(tablep)) 
            warning("p-value smaller than printed p-value")
        else warning("p-value greater than printed p-value")
    if (alternative == "stationary") 
        PVAL <- interpol
    else if (alternative == "explosive") 
        PVAL <- 1 - interpol
    else stop("irregular alternative")
    PARAMETER <- k - 1
    METHOD <- "Augmented Dickey-Fuller Test"
    names(STAT) <- "Dickey-Fuller"
    names(PARAMETER) <- "Lag order"
    structure(list(statistic = STAT, parameter = PARAMETER, alternative = alternative, 
        p.value = PVAL, method = METHOD, data.name = DNAME), 
        class = "htest")
}
<environment: namespace:tseries>