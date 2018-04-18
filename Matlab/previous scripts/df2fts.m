

function myfts=df2fts(Field,FromDate,ToDate)
% DF2FTS(EXPRESSION,FIELD,FROMDATE,TODATE) for historical
% DF2FTS(EXPRESSION,FROMDATE) for time series
% c1=bloomberg(8194,'172.16.1.92');
% data = fetch(c1, 'IBM US Equity', 'HISTORY','last_price', '12/16/08','12/23/08','d')

%Gets data from the Bloomberg, calcuates the expression
% puts it in a time series, saves the time series for use
% with FTSGUI and returns it for use with CHARTFTS
%
% USEAGE:
%    % not that you'd want to calculate this...
%
%    % historical
%       myfts=df2fts( ...
%          'exp(2 * GT5 Govt -GT10 Govt - GT2 Govt)', ...
%          'BidYield',today-40.*365.25,today);
%
%    % or time series
%
%       myfts=df2fts( ...
%          'log(2 * GT5 Govt -GT10 Govt - GT2 Govt)', ...
%          today);
%
%    Then you can use
%
%       chartfts(myfts);
%
%    %or 
%
%       ftsgui;
%       % now load myfts"
%
% IT'S NOT FANCY, BUT IT WORKS
%
% see BLOOMBERG/FETCH, FTSGUI, CHARTFTS

% Michael Robbins
% robbins@bloomberg.net
% michael.robbins@us.cibc.com

if nargin<3
    fprintf('df2fts does not yet support timeseries data');
    myfts=[];
    return;
end;

if nargin<3 % TIMESERIES
    FromDate=Field;
    Field='Ticks';
end;

% GET DATA
Connect = bloomberg(8194,'172.16.1.92');;
for loop=1:length(tickers)
    if nargin<3
        temp = fetch(Connect,tickers{loop},'TIMESERIES',FromDate);
        d=temp(:,2:3);
    else
        d = fetch(Connect,tickers{loop},'HISTORY',Field,FromDate,ToDate);
    end;
    tempfts{loop}=fints(d(:,1),d(:,2),Field,'D',tickers{loop});
end;
close(Connect);

% MAKE OBJECTS COMPATIBLE
idates=tempfts{1}.dates;
for loop=2:length(tickers)
    idates=intersect(idates,tempfts{loop}.dates);
end;
sidates=datestr(idates);

% PARSE ARITMETIC EXPRESSION
ParseStr=CIX;
for loop=1:length(tickers)
    ParseStr=strrep(ParseStr,tempfts{loop}.desc,sprintf('tempfts{%d}(sidates)',loop));
end;
myfts=eval([ParseStr ';']);
myfts.desc=CIX;

