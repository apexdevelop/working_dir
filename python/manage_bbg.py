import pandas as pd
#add additional module path
import sys
sys.path.append('C:\Python27\lib\site-packages')
import tia.bbg.datamgr as dm

mgr = dm.BbgDataManager()
sids = mgr['2600 HK EQUITY', 'AA EQUITY', 'AWC AU EQUITY', '486 HK EQUITY', 'HNDL IN EQUITY']
df = sids.get_historical('CHG_PCT_1D', '1/5/2009', '10/04/2017')

#write df to csv file
df.to_csv("test_ofile2.csv",sep=',')


#ts1=df.ix[:,0].copy()
#ts2=df.ix[:,1].copy()

#fillna doesn't work for first element, for now just change the start date to'1/5/2009' instead of '1/1/2009'
#y=ts2.fillna(method='ffill')
#x=ts1.fillna(method='ffill')


#import granger_adf
#from granger_adf import plot_price_series
#from granger_adf import plot_scatter_series
#from granger_adf import adf


#plot_price_series(df)
#plot_scatter_series(df)
#results=adf(df)
#results<type 'tuple'>
#adf=results[0]
#padf=results[1]
#bestlag=results[2]


