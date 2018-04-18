> getAnywhere('pacf.default')
A single object matching ‘pacf.default’ was found
It was found in the following places
  registered S3 method for pacf from namespace stats
  namespace:stats
with value

function (x, lag.max = NULL, plot = TRUE, na.action = na.fail, 
    ...) 
{
    series <- deparse(substitute(x))
    x <- drop(na.action(as.ts(x)))
    if (!is.numeric(x)) 
        stop("'x' must be numeric")
    x.freq <- frequency(x)
    sampleT <- NROW(x)
    if (is.null(lag.max)) 
        lag.max <- if (is.matrix(x)) 
            floor(10 * (log10(sampleT) - log10(ncol(x))))
        else floor(10 * (log10(sampleT)))
    lag.max <- min(lag.max, sampleT - 1)
    if (lag.max < 1) 
        stop("'lag.max' must be at least 1")
    if (is.matrix(x)) {
        if (any(is.na(x))) 
            stop("NAs in 'x'")
        nser <- ncol(x)
        x <- sweep(x, 2, colMeans(x), check.margin = FALSE)
        lag <- matrix(1, nser, nser)
        lag[lower.tri(lag)] <- -1
        pacf <- ar.yw(x, order.max = lag.max)$partialacf
        lag <- outer(1L:lag.max, lag/x.freq)
        snames <- colnames(x)
    }
    else {
        x <- scale(x, TRUE, FALSE)
        acf <- drop(acf(x, lag.max = lag.max, plot = FALSE, na.action = na.action)$acf)
        pacf <- array(.C(C_uni_pacf, as.double(acf), pacf = double(lag.max), 
            as.integer(lag.max))$pacf, dim = c(lag.max, 1L, 1L))
        lag <- array((1L:lag.max)/x.freq, dim = c(lag.max, 1L, 
            1L))
        snames <- NULL
    }
    acf.out <- structure(.Data = list(acf = pacf, type = "partial", 
        n.used = sampleT, lag = lag, series = series, snames = snames), 
        class = "acf")
    if (plot) {
        plot.acf(acf.out, ...)
        invisible(acf.out)
    }
    else acf.out
}
<bytecode: 0x0a492b10>
<environment: namespace:stats>
