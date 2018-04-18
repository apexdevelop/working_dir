
clear all;
cd('C:\Users\ychen\Documents\MATLAB');
javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.8.8.2\lib\blpapi3.jar');
% [~,txt1]=xlsread('tpx_snapshot.xlsm','factors','a3:a100');
% [~,txt2]=xlsread('tpx_snapshot.xlsm','factors','c1:zz1');
filename='factors_multi_coint.xlsx';
[~,txt1]=xlsread('factors.xlsx','shipping','a3:a100'); %factor
[~,txt2]=xlsread('factors.xlsx','shipping','c1:zz1'); %equity

mat_pval=[];
mat_rsquare=[];

for q=1:size(txt2,2)
new_txt1=[txt2(q);txt1];

%% generate Data

startdate='2012/06/14';
enddate=today();
per={'daily','non_trading_weekdays','previous_value'};
field1='Last_Price';
% curr='USD';
curr=[];
[~, dates, prices]=blp_data(new_txt1,field1,startdate,enddate,per,curr);
n_dim=size(prices,2)-1;

field1='CHG_PCT_1D';
[~, ~, rtns_1d]=blp_data(new_txt1,field2,startdate,enddate,per,curr);

tday1=dates(:, 2); 
px1=prices(:, 2);
tday1(isnan(px1))=[];
px1(isnan(px1))=[];
px1(find(~tday1))=[];
tday1(find(~tday1))=[];

for i=2:n_dim
    tday2=dates(:, i+1); 
    px2=prices(:, i+1);
    tday2(isnan(px2))=[];
    px2(isnan(px2))=[];
    px2(find(~tday2))=[];
    tday2(find(~tday2))=[];
    
    [n1n2, idx1, idx2]=intersect(tday1, tday2);
    tday1=tday1(idx1);
    px1=[px1(idx1,:) px2(idx2)];
end

Px_Y=px1;
Px_Y(Px_Y<0)=0.01;

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
% date=tday1(2:end);

%% VAR process
%p is number of lag
p=2;

M=220;
N=20;
Ypred=zeros(size(rtn_Y,1),1);
Ypred(1:M-1,1)=Px_Y(1:M-1,1);
j=M;

mat_inmodel=[];


while j<=size(rtn_Y,1)
      X=rtn_Y(j-M+1:j,2:end);
      Y=rtn_Y(j-M+1:j,1);
      [b,se,pval,inmodel,stats,nextstep,history]=stepwisefit(X,Y,'penter',0.26,'premove',0.41,'display','off');
      
      temp_rsquare=[];
      for j1=1:M
          new_rsquare=[];
          r_temp=[rtn_Y(j-M+j1,2:end)'.*(inmodel'.*b);stats.intercept];
          if rtn_Y(j-M+j1,1)~=0
             new_rsquare=r_temp./rtn_Y(j-M+j1,1);
          end
          temp_rsquare=[temp_rsquare new_rsquare];
      end
      v_rsquare=mean(temp_rsquare,2);
      
      mat_inmodel=[mat_inmodel;inmodel];
      
      if j<=size(rtn_Y,1)-N         
         temp=rtn_Y(j+1:j+N,2:end)*(inmodel'.*b)+stats.intercept;         
         
%          r_temp=[rtn_Y(j+j1,2:end)'.*(inmodel'.*b) ;stats.intercept];
%          v_rsquare=r_temp./rtn_Y(j+j1,1);
         
         reverse_diff=cumsum([log(Px_Y(j+1,1));temp]);
         reverse_log=exp(reverse_diff);
         Ypred(j:j+N,1)=reverse_log;
      else
         T_pred=size(rtn_Y,1)-j;
         temp=rtn_Y(j+1:end,2:end)*(inmodel'.*b)+stats.intercept;
         
%          r_temp=[rtn_Y(end,2:end)'.*(inmodel'.*b) ;stats.intercept];
%          v_rsquare=r_temp./rtn_Y(end,1);
         
         reverse_diff=cumsum([log(Px_Y(end-T_pred,1));temp]);
         reverse_log=exp(reverse_diff);
         Ypred(j:end,1)=reverse_log; 
      end
      j=j+N;
end

% col_inmodel=reshape(inmodel,size(inmodel,2),1);
% xlswrite('tpx_snapshot.xlsm',pval,'factors','d3');
% xlswrite('factors.xlsx',pval,'Sheet2','c3');


% spread=Px_Y(M+1:end,1)-Ypred(M:end,1);
% Zspread=zscore(spread);
% 
% plot(1:size(Ypred,1),Ypred(:,1),'--r')
% hold on
% plot(1:size(Ypred,1),Px_Y(2:end,1),'k')

% 
% 
% error=Y(end-9:end,:)-FY;
% SSerror=error(:)'*error(:);
% 
% Ysim=vgxsim(EstSpec,10,[],Yest,[],2000);

% [isStable,isInvertible]=vgxqual(EstSpec);
% vgxplot(EstSpec,Yest,FY,FYCov);

mat_pval=[mat_pval pval];
mat_rsquare=[mat_rsquare v_rsquare];
end