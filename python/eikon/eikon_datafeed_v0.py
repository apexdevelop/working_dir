# -*- coding: utf-8 -*-
"""
Created on Fri Jan 19 13:14:40 2018

@author: YChen
"""
us_ticker='MSFT.O'
jp_ticker1='9984.T'
jp_ticker2='9432.T'
jp_ticker3='9433.T'
jp_ticker4='9437.T'

import eikon as ek
ek.set_app_id('FE608B4F468A9915E559B')

test=ek.get_news_headlines('R:LHAG.DE', date_from='2017-04-05T09:00:00', date_to='2017-04-05T18:00:00')
news_single_stk=ek.get_news_headlines('R:9984.T', date_from='2017-01-11T09:00:00', date_to='2018-01-19T13:00:00')

"""
Now, let's display the latest news story satidfying the news search expression "EU AND POL", which represents news on the European Union politics.

First, retrieve the news headlines containing the string 'world cup', then get the story ID from the response and finally request the story.
"""

headlines = ek.get_news_headlines('EU AND POL',1)

from datetime import date

start_date, end_date = date(2016, 1, 1), date.today()
q = "Product:IFREM AND Topic:ISU AND Topic:EUB AND (\"PRICED\" OR \"DEAL\")"
headlines = ek.get_news_headlines(query=q, date_from=start_date, date_to=end_date, count=100)

storyId = headlines.iat[0,2]
from IPython.core.display import HTML
html = ek.get_news_story(storyId)
html_story=HTML(html)
html_story=ek.get_news_story(storyId)

"""
The following commands return time series of daily price history for Microsoft Corp ordinary share between 1st of Jan and 10th of Jan 2016.
"""
df1 = ek.get_timeseries(["MSFT.O"], 
                       start_date="2016-01-01",  
                       end_date="2016-01-10")

df2 = ek.get_timeseries([jp_ticker1], 
                       start_date="2018-01-01",  
                       end_date="2018-01-19")

df3 = ek.get_timeseries([jp_ticker1,jp_ticker2], 'CLOSE',start_date="2018-01-01", end_date="2018-01-19")

df4 = ek.get_timeseries([us_ticker], 
                        'CLOSE',
                       start_date="2018-01-01",  
                       end_date="2018-01-19")

#if don't specify calendardays,there will be an error for multiple tickers
#ValueError: Length mismatch: Expected axis has 6 elements, new values have 5 elements
df5 = ek.get_timeseries(['CAT.N','6301.T'], 
                        'CLOSE',
                        start_date="2018-01-01", 
                        end_date="2018-01-19",
                        calendar='calendardays')


"""
The following commands retrieve fundamental data - Revenue and Gross Profit - for Google, Microsoft abd Facebook
"""
df_funda, err = ek.get_data([jp_ticker1,jp_ticker2, jp_ticker3,jp_ticker4], 
                      [ 'TR.Revenue','TR.GrossProfit'])


df, err = ek.get_data("IBM", 
					[ 
                    {'TR.RevenueActValue':{'params':{'Period': 'FY0','Scale': 6, 'Curn': 'USD'}}},
                    {'TR.RevenueMeanEstimate':{'params':{'Period': 'FY1','Scale': 6, 'Curn': 'USD'}}},
                    {'TR.RevenueMeanEstimate':{'params':{'Period': 'FY2','Scale': 6, 'Curn': 'USD'}}}
                    ])
