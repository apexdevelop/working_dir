# -*- coding: utf-8 -*-
"""
Created on Mon Jan 08 10:34:42 2018

@author: YChen
"""
import pandas as pd

#there are several ways to read data from csv
from os.path import expanduser
home = expanduser("~")
path=home + '/Documents/git/working_dir/python/data/'
file_name = 'oil_universe.csv'
fullpath=path+file_name
#method 1 using numpy.genfromtxt
import numpy as np
arr = np.genfromtxt(fullpath,delimiter=',',dtype=None) #if you need to read text from csv, need to set dtype=None
arr1=arr[:,0]
arr2=arr[:,1]
arr3=arr[:,2]

#remove empty elements in arr1, there must be easier ways
arr_rm=[]
for i in range(len(arr1)):
    if arr1[i] == '':
       arr_rm.append(i)
new_arr1=np.delete(arr1,arr_rm)

arr_rm=[]
for i in range(len(arr2)):
    if arr2[i] == '':
       arr_rm.append(i)
new_arr2=np.delete(arr2,arr_rm)

#generate data from Bloomberg
#add additional module path
#import sys
#sys.path.append('C:\Python27\lib\site-packages')
import tia.bbg.datamgr as dm
mgr = dm.BbgDataManager()

field1 = 'LAST_PRICE'
field2 = 'CHG_PCT_1D'
flds=[field1,field2]
startdate = '3/12/2012'
enddate= '1/5/2018'

sids_equity = mgr[new_arr1]
df_epx = sids_equity.get_historical(field1, startdate, enddate)
df_ertn = sids_equity.get_historical(field2, startdate, enddate)

sids_bench = mgr[new_arr2]
df_bpx = sids_bench.get_historical(field1, startdate, enddate)
df_brtn = sids_bench.get_historical(field2, startdate, enddate)

sids_factor = mgr[arr3]
df_fpx = sids_factor.get_historical(field1, startdate, enddate)
df_frtn = sids_factor.get_historical(field2, startdate, enddate)

"""
realign data
"""
n_equity=len(new_arr1)
n_factor=len(arr3)
l_px=[]#list
l_rtn=[]#list
#have to get column names of df_bpx, because bbgdatamanager deleted duplicate tickers
colnames_bench=list(df_bpx)
for i in range(n_equity):
    for j in range(n_factor):
        epx=df_epx.iloc[:,i]
        ertn=df_ertn.iloc[:,i]
        if new_arr2[i]==colnames_bench[0]:
           bpx=df_bpx.iloc[:,0]
           brtn=df_brtn.iloc[:,0]
        else:
           bpx=df_bpx.iloc[:,1]
           brtn=df_brtn.iloc[:,1]
        fpx=df_fpx.iloc[:,j]
        frtn=df_frtn.iloc[:,j]
        frames_px=[epx,bpx,fpx]
        raw_df_px=pd.concat(frames_px,axis=1)
        full_df_px=raw_df_px.dropna(axis=0,how='any')
        l_px.append(full_df_px)
        
        frames_rtn=[ertn,brtn,frtn]
        raw_df_rtn=pd.concat(frames_rtn,axis=1)
        full_df_rtn=raw_df_rtn.dropna(axis=0,how='any')
        temp_names=list(full_df_rtn)
        equity_name = temp_names[0]
        #factor_name = temp_names[2]
        relative_rtn=pd.Series(full_df_rtn.iloc[:,0]-full_df_rtn.iloc[:,1],name = equity_name)
        full_relative_rtn=pd.concat([relative_rtn,full_df_rtn.iloc[:,2]],axis=1)
        l_rtn.append(full_relative_rtn)

"""
Rolling Analysis
"""
from scipy.stats.stats import pearsonr
#result from pearsonr is a tuple (corr, pvalue of corr)
#parameters

from statsmodels.tsa.stattools import grangercausalitytests

M=220
l_corr=[]
arr=np.zeros((len(l_rtn)-M,n_equity*n_factor))
df_corr=pd.DataFrame(data=arr)
df_granger=pd.DataFrame(data=arr)

for i in range(n_equity):
    for j in range(n_factor):
        v_corr=np.zeros((len(l_rtn)-M,1))
        v_granger=np.zeros((len(l_rtn)-M,1))
        sample_df=l_rtn[(i+1)*n_equity+j]
        for t in range(len(l_rtn)-M):
            temp_ertn=sample_df.iloc[t:t+M,0]
            temp_frtn=sample_df.iloc[t:t+M:,1]
            temp_corr=pearsonr(temp_ertn,temp_frtn)
            v_corr[t]=temp_corr[0]
            
            temp_granger=grangercausalitytests(sample_df.iloc[t:t+M,:],1)
            #v_granger[t]=temp_granger[0]
            
        arr[:,i*n_factor+j]=v_corr[:,0]
        #error if doing arr[:,i*n_factor+j]=v_corr, shape of v_corr is (62,1)
        #ValueError: could not broadcast input array from shape (62,1) into shape (61)
        df_corr.iloc[:,i*n_factor+j]=v_corr[:,0]
        df_granger.iloc[:,i*n_factor+j]=v_granger[:,0]
        l_corr.append(v_corr)
        
        outpath1=home + '/Documents/git/working_dir/python/data/sf_test_corr_arr.csv'
        csv1 = np.savetxt(outpath1,arr,delimiter=',')
        
        outpath2=home + '/Documents/git/working_dir/python/data/sf_test_corr_df.csv'
        csv2 = np.savetxt(outpath2,df_corr,delimiter=',')
        
        outpath3=home + '/Documents/git/working_dir/python/data/sf_test_granger_df.xlsx'
        #df_granger.to_excel(outpath3)
        
