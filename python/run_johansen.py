import johansen
from johansen import coint_johansen

####get data from yahoo
from pandas_datareader import data
import datetime
import pandas as pd
#start = datetime.datetime(2016, 9, 1)
#end = datetime.datetime(2017, 9, 1)
start='2016-09-01'
end='2017-09-01'
ts1 = data.DataReader("BABA", "yahoo", start, end)
ts2 = data.DataReader("JD", "yahoo", start, end)

df = pd.DataFrame(index=ts1.index)
df["ts1"] = ts1["Adj Close"]
df["ts2"] = ts2["Adj Close"]

######get data from bloomberg
#import pandas as pd
#import tia.bbg.datamgr as dm

#mgr = dm.BbgDataManager()
#sids = mgr['MSFT US EQUITY', 'IBM US EQUITY']
#df = sids.get_historical('PX_LAST', '1/1/2016', '9/12/2017')


x=df
p=0
k=2

coint_johansen(x,p,k)
