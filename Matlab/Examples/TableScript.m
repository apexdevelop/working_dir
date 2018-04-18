%% Table Script

%% Import data from Excel as a table
Data = readtable('IndexData.xlsx');

%% 
% Notice that the data is stored in a tabular format, with the column headings.
% The dates are also stored in the same table (they are of type "datetime",
% which is a new data type for working with dates and times).

%% Extract specific columns
%
% You can extract data for specific columns using "dot" indexing. Reference
% columns by their names.

Canada = Data.Canada; % "Canada" is now a type double

%% Extract segments of data using row-column indexing
%
% The traditional row-column indexing that you use for doubles also works.
% Here we extract the first 10 rows of all the columns except the date column. 

SubTable = Data(1:10,2:end); % round brackets -> result is another table

%%
SubDouble = Data{1:10,2:end}; % curly brackets -> result is a double