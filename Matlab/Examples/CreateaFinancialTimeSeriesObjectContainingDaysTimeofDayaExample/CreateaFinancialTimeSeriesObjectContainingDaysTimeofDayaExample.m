%% Create a Financial Time Series Object Containing Days, Time of Day, and Data  

% Copyright 2015 The MathWorks, Inc.


%% 
% Define the data: 
data = [1:6]'  

%% 
% Define the dates: 
dates = [now:now+5]'  

%% 
% Create the financial times series object: 
tsobjkt = fints(dates, data)   
