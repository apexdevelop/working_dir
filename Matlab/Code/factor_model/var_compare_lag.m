clear all;
cd('C:\Users\ychen\Documents\MATLAB');
javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar')

%% generate Data
% txt1={'GJGB10 Index';'USGG10YR Index'};
% startdate='2012/11/14';
% per={'daily','non_trading_weekdays','previous_value'};
% [~, dates, prices]=blp_test(txt1,startdate,per);
% n_dim=size(prices,2)-1;
% 
% tday1=dates(:, 2); 
% px1=prices(:, 2);
% tday1(find(~tday1))=[];
% px1(find(~px1))=[];
% 
% for i=2:n_dim
%     tday2=dates(:, i+1); 
%     px2=prices(:, i+1);
%     tday2(find(~tday2))=[];
%     px2(find(~px2))=[];
%     [n1n2, idx1, idx2]=intersect(tday1, tday2);
%     tday1=tday1(idx1);
%     Px_Y=[prices(idx1,2:i) prices(idx2,i+1:end)];
% end
% 
% rtn_Y=zeros(size(Px_Y,1),n_dim);
% for i=1:n_dim
%     h = pptest(Px_Y(:,i));
%     if h==0 
%         rtn_Y(2:end,i)=diff(log(Px_Y(:,i)));
%     else
%         rtn_Y(:,i)=Px_Y(:,i);
%     end
% end
% rtn_Y=rtn_Y(2:end,:);
% date=tday1(2:end);

load Data_USEconModel
gdp = Dataset.GDP;
m1 = Dataset.M1SL;
tb3 = Dataset.TB3MS;

dGDP = 100*diff(log(gdp(49:end)));
dM1 = 100*diff(log(m1(49:end)));
dT3 = diff(tb3(49:end));
Y = [dGDP dM1 dT3];
n_dim=size(Y,2);

%% VAR process
T=ceil(.9*size(Y,1));
YF=Y((T+1):end,:);
TF=size(YF,1);
%p is number of lag
% dt=logical(eye(n_dim));
% VAR2diag=vgxset('ARsolve',repmat({dt},2,1),'asolve',true(n_dim,1),'Series',{'GDP','M1','3-mo T-bill'});
% VAR2full=vgxset(VAR2diag,'ARsolve',[]);
% VAR4diag=vgxset(VAR2diag,'nAR',4,'ARsolve',repmat({dt},4,1));
% VAR4full=vgxset(VAR2full,'nAR',4);

max_lag=15;
num_lag=max_lag-1;
mat_param=zeros(num_lag,1);
mat_LLF=zeros(num_lag,1);

for p=2:max_lag
    Ypre=Y(1:p,:);
    Yest=Y(p+1:T,:);
    Spec = vgxset('n',n_dim,'nAR',p);
    [EstSpec,EstStdErrors,LLF,W] = vgxvarx(Spec,Yest,[],Ypre);
    [NumParam,NumActive] = vgxcount(EstSpec);
    mat_param(p-1)=NumActive;
    mat_LLF(p-1)=LLF;
end

AIC=aicbic(mat_LLF,mat_param);
[min_AIC,best_lag]=min(AIC);
% [EstSpec1,EstStdErrors1,LLF1,W1]=vgxvarx(VAR2diag,Yest,[],Ypre,'CovarType','Diagonal');
% [EstSpec2,EstStdErrors2,LLF2,W2]=vgxvarx(VAR2full,Yest,[],Ypre);
% [EstSpec3,EstStdErrors3,LLF3,W3]=vgxvarx(VAR4diag,Yest,[],Ypre,'CovarType','Diagonal');
% [EstSpec4,EstStdErrors4,LLF4,W4]=vgxvarx(VAR4full,Yest,[],Ypre);

% [isStable1,isInvertible1]=vgxqual(EstSpec1);
% [isStable2,isInvertible2]=vgxqual(EstSpec2);
% [isStable3,isInvertible3]=vgxqual(EstSpec3);
% [isStable4,isInvertible4]=vgxqual(EstSpec4);

% [n1,n1p]=vgxcount(EstSpec1);
% [n2,n2p]=vgxcount(EstSpec2);
% [n3,n3p]=vgxcount(EstSpec3);
% [n4,n4p]=vgxcount(EstSpec4);

