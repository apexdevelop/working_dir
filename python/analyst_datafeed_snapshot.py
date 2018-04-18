# -*- coding: utf-8 -*-
"""
Created on Tue Feb 06 10:37:55 2018

@author: YChen

TODO: How to organize result if multiple ticker, multiple fields
reference
https://stackoverflow.com/questions/466345/converting-string-into-datetime
https://docs.python.org/2/library/datetime.html#datetime.datetime.strptime
https://docs.python.org/2/library/datetime.html#strftime-strptime-behavior
"""

import pandas as pd
import numpy as np
from datetime import datetime

current_datetime=datetime.now()
current_date=current_datetime.strftime("%m/%d/%Y")
current_date2=current_datetime.strftime("%m%d%Y")

path='C:/Users/YChen/Documents/git/working_dir/python/data/'
file_name = 'analyst_ticker_s.csv'
fullpath=path+file_name
arr = np.genfromtxt(fullpath,delimiter=',',dtype=None)

"""
np.genfromtxt doesn't work for broker.csv. Error Msg:
  File "C:\Users\YChen\Anaconda2\lib\site-packages\numpy\lib\npyio.py", line 1867, in genfromtxt
    raise ValueError(errmsg)
    ValueError: Some errors were detected !
    Line #33 (got 3 columns instead of 2)
"""
file_name2="broker.xlsx"
fullpath2=path+file_name2
df_broker = pd.read_excel(fullpath2)
broker_code=df_broker.iloc[:,0]

import sys
sys.path.append('C:\Python27\lib\site-packages')
#Bloomberg reference Data
from tia.bbg import LocalTerminal
#should use get_reference to get short_name and last_price
g_fields = ['SHORT_NAME','LAST_PRICE']
resp = LocalTerminal.get_reference_data(arr,g_fields)
df_g=resp.as_frame()

#Bloomberg Historical Data
import tia.bbg.datamgr as dm
mgr = dm.BbgDataManager()
sid = mgr[arr]
s_field1="BEST_ANALYST_RATING"
s_field2="BEST_TARGET_PRICE"
lookback_window=365
snap_window=2
enddate= current_datetime
#startdate = pd.tseries.offsets.BDay(-lookback_window).apply(enddate)
startdate = pd.tseries.offsets.BDay(-90).apply(enddate)
period='DAILY'
#curr='USD'
override_field="BEST_DATA_SOURCE_OVERRIDE"
override_value='UBS'
#overridables = zip(override_field, override_value)
overridables ={override_field:override_value}

session = LocalTerminal._create_session()
session.start()
session.openService("//blp/refdata")
refDataService = session.getService("//blp/refdata")

from tia.bbg import v3api

#req=v3api.HistoricalDataRequest('6502 JT equity', s_field1, start=startdate,overrides=overridables)
#resp2=LocalTerminal.execute(req)

request = refDataService.createRequest("HistoricalDataRequest")
request.getElement("securities").appendValue("6502 JT Equity")
request.getElement("fields").appendValue("BEST_ANALYST_RATING")
request.set("periodicityAdjustment", "ACTUAL")
request.set("periodicitySelection", "WEEKLY")
request.set("startDate", "20171201")
request.set("endDate", "20180208")
request.set("maxDataPoints", 100)
        
# add overrides
overrideField="BEST_DATA_SOURCE_OVERRIDE"
overrideValues=['MZS','UBS']
overrides = request.getElement("overrides")
for overrideValue in overrideValues:
    override = overrides.appendElement()
    override.setElement('fieldId', overrideField)
    override.setElement('value', overrideValue)

session.sendRequest(request)    
resp3=v3api.HistoricalDataResponse(request)
test_df=resp3.as_frame()

import blpapi
while True:
                evt = session.nextEvent(500)
                if evt.eventType() == blpapi.Event.RESPONSE:
                    request.on_event(evt, is_final=True)
                    break
                elif evt.eventType() == blpapi.Event.PARTIAL_RESPONSE:
                    request.on_event(evt, is_final=False)
                else:
                    pass
                    #request.on_admin_event(evt)


test_df=resp2.as_frame()

hist_req=v3api.HistoricalDataRequest('6502 JT equity', s_field1, start=startdate,overrides=overridables)


response = LocalTerminal.get_historical('6502 JT equity', s_field1, start=startdate,overrides=overridables)
df_response=response.as_frame()
df_rating = sid.get_historical(s_field1, startdate, enddate,[override_field,broker_code])
df_tp = sid.get_historical(s_field2, startdate, enddate,period)

d={1:'one',2:'two',3:'three'}
for k, v in d.iteritems():
    print k
    print v


dims=indf.shape
n_ob=dims[0]
indf_time=indf.iloc[:,1]
indf_date=indf.iloc[:,0]
indf_ticker=indf.iloc[:,2]
indf_condition=indf.iloc[:,4]


