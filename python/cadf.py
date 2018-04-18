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


def plot_price_series(df, ts1, ts2):
    months = mdates.MonthLocator()  # every month
    fig, ax = plt.subplots()
    ax.plot(df.index, df[ts1], label=ts1)
    ax.plot(df.index, df[ts2], label=ts2)
    ax.xaxis.set_major_locator(months)
    ax.xaxis.set_major_formatter(mdates.DateFormatter('%b %Y'))
    ax.set_xlim(datetime.datetime(2012, 1, 1), datetime.datetime(2013, 1, 1))
    ax.grid(True)
    fig.autofmt_xdate()

    plt.xlabel('Month/Year')
    plt.ylabel('Price ($)')
    plt.title('%s and %s Daily Prices' % (ts1, ts2))
    plt.legend()
    plt.show()

def plot_scatter_series(df, ts1, ts2):
    plt.xlabel('%s Price ($)' % ts1)
    plt.ylabel('%s Price ($)' % ts2)
    plt.title('%s and %s Price Scatterplot' % (ts1, ts2))
    plt.scatter(df[ts1], df[ts2])
    plt.show()

def plot_residuals(df):
    months = mdates.MonthLocator()  # every month
    fig, ax = plt.subplots()
    ax.plot(df.index, df["res"], label="Residuals")
    ax.xaxis.set_major_locator(months)
    ax.xaxis.set_major_formatter(mdates.DateFormatter('%b %Y'))
    ax.set_xlim(datetime.datetime(2012, 1, 1), datetime.datetime(2013, 1, 1))
    ax.grid(True)
    fig.autofmt_xdate()

    plt.xlabel('Month/Year')
    plt.ylabel('Price ($)')
    plt.title('Residual Plot')
    plt.legend()

    plt.plot(df["res"])
    plt.show()

if __name__ == "__main__":
    start = datetime.datetime(2016, 9, 1)
    end = datetime.datetime(2017, 9, 1)

    ts1 = data.DataReader("BABA", "yahoo", start, end)
    ts2 = data.DataReader("JD", "yahoo", start, end)

    df = pd.DataFrame(index=ts1.index)
    df["ts1"] = ts1["Adj Close"]
    df["ts2"] = ts2["Adj Close"]

    # Plot the two time series
    #plot_price_series(df, "ts1", "ts2")

    # Display a scatter plot of the two time series
    #plot_scatter_series(df, "ts1", "ts2")

    # Calculate optimal hedge ratio "beta"
    y=df["ts2"] 
    x=df["ts1"]
    #y=df.iloc[:,0]
    #x=df.iloc[:,1]
    xnc = sm.add_constant(x)
    model = sm.OLS(y,xnc)
    results = model.fit()
    
    #beta = results.params["ts1"]
    beta = results.params.iloc[1]
    #alpha=results.params["const"]
    alpha = results.params.iloc[0]
    
    #if no constant, y(t)=by(t-1)
    #b = results.params.iloc[0]
    
    # Calculate the residuals of the linear combination
    #res1= alpha*df["ts2"] - beta*df["ts1"]
    df["res"] = results.resid
    #res = results.resid
    #res_std=np.std(res)

    # Plot the residuals
    #plot_residuals(df)

    # Calculate and output the CADF test on the residuals
    cadf = ts.adfuller(df["res"])
    pprint.pprint(cadf)

    cadf2=ts.coint(y,x,trend='c')
    pprint.pprint(cadf)
