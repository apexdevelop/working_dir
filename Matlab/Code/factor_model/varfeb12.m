clear all;
cd('C:\Users\ychen\Documents\MATLAB');
javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar')

%% generate Data
txt1={'015760 KS Equity';'USDEUR Curncy'};
startdate='2012/11/14';
per={'daily','non_trading_weekdays','previous_value'};
[~, dates, prices]=blp_test(txt1,startdate,per);
n_dim=size(prices,2)-1;

tday1=dates(:, 2); 
px1=prices(:, 2);
tday1(find(~tday1))=[];
px1(find(~px1))=[];

for i=2:n_dim
    tday2=dates(:, i+1); 
    px2=prices(:, i+1);
    tday2(find(~tday2))=[];
    px2(find(~px2))=[];
    [n1n2, idx1, idx2]=intersect(tday1, tday2);
    tday1=tday1(idx1);
    Px_Y=[prices(idx1,2:i) prices(idx2,i+1:end)];
end

rtn_Y=zeros(size(Px_Y,1),n_dim);
for i=1:n_dim
    h = pptest(Px_Y(:,i));
    if h==0 
        rtn_Y(2:end,i)=diff(log(Px_Y(:,i)));
    else
        rtn_Y(:,i)=Px_Y(:,i);
    end
end
rtn_Y=rtn_Y(2:end,:);
date=tday1(2:end);
%% VAR process
%p is number of lag
p=4;
Spec = vgxset('n',n_dim,'nAR',p);

impSpec = vgxvarx(Spec,rtn_Y(p+1:end,:),[],rtn_Y(1:p,:));
impSpec = vgxset(impSpec,'Series',...
  {char(txt1(1)),char(txt1(2))});
FT = 20;

W0 = zeros(FT, 2); % Innovations without a shock
W1 = W0;
W1(1,2) = sqrt(impSpec.Q(2,2)); % Innovations with a shock
Yimpulse = vgxproc(impSpec,W1,[],rtn_Y); % Process with shock
Ynoimp = vgxproc(impSpec,W0,[],rtn_Y); % Process with no shock
Yimp1 = exp(cumsum(Yimpulse(:,1))); % Undo scaling
Ynoimp1 = exp(cumsum(Ynoimp(:,1)));
RelDiff = (Yimp1 - Ynoimp1) ./ Yimp1;

plot(1:FT,100*RelDiff);
title(...
'Impact of Factor on Equity')
ylabel('% Change')
% dateaxis('x',12)
