from pandas_datareader import data
import datetime
from datetime import date, timedelta

import matplotlib.pyplot as plt
import pandas as pd
        
start='2010-01-04'    
end='2017-09-05'
all_weekdays = pd.date_range(start=start, end=end, freq='B')
source1='yahoo'
panel_data1=data.DataReader(universe1, source1 , start, end)

close1=panel_data1['Adj Close']
aw_close1 = close1.reindex(all_weekdays)
aw_close1 = aw_close1.fillna(method='ffill')
