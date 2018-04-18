data(managers)
# plain
chart.BarVaR(managers[,1,drop=FALSE], main="Monthly Returns")
# with risk line
chart.BarVaR(managers[,1,drop=FALSE],
             methods="HistoricalVaR",
             main="... with Empirical VaR from Inception")
# with lines for all managers in the sample
chart.BarVaR(managers[,1:6],
             methods="GaussianVaR",
             all=TRUE, lty=1, lwd=2,
             colorset= c("red", rep("gray", 5)),
             main="... with Gaussian VaR and Estimates for Peers")
## Not run:
# not run on CRAN because of example time
# with multiple methods
chart.BarVaR(managers[,1,drop=FALSE],
             methods=c("HistoricalVaR", "ModifiedVaR", "GaussianVaR"),
             main="... with Multiple Methods")
# cleaned up a bit
chart.BarVaR(managers[,1,drop=FALSE],
             methods=c("HistoricalVaR", "ModifiedVaR", "GaussianVaR"),
             lwd=2, ypad=.01,
             main="... with Padding for Bottom Legend")
# with 'cleaned' data for VaR estimates
chart.BarVaR(managers[,1,drop=FALSE],
             methods=c("HistoricalVaR", "ModifiedVaR"),
             lwd=2, ypad=.01, clean="boudt",
             main="... with Robust ModVaR Estimate")
# Cornish Fisher VaR estimated with cleaned data,
# with horizontal line to show exceptions
chart.BarVaR(managers[,1,drop=FALSE],
             methods="ModifiedVaR",
             lwd=2, ypad=.01, clean="boudt",
             show.horizontal=TRUE, lty=2,
             main="... with Robust ModVaR and Line for Identifying Exceptions")
## End(Not run)
