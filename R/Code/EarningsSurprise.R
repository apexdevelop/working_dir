library(Rbbg)
library(lubridate)
library(plyr)
library(dplyr)
library(MASS)
library(gdata)
library(timeDate)
library(zoo)
# Functions ## Organize these into packages etc. for better software design

# adjust_biz_day - returns the previous business day of x (String)
adjust_biz_day  <- function (x) {
  while (!isBizday(timeDate(x), holidays = holidayNYSE())) {
    x = floor_date(x, "day") + days(-1)
  }
  return (x)
}

# End of all function definitions

setwd("C:/Users/ychen/Documents/R/Data")
#perl="C:/perl64/bin/perl.exe"
mydata = read.xls("universe_earnings.xlsx") #Our current portfolio

# mydata = read.csv("universe_earnings.csv")
myTickers = as.matrix(mydata)
fields  <- c("sales_surp_percent",
             "opp_surp_percent", 
             "eps_surp_adjusted_percent"
             #"net_income_surp_adjusted_percent"
)

default_fields  <-  c("short_name",
                      "expected_report_dt",
                      "latest_announcement_dt",
                      "country_full_name",
                      "industry_group",
#                       "sales_surp_amount",
#                       "opp_surp_amount",
#                       "eps_surp_adjusted_amount",
                      "last_price",
                      "chg_pct_5d",
                      "rel_5d",
                      "chg_pct_1m",
                      "rel_1m",
                      "best_sales",
                      "best_sales_hi",
                      "best_sales_lo",
                      "best_sales_4wk_pct_chg",
                      "best_eps",
                      "best_eps_hi",
                      "best_eps_lo",
                      "best_eps_4wk_pct_chg",
                      "best_eps_gaap_4wk_pct_chg",
                      "best_net_income",
                      "best_net_hi",
                      "best_net_lo",
                      "best_net_4wk_pct_chg",
                      "best_opp",
                      "best_opp_hi",
                      "best_opp_lo",
                      "best_opp_4wk_pct_chg",
                      "best_ebitda",
                      "best_ebitda_hi",
                      "best_ebitda_lo",
                      "best_ebitda_4wk_pct_chg",
                      "best_roa",
                      "best_roa_hi",
                      "best_roa_lo",
                      "best_roa_4wk_pct_chg",
                      "best_roe",
                      "best_roe_hi",
                      "best_roe_lo",
                      "best_roe_4wk_pct_chg"
)

override_fields  <- c("best_fperiod_override")
price_source_override  <- ("BEST_data_source_override")

S_S_th    <- 1
OP_S_th   <- 1
EPS_S_th  <- 1


conn  <- blpConnect()

today = Sys.Date()
p_m   = floor_date(today, "day") + months(-1)
p_q   = floor_date(today, "day") + months(-3)
p_w   = floor_date(today, "day") + days(-7)
p_2q  = floor_date(today, "day") + months(-6)
no_of_quarters = 4 # No. of quarters to collect stats

# p_w   = adjust_biz_day(p_w)
# p_m = adjust_biz_day(p_m)
# p_q    = adjust_biz_day(p_q)
# p_2q  = adjust_biz_day(p_2q)

# Collect data for the last no_of_quarters in myResults, but beginning with current (to be reported) period estimates
myresults = bdp(conn, myTickers, 
                default_fields, 
                c(override_fields, price_source_override), 
                c("1FQ", "BST"))
numeric_cols  <- sapply(myresults, mode) == 'numeric'
myresults[numeric_cols]  <- round(myresults[numeric_cols], 2)

# Determine if the company has yearly/quarterly based on last quarter
myresults$Q_Y = "Q" # Mark Financial Period as Q for all data
# # Mark FPeriod as "Y"early if "Q"uarterly data is not available when getting surprise % later on
# For most cases, I have seen that the BEST_Sales is available for the current reporting quarter.

