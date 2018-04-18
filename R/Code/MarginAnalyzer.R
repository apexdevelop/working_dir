library(Rbbg)
library(lubridate)
library(plyr)
library(dplyr)
library(MASS)
library(gdata)
library(timeDate)
library(sqldf)
library(zoo)
library(xlsx)

adjust_biz_day  <- function (x) {
  while (!isBizday(timeDate(x), holidays = holidayNYSE())) {
    x = floor_date(x, "day") + days(-1)
  }
  return (x)
}

setwd("C:/Users/ychen/Documents/R/Data")
#perl="C:/perl64/bin/perl.exe"
#margin = read.csv("CH Margin Volume.csv") #Read file
margin = read.xls("CH Margin Volume.xlsx") #Read file

margin[, 2]  <- paste(margin[, 2], " CH Equity", sep="") # Make stock code into ticker
margin  <- margin[, -c(1,6,7,8)] # Drop useless column

margin$daily_net_buy  <- margin$Daily_Margin_Buy - margin$Daily_Margin_Repay
# summary_data = ddply(margin, c("Stock"), summarise, mean=mean(Margin), sd=sd(Margin))

z_data  <- ddply(margin, .(Stock), function(x) { x$z = scale(x$Margin)
                                                 x$mean = mean(x$Margin)
                                                 x$mean_dnb = mean(x$daily_net_buy)
                                                 x$z_dnb = scale(x$daily_net_buy)
                                                 x$sd_dnb = sd(x$daily_net_buy)
                                                 x$min_dnb = min(x$daily_net_buy)
                                                 x$max_dnb = max(x$daily_net_buy)
                                                 x$sd = sd(x$Margin)
                                                 x$min = min(x$Margin)
                                                 x$max = max(x$Margin)
                                                 return(x)})

z_data_30  <- ddply(margin[ymd(margin$Date) >= adjust_biz_day(ymd(Sys.Date())+days(-30)), ], 
                    .(Stock), 
                    function(x) { x$z_M_30 = scale(x$Margin)
                                  x$z_30_dnb = scale(x$daily_net_buy)
                                  x$l_date = max(x$Date)
                                  return(x)}
                   )


agg_data_30  <- ddply(margin[ymd(margin$Date) >= adjust_biz_day(ymd(Sys.Date())+days(-30)), ], 
                    .(Stock), 
                    summarise, mean_30=mean(Margin)/1000, 
                               mean_30_dnb=mean(daily_net_buy)/1000,  
                               sd_30=sd(Margin)/1000,
                               min_30=min(Margin)/1000,
                               max_30=max(Margin)/1000
                     )

conn  <- blpConnect()

mkt_cap  <- bdp(conn, agg_data_30[, "Stock"], c("CUR_MKT_CAP", "TURNOVER"), ("SCALING_FORMAT"), ("MLN"))
names(mkt_cap)[names(mkt_cap)=="CUR_MKT_CAP"] <- paste0("mkt_cap")
names(mkt_cap)[names(mkt_cap)=="TURNOVER"] <- paste0("turnover")
mkt_cap  <- cbind(Stock = rownames(mkt_cap), mkt_cap)
agg_data_30  <- merge(agg_data_30, mkt_cap, "Stock")


latest_movers  <- sqldf("SELECT agg_data_30.*, z_data_30.l_date, z_data_30.z_30_dnb, z_data_30.z_M_30  FROM agg_data_30 LEFT JOIN z_data_30
                      USING(Stock) WHERE Date=l_date")
latest_movers  <- sqldf("SELECT latest_movers.*, z_data.z, z_data.z_dnb, z_data.Margin as Margin, 
                      (z_data.Margin/POWER(10, 6))/mkt_cap AS M_pct_mktcap,
                      z_data.daily_net_buy as daily_net_buy,
                      (z_data.daily_net_buy/POWER(10, 6))/mkt_cap as dnb_pct_mktcap,
                      z_data.Margin/turnover as M_pct_turn,
                      z_data.daily_net_buy/turnover as dnb_pct_turn
                      FROM latest_movers LEFT JOIN z_data
                      USING(Stock) WHERE l_date=Date")
 top_movers = latest_movers
 # top_movers  <- top_movers[with(top_movers, order(-dnb_pct_mktcap)), ]

# To Do: Divide Margin_Mean/Market Cap (from BB) to normalize and compare stocks

tot_nb_1w = sqldf("select Stock, SUM(daily_net_buy) AS tot_nb_1w from z_data_30 WHERE Date >= l_date-7 GROUP BY Stock")
nb_1w = sqldf("select Stock, Margin AS M_1w from z_data_30 WHERE Date = l_date-7 GROUP BY Stock")
tmp = merge(tot_nb_1w, nb_1w, "Stock", all.x=TRUE)
tmp$tot_nb_1w[is.na(tmp$tot_nb_1w)]  <- 0
tmp  <- merge(tmp, mkt_cap, "Stock")
tmp$tot_nb1w_mktcap  <- tmp$tot_nb_1w/(tmp$mkt_cap*10^6)

tmp  <- merge(top_movers, tmp, "Stock")
tmp  <- tmp[with(tmp, order(-M_pct_turn)), ]

write.xlsx(top_movers, "Margin_Analyzer.xlsx")
#write.csv(top_movers, "Margin_Analyzer.csv")
