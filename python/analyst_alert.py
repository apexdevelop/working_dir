# -*- coding: utf-8 -*-
"""
Created on Tue Feb 06 10:37:55 2018

@author: YChen

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
file_name = 'analyst_alert_'+current_date2+'.xlsx'
fullpath=path+file_name
indf = pd.read_excel(fullpath, sheetname='Worksheet')
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
        #don't use rfind here, there is a broker called "Day by Day"
        idx_by = new_condition.find('by')
        #broker
        out_df.iloc[i,3]=new_condition[idx_by+3:]
        if 'Target Px' not in new_condition:
            tg_str = ''
        else:
            if 'Target Px increased' in new_condition:
               tg_str='TP+'
            elif 'Target Px decreased' in new_condition:
               tg_str='TP-'
            r_idx_to = new_condition.rfind('creased to')
            new_tp_str=new_condition[r_idx_to+11:idx_by-1]
            new_tp_number=float(new_tp_str)
            out_df.iloc[i,5]=new_tp_number
            
        if 'Upgraded' in new_condition:
            rating_str='Upgrade'
            r_idx_to = new_condition.rfind('Upgraded to')
            new_rating=new_condition[r_idx_to+12:idx_by-1]
            out_df.iloc[i,6]=new_rating
        elif 'Downgraded' in new_condition:
            rating_str='Downgrade'
            r_idx_to = new_condition.rfind('Downgraded to')
            new_rating=new_condition[r_idx_to+14:idx_by-1]
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