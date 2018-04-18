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
library(stringr)
library(reshape2)
library(stats)


adjust_biz_day  <- function (x) {
  while (!isBizday(timeDate(x), holidays = holidayNYSE())) {
    x = floor_date(x, "day") + days(-1)
  }
  return (x)
}

# Direction = 1, if we are counting upgrades. -1 to count downgrade velocity
# Below is the logic to count no. of upgrades or downgrades
# Note that, upgrade to buy from sell results in count of 2 as the jump in scale is 2.
count_up_down  <- function(high, mid, low, dir=1) {
  up_count = 0
  down_count = 0
  count = 0
  
  l = low
  m = mid
  h = high
  
    while (((low < 0 && mid > 0) || (low > 0 && mid < 0))) {
      low  <- low + sign(mid)
      mid  <- mid - sign(mid)
      count  <- count + 1
    }
  
    while (((low < 0 && high > 0) || (low > 0 && high < 0 ))) {
      low  <- low + sign(high)
      high  <- high  - sign(high)
      count  <- count + 2
    }
  
    while (((mid < 0 && high > 0) || (mid > 0 && high < 0 ))) {
      mid  <- mid + sign(high)
      high  <- high - sign(high)
      count  <- count + 1
    }
    
    if ((l < 0 && (m > 0 || h > 0)) || (m < 0 && h > 0)) {
      up_count  <-  count
    }
    else {
      down_count  <-  count
    }
 
    if (dir == 1) {
      return (up_count) 
    }
    else {
      return (-down_count)
    }
}

v_count_up_down  <- Vectorize(count_up_down, c("high", "mid", "low"), TRUE)

rename_columns  <- function(res, suffix = "") {
  #  res  <- results
  #  suffix  <- "p_1M"
  if (!(suffix == "")) { suffix  <- paste0("_", suffix) }
  
  names(res)[names(res)=="chg_pct_1d"] <- paste0("pct_1d", suffix)
  names(res)[names(res)=="chg_pct_5d"] <- paste0("pct_5d", suffix)
  names(res)[names(res)=="rel_1d"] <- paste0("rel_1d", suffix)
  names(res)[names(res)=="rel_5d"] <- paste0("rel_5d", suffix)
  names(res)[names(res)=="rel_1m"] <- paste0("rel_1m", suffix)
  names(res)[names(res)=="rel_3m"] <- paste0("rel_3m", suffix)
  names(res)[names(res)=="last_price"] <- paste0("px", suffix)
  names(res)[names(res)=="eqy_rec_cons"] <- paste0("cons", suffix)
  names(res)[names(res)=="tot_buy_rec"] <- paste0("buy", suffix)
  names(res)[names(res)=="tot_sell_rec"] <- paste0("sell",  suffix)
  names(res)[names(res)=="tot_hold_rec"] <- paste0("hold", suffix)
  names(res)[names(res)=="tot_analyst_rec"] <- paste0("tot_recs", suffix)
  names(res)[names(res)=="BEST_target_price"] <- paste0("tp",  suffix)
  names(res)[names(res)=="spr_val"] <- paste0("spr_val", suffix)
  names(res)[names(res)=="spr"] <- paste0("spr",  suffix)
  
  return(res)
}

relative_time_periods  <-  function (period) {
  # For a given date, assign relative periods
  p_1m   <<- floor_date(period, "day") + months(-1)
  p_2m   <<- floor_date(period, "day") + months(-2)
  p_3m   <<- floor_date(period, "day") + months(-3)
  p_4m   <<- floor_date(period, "day") + months(-4)
  p_5m   <<- floor_date(period, "day") + months(-5)
  p_6m   <<- floor_date(period, "day") + months(-6)
  p_7m   <<- floor_date(period, "day") + months(-7)
  p_8m   <<- floor_date(period, "day") + months(-8)
  p_9m   <<- floor_date(period, "day") + months(-9)
  p_10m  <<- floor_date(period, "day") + months(-10)
  p_11m  <<- floor_date(period, "day") + months(-11)
  p_12m  <<- floor_date(period, "day") + months(-12)
  
  p_d    <<- floor_date(period, "day") + days(-1)
  p_w    <<- floor_date(period, "day") + days(-7)
  
  
  
  p_1m   <<- adjust_biz_day(p_1m)
  p_2m   <<- adjust_biz_day(p_2m)
  p_3m   <<- adjust_biz_day(p_3m)
  p_4m   <<- adjust_biz_day(p_4m)
  p_5m   <<- adjust_biz_day(p_5m)
  p_6m   <<- adjust_biz_day(p_6m)
  p_7m   <<- adjust_biz_day(p_7m)
  p_8m   <<- adjust_biz_day(p_8m)
  p_9m   <<- adjust_biz_day(p_9m)
  p_10m  <<- adjust_biz_day(p_10m)
  p_11m  <<- adjust_biz_day(p_11m)
  p_12m  <<- adjust_biz_day(p_12m)
  p_d    <<- adjust_biz_day(p_d)
  p_w    <<- adjust_biz_day(p_w)
}

setwd("C:/Users/ychen/Documents/R/Data")
#mydata = read.csv("universe_earnings.csv")
mydata = read.xls("universe_earnings.xlsx")
myTickers = as.matrix(mydata)

today = Sys.Date()


default_fields  <- c( "short_name",
                      "country_full_name",
                      "industry_group",
                      "gics_sub_industry_name"
)

# Bloomberg does not give historical values via a BDH call for special_fields.
# Only latest values are available. Therefore, for older dates,
# we need to calculate using "interval_percent_change" on last_px from BB.
# Ex: if you wanted to find chg_pct_3m, one month ago, then it has to be done this way.

special_fields   <- c("chg_pct_1m", "chg_pct_3m") 

value_fields  <-  c(
  "chg_pct_1d",
  "chg_pct_5d",
  "rel_1d",
  "rel_5d",
  "rel_1m",
  "rel_3m",
  "last_price",
  "eqy_rec_cons",
  "tot_buy_rec",
  "tot_sell_rec",
  "tot_hold_rec",
  "tot_analyst_rec",
  "BEST_target_price"
)

option_fields  <- c("nonTradingDayFillOption", "nonTradingDayFillMethod")
option_values  <- c("ALL_CALENDAR_DAYS", "PREVIOUS_VALUE")

conn  <- blpConnect()

# get latest data and historical
history  <- c("p_d", "p_w", "p_1m", "p_2m", "p_3m", "p_4m","p_5m", "p_6m", "p_7m",
              "p_8m" ,"p_9m", "p_10m", "p_11m", "p_12m")

## latest
time_series_data = data.frame()
basic_data = bdp(conn, myTickers, c(default_fields)) # repeat this for the time series
basic_data  <- rename_columns(basic_data)
basic_data  <- cbind(ticker = rownames(basic_data), basic_data)
basic_data.rownames  <- NULL

back_test_start = adjust_biz_day(floor_date(today, "day") + months(-12))

p_1y = adjust_biz_day(floor_date(today, "day") + years(-1))
p_2y = adjust_biz_day(floor_date(today, "day") + years(-2))

time_seq = timeSequence(back_test_start, today)

ldply(c(today, p_1y, p_2y), function (test_per) {
  myresults = bdh(conn, myTickers, c(value_fields), start_date=test_per, end_date=test_per,
                  option_names=option_fields, option_values=option_values)
  myresults$spr_val  <- myresults$BEST_target_price - myresults$last_price
  myresults$spr      <- round(myresults$spr_val/myresults$last_price, 2)
  
  ## historical
  relative_time_periods(test_per)
  
  
  ldply(history, function (per) {
    period  <- eval(parse(text=paste0(per)))
    results  <- bdh(conn, myTickers, value_fields, start_date=period, end_date=period, 
                    option_names=option_fields, option_values=option_values)
    results$spr_val  <- results$BEST_target_price - results$last_price
    results$spr      <- round(results$spr_val/results$last_price, 2)
    
    results  <- results[, !(colnames(results) %in% c("date"))]
    results  <- rename_columns(results, per)
    
    myresults  <<- merge(myresults, results, "ticker")
  })
  
  # Monthly calculated metrics. 1m ago to 11m ago spread velocity (spr_v columns)
  # For 12m, we need to handle it separately over the time series 
  # in time_series_data
  history_monthly = history[!(history %in% c("p_d", "p_w", "p_12m"))]
  ldply(history_monthly, function(per) {
    spr_col1  <- paste0("spr_", per)
    buy_col1  <- paste0("buy_", per)
    sell_col1  <- paste0("sell_", per)
    hold_col1   <- paste0("hold_", per)
    ret_col1  <- paste0("rel_1m_", per)
    tp_col1   <- paste0("tp_", per)

    a = str_match(per, "[0-9]")
    a = as.numeric(a[1]) + 1
    spr_col2 = paste0("spr_", grep(paste0("_", a), history_monthly, value=TRUE))
    buy_col2  <- paste0("buy_", grep(paste0("_", a), history_monthly, value=TRUE))
    sell_col2  <- paste0("sell_", grep(paste0("_", a), history_monthly, value=TRUE))
    hold_col2  <- paste0("hold_", grep(paste0("_", a), history_monthly, value=TRUE))
    ret_col2 = paste0("rel_1m_", grep(paste0("_", a), history_monthly, value=TRUE))
    tp_col2  = paste0("tp_", grep(paste0("_", a), history_monthly, value=TRUE))
    
    spr_col = paste0("spr_v_", per)                  
    ret_col = paste0("rel_i_", per)
    tp_col  = paste0("tp_v_", per)
    buy_col  = paste0("buy_v_", per)
    sell_col  = paste0("sell_v_", per)
    hold_col  = paste0("hold_v_", per)
    
    myresults[, spr_col] <<- myresults[, spr_col1] - myresults[, spr_col2]
    myresults[, ret_col] <<- myresults[, ret_col1] - myresults[, ret_col2]
    myresults[, tp_col]  <<- (myresults[, tp_col1] - myresults[, tp_col2])/myresults[, tp_col2]
#     myresults[, buy_col] <- myresults[, buy_col1] - myresults[, buy_col2]
#     myresults[, sell_col] <- myresults[, sell_col1] - myresults[, sell_col2]
#     myresults[, hold_col] <- myresults[, hold_col1] - myresults[, hold_col2]
    
    delta_buy  = myresults[, buy_col1] - myresults[, buy_col2]
    delta_sell = myresults[, sell_col1] - myresults[, sell_col2]
    delta_hold = myresults[, hold_col1] - myresults[, hold_col2]

    delta_buy[is.na(delta_buy)]  <- 0
    delta_hold[is.na(delta_hold)]  <- 0
    delta_sell[is.na(delta_sell)]  <- 0

    cat("\n calling up_down_count for Per = ", per)
    myresults[, paste0("up_v_", per)] <<- v_count_up_down(delta_buy, delta_hold, delta_sell, 1)
    myresults[, paste0("down_v_", per)] <<- v_count_up_down(delta_buy, delta_hold, delta_sell, -1)

  })
  
  myresults <- merge(basic_data, myresults, "ticker")
  
  # Done for a particular date
  time_series_data <<- rbind(time_series_data, myresults)
})

# We have collected all the time-series historical data so far, and also
# calculated some derived metrics like "velocity"
# Now we can predict some signals or analyze the time series

all_keys = data.frame(time_series_data[, c("short_name", "date")])

# Calculate some cross-sectional metrics. 
ddply(all_keys, .(short_name, date), function(x) {
#   x = all_keys[1, ]
    buy_v_cols = grep("up_v", names(time_series_data), value=TRUE)
    sell_v_cols = grep("down_v", names(time_series_data), value=TRUE)
    tp_v_cols = grep("tp_v", names(time_series_data), value=TRUE)
    rel_i_cols = grep("rel_i", names(time_series_data), value=TRUE)
    
    up  <- time_series_data[time_series_data["short_name"] == x$short_name, c("short_name", buy_v_cols)]
    down  <- time_series_data[time_series_data["short_name"] == x$short_name, c("short_name", sell_v_cols)]
    tp  <- time_series_data[time_series_data["short_name"] == x$short_name, c("short_name", tp_v_cols)]
    z  <- time_series_data[time_series_data["short_name"] == x$short_name, c("short_name", rel_i_cols)]

    up.m  <- melt(up, id.vars=c("short_name"))
    down.m  <- melt(down, id.vars=c("short_name"))
    tp.m  <- melt(tp, id.vars=c("short_name"))
    z.m  <- melt(z, id.vars=c("short_name"))
    names(z.m)[names(z.m)=="variable"] <- "rel_r"
    names(z.m)[names(z.m)=="value"] <- "rr_1m"

  
    z.m  <- cbind(z.m, up.m[, c("variable", "value")])
    z.m  <- z.m[, -grep("variable", names(z.m))]
    names(z.m)[names(z.m)=="value"] <- "up"
  
    z.m  <- cbind(z.m, down.m[, c("variable", "value")])
    z.m  <- z.m[, -grep("variable", names(z.m))]
    names(z.m)[names(z.m)=="value"] <- "down"
  
    z.m  <- cbind(z.m, tp.m[, c("variable", "value")])
    z.m  <- z.m[, -grep("variable", names(z.m))]
    names(z.m)[names(z.m)=="value"] <- "tp_v"
  
    z.m[, "tp_v"]  <- round(z.m[, "tp_v"], 4)
  
    time_series_data[time_series_data["short_name"] == x[1,1], "up_cor"] <<- cor(z.m["rr_1m"], z.m["up"])[1]
    time_series_data[time_series_data["short_name"] == x[1,1], "down_cor"] <<- cor(z.m["rr_1m"], z.m["down"])[1]
    time_series_data[time_series_data["short_name"] == x[1,1], "tp_cor"] <<- cor(z.m["rr_1m"], z.m["tp_v"])[1]
    time_series_data[time_series_data["short_name"] == x[1,1], "tp_avg"] <<- round(mean(z.m[, "tp_v"]), 4)
})

# Compare velocity and relative return impact to see if signals are present

# z-score can be allotted to monthly velocity factors, over the time series
# thereby covering 3 years or 36 data points
# If z is high, is the rel_i_* return high? is out question

# To score on z, make a vector out of all monthly velocities
# How to match this with the matrix we have?

library(xlsx)
#write.csv(time_series_data, "RatingsAnalysis.csv")
write.xlsx(time_series_data, "RatingsAnalysis.xlsx")


