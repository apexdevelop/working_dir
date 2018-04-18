###somehow, it does not work
library(Rbbg)
conn=blpConnect()
result=bar(conn, "SPY US Equity", "TRADE", "2017-09-21 09:00:00", "2017-09-21 15:00:00", "60")

#############
#> result=bar(conn, "RYA ID Equity", "TRADE", "2010-09-21 09:00:00.000", "2010-09-21 15:00:00.000", "60")
#Error in matrix.data[, 1] : subscript out of bounds
#> result=bar(conn, "SPY US Equity", "TRADE", "2010-09-21 09:00:00", "2010-09-21 15:00:00", "60")
#Error in .jcall("RJavaTools", "Ljava/lang/Object;", "invokeMethod", cl,  : 
#                  java.lang.ArrayIndexOutOfBoundsException: 6
#> result=bar(conn, "SPY US Equity", "TRADE", "2017-09-21 09:00:00", "2017-09-21 15:00:00", "60")
#Error in .jcall("RJavaTools", "Ljava/lang/Object;", "invokeMethod", cl,  : 
# java.lang.ArrayIndexOutOfBoundsException: 6