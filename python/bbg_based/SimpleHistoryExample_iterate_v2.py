# -*- coding: utf-8 -*-
"""
Created on Mon Apr 23 14:41:51 2018

@author: YChen
"""

import blpapi
from optparse import OptionParser

from os.path import expanduser
home = expanduser("~")                   
path = home + '/Documents/git/working_dir/python/data/iterate_test.xlsx'

import pandas as pd
import numpy as np
field_names = ('date','BEST_ANALYST_RATING')
out_df= pd.DataFrame(columns=field_names,index = range(1,101))


SECURITY_DATA = blpapi.Name("securityData")
SECURITY = blpapi.Name("security")
FIELD_DATA = blpapi.Name("fieldData")
FIELD_EXCEPTIONS = blpapi.Name("fieldExceptions")
FIELD_ID = blpapi.Name("fieldId")
ERROR_INFO = blpapi.Name("errorInfo")

def parseCmdLine():
    parser = OptionParser(description="Retrieve Historical data.")
    parser.add_option("-a",
                      "--ip",
                      dest="host",
                      help="server name or IP (default: %default)",
                      metavar="ipAddress",
                      default="localhost")
    parser.add_option("-p",
                      dest="port",
                      type="int",
                      help="server port (default: %default)",
                      metavar="tcpPort",
                      default=8194)

    (options, args) = parser.parse_args()

    return options
    
def processMessage(msg):
    securityData = msg.getElement(SECURITY_DATA)
    sec_name = securityData.getElementAsString(SECURITY)
    #print securityData.getElementAsString(SECURITY)
    print sec_name
    fieldData = securityData.getElement(FIELD_DATA)
    
    count_nob = 0
    
    for dataPoint in fieldData.values():
        for field in dataPoint.elements():
            if not field.isValid():
                print field.name(), "is NULL."
            elif field.isArray():
                # The following illustrates how to iterate over complex data returns.
                for i, row in enumerate(field.values()):
                    print "Row %d: %s" % (i, row)
            else:
                if field.name()==field_names[0]:
                   out_df.iloc[count_nob,0]=field.getValueAsString()
                if field.name()==field_names[1]:
                   out_df.iloc[count_nob,1]=field.getValueAsString()
            
        count_nob = count_nob + 1
        
    fieldExceptionArray = securityData.getElement(FIELD_EXCEPTIONS)
    for fieldException in fieldExceptionArray.values():
        errorInfo = fieldException.getElement(ERROR_INFO)
        print "%s: %s" % (errorInfo.getElementAsString("category"),
                          fieldException.getElementAsString(FIELD_ID))
    return out_df

def main():
    options = parseCmdLine()

    # Fill SessionOptions
    sessionOptions = blpapi.SessionOptions()
    sessionOptions.setServerHost(options.host)
    sessionOptions.setServerPort(options.port)

    print "Connecting to %s:%s" % (options.host, options.port)
    # Create a Session
    session = blpapi.Session(sessionOptions)

    # Start a Session
    if not session.start():
        print "Failed to start session."
        return

    try:
        # Open service to get historical data from
        if not session.openService("//blp/refdata"):
            print "Failed to open //blp/refdata"
            return

        # Obtain previously opened service
        refDataService = session.getService("//blp/refdata")

        # Create and fill the request for the historical data
        request = refDataService.createRequest("HistoricalDataRequest")
        request.getElement("securities").appendValue("9984 JP Equity")
        request.getElement("fields").appendValue(field_names[1])
        #request.getElement("fields").appendValue(field_names[2])
        request.set("periodicityAdjustment", "ACTUAL")
        request.set("periodicitySelection", "DAILY")
        request.set("startDate", "20150101")
        request.set("endDate", "20180331")
        request.set("maxDataPoints", 100)
        
        # add overrides
        overrideField="BEST_DATA_SOURCE_OVERRIDE"
        #overrideValues=['BST','GSR']
        overrideValues='HSB'
        overrides = request.getElement("overrides")
        override = overrides.appendElement()
        override.setElement('fieldId', overrideField)
        override.setElement('value', overrideValues)
        '''
        for overrideValue in overrideValues:
            override = overrides.appendElement()
            override.setElement('fieldId', overrideField)
            override.setElement('value', overrideValue)
        '''
        print "Sending Request:", request
        # Send the request
        session.sendRequest(request)

        # Process received events
        while(True):
            # We provide timeout to give the chance for Ctrl+C handling:
            ev = session.nextEvent(500)
            for msg in ev:
                # Process the response generically.
                #print msg
                if ev.eventType() == blpapi.Event.PARTIAL_RESPONSE or ev.eventType() == blpapi.Event.RESPONSE:
                    result = processMessage(msg)
                    
                    result.to_excel(path,index=False)
                    #print type(result)
                    #for x in result:
                    #  print x
                    
            if ev.eventType() == blpapi.Event.RESPONSE:
                # Response completely received, so we could exit
                break
    finally:
        # Stop the session
        session.stop()

       
if __name__ == "__main__":
    print "SimpleHistoryExample"
    try:
        main()
    except KeyboardInterrupt:
        print "Ctrl+C pressed. Stopping..."
