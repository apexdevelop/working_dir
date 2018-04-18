# -*- coding: utf-8 -*-
"""
TODO: since can't solve the automatical sorting property from tia module, has to pull bbg data one by one ticker
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
startdate = '1/5/2009'
enddate= '10/4/2017'
l_px1=[]
l_px2=[]

"""Note
get_historical() takes at most 5 arguments
frame = self.terminal.get_historical(sids, flds, start=start, end=end, period=period, **overrides).as_frame()
currency is one of overrides, so has to point out currency=...
"""

"""try pulling out price all together, 21.26 seconds
"""
import time
start_time = time.time()

sid1 = mgr[arr1]
df_px1 = sid1.get_historical(field1, startdate, enddate,'DAILY', currency="USD")
colnames1=df_px1.columns.values
l_colnames1=colnames1.tolist()
v_idx1=np.zeros((len(arr1),1))
for i in range(len(arr1)):
    v_idx1[i]=l_colnames1.index(arr1[i])
    l_px1.append(df_px1.iloc[:,v_idx1[i]])

sid2 = mgr[arr2]
df_px2 = sid2.get_historical(field1, startdate, enddate,'DAILY', currency="USD")
colnames2=df_px2.columns.values
l_colnames2=colnames2.tolist()
v_idx2=np.zeros((len(arr2),1))
for i in range(len(arr2)):
    v_idx2[i]=l_colnames2.index(arr2[i])
    l_px2.append(df_px2.iloc[:,v_idx2[i]])

print("--- %s seconds ---" % (time.time() - start_time))

"""pulling out price one by one, 95.53 seconds
"""
start_time = time.time()
for ticker in arr1:
    sid = mgr[ticker]
    df_px = sid.get_historical(field1, startdate, enddate,'DAILY', currency="USD")
    l_px1.append(df_px)
    
for ticker2 in arr2:
    sid2 = mgr[ticker2]
    df_px2 = sid2.get_historical(field1, startdate, enddate,'DAILY', currency="USD")
    l_px2.append(df_px2)    
print("--- %s seconds ---" % (time.time() - start_time))

"""
realign data
"""
numPairs=len(arr1)
l_aligned=[]
for i in range(numPairs):
    px1=l_px[i]
    px2=l_px2[i]
    frames_px=[px1,px2]
    raw_df_px=pd.concat(frames_px,axis=1)
    clean_df_px=raw_df_px.dropna(axis=0,how='any')
    l_aligned.append(clean_df_px)