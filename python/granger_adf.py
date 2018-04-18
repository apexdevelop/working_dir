# https://www.quantstart.com/articles/Basics-of-Statistical-Mean-Reversion-Testing-Part-II
# cadf.py

#os.chdir('C:\Users\YChen\Documents\git\working_dir\python')

import datetime
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import pandas as pd
#import pandas.io.data as web, deprecated
from pandas_datareader import data
import pprint
import statsmodels.tsa.stattools as ts
import statsmodels.api as sm
#from pandas.stats.api import ols, deprecated


def plot_price_series(df):
    ts1=df.ix[:,0].copy()
    ts2=df.ix[:,1].copy()
    ts2=ts2.fillna(method='ffill')
    ts1=ts1.fillna(method='ffill')
    months = mdates.MonthLocator()  # every month
    fig, ax = plt.subplots()
    ax.plot(df.index, ts1, label="ts1")
    ax.plot(df.index, ts2, label="ts2")
    ax.xaxis.set_major_locator(months)
    ax.xaxis.set_major_formatter(mdates.DateFormatter('%b %Y'))
    #ax.set_xlim(datetime.datetime(2012, 1, 1), datetime.datetime(2013, 1, 1))
    ax.grid(True)
    fig.autofmt_xdate()

    plt.xlabel('Month/Year')
    plt.ylabel('Price ($)')
    plt.title('%s and %s Daily Prices' % ('ts1', 'ts2'))
    plt.legend()
    plt.show()

def plot_scatter_series(df):
    ts1=df.ix[:,0].copy()
    ts2=df.ix[:,1].copy()
    ts2=ts2.fillna(method='ffill')
    ts1=ts1.fillna(method='ffill')
    plt.xlabel('%s Price ($)' % 'ts1')
    plt.ylabel('%s Price ($)' % 'ts2')
    plt.title('%s and %s Price Scatterplot' % ('ts1', 'ts2'))
    plt.scatter(ts1, ts2)
    plt.show()

def plot_residuals(df,res):
    months = mdates.MonthLocator()  # every month
    fig, ax = plt.subplots()
    ax.plot(df.index, res, label="Residuals")
    ax.xaxis.set_major_locator(months)
    ax.xaxis.set_major_formatter(mdates.DateFormatter('%b %Y'))
    #ax.set_xlim(datetime.datetime(2012, 1, 1), datetime.datetime(2013, 1, 1))
    ax.grid(True)
    fig.autofmt_xdate()

    plt.xlabel('Month/Year')
    plt.ylabel('Price ($)')
    plt.title('Residual Plot')
    plt.legend()

    plt.plot(res)
    plt.show()

def adf(df):
    # Plot the two time series
    #plot_price_series(df)

    # Display a scatter plot of the two time series
    #plot_scatter_series(df)

    # Calculate optimal hedge ratio "beta"
    ts1=df.ix[:,0].copy()
    ts2=df.ix[:,1].copy()
    y=ts2.fillna(method='ffill')
    x=ts1.fillna(method='ffill')
    x = sm.add_constant(x)
    model = sm.OLS(y,x)
    results = model.fit()
    
    #beta = results.params["ts1"]
    beta = results.params.iloc[1]
    #alpha=results.params["const"]
    alpha = results.params.iloc[0]
    
    # Calculate the residuals of the linear combination
    #res1= alpha*df["ts2"] - beta*df["ts1"]
    res = results.resid

    # Plot the residuals
    #plot_residuals(df,res)

    # Calculate and output the CADF test on the residuals
    # http://www.statsmodels.org/dev/generated/statsmodels.tsa.stattools.adfuller.html
    cadf = ts.adfuller(res)
    #pprint.pprint(cadf)
    return cadf
    
