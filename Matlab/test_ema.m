clearvars;
cd('Y:/working_directory/Matlab/Data/dispersion');
Data = readtable('cs-movavg.xls');
price=Data{1:30,3};
price_row=reshape(price,1,30);

price_mov=tsmovavg(price_row,'e',10);
price_mov_col=transpose(price_mov);
price_ema=[price(1:9); price_mov_col(10:end)];


price_mov2=tsmovavg2(price_row,'e',10);
price_mov_col2=transpose(price_mov2);
price_ema2=[price(1:9); price_mov_col2(10:end)];

vin=price_row;
varargin=10;
timePer=varargin;
% vinVars = # variables; observ = # obervations
[vinVars, observ] = size(vin);
vout = nan(vinVars, observ);
vout(:, timePer) = sum(vin(:, 1:timePer), 2)/timePer;
% Calculate the exponential percentage
k = 2 / (timePer + 1);

% K*vin; 1-k
kvin = vin(:, timePer:observ) * k;
oneK = 1-k;
% First period calculation
vout(:, timePer) = kvin(:, 1) + (vout(:, timePer) * oneK);

% Remaining periods calculation
for idx = timePer+1:observ
    vout(:, idx) = kvin(:, idx-timePer+1) + (vout(:, idx-1) * oneK);
end
