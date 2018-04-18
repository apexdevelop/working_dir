# -*- coding: utf-8 -*-
"""
Created on Thu Feb 08 14:29:31 2018

@author: YChen
"""
import blpapi
import datetime
from optparse import OptionParser

TODAY = datetime.datetime.today()
APIREFDATA_SVC    = '//blp/refdata'
RESPONSE = 5
PARTIAL_RESPONSE = 6

def MakeRequest(security, fldList, overrideFields=None, overrideValues=None):
    '''
        Request test harness
    '''
    result = []
    
    
    parser = OptionParser(description="Retrieve reference data.")
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
    
    
    sessionOptions = blpapi.SessionOptions()
    sessionOptions.setServerHost(options.host)
    sessionOptions.setServerPort(options.port)

    print "Connecting to %s:%s" % (options.host, options.port)
    # Create a Session
    session = blpapi.Session(sessionOptions)
    
    session.QueueEvents = True
    session.Start()
    session.OpenService(APIREFDATA_SVC)
    service = session.GetService(APIREFDATA_SVC)

    req = service.CreateRequest("ReferenceDataRequest")

    #not sure if this will work
    sec = req.GetElement('securities')
    sec.AppendValue(security)

    flds = req.GetElement('fields')
    for fld in fldList:
        flds.AppendValue(fld)

    if overrideFields:
        overridables = zip(overrideFields, overrideValues)
        overrides = req.GetElement("overrides")
        for overrideField, overrideValue in overridables:
            override = overrides.AppendElment()
            override.SetElement('fieldId', overrideField)
            override.SetElement('value', overrideValue)

    session.SendRequest(req)

    while True:
        eventObj = session.NextEvent()
        if eventObj.EventType == PARTIAL_RESPONSE or eventObj.EventType == RESPONSE:
            it = eventObj.CreateMessageIterator()

            while it.Next():
                msg = it.Message
                numSecurities = msg.GetElement("securityData").NumValues
                for secIndex in xrange(0, numSecurities):
                    security = msg.GetElement("securityData").GetValue(secIndex)

                    fields = security.GetElement("fieldData")
                    numFields = fields.NumElements
                    for fldIndex in xrange(0, numFields):
                        field = fields.GetElement(fldIndex).Value
                        result.append(field)
            if eventObj.EventType == RESPONSE:
                break
    return result

def MakeHistoricalDataRequest(security, fldList, overrideFields=None, overrideValues=None, dateFrom=None, dateTo=None):
    '''
        Historical request test harness
    '''
    result = []
    
    parser = OptionParser(description="Retrieve reference data.")
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
    
    
    sessionOptions = blpapi.SessionOptions()
    sessionOptions.setServerHost(options.host)
    sessionOptions.setServerPort(options.port)

    print "Connecting to %s:%s" % (options.host, options.port)
    # Create a Session
    session = blpapi.Session(sessionOptions)
    
    session.QueueEvents = True
    session.start()
    session.openService(APIREFDATA_SVC)
    service = session.getService(APIREFDATA_SVC)

    req = service.createRequest("HistoricalDataRequest")

    sec = req.getElement('securities')
    sec.appendValue(security)

    flds = req.getElement('fields')
    for fld in fldList:
        flds.appendValue(fld)

    if dateFrom:
        req.set('startDate', dateFrom)
    else:
        req.set('startDate', TODAY.strftime('%Y%m%d'))

    if dateTo:
        req.set('endDate', dateTo)
    else:
        req.set('endDate', TODAY.strftime('%Y%m%d'))
    req.set('periodicitySelection', 'DAILY')

    if overrideFields:
        overridables = zip(overrideFields, overrideValues)
        overrides = req.getElement("overrides")
        for overrideField, overrideValue in overridables:
            override = overrides.appendElement()
            override.setElement('fieldId', overrideField)
            override.setElement('value', overrideValue)

    session.sendRequest(req)

    while True:
        eventObj = session.nextEvent()
        if eventObj.eventType == PARTIAL_RESPONSE or eventObj.eventType == RESPONSE:
            it = eventObj.createMessageIterator()

            while it.Next():
                msg      = it.Message
                security = msg.getElement("securityData")
                #secVal   = security.GetElement("security")
                field_exceptions = security.getElement("fieldExceptions")

                # process exceptions
                if field_exceptions.NumValues > 0:
                    element = field_exceptions.getValuesAsElement(0)
                    field_id = element.getElement("fieldId")
                    error_info = element.getElement("errorInfo")
                    error_message = error_info.getElement("message")
                    logger.warn('Exception with %s with message: %s' %(field_id, error_message))

                # process field data
                field_data = security.getElement("fieldData")
                numFields = field_data.NumValues
                for fldIndex in xrange(0, numFields):
                    element = field_data.getValueAsElement(fldIndex)

                    # repack everything by date
                    subResult = []
                    for field in fldList:
                        if element.HasElement(field):
                            subResult.append(element.GetElement(field).Value)
                    result.append(subResult)

            if eventObj.EventType == RESPONSE:
                break

    return result

def main():
    security='6502 JT Equity'
    fldList='BEST_ANALYST_RATING'
    overrideFields="BEST_DATA_SOURCE_OVERRIDE"
    overrideValues="UBS"
    dateFrom="20171201"
    dateTo="20180208"
    test_result= MakeHistoricalDataRequest(security, fldList, overrideFields=overrideFields, overrideValues= overrideValues, dateFrom=dateFrom, dateTo=dateTo)
