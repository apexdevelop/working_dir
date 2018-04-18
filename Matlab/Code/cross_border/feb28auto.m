% Yan 2014 Sep 02 revisit
% Yan 2013 Feb 28 pod, make it beatiful
% quote function crosspod and importdata
clear all;
cd('C:\Users\ychen\Documents\MATLAB\cross_border');
window=365; %window is all the calendar days
lookback=10;%number of days used to conduct the moving average
txt1={'HSI Index';'914 HK Equity'};
txt2={'SHASHR Index';'600585 CH Equity'};
txt3={'CNY Curncy','HKD Curncy'};
fields={'last_price','volume_avg_30d'};
[A Am B Bm C Cm]=crosspod(window,lookback,txt1,txt2,txt3,fields);