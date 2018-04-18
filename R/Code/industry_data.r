library(Rbbg)
conn  <- blpConnect()
myTickers=c("CHPACHIN Index")
fields=c("CHG_PCT_1D")

option_fields  <- c("periodicitySelection","nonTradingDayFillOption", "nonTradingDayFillMethod")
option_values  <- c("MONTHLY","ALL_CALENDAR_DAYS", "PREVIOUS_VALUE")

results  <- bdh(conn, myTickers, fields, start_date="20110101", end_date="20150622", 
                option_names=option_fields, option_values=option_values,dates.as.row.names = FALSE)