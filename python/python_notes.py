#install new package on anaconda
https://conda.io/docs/user-guide/tasks/manage-pkgs.html#installing-packages
Use the Terminal or an Anaconda Prompt for the following steps.
conda install 
if it is not in Anaconda channel, then just use pip install

https://datanitro.com/blog/python_on_windows
http://www.lfd.uci.edu/~gohlke/pythonlibs/#statsmodels
https://withsteps.com/3726/pip-is-not-recognized-as-an-internal-or-external-command.html

command line use exit() to exit python

#C:\Users\YChen\Downloads>pip install numpy-1.13.1+mkl-cp27-cp27m-win32.whl
install numpy using pip
setx PATH "%PATH%;C:\Python27\Scripts"
if adding C:\Python27\Scripts to PATH, then don't have to go to C:\Python27\Scripts to pip install
if added path when cmd was open, have to close cmd and reopen to make pip work

otherwise go to C:\Python27\Scripts to pip install packages
C:\Python27\Scripts>pip install numpy

https://stackoverflow.com/questions/37267399/importerror-cannot-import-name-numpy-mkl


somehow pip install scipy doesn't work, have to go to C:\Users\YChen\Downloads, then run 
>pip install scipy-0.19.1-cp27-cp27m-win32.whl

C:\Users\YChen>pip install matplotlib

C:\Users\YChen>pip install pandas

C:\Users\YChen>pip install statsmodels

pip install pandas_datareader

DEPR: remove statsmodels as a dependency
remove pd.ols, pd.fama_macbeth from top-level namespace


#####running python on your OS
http://www.cs.bu.edu/courses/cs108/guides/runpython.html



To get the current working directory use
import os
os.getcwd()

https://stackoverflow.com/questions/4028904/how-to-get-the-home-directory-in-python
To get home directory in path
from os.path import expanduser
home = expanduser("~")

If you're on Python 3.5+ you can use pathlib.Path.home():
from pathlib import Path
home = str(Path.home())    
    
os.chdir("C:\Users\YChen\Documents\git\working_dir\python")
Change the current working directory to path. Availability: Unix, Windows.


sys.path.append('C:\Users\YChen\Documents\git\working_dir\python')

C:\python27\python.exe C:\Users\YChen\Documents\git\working_dir\python\price.py


run script from the shell
>>> execfile('cadf.py')

>>> import statsmodels.tsa.stattools as ts

Warning (from warnings module):
  File "Y:\Program Files\Python27\lib\site-packages\statsmodels\compat\pandas.py", line 56
    from pandas.core import datetools
FutureWarning: The pandas.core.datetools module is deprecated and will be removed in a future version. Please use the pandas.tseries module instead.


if 
start=datetime.datetime(2010,1,1)
end=date.today()
action=data.DataReader(ticker, 'yahoo-actions' , start, end)

####subsettting dataframes#######
#https://stackoverflow.com/questions/11285613/selecting-columns-in-a-pandas-dataframe
df1 = df[['a','b']]
Note: df[['a','b']] produces a copy
df1 = df.ix[:,0:2] # Remember that Python does not slice inclusive of the ending index.
df1 = df.ix[:,0:2].copy() # To avoid the case where changing df1 also changes df

pandas writing dataframe to csv file
https://stackoverflow.com/questions/16923281/pandas-writing-dataframe-to-csv-file


################################
transform data from Bloomberg to data structure in python
https://stackoverflow.com/questions/19387868/how-do-i-store-data-from-the-bloomberg-api-into-a-pandas-dataframe

non_trading_day_fill_option: (NON_TRADING_WEEKDAYS | ALL_CALENDAR_DAYS | ACTIVE_DAYS_ONLY)
non_trading_day_fill_method: (PREVIOUS_VALUE | NIL_VALUE)


##############################Data explorar
https://docs.anaconda.com/anaconda/install/windows
https://pythonhosted.org/spyder/installation.html
https://www.quora.com/What-are-some-good-methods-to-browse-datasets-in-python-like-the-Data-Editor-in-Stata-or-R



