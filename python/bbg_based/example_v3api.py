#the following website's example is more easily understood
#http://nbviewer.jupyter.org/github/bpsmith/tia/blob/master/examples/v3api.ipynb
import pandas as pd
#add additional module path
import sys
sys.path.append('C:\Python27\lib\site-packages')
from tia.bbg import LocalTerminal

if __name__ == '__main__':
    #FutureWarning: pandas.core.datetools.BDay is deprecated. Please use pandas.tseries.offsets.BDay instead.
    #d = pd.datetools.BDay(-4).apply(pd.datetime.now())
    d_new = pd.tseries.offsets.BDay(-3).apply(pd.datetime.now())
    d_end = pd.tseries.offsets.BDay(-1).apply(pd.datetime.now())
    #FutureWarning: pandas.core.datetools.BMonthBegin is deprecated. Please use pandas.tseries.offsets.BMonthBegin instead.
    #m = pd.datetools.BMonthBegin(-2).apply(pd.datetime.now())
    m_new = pd.tseries.offsets.BMonthBegin(-2).apply(pd.datetime.now())
    
    def banner(msg):
        print '*' * 25
        print msg
        print '*' * 25

    banner('ReferenceDataRequest: single security, single field, frame response')
    response = LocalTerminal.get_reference_data('msft us equity', 'px_last')
    print response.as_map()
    print response.as_frame()

    banner('ReferenceDataRequest: single security, multi-field (with bulk), frame response')
    response = LocalTerminal.get_reference_data('eurusd curncy', ['px_last', 'fwd_curve'])
    print response.as_map()
    rframe = response.as_frame()
    print rframe.columns
    # show frame within a frame
    #print rframe.ix[0, 'fwd_curve'].tail()
    #DeprecationWarning: .ix is deprecated. Please use.loc for label based indexing or.iloc for positional indexing
    print rframe.iloc[0, 1].tail()

    #ability to ignore errors
    banner('ReferenceDataRequest: multi security, multi-field, bad field')
    response = LocalTerminal.get_reference_data(['eurusd curncy', 'msft us equity'], ['px_last', 'fwd_curve'],
                                                ignore_field_error=1)
    print response.as_frame()['fwd_curve']['eurusd curncy']

    banner('HistoricalDataRequest: multi security, multi-field, daily data')
    response = LocalTerminal.get_historical(['eurusd curncy', 'msft us equity'], ['px_last', 'px_open'], start=d)
    print response.as_map()
    print response.as_frame().head(5)
    
    banner('HistoricalDataRequest: multi security, single-field, daily data')
    response = LocalTerminal.get_historical(['cat equity', '6301 jp equity'], 'px_last', start=d_new, end=d_end)
    print response.as_map()
    print response.as_frame().head(5)

    banner('HistoricalDataRequest: multi security, multi-field, weekly data')
    response = LocalTerminal.get_historical(['eurusd curncy', 'msft us equity'], ['px_last', 'px_open'], start=m,
                                                 period='WEEKLY')
    print '--------- AS SINGLE TABLE ----------'
    print response.as_frame().head(5)
    
    response = LocalTerminal.get_historical('1332 JT equity', 'px_last', start=d)
    print response.as_frame().head(5)
    
    #
    # HOW TO
    #
    # - Retrieve an fx vol surface:  BbgReferenceDataRequest('eurusd curncy', 'DFLT_VOL_SURF_MID')
    # - Retrieve a fx forward curve:  BbgReferenceDataRequest('eurusd curncy', 'FWD_CURVE')
    # - Retrieve dividends:  BbgReferenceDataRequest('csco us equity', 'BDVD_PR_EX_DTS_DVD_AMTS_W_ANN')
    
    """
    Intraday Tick Request
    """
    #added by yan Jan 12, 2018
    banner('Getintradaytick: single security, single field, frame response')
    sid = 'sftby us equity'
    events=['TRADE', 'AT_TRADE']
    dt = pd.tseries.offsets.BDay(-1).apply(pd.datetime.now())
    start = pd.datetime.combine(dt, datetime.time(13, 30))
    end = pd.datetime.combine(dt, datetime.time(21, 30))
    response = LocalTerminal.get_intraday_tick(sid,events,start)
    #print response.as_map()
    rframe=response.as_frame()
    rframehead=rframe.head()
    print rframehead
    
    df_tick=rframe.iloc[:,3]
    
    """
    Intraday Bar Request
    """
    sid = 'IBM US EQUITY'
    event = 'TRADE'
    f = LocalTerminal.get_intraday_bar(sid, event, start, end, interval=60).as_frame()
    print f.head()
    
    # More complex example
    # Retrive all members of the S&P 500, then get price and vol data
    resp_spx = LocalTerminal.get_reference_data('spx index', 'indx_members')
    members_spx = resp_spx.as_frame().iloc[0, 0]
    #members = resp.as_frame().ix[0, 'indx_members']
    resp_nky = LocalTerminal.get_reference_data('nky index', 'indx_members')
    members_nky = resp_nky.as_frame().iloc[0, 0]
    # append region + yellow key = 'US EQUITY'
    adj_members_nky = members_nky.apply(lambda x: x + ' EQUITY')
    #convert dataframe to list
    tickers_nky=list(adj_members_nky.values.flatten())
    resp = LocalTerminal.get_reference_data(tickers_nky, ['PX_LAST', 'VOLATILITY_30D'])
    resp.as_frame().head()
