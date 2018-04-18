
javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.6.1.0\lib\blpapi3.jar') % for using blp in function (blp_txt)
cd('C:\Users\ychen\Documents\MATLAB');
clear all;
% if matlabpool('size') ~= 0
%    matlabpool close;
% end
%% import data set from bloomberg and generate pairs

totcd=825; 
[names, date, price]=blp_txt('input1.txt',totcd);%equity
[fnames, fdate, fprice]=blp_txt('input2.txt',totcd);%market index
n_stock=size(price,2)-1;
% n_stock=2;

stk1={''};
stk2={''};

for sn=1:n_stock
    new_stk1=repmat(names(sn),1,n_stock-1);
    stk1=[stk1  new_stk1];
    for sm=1:n_stock
        if sm~=sn
           stk2=[stk2  names(sm)];
        end
    end
end

%% Initialize parameters and metrics
window = 240:60:300;
freq   = 20:20:60;
spread=1:0.1:3;
p_ADF=[0.05,0.25,0.45,0.90];
scaling=1;
cost=0;

Metrics=[]; %store outputs

% for sn=1:n_stock
    sn=1;
    tday1=date(:, sn+1); 
    adjcls1=price(:, sn+1);
    tday1(find(~tday1))=[];
    adjcls1(find(~adjcls1))=[];
    
    tday_f=fdate(:,sn+1);
    px_f=fprice(:,sn+1);%index price
    tday_f(find(~tday_f))=[];
    px_f(find(~px_f))=[];
    [fn1,idx1,idxf]=intersect(tday1,tday_f);
    
    tempY=zeros(size(fn1,1),2);
    tempY(:,1)=adjcls1(idx1);
    tempY(:,2)=px_f(idxf);
    temp_date=tday1(idx1);
    
%     for sm=1:n_stock
       sm=3;
        if sm~=sn
           tday2=date(:, sm+1); 
           adjcls2=price(:, sm+1);                 
           [fn1n2, idx_temp, idx2]=intersect(temp_date, tday2); 
           
           tday=tday2(idx2);
           baddata=find(~tday);
           tday(baddata)=[];
           
           Y=zeros(size(fn1n2,1),3);
           Y(:,1)=tempY(idx_temp,1);%stock1
           Y(:,3)=tempY(idx_temp,2);%index
           Y(:,2)=adjcls2(idx2);%stock2
           
           %convert to log prices
           Y=log(Y);%include index
           
           %%
           dates=tday;
           [~,~,~,~,reg] = egcitest(Y,'test','t2');
c0 = reg.coeff(1);
b = reg.coeff(2:3);
beta = [1; -b];
q = 2;
[numObs,numDims] = size(Y);
tBase = (q+2):numObs; % Commensurate time base, all lags
T = length(tBase); % Effective sample size
DeltaYLags = zeros(T,(q+1)*numDims);
YLags = lagmatrix(Y,0:(q+1)); % Y(t-k) on observed time base
LY = YLags(tBase,(numDims+1):2*numDims);
for k = 1:(q+1)
    DeltaYLags(:,((k-1)*numDims+1):k*numDims) = ...
               YLags(tBase,((k-1)*numDims+1):k*numDims) ...
             - YLags(tBase,(k*numDims+1):(k+1)*numDims);
end

DY = DeltaYLags(:,1:numDims); % (1-L)Y(t)
DLY = DeltaYLags(:,(numDims+1):end); % [(1-L)Y(t-1),...,(1-L)Y(t-q)]
X = [(LY*beta-c0),DLY,ones(T,1)];
P = (X\DY)'; % [alpha,B1,...,Bq,c1]
alpha = P(:,1);
B1 = P(:,2:4);
B2 = P(:,5:7);
c1 = P(:,end);
res = DY-X*P';
EstCov = cov(res);

numSteps = 30;

% Preallocate:
YSim = zeros(numSteps,numDims);
eps = zeros(numSteps,numDims);

% Specify q+1 presample values:
YSim(1,:) = Y(end-2,:);
YSim(2,:) = Y(end-1,:);
YSim(3,:) = Y(end,:);

% Simulate numSteps postsample values:
rng('default'); % For reproducibility
for t = 4:numSteps+3

    eps(t,:) = mvnrnd([0 0 0],EstCov,1); % Normal innovations

    YSim(t,:) = YSim(t-1,:) ...
                + YSim(t-1,:)*beta*alpha'...
                + (YSim(t-1,:)-YSim(t-2,:))*B1'...
                + (YSim(t-2,:)-YSim(t-3,:))*B2'...
                + (alpha*c0 + c1)'...
                + eps(t,:);

end

% Plot sample and forecast path:
plot(dates,Y,'LineWidth',2)
xlabel('Year')
ylabel('Percent')
title('{\bf Forecast Path}')
hold on
D = dates(end);
plot(D:(D+numSteps),YSim(3:end,:),'-.','LineWidth',2)
Ym = min([Y(:);YSim(:)]);
YM = max([Y(:);YSim(:)]);
fill([D D D+numSteps D+numSteps],[Ym YM YM Ym],'b','FaceAlpha',0.1)
axis tight
grid on
hold off

       
           
          
           
     
       end
        
%     end
% end
       
 stk1_col=reshape(stk1,n_stock*(n_stock-1)+1,1);
 stk2_col=reshape(stk2,n_stock*(n_stock-1)+1,1);
%  v_title={'B','abs(B)','RSQR','STAT','L','P','SL','SC','abs(SC)','Signal_TH','TR','AR','Num_T','HP','WinP'};
%  [~,universe_name]=xlsread('Copair','pairs','a1');
%  char_universe=char(universe_name);
%  xlswrite('copair_output',v_title,char_universe,'d1');
%  xlswrite('copair_output',stk1_col,char_universe,'b1');
%  xlswrite('copair_output',stk2_col,char_universe,'c1');
%  xlswrite('copair_output',[NUM_T TR AR HP WinP B abs(B) RSQR STAT L SL SC abs(SC) S_TH P],char_universe,'d2');

