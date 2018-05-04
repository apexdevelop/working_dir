#there are several ways to read data from csv
from os.path import expanduser
home = expanduser("~")
path=home + '/Documents/git/working_dir/python/data/'
file_name = 'oil_universe.csv'
fullpath=path+file_name

#method 1 using numpy.genfromtxt
import numpy as np
#if you need to read text from csv, need to set dtype=None
arr = np.genfromtxt(fullpath,delimiter=',',dtype=None)
arr1=arr[:,0]
arr2=arr[:,1]
arr3=arr[:,2]
"""
#method 2 using pandas.read_csv
import pandas as pd
df=pd.read_csv(fullpath,header=None)

#method 3 csv.reader
#method 3 works in plain python complier, doesn't work in Spyder
import csv
with open(file_name) as csvfile:
    csv_reader = csv.reader(csvfile, delimiter=',')
    u_equity=[]
    u_bench=[]
    u_factor=[]
    for row in csv_reader:
        ticker1=row[0]
        ticker2=row[1]
        ticker3=row[2]
        u_equity.append(ticker1)
        u_bench.append(ticker2)
        u_factor.append(ticker3)
    #print(universe1)
    #print(universe2)

method 4    
import pandas as pd
df = pd.read_excel("Z:/Proj/Trading/Amie Ma/Cointegration_inout_v0.xlsx", sheetname='input')
ts1=df['tempY']
ts2=df['Unnamed: 4']
"""