% reject1 = lratiotest(LLF2,LLF1,n2p - n1p) %if 1, reject restricted(diagonal model)
% reject2 = lratiotest(LLF4,LLF3,n4p - n3p)
% reject3 = lratiotest(LLF4,LLF2,n4p - n2p)
% AIC = aicbic([LLF1 LLF2 LLF3 LLF4],[n1p n2p n3p n4p])

% [FY1,FYCov1] = vgxpred(EstSpec1,TF,[],Yest);
% [FY2,FYCov2] = vgxpred(EstSpec2,TF,[],Yest);
% [FY3,FYCov3] = vgxpred(EstSpec3,TF,[],Yest);
% [FY4,FYCov4] = vgxpred(EstSpec4,TF,[],Yest);
% 
% figure
% vgxplot(EstSpec2,Yest,FY2,FYCov2)
% 
% error1 = YF - FY1;
% error2 = YF - FY2;
% error3 = YF - FY3;
% error4 = YF - FY4;
% 
% SSerror1 = error1(:)' * error1(:);
% SSerror2 = error2(:)' * error2(:);
% SSerror3 = error3(:)' * error3(:);
% SSerror4 = error4(:)' * error4(:);
% figure
% bar([SSerror1 SSerror2 SSerror3 SSerror4],.5)
% ylabel('Sum of squared errors')
% set(gca,'XTickLabel',...
%     {'AR2 diag' 'AR2 full' 'AR4 diag' 'AR4 full'})
% title('Sum of Squared Forecast Errors')

%% Forecasting
% [ypred,ycov] = vgxpred(EstSpec2,10,[],YF);
% yfirst = [gdp,m1,tb3];
% yfirst = yfirst(49:end,:);           % Remove NaNs
% dates = dates(49:end);
% endpt = yfirst(end,:);
% endpt(1:2) = log(endpt(1:2));
% ypred(:,1:2) = ypred(:,1:2)/100;     % Rescale percentage
% ypred = [endpt; ypred];              % Prepare for cumsum
% ypred(:,1:3) = cumsum(ypred(:,1:3));
% ypred(:,1:2) = exp(ypred(:,1:2));
% lastime = dates(end);
% timess = lastime:91:lastime+910;     % Insert forecast horizon
% 
% figure
% subplot(3,1,1)
% plot(timess,ypred(:,1),':r')
% hold on
% plot(dates,yfirst(:,1),'k')
% datetick('x')
% grid on
% title('GDP')
% subplot(3,1,2);
% plot(timess,ypred(:,2),':r')
% hold on
% plot(dates,yfirst(:,2),'k')
% datetick('x')
% grid on
% title('M1')
% subplot(3,1,3);
% plot(timess,ypred(:,3),':r')
% hold on
% plot(dates,yfirst(:,3),'k')
% datetick('x')
% grid on
% title('3-mo T-bill')
% hold off
% 
% % Forecasting with vgxsim
% rng(1); % For reproducibility
% ysim = vgxsim(EstSpec2,10,[],YF,[],2000);
% 
% yfirst = [gdp,m1,tb3];
% endpt = yfirst(end,:);
% endpt(1:2) = log(endpt(1:2));
% ysim(:,1:2,:) = ysim(:,1:2,:)/100;
% ysim = [repmat(endpt,[1,1,2000]);ysim];
% ysim(:,1:3,:) = cumsum(ysim(:,1:3,:));
% ysim(:,1:2,:) = exp(ysim(:,1:2,:));
% 
% ymean = mean(ysim,3);
% ystd = std(ysim,0,3);
% 
% figure
% subplot(3,1,1)
% plot(timess,ymean(:,1),'k')
% datetick('x')
% grid on
% hold on
% plot(timess,ymean(:,1)+ystd(:,1),'--r')
% plot(timess,ymean(:,1)-ystd(:,1),'--r')
% title('GDP')
% subplot(3,1,2);
% plot(timess,ymean(:,2),'k')
% hold on
% datetick('x')
% grid on
% plot(timess,ymean(:,2)+ystd(:,2),'--r')
% plot(timess,ymean(:,2)-ystd(:,2),'--r')
% title('M1')
% subplot(3,1,3);
% plot(timess,ymean(:,3),'k')
% hold on
% datetick('x')
% grid on
% plot(timess,ymean(:,3)+ystd(:,3),'--r')
% plot(timess,ymean(:,3)-ystd(:,3),'--r')
% title('3-mo T-bill')
% hold off