# # Set up the structure for the code that follows
names(myresults)[names(myresults)=="expected_report_dt"] <- paste0("Nxt_dt")
names(myresults)[names(myresults)=="latest_announcement_dt"] <- paste0("Last_dt")
names(myresults)[names(myresults)=="country_full_name"] <- paste0("Country")
names(myresults)[names(myresults)=="industry_group"] <- paste0("Industry")
# names(myresults)[names(myresults)=="sales_surp_amount"] <- paste0("S_S_Amt")
# names(myresults)[names(myresults)=="opp_surp_amount"] <- paste0("OP_S_Amt")
# names(myresults)[names(myresults)=="eps_surp_adjusted_amount"] <- paste0("EPS_S_Amt")
names(myresults)[names(myresults)=="last_price"] <- paste0("L_Px")
names(myresults)[names(myresults)=="best_target_price"] <- paste0("TP")
names(myresults)[names(myresults)=="best_target_1wk_chg"] <- paste0("TP_chg_w")
names(myresults)[names(myresults)=="best_target_4wk_chg"] <- paste0("TP_chg_4w")
names(myresults)[names(myresults)=="best_sales_4wk_pct_chg"] <- paste0("s_4w %")
names(myresults)[names(myresults)=="best_eps_4wk_pct_chg"] <- paste0("eps_4w %")
names(myresults)[names(myresults)=="best_eps_gaap_4wk_pct_chg"] <- paste0("eps_gaap_4w %")
names(myresults)[names(myresults)=="best_net_4wk_pct_chg"] <- paste0("net_4w %")
names(myresults)[names(myresults)=="best_opp_4wk_pct_chg"] <- paste0("op_4w %")
names(myresults)[names(myresults)=="best_ebitda_4wk_pct_chg"] <- paste0("ebitda_4w %")
names(myresults)[names(myresults)=="best_roa_4wk_pct_chg"] <- paste0("roa_4w %")
names(myresults)[names(myresults)=="best_roe_4wk_pct_chg"] <- paste0("roe_4w %")

names(myresults)[names(myresults)=="best_sales"] <- paste0("S")
names(myresults)[names(myresults)=="best_sales_hi"] <- paste0("S_h")
names(myresults)[names(myresults)=="best_sales_lo"] <- paste0("S_l")
names(myresults)[names(myresults)=="best_eps"] <- paste0("EPS")
names(myresults)[names(myresults)=="best_eps_hi"] <- paste0("EPS_h")
names(myresults)[names(myresults)=="best_eps_lo"] <- paste0("EPS_l")
names(myresults)[names(myresults)=="best_net_income"] <- paste0("NI")
names(myresults)[names(myresults)=="best_net_hi"] <- paste0("NI_h")
names(myresults)[names(myresults)=="best_net_lo"] <- paste0("NI_l")
names(myresults)[names(myresults)=="best_opp"] <- paste0("OP")
names(myresults)[names(myresults)=="best_opp_hi"] <- paste0("OP_h")
names(myresults)[names(myresults)=="best_opp_lo"] <- paste0("OP_l")
names(myresults)[names(myresults)=="best_ebitda"] <- paste0("EBITDA")
names(myresults)[names(myresults)=="best_ebitda_hi"] <- paste0("EBITDA_h")
names(myresults)[names(myresults)=="best_ebitda_lo"] <- paste0("EBITDA_l")
names(myresults)[names(myresults)=="best_roa"] <- paste0("ROA")
names(myresults)[names(myresults)=="best_roa_hi"] <- paste0("ROA_h")
names(myresults)[names(myresults)=="best_roa_lo"] <- paste0("ROA_l")
names(myresults)[names(myresults)=="best_roe"] <- paste0("ROE")
names(myresults)[names(myresults)=="best_roe_hi"] <- paste0("ROE_h")
names(myresults)[names(myresults)=="best_roe_lo"] <- paste0("ROE_l")

names(myresults)[names(myresults)=="rel_1m"] <- paste0("rel_1m")
names(myresults)[names(myresults)=="rel_5d"] <- paste0("rel_5d")
names(myresults)[names(myresults)=="chg_pct_5d"] <- paste0("5d")
names(myresults)[names(myresults)=="chg_pct_1m"] <- paste0("1m")
names(myresults)[names(myresults)=="short_name"] <- paste0("name")


myresults  <- cbind(Ticker = rownames(myresults), myresults)
myresults.rownames  <- NULL

# Calculate hi and low as +/- %
h = myresults[, (grep('_h$', names(myresults)))]
l = myresults[, (grep('_l$', names(myresults)))]

ldply(h, function(c){
  col = gsub('(^.+?)_h$', "\\1", c)
  
})

