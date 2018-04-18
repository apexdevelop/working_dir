# -*- coding: utf-8 -*-
"""
Created on Fri Jan 12 14:27:14 2018
This notebook shows how to use the components defined in the model. The model module is meant as a light-weight trade model which allows flexible portfolio construction and valuation. The portfolio then handles the position management (long/short), and p&l accounting.
@author: YChen
"""

#import tia.analysis.model as model
#BUG: setup.py missing tia.analysis.model subpackage
#https://github.com/bpsmith/tia/issues/35
from tia.analysis.model import *
import pandas as pd

from tia.util.fmt import new_dynamic_formatter, DynamicColumnFormatter

#matplotlib inline
import matplotlib.pyplot as plt
try:
    plt.style.use('fivethirtyeight')
    plt.rcParams['lines.linewidth'] = 1.4
except:
    pass

# Load microsoft - note it retrieves the dividends too
#from tia.analysis.model import ins
#msft = ins.load_yahoo_stock('MSFT', start='1/1/2010')
#msft.pxs.frame.tail()
field = 'EQY_DPS'
startdate = '1/1/2014'
enddate= '12/31/2017'
import tia.bbg.datamgr as dm
mgr = dm.BbgDataManager()
sid =mgr['MSFT Equity']
dvds = sid.get_historical(field, startdate, enddate,period='QUARTERLY')
index=dvds.index
adj_index =index.to_period(freq='Q')
adj_dvds=dvds.set_index(adj_index)
#fig, axes = plt.subplots(1, 2, figsize=(12, 3))
adj_dvds.plot(kind='bar', title='msft dividends')


#
# Create a signal for when the 10x20 moving average (buy/sell single contract)
# - you can create your own simulation and build trades (using model.Trade or
#   model.TradeBlotter)
from tia.analysis.ta import cross_signal, sma, Signal
pxs= sid.get_historical('PX_LAST', startdate, enddate)
ma10, ma20 = sma(pxs, 10), sma(pxs, 20)

"""
C:\Python27\lib\site-packages\tia\analysis\ta.py:18: FutureWarning: pd.rolling_mean is deprecated for Series and will be removed in a future version, replace with 
        Series.rolling(min_periods=10,window=10,center=False).mean()
  return pd.rolling_mean(arg, n, min_periods=n)
"""
ma10_new=sma(pxs,10)

sig = cross_signal(ma10, ma20)
#series_pxs=pd.Series(pxs)
"""
Here to convert dataframe to series, pd.Series works weirdly
reference the following website
https://stackoverflow.com/questions/33246771/convert-pandas-data-frame-to-series
"""
series_pxs=pxs.iloc[:,0]
trades = Signal(sig).close_to_close(series_pxs)
# show last 10 trades
trades[-10:]

from pandas_datareader import data
start='2014-01-01'
end='2017-12-31'
msft=data.DataReader('MSFT', 'yahoo', start, end)
# Build the portfolio
from tia.analysis.model import port
newport = port.SingleAssetPortfolio(msft, trades)

# show the ltd transaction level pl frame
newport.pl.ltd_txn_frame.tail()

# show the daily pl frame (rolled up by day)
newport.pl.dly_frame.tail()
