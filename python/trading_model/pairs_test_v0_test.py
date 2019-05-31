import numpy as np
import statsmodels.api as sm
import statsmodels.tsa.stattools as ts
import pandas as pd
import scipy.stats as sc

def openFile(path):
    try:
        #csv = np.genfromtxt(path,delimiter=',',skip_header=1) #if use this line, then don't need np.delete
        csv = np.genfromtxt(path,delimiter=',')
        dates = csv[:,0]
        price = csv[:,[1,2]]
        price = price.T
        dates = np.delete(dates,0)
        price = np.delete(price,0,1)#0 means first column, 1 means column axis
        price = np.log(price)
        rawmat = np.vstack((dates,price))
        return rawmat
    except IOError as e:
        print(e.args)
        return False

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
    alpha = res.params[0] # 
    residual = res.resid
    #stderr = np.std(residual)
    stderr = np.std(residual, ddof=2) # degree of freedom 2 for matching with matlab result
    adf_test = ts.adfuller(residual)
    adf = adf_test[0]
    p_value = adf_test[1]
    crit_value = adf_test[4]
    return beta, alpha, adf, p_value, crit_value, stderr, residual

def betaidx_rollingMatrix(beta_idx,x,start,end):
    try:
        if beta_idx == 1:
            if end != -1:
                x = x[:,start:end]
            else:
                x = x[:,start:]
        elif beta_idx == 2:
            if end != -1:
                t_mean = np.mean(prices[:,start:end],axis=1)
                t_mean = np.expand_dims(t_mean,axis=1)
                x = x[:,start:end]-np.tile(t_mean,(len(t_mean[0]),start-end))
            else:
                t_mean = np.mean(prices[:,start:],axis=1)
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


#def main():
    #path = 'C:\\Users\\YChen\\Documents\\git\\working_dir\\python\\Cointegration_inout_v0.csv'
    path = 'C:\\Users\\YanCh\\Documents\\working_dir\\python\\data\\Cointegration_inout_v0.csv'
    #call date and price1 and price2. prices will turn to log value
    raw = openFile(path)
    #remove any number is smaller than 0
    raw = raw[:,raw.min(axis=0)>=0]
    #take out the part of prices
    prices = raw[1:,:]

    #parameters
    m = 60
    n = 5
    pADF_TH = 0.2
    beta_idx = 1
    numOfCol = len(prices[0])
    zscr = np.zeros((numOfCol,1))
    v_residual = np.zeros((numOfCol,1))
    v_ADF = np.zeros((numOfCol,1))
    v_pADF = np.zeros((numOfCol,1))
    v_h = np.zeros((numOfCol,1))
    v_Beta = np.zeros((numOfCol,1))

    ##calulate Z_residual
    if m < numOfCol:
        j = m
        while j <= numOfCol:
            ny1 = betaidx_rollingMatrix(beta_idx,prices,j-m,j)
            b, a, adf, pv, cv, stderr, resid = modeling(ny1[1,:],ny1[0,:]) #second row is x, first row is y
            if j <= numOfCol-n:
                for i in range(j,j+n):
                    if v_h[i] < pADF_TH:
                        v_h[i] = 0.0
                v_Beta[j-1:j+n-1] = np.ones((n,1))*b
                v_ADF[j-1:j+n-1] = np.ones((n,1))*adf
                v_pADF[j-1:j+n-1] = np.ones((n,1))*pv
                if pv < pADF_TH: 
                    v_h[j-1:j+n-1] = np.zeros((n,1))
                else:
                    v_h[j-1:j+n-1] = np.ones((n,1))
            else:
                v_h[j-1:] = np.ones((numOfCol-j+1,1))*a
                for i in range(j,numOfCol):
                    if v_h[i] < pADF_TH:
                        v_h[i] = 0.0
                v_Beta[j-1:] = np.ones((numOfCol-j+1,1))*b
                v_ADF[j-1:] = np.ones((numOfCol-j+1,1))*adf
                v_pADF[j-1:] = np.ones((numOfCol-j+1,1))*pv
                if pv < pADF_TH: 
                    v_h[j-1:] = np.zeros((numOfCol-j+1,1))
                else:
                    v_h[j-1:] = np.ones((numOfCol-j+1,1))
            # beta index
            if j <= numOfCol-n:
                ny2 = betaidx_rollingMatrix(beta_idx,prices,j-1,j+n-1)
                t_nb = np.array([1,-b]).reshape(2,1)
                if j == m:
                    for i in range(0,j):
                        v_residual[i] = resid[i]
                v_residual[j-1:j+n-1] = np.dot(ny2.T,t_nb)-a
                #ahhh = v_residual[j-1:j+n-1]-np.mean(v_residual[j-m:j-1])
                zscr[j-1:j+n-1] = np.dot((v_residual[j-1:j+n-1]-np.mean(v_residual[j-m:j-1])),(1./stderr))
            else:
                ny2 = betaidx_rollingMatrix(beta_idx,prices,j-1,-1)
                t_nb = np.array([1,-b]).reshape(2,1)
                if j == m:
                    for i in range(0,j):
                        v_residual[i] = resid[i]
                v_residual[j-1:] = np.dot(ny2.T,t_nb)-a
                zscr[j-1:] = np.dot((v_residual[j-1:] - np.mean(v_residual[j-1:])),(1./stderr))
            j += n
    else:
        b, a, adf, pv, cv, stderr = modeling(prices[1,:],prices[0,:]) #second row is x, first row is y
        for i in range(v_h.size):
            if v_h[i] < pADF_TH:
                v_h[i] = 0.0
        v_Beta[:] = np.ones((numOfCol,1))*b
        v_ADF[:] = np.ones((numOfCol,1))*adf
        v_pADF[:] = np.ones((numOfCol,1))*pv
        if pv < pADF_TH: 
            v_h[:] = np.zeros((numOfCol,1))
        else:
            v_h[:] = np.ones((numOfCol,1))
        t_nb = np.array([1,-b]).reshape(2,1)
        v_residual[:] = np.dot(prices.T,t_nb)-a
        zscr[:] = np.dot((v_residual[:] - np.mean(v_residual[:])),(1./stderr))

    #save the result
    raw_output = np.concatenate((raw[0,None].T,prices[0:].T,v_residual,zscr,v_ADF,v_pADF,v_h,v_Beta),axis=1)
    #raw = np.vstack((raw[0,:].T,prices[0:,:].T),axis=1)
    saveFile(path,raw_output)
    #saveFile('C:\\Users\\YChen\\Documents\\git\\working_dir\\python\\Cointegration_output_v0.csv',raw_output)
            
#run model            
#main()

                
            

