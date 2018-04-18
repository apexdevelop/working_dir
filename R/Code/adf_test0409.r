setwd("C:/Documents and Settings/YChen/My Documents/R")
# set output options
options(width = 70, digits=4)

# load required packages
library(ellipse)
library(fEcofin)                # various data sets
library(PerformanceAnalytics)   # performance and risk analysis functions
library(zoo)

# load Data
library(tseries)
residual = read.csv("test_adf.csv", stringsAsFactors=F)
residual.mat=as.matrix(residual)
residual.adf=adf.test(residual.mat,alternative="stationary",k=1)
