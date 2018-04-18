####https://www.r-bloggers.com/setting-graph-margins-in-r-using-the-par-function-and-lots-of-cow-milk/
plot(1:10,ann=FALSE,type="n",xaxt="n",yaxt="n")
for(j in 1:4) for(i in 0:10) mtext(as.character(i),side=j,line=i)


# one way to have a custom x axis
plot(1:10, xaxt = "n")
axis(1, xaxp = c(2, 9, 7))

plot(1:10, xaxt = "n")
axis(1, xaxp = c(1, 9, 8))