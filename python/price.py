#http://www.learndatasci.com/python-finance-part-yahoo-finance-api-pandas-matplotlib/

from pandas_datareader import data
import datetime
from datetime import date, timedelta

import matplotlib.pyplot as plt
import pandas as pd

#today=date.today()
#previous=today-timedelta(10)

#start=datetime.datetime(2010,1,1)
start='2010-01-04'

#end=datetime.datetime(2016,12,9)
#end=date.today()
end='2017-09-05'

# Getting all weekdays between start and end
all_weekdays = pd.date_range(start=start, end=end, freq='B')

# Define the instruments to download. We would like to see Apple, Microsoft and the S&P500 index.
tickers1 = ['AAPL', 'MSFT', '^GSPC']

ticker="^GSPC"

# Define which online source one should use
source1='yahoo'

panel_data1=data.DataReader(tickers1, source1 , start, end)

# Getting just the adjusted closing prices. This will return a Pandas DataFrame
# The index in this DataFrame is the major index of the panel_data.
close1=panel_data1['Adj Close']
#get index of close2 from following line, it is the date series
#close1.index
#print panel_data1.iloc[0,0] #yahoo defaults to descending order

# How do we align the existing prices in adj_close with our new set of dates?
# All we need to do is reindex close using all_weekdays as the new index
aw_close1 = close1.reindex(all_weekdays)
#aw_close1.head(10)

# Reindexing will insert missing values (NaN) for the dates that were not present
# in the original set. To cope with this, we can fill the missing by replacing them
# with the latest available price for each instrument.
aw_close1 = aw_close1.fillna(method='ffill')
#however, if the first line is NA, it can't be filled, so I have to change start date to 01-04 from 01-01 for now
aw_close1.head(10)


#We can see a summary of the values in each of the instrument by calling the describe() method of a Pandas DataFrame:
aw_close1.describe()


# Get the MSFT time series. This now returns a Pandas Series object indexed by date.
msft = aw_close1.ix[:, 'MSFT']

# Calculate the 20 and 100 days moving averages of the closing prices
short_rolling_msft = msft.rolling(window=20).mean()
long_rolling_msft = msft.rolling(window=100).mean()

#Once a rolling object has been obtained, a number of functions can be
#applied on it, such as sum(), std() or mean()


# Plot everything by leveraging the very powerful matplotlib package
fig = plt.figure()
ax = fig.add_subplot(1,1,1)
ax.plot(msft.index, msft, label='MSFT')
ax.plot(short_rolling_msft.index, short_rolling_msft, label='20 days rolling')
ax.plot(long_rolling_msft.index, long_rolling_msft, label='100 days rolling')
ax.set_xlabel('Date')
ax.set_ylabel('Adjusted closing price ($)')
ax.legend()
plt.show()

#####################################google finance
tickers2 = ['AAPL', 'MSFT', 'SPY'] #^GSPC is not a symbol from google
source2='google'
panel_data2=data.DataReader(tickers2, source2 , start, end)
panel_data2=data.DataReader('HKG:0857', source2 , start, end)
close2=panel_data2['Close'] #panel_data2['Close',:,:]
#print panel_data2.iloc[0,0] #google defaults to ascending order
#############################################






#Historical corporate actions (Dividends and Stock Splits) with ex-dates from Yahoo! Finance.
#action=data.DataReader(ticker, 'yahoo-actions' , start, end)
#print action


#Historical dividends from Yahoo! Finance.
#dvd=data.DataReader(ticker, 'yahoo-dividends' , start, end)
#print dvd


#The YahooQuotesReader class allows to get quotes data from Yahoo! Finance.
#quote = data.get_quote_yahoo('AMZN')