for (n in 0:no_of_quarters) { 

  f_period_override  <- paste0("-", n, "FQ")
  f_period_colname <- paste0( n, "FQ")
  period_data = bdp(conn, myTickers, fields, override_fields, f_period_override)
  
  # Rename columns 
  names(period_data)[names(period_data)=="sales_surp_percent"] <- paste0("S_", f_period_colname)
  names(period_data)[names(period_data)=="opp_surp_percent"] <- paste0("OP_", f_period_colname)
  names(period_data)[names(period_data)=="eps_surp_adjusted_percent"] <- paste0("EPS_", f_period_colname)
  period_data["Q_Y"] = "Q"
  period_data  <- cbind(Ticker = rownames(period_data), period_data)
  # rownames(period_data)  <- NULL
  
  col_name = paste0("S_", f_period_colname)
  
  # For missing data (tickers), try parameter as -1FY to get YEARLY data
  #######
  # *************************
  # Enable the below lines of code during Year END earnings season
  # *************************
  #######
#   missing_data = as.matrix(row.names(period_data[is.na(period_data[col_name]), ]))
#   f_period_override  <- paste0("-", n, "FY")
#   period_data_fy = bdp(conn, missing_data, fields, override_fields, f_period_override)
#   
#   # Rename columns 
#   names(period_data_fy)[names(period_data_fy)=="sales_surp_percent"] <- paste0("S_", f_period_colname)
#   names(period_data_fy)[names(period_data_fy)=="opp_surp_percent"] <- paste0("OP_", f_period_colname)
#   names(period_data_fy)[names(period_data_fy)=="eps_surp_adjusted_percent"] <- paste0("EPS_", f_period_colname)
#   period_data_fy$Q_Y  <- "Y"
#   period_data_fy  <- cbind(Ticker = rownames(period_data_fy), period_data_fy)
#   
#   # Combine the yearly data if quarterly is missing for a -nFP finacial period.
#   period_data[is.na(period_data[col_name]), ]  <- 
#     period_data_fy[row.names(period_data[is.na(period_data[col_name]), ]), ]
#   
#   rownames(period_data)  <- NULL
  
#   __ END OF YEARLY SECTION OF THE CODE __

  # Store results for the quarter
  myresults  <- merge(myresults,period_data,"Ticker")
  myresults[myresults$Q_Y.y == "Y", "Q_Y.x"] = "Y"
  myresults  <- subset(myresults, select=-c(Q_Y.y))
  colnames(myresults)[which(names(myresults) == "Q_Y.x")]  <- "Q_Y"
}


# Calculate Statistics 
factors <- c('S_','OP_','EPS_')

# Testing code
# sapply(factors, function(x)as.matrix(apply(period_data[,grep(paste("^", x, sep=""),names(period_data)), drop = FALSE], 1, mean)))
# period_data$  <- rowMeans(subset(period_data, select = grep(paste("^", x, sep=""), names(period_data))), na.rm=TRUE)

## This below piece of shit code does not work ... see pasting it inside the ldply() below
# t  <- paste('^', 'S_', '.+?F', sep="")
# tmp  <-  paste(grep(t, names(myresults), value=TRUE), collapse="+")
# tmp  <- paste("I(", tmp, ")", sep = "")
# tmp  <-  as.formula(paste(tmp, "Ticker", sep = " ~ "))
# junk = summaryBy(tmp, data=myresults,FUN=c(mean), na.rm=TRUE, var.names=paste(x, "mean", sep=""))

library(doBy)
period_stats  <- myresults

# Calculate mean, grouped by ticker for all groups of surprises. Mean of all Sales surprise
# is given by mean of S_1FQ, S_2FQ and so on as S. And repeat this for OP and Adj. EPS using ldply()
# For each group's mean/statistic save the column to a global variable (period_stats)
# summaryBy(S_1FQ+S_2FQ+... ~ Ticker, data=period_data,FUN=c(mean), na.rm=TRUE)


ldply(factors, function(attr){
  # t  <- paste('^', 'S_', '.+?F', sep="")
  cols = names(period_stats)
  stat_col = paste(attr, "mean", sep="")
  x = paste('^', attr, '.+?F', sep="")
  period_stats[, paste(stat_col)]  <<- round(rowMeans(subset(period_stats, select = grep(paste(x), cols)), na.rm=TRUE), digits = 2)
})

# period_stats[, "S_1FQ"] > period_stats[, "S_mean"]
# apply(logicalCols, 1, all)

ldply(factors, function(attr){
  cols = names(period_stats)
  stat_col = paste(attr, "mean", sep="")
  threshold = paste(attr, "S_th", sep="")
  x = paste('^', attr, '.+?F', sep="")
  cols  <- grep(paste(x), cols, value=TRUE)
  
  trend_col_th = paste(attr, "trend_th", sep="")
  
  logicalPlus   <- data.frame(period_stats[, cols] > get(threshold))
  logicalMinus  <- data.frame(period_stats[, cols] < -get(threshold))
  
  logicalPlus[logicalPlus == TRUE] = "+"
  logicalPlus[logicalMinus == TRUE] = "-"
  logicalPlus[logicalPlus == FALSE] = 0

  period_stats[, paste(trend_col_th)]  <<- do.call(paste0, logicalPlus)

})

library(xlsx)
write.xlsx(period_stats, "EarningsOutput.xlsx")

#write.csv(period_stats, "EarningsOutput.csv")