setwd("C:/Documents and Settings/YChen/My Documents/R")

library(zoo)            # Load the zoo package

# Read the CSV files into data frames
#
data = read.csv("test.csv", stringsAsFactors=F)
data.his=data[1:125,]
mod.burg<-ar(data.his,method="burg",order.max=20)
mod.ols<-ar(data.his,method="ols",order.max=20)
mod.mle<-ar(data.his,method="mle",order.max=20)
mod.yw<-ar(data.his,method="yw",order.max=20)#yule-walker is the default method


mod.pred=predict(mod,as.matrix(data.his),n.ahead=5)


methods()
getAnywhere('ar.yw.default')

getAnywhere('predict.ar')

object=mod
newdata=as.matrix(data.his)
n.ahead=5
function (object, newdata, n.ahead = 1L, se.fit = TRUE, ...) 
{
    if (n.ahead < 1L) 
        stop("'n.ahead' must be at least 1")
    if (missing(newdata)) {
        newdata <- eval.parent(parse(text = object$series))
        if (!is.null(nas <- object$call$na.action)) 
            newdata <- eval.parent(call(nas, newdata))
    }
    nser <- NCOL(newdata)
    ar <- object$ar
    p <- object$order
    st <- tsp(as.ts(newdata))[2L]
    dt <- deltat(newdata)
    xfreq <- frequency(newdata)
    tsp(newdata) <- NULL
    class(newdata) <- NULL
    if (NCOL(ar) != nser) 
        stop("number of series in 'object' and 'newdata' do not match")
    n <- NROW(newdata)
    if (nser > 1L) {
        if (is.null(object$x.intercept)) 
            xint <- rep.int(0, nser)
        else xint <- object$x.intercept
        x <- rbind(sweep(newdata, 2L, object$x.mean, check.margin = FALSE), 
            matrix(rep.int(0, nser), n.ahead, nser, byrow = TRUE))
        pred <- if (p) {
            for (i in seq_len(n.ahead)) {
                x[n + i, ] <- ar[1L, , ] %*% x[n + i - 1L, ] + 
                  xint
                if (p > 1L) 
                  for (j in 2L:p) x[n + i, ] <- x[n + i, ] + 
                    ar[j, , ] %*% x[n + i - j, ]
            }
            x[n + seq_len(n.ahead), ]
        }
        else matrix(xint, n.ahead, nser, byrow = TRUE)
        pred <- pred + matrix(object$x.mean, n.ahead, nser, byrow = TRUE)
        colnames(pred) <- colnames(object$var.pred)
        if (se.fit) {
            warning("'se.fit' not yet implemented for multivariate models")
            se <- matrix(NA, n.ahead, nser)
        }
    }
    else {
        if (is.null(object$x.intercept)) 
            xint <- 0
        else xint <- object$x.intercept
        x <- c(newdata - object$x.mean, rep.int(0, n.ahead))
        if (p) {
            for (i in seq_len(n.ahead)) x[n + i] <- sum(ar * 
                x[n + i - seq_len(p)]) + xint
            pred <- x[n + seq_len(n.ahead)]
            if (se.fit) {
                npsi <- n.ahead - 1L
                psi <- .C(C_artoma, as.integer(object$order), 
                  as.double(ar), psi = double(npsi + object$order + 
                    1L), as.integer(npsi + object$order + 1L))$psi[seq_len(npsi)]
                vars <- cumsum(c(1, psi^2))
                se <- sqrt(object$var.pred * vars)[seq_len(n.ahead)]
            }
        }
        else {
            pred <- rep.int(xint, n.ahead)
            if (se.fit) 
                se <- rep.int(sqrt(object$var.pred), n.ahead)
        }
        pred <- pred + rep.int(object$x.mean, n.ahead)
    }
    pred <- ts(pred, start = st + dt, frequency = xfreq)
    if (se.fit) 
        list(pred = pred, se = ts(se, start = st + dt, frequency = xfreq))
    else pred
}
<bytecode: 0x0585afec>
<environment: namespace:stats>