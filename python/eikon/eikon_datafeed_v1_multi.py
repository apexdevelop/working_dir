# -*- coding: utf-8 -*-
"""
Created on Fri Jan 19 13:14:40 2018

@author: YChen
"""
import eikon as ek
ek.set_app_id('FE608B4F468A9915E559B')
#from datetime import date
#start_date, end_date = date(2016, 1, 1), date.today()

import pandas as pd

#there are several ways to read data from csv
path='C:/Users/YChen/Documents/git/working_dir/python/data/'
file_name = 'coint_universe_eikon.csv'
fullpath=path+file_name
#method 1 using numpy.genfromtxt
import numpy as np
arr = np.genfromtxt(fullpath,delimiter=',',dtype=None) #if you need to read text from csv, need to set dtype=None
arr1=arr[:,0]
arr2=arr[:,1]

l_ric1=[]
for ric1 in arr1:
    l_ric1.append(ric1)
#if don't specify calendardays,there will be an error for multiple tickers
#ValueError: Length mismatch: Expected axis has 6 elements, new values have 5 elements
df1 = ek.get_timeseries(l_ric1, 
                        'CLOSE',
                        start_date="2018-01-01", 
                        end_date="2018-01-19",
                        calendar='calendardays')

#eikon also removes duplicate tickers, so there are only 63columns though 154 tickers

l_ric2=[]
for ric2 in arr2:
    l_ric2.append(ric2)
#if don't specify calendardays,there will be an error for multiple tickers
#ValueError: Length mismatch: Expected axis has 6 elements, new values have 5 elements
df2 = ek.get_timeseries(l_ric2, 
                        'CLOSE',
                        start_date="2018-01-01", 
                        end_date="2018-01-19",
                        calendar='calendardays')

v_idx1=np.zeros((len(arr1),1))
for i in range(len(l_ric1)):
    current_idx1=l_ric1.index(l_ric1[i])
    v_idx1[i]=current_idx1

v_idx1_adj=np.zeros((len(arr1),1)) 
j=1
max_idx1=0
while j<=v_idx1[-1,0]:
    count = 0
    for i in range(1,len(v_idx1)):
        if v_idx1[i] == j:
           count = count + 1
           if count == 1:
              max_idx1=max_idx1+1           
           v_idx1_adj[i]=max_idx1
    j=j+1            

    
v_idx2=np.zeros((len(arr2),1))
for i in range(len(l_ric2)):
    current_idx2=l_ric2.index(l_ric2[i])
    v_idx2[i]=current_idx2

v_idx2_adj=np.zeros((len(arr2),1)) 
j=1
max_idx2=0
while j<=v_idx2[-1,0]:
    count = 0
    for i in range(1,len(v_idx2)):
        if v_idx2[i] == j:
           count = count + 1
           if count == 1:
              max_idx2=max_idx2+1           
           v_idx2_adj[i]=max_idx2
    j=j+1            

"""
realign data
"""
numPairs=len(arr1)
l_aligned=[]
for i in range(numPairs):
    idx1=int(v_idx1_adj[i,0])
    px1=df1.iloc[:,idx1]
    idx2=int(v_idx2_adj[i,0])
    px2=df2.iloc[:,idx2]
    frames_px=[px1,px2]
    raw_df_px=pd.concat(frames_px,axis=1)
    clean_df_px=raw_df_px.dropna(axis=0,how='any')
    l_aligned.append(clean_df_px)