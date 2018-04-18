"""TODO
6301 JP defaults in front of CAT US
implement in multiple pairs
use data from Thomson Reuters
optimization function in Python
"""


import numpy as np
import statsmodels.api as sm
import statsmodels.tsa.stattools as ts
import pandas as pd
import scipy.stats as sc
#add additional module path for Bloomberg
import sys
sys.path.append('C:\Python27\lib\site-packages')
import tia.bbg.datamgr as dm

def coint_datafeed(path,field,startdate,enddate,period,curr):
    try:
        arr = np.genfromtxt(path,delimiter=',',dtype=None)
        #remove empty elements in arr1, there must be easier ways
        arr_rm=[]
        for i in range(len(arr)):
            if arr[i] == '':
               arr_rm.append(i)
        new_arr=np.delete(arr,arr_rm)
        mgr = dm.BbgDataManager()
        #field = 'LAST_PRICE'
        #startdate = '1/5/2009'
        #enddate= '10/4/2017'
        sids = mgr[new_arr]
        df_px = sids.get_historical(field, startdate, enddate,period,currency=curr)
        
        return df_px
    except IOError as e:
        print(e.args)
        return False

def align_data(df):
    s1=df.iloc[:,0] #series
    s2=df.iloc[:,1]
    frames=[s1,s2]
    raw_df=pd.concat(frames,axis=1)
    new_df=raw_df.dropna(axis=0,how='any')
    return new_df


def saveFile(path,arr):
    try:
        csv = np.savetxt(path,arr,delimiter=',')
        return True
    except IOError as e:
        print(e.args)
        return False


def modeling(x,y):
    x = sm.add_constant(x)
    model = sm.OLS(y,x)
    res = model.fit()
    beta = res.params[1]
    alpha = res.params[0]
    residual = res.resid
    stderr = np.std(residual, ddof=2) # degree of freedom 2 for matching with matlab result
    #stderr = np.sqrt(np.divide(np.sum(np.power(np.subtract(residual,np.average(residual)),2)),np.subtract(residual.shape,1)))
    #stderr = np.sqrt(np.divide(np.sum(np.power(np.subtract(residual,np.average(residual)),2)),np.subtract(residual.shape,2)))
    ##regression for residual
    res_x = residual[0:-1]
    res_y = residual[1:]
    res_reg_m = sm.OLS(res_y,res_x)
    res_reg = res_reg_m.fit()
    res_alpha = res_reg.params[0] #beta for residual
    res_reg_res = res_reg.resid
    mse = np.dot(res_reg_res.reshape(1,-1),res_reg_res)/(res_x.size -1)
    cov = np.multiply(mse,1./np.dot(res_x.reshape(1,-1),res_x))
    se_a = np.sqrt(cov)
    teststat = (res_alpha-1)/se_a #adf2
    return beta, alpha, teststat, -2.7421, stderr, residual

def fill_value(alpha,beta,adf2,cv,v_h,v_Beta,v_ADF,start,end,window):
    if window != 0: 
        for i in range(start, start + window):
            v_Beta[start-1:start+window-1] = np.ones((window,1))*beta
            v_ADF[start-1:start+window-1] = np.ones((window,1))*adf2
            if adf2 > cv: 
                v_h[start-1:start+window-1] = np.zeros((window,1))
            else:
                v_h[start-1:start+window-1] = np.ones((window,1))
    else:
        for i in range(start,end + 1):
            v_Beta[start-1:] = np.ones((end-start+1,1))*beta
            v_ADF[start-1:] = np.ones((end-start+1,1))*adf2
            if adf2 > cv: 
                v_h[start-1:] = np.zeros((end-start+1,1))
            else:
                v_h[start-1:] = np.ones((end-start+1,1))
    return v_Beta, v_ADF, v_h

def fill_residual_zscr(v_residual, zscr, resid, beta_idx, prices, alpha, beta, stderr, start, end, window, m):
    if window != 0:
        ny2 = betaidx_rollingMatrix(beta_idx,prices,start-1,start+window-1)
        t_nb = np.array([1,-beta]).reshape(2,1)
        if start == m:
            for i in range(0,start):
                v_residual[i] = resid[i]
        v_residual[start-1:start+window-1] = np.dot(ny2.T,t_nb)-alpha
        zscr[start-1:start+window-1] = np.dot((v_residual[start-1:start+window-1]-np.mean(v_residual[start-m:start])),(1./stderr))
    else:
        ny2 = betaidx_rollingMatrix(beta_idx,prices,start-1,end)
        t_nb = np.array([1,-beta]).reshape(2,1)
        if start == m:
            for i in range(0,start):
                v_residual[i] = resid[i]
        v_residual[start-1:] = np.dot(ny2.T,t_nb)-alpha
        zscr[start-1:] = np.dot((v_residual[start-1:] - np.mean(v_residual[start-m:start])),(1./stderr))
    return v_residual, zscr

def betaidx_rollingMatrix(beta_idx,x,start,end):
    try:
        if beta_idx == 1:
            if end != -1:
                x = x[:,start:end]
            else:
                x = x[:,start:]
        elif beta_idx == 2:
            if end != -1:
                t_mean = np.mean(x[:,start:end],axis=1)
                t_mean = np.expand_dims(t_mean,axis=1)
                x = x[:,start:end]-np.tile(t_mean,(len(t_mean[0]),start-end))
            else:
                t_mean = np.mean(x[:,start:],axis=1)
                t_mean = np.expand_dims(t_mean,axis=1)
                x = x[:,start:]-np.tile(t_mean,(len(t_mean[0]),x.size-start+1))
        elif beta_idx == 3:
            if end != -1:
                x = sc.zscore(x[:,start:end],1,1)
            else:
                x = sc.zscore(x[:,start:],1,1)
        else:
            raise ValueError("beta idx is incorrect. please neter correct beta index","beta_idx")
    except ValueError as e:
        print(e.args)
    return x

def rolling_z_score(arr,window):
    res = np.zeros(arr.shape)
    if(arr[:,0].size < window):
        for i in range(window,arr[:,0].size+1):
            res[i-window:i,:] = sc.zscore(arr[i-window:i,:],axis=1)
    else:
        res = sc.zscore(arr,axis=1)
    return res

def trade_decision(signal_TH,hp_TH,prices,m,numOfCol,adj_day,zscr,v_h):
    #v_residual = np.zeros((numOfCol,1))
    #v_ADF = np.zeros((numOfCol,1))
    #v_Beta = np.zeros((numOfCol,1))
    s = np.zeros((numOfCol,2))
    r_trade = np.zeros((numOfCol,1))
    cPnL = np.zeros((numOfCol,1))
    ret_v = np.zeros((numOfCol,1))
    ret_adj_v = np.zeros((numOfCol,1))
    hp_v = np.zeros((numOfCol,1))
    trades = 0
    is_open = 0
    enterSignal = 0
    entry_idx = 0
    signal = 0
    enter = 0
    if signal_TH > 0:
        signal = -1 #short
    else:
        signal = 1 # long

    for j in range(m,numOfCol):
        if is_open != 0: #if position opened
            s[j-1,0] = s[j-2,0]
            s[j-1,1] = -s[j-1,0]
            r_trade[entry_idx] = 0
            current_r = np.sum(np.concatenate((np.zeros((1,2)),np.multiply(s[entry_idx-1:j-1,:],(np.diff(prices[:,entry_idx-1:j])).T))),axis=1)
            r_trade[j-1] = np.sum(current_r)
            cumul_r = np.sum(np.concatenate((np.zeros((1,2)),np.multiply(s[0:j-1,:],(np.diff(prices[:,0:j])).T))),axis=1)
            cPnL[j-1] = np.sum(cumul_r)
            #exit
            if signal < 0: 
                if(np.equal(s[j-1,0],signal) and np.less(zscr[j-1],-0.25*enterSignal)) or np.less(r_trade[j-1],-0.15) \
                    or (j - entry_idx - 1) > hp_TH or np.equal(v_h[j-1],0):
                    enter = 1
            else:
                if (np.equal(s[j-1,0],1) and np.greater(zscr[j-1],-0.25*enterSignal)) or np.less(r_trade[j-1],-0.15) \
                    or (j-entry_idx-1) > hp_TH or np.equal(v_h[j-1],0):
                    enter = 1
            if enter == 1:
                enter = 0
                trades += 1
                is_open = 0
                ret_v[j-1] = r_trade[j-1]
                adj_ret = 100*((r_trade.item(j-1)/100+1)**(adj_day/(j-entry_idx-1))-1)
                ret_adj_v[j-1] = adj_ret
                hp_v[j-1] = j-entry_idx-1
        else: #position is not opened
                cPnL[j-1] = cPnL[j-2]
                if signal < 0:
                    if np.equal(s[j-2,0],0) and np.greater(zscr[j-2],signal_TH) and np.less_equal(zscr[j-1],zscr[j-2]) \
                        and np.greater_equal(zscr[j-1],0.75*zscr[j-2]) and np.not_equal(v_h[j-1],0):
                        enter = 1
                else:
                    if np.equal(s[j-2,0],0) and np.less(zscr[j-2],signal_TH) and np.greater_equal(zscr[j-1],zscr[j-2]) \
                        and np.less_equal(zscr[j-1],0.75*zscr[j-2]) and np.not_equal(v_h[j-1],0):
                        enter = 1
                if enter == 1:
                    enter = 0
                    enterSignal = zscr[j-1]
                    s[j-1,0] = signal
                    s[j-1,1] = -s[j-1,0]
                    entry_idx = j-1
                    is_open = 1
    if trades >= 1:
        ret_v = ret_v[np.where(ret_v != 0)]
        exp_ret = np.mean(ret_v)
        exp_vol = np.std(ret_v,ddof=1)
        wins = ret_v[np.where(ret_v > 0)]
        nwins = len(wins)
        #from operator import truediv
        winp = (nwins*1.00)/(trades*1.00)
        losses = ret_v[np.where(ret_v <= 0)]
        omega = np.sum(wins)/(np.sum(wins)-np.sum(losses))
        exp_hp = np.round(np.mean(hp_v[np.where(hp_v > 0)]))
    else:
        exp_ret = -99999
        exp_vol = -99999
        winp = -99999
        omega = -99999
        exp_hp = -99999            
    return exp_ret, exp_vol, winp, omega, exp_hp, trades

#def main():
    directory='C:/Users/YChen/Documents/git/working_dir/python/data/'
    file_name = 'coint_universe_single.csv'
    path=directory+file_name
    #generate data from Bloomberg
    field = 'LAST_PRICE'
    startdate = '1/5/2009'
    enddate= '10/4/2017'
    period='DAILY'
    curr='USD'
    raw_bbg = coint_datafeed(path,field,startdate,enddate,period,curr)
    dropna_bbg=align_data(raw_bbg)
    log_px=np.log(dropna_bbg)
    #convert dataframe to nparray, easier  to fit into Gina's code
    arr_px=log_px.as_matrix()
    row_logpx=arr_px.T
    #parameters
    m = 60
    n = 5
    pADF_TH = 0.2
    signal_TH = 1.5
    beta_idx = 1
    hp_TH = 44    
    is_adf = True
    adj_day = 20

    v_spread = np.diff(row_logpx,axis=0)
    z_spread = rolling_z_score(v_spread,m)

    numOfOb = len(row_logpx[0])
    zscr = np.zeros((numOfOb,1))
    v_residual = np.zeros((numOfOb,1))
    v_ADF = np.zeros((numOfOb,1))
    v_h = np.zeros((numOfOb,1))
    v_Beta = np.zeros((numOfOb,1))

    ##calulate Z_residual
    if m < numOfOb:
        j = m
        while j <= numOfOb:
            ny1 = betaidx_rollingMatrix(beta_idx,row_logpx,j-m,j)
            b, a, adf2, cv, stderr, resid = modeling(ny1[1,:],ny1[0,:]) #second row is x, first row is y
            if j <= numOfOb-n:
                v_Beta[:], v_ADF[:], v_h[:] = fill_value(a,b,adf2,cv,v_h,v_Beta,v_ADF,j,0,n)
            else:
                v_Beta[:], v_ADF[:], v_h[:] = fill_value(a,b,adf2,cv,v_h,v_Beta,v_ADF,j,numOfOb,0)
            # beta index
            if j <= numOfOb-n:
                v_residual, zscr = fill_residual_zscr(v_residual,zscr,resid,beta_idx,row_logpx,a,b,stderr,j,0,n,m)
            else:
                v_residual, zscr = fill_residual_zscr(v_residual,zscr,resid,beta_idx,row_logpx,a,b,stderr,j,-1,0,m)
            j += n
    else:
        b, a, adf2, cv, stderr = modeling(row_logpx[1,:],row_logpx[0,:]) #second row is x, first row is y
        t_nb = np.array([1,-b]).reshape(2,1)
        v_residual[:] = np.dot(arr_px,t_nb)-a #seems like here arr_px can be replaced by a dataframe
        zscr[:] = np.dot((v_residual[:] - np.mean(v_residual[:])),(1./stderr))

    ## part 2
    cross = 0
    v_cross = np.zeros((numOfOb,1)) 
    for ctr in range(0,numOfOb-1):
        if np.greater(zscr[ctr,0],0) & np.less(zscr[ctr+1,0],0):
            v_cross[ctr] = ctr
        elif np.greater(0,zscr[ctr,0]) & np.less(0,zscr[ctr+1,0]):
            v_cross[ctr] = ctr
        else:
            continue
    diff_cross = np.diff(np.squeeze(v_cross))
    avg_cross_elapsed = np.round(diff_cross)
    half_cross = np.round(0.5*avg_cross_elapsed)

    ## calculate performance statistics
    if not is_adf:
        v_h = np.ones((numOfOb,1))
    exp_ret, exp_vol, winp, omega, exp_hp, trades = trade_decision(signal_TH,hp_TH,row_logpx,m,numOfCol,adj_day,zscr,v_h)
    #save the result
    result = [exp_ret,exp_vol,winp,omega,exp_hp,trades,v_Beta.item(-1),v_ADF.item(-1)]
    saveFile('C:\\Users\\YChen\\Documents\\git\\working_dir\\python\\Cointegration_output_v1.csv',result)
            
#run model            
main()

                
            