pre_datetime=pd.tseries.offsets.BDay(-1).apply(current_datetime)
pre_date=pre_datetime.strftime("%m/%d/%Y")
US_str=pre_date+' '+'16:00:00'
US_cutoff= datetime.strptime(US_str, '%m/%d/%Y %H:%M:%S')
JP_str=current_date+' '+'01:00:00'
JP_cutoff= datetime.strptime(JP_str, '%m/%d/%Y %H:%M:%S')
HK_str=current_date+' '+'03:00:00'
HK_cutoff= datetime.strptime(HK_str, '%m/%d/%Y %H:%M:%S')
KR_str=current_date+' '+'01:30:00'
KR_cutoff= datetime.strptime(KR_str, '%m/%d/%Y %H:%M:%S')
TW_str=current_date+' '+'00:30:00'
TW_cutoff= datetime.strptime(TW_str, '%m/%d/%Y %H:%M:%S')

indf_index=indf.index

out_df_columns=['is_after_mkt','event','event_date','broker','ticker','new_tp','new_rating']
out_df= pd.DataFrame(np.nan, indf_index, columns=out_df_columns)
#df_isafter = pd.DataFrame(np.nan, indf_index, columns=['is_after_mkt'])
#df_event = pd.DataFrame(np.nan, indf_index, columns=['event'])
#df_broker = pd.DataFrame(np.nan, indf_index, columns=['broker'])
#df_new_tp = pd.DataFrame(np.nan, indf_index, columns=['new_tp'])
#df_new_rating = pd.DataFrame(np.nan, indf_index, columns=['new_rating'])

"""
filling is_after_mkt,event_date,ticker
"""
for i in range(n_ob):
    test_date=indf_date[i]
    out_df.iloc[i,2]=test_date
    test_time=indf_time[i]
    test_datetime=test_date+' '+ test_time
    py_datetime_test = datetime.strptime(test_datetime, '%m/%d/%Y %H:%M:%S')
    #py_day=py_datetime_test.day
    #py_hour=py_datetime_test.hour
    #py_minute=py_datetime_test.minute

    test_ticker=indf_ticker[i]
    out_df.iloc[i,4]=test_ticker
    security=test_ticker[:-7]
    country=security[-2:]
    if country == 'JP':
       cutoff=JP_cutoff
    elif country == 'HK':
       cutoff = HK_cutoff
    elif country == 'KS':
       cutoff = KR_cutoff
    elif country == 'TW':
       cutoff = TW_cutoff
    elif country == 'US':
       cutoff = US_cutoff
    else:
       cutoff = HK_cutoff
   
    if py_datetime_test>cutoff:
      out_df.iloc[i,0]='A'
    else:
      out_df.iloc[i,0]='B/D' 

"""
filling event,broker,new_tp,new_rating
"""
for i in range(n_ob):
    new_condition=indf_condition[i]
    if 'by' in new_condition:
        r_idx_by = new_condition.rfind('by')
        #broker
        out_df.iloc[i,3]=new_condition[r_idx_by+3:]
        if 'Target Px' not in new_condition:
            tg_str = ''
        else:
            if 'Target Px increased' in new_condition:
               tg_str='TP+'
            elif 'Target Px decreased' in new_condition:
               tg_str='TP-'
            r_idx_to = new_condition.rfind('creased to')
            new_tp_str=new_condition[r_idx_to+11:r_idx_by-1]
            new_tp_number=float(new_tp_str)
            out_df.iloc[i,5]=new_tp_number
            
        if 'Upgraded' in new_condition:
            rating_str='Upgrade'
            r_idx_to = new_condition.rfind('Upgraded to')
            new_rating=new_condition[r_idx_to+12:r_idx_by-1]
            out_df.iloc[i,6]=new_rating
        elif 'Downgraded' in new_condition:
            rating_str='Downgrade'
            r_idx_to = new_condition.rfind('Downgraded to')
            new_rating=new_condition[r_idx_to+14:r_idx_by-1]
            out_df.iloc[i,6]=new_rating
        else:
            rating_str=''
        
        out_df.iloc[i,1]=tg_str+rating_str

#out_list=[df_isafter,df_event,df_broker,df_new_tp,df_new_rating]
#out_df1=pd.concat(out_list,ignore_index=True)
#out_df2 = pd.merge(df_isafter,df_event,right_index=True, left_index=True)
#out_df3 = pd.merge(df_broker,df_new_tp,right_index=True, left_index=True)
#out_df4 = pd.merge(out_df2,out_df3,right_index=True, left_index=True)
#out_df5 = pd.merge(out_df4,df_new_rating,right_index=True, left_index=True)
outpath='C:/Users/YChen/Documents/git/working_dir/python/data/'
outfile_name = 'test_analyst_output_'+current_date2+'.xlsx'
fullpath=outpath+outfile_name
out_df.to_excel(fullpath,index=False)
#csv = np.savetxt(path,arr,delimiter=',')