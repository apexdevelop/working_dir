# -*- coding: utf-8 -*-
"""
Created on Mon Jan 08 10:34:42 2018

@author: YChen
"""
import pandas as pd

#there are several ways to read data from csv
path='C:/Users/YChen/Documents/git/working_dir/python/data/'
file_name = 'coint_universe.csv'
fullpath=path+file_name
#method 1 using numpy.genfromtxt
import numpy as np
arr = np.genfromtxt(fullpath,delimiter=',',dtype=None) #if you need to read text from csv, need to set dtype=None
arr1=arr[:,0]
arr2=arr[:,1]

"""
#remove empty elements in arr1, there must be easier ways
arr_rm=[]
for i in range(len(arr)):
    if arr[i] == '':
       arr_rm.append(i)
new_arr=np.delete(arr,arr_rm)
"""
#generate data from Bloomberg
#add additional module path
import sys
sys.path.append('C:\Python27\lib\site-packages')
import tia.bbg.datamgr as dm
mgr = dm.BbgDataManager()

field1 = 'LAST_PRICE'
field2 = 'CHG_PCT_1D'
flds=[field1,field2]
startdate = '1/5/2009'
enddate= '10/4/2017'

sids_equity = mgr[arr1]

"""Note
get_historical() takes at most 5 arguments
frame = self.terminal.get_historical(sids, flds, start=start, end=end, period=period, **overrides).as_frame()
currency is one of overrides, so has to point out currency=...
"""
df_epx = sids_equity.get_historical(field1, startdate, enddate,'DAILY', currency="USD")
#df_ertn = sids_equity.get_historical(field2, startdate, enddate)


"""
realign data
"""
px1=df_epx.iloc[:,0]
px2=df_epx.iloc[:,1]
frames_px=[px1,px2]
raw_df_px=pd.concat(frames_px,axis=1)
full_df_px=raw_df_px.dropna(axis=0,how='any')