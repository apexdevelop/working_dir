#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jan 18 13:56:22 2018

@author: yanyan
"""

    

arr=[5,4,3,2,1]
start = int(len(arr)/2)
size = len(arr)-1
i = start
count = 0
while i>=0:
    j = i
    l=2*j+1
    while l<=size:
       minIndex=j
    #compare with left
       
       if arr[minIndex]>arr[l]:
          minIndex = l
    #compare with right    
       r=2*j+2
       if r<=size and arr[minIndex]>arr[r]:
          minIndex = r
       if j==minIndex:
          break
       else:
          min_child = arr[minIndex]
          arr[minIndex]=arr[j]
          arr[j]=min_child
          j=minIndex
          l=2*j+1
          """
          if minIndex<=start:
             j = minIndex
             l=2*j+1
             if l<=size and arr[minIndex]>arr[l]:
                minIndex = l   
             r=2*j+2
             if r<=size and arr[minIndex]>arr[r]:
                minIndex = r
             if j!=minIndex:
                min_child = arr[minIndex]
                arr[minIndex]=arr[j]
                arr[j]=min_child
          """
       i = i -1 
