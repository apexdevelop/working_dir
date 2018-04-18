
clear all;
cd('C:\Users\ychen\Documents\MATLAB');
javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar');
% shipping,utility,steel,coal,display,solar,bond,aluminum,exports,hitachi,softbank
shname='exports';
[~,txt1]=xlsread('factors.xlsx',shname,'b5:b11'); %factor
[~,txt2]=xlsread('factors.xlsx',shname,'d1:zz1'); %equity
[~,txt3]=xlsread('factors.xlsx',shname,'d2:zz2'); %market
[direction,~]=xlsread('factors.xlsx',shname,'d3:zz3'); 
[v_TH,~]=xlsread('factors.xlsx',shname,'d4:zz4'); 


mat_pval=[];
mat_quasi_rsqr=[];
mat_whole_rsqr=[];

[~,txt_f]=xlsread('factors.xlsx',shname,'b12:b12'); %weekly factor
startdate='2012/01/04';
enddate=today();
per_n={'daily','non_trading_weekdays','nil_value'};
per_p={'daily','non_trading_weekdays','previous_value'};
field1='Last_Price';
field2='CHG_PCT_1D';

c=blp;
new=char(txt_f);
[d1, sec] = history(c, new,field2,startdate,enddate,per_n);
[d2, sec] = history(c, new,field1,startdate,enddate,per_p);
date_5d(1:size(d1,1),1)=d1(1:size(d1,1),1);
rtn_5d(1:size(d1,1),1)=d1(1:size(d1,1),2);
fpx(1:size(d2,1),1)=d2(1:size(d2,1),2);
close(c);
rtn_5d_forz=rtn_5d(~isnan(rtn_5d));

window=26;
N=1;
if window<size(rtn_5d_forz,1)
   M=window;
else
   M=size(rtn_5d_forz,1);
end
    
short_z5d=zeros(size(rtn_5d_forz,1),1);
short_z5d(1:M-1)=zscore(rtn_5d_forz(1:M-1));
for i=M : size(rtn_5d_forz,1)
    temp_z5d=zscore(rtn_5d_forz(i-M+1:i,1));
    short_z5d(i,1)=temp_z5d(end);
end    
long_z5d=zeros(size(rtn_5d,1),1);
long_z5d(~isnan(rtn_5d))=short_z5d;
rtn_5d(isnan(rtn_5d))=0;

%% generate Equity and other factor's Data
% curr='USD';
curr=[];
[~, dates_b, rtns_b]=blp_data(transpose(txt3),field2,startdate,enddate,per_p,curr);
Signal_TH=1.5;
hp_TH=44;

best_Metrics_p=[];
mean_Metrics_p=[];
best_Metrics_n=[];
mean_Metrics_n=[];
current_Metrics=[];


for q=1:size(txt2,2)
    new_txt1=[txt2(q);txt1];
    [~, dates, prices]=blp_data(new_txt1,field1,startdate,enddate,per_p,curr);
    n_dim=size(prices,2)-1;
    [~, ~, rtns_1d]=blp_data(new_txt1,field2,startdate,enddate,per_p,curr);

    tday1=dates(:, 2); 
    px1=prices(:, 2);
    rtn1_1d=rtns_1d(:,2);
    tday1(isnan(px1))=[];
    rtn1_1d(isnan(px1))=[];
    px1(isnan(px1))=[];
    px1(find(~tday1))=[];
    rtn1_1d(find(~tday1))=[];
    tday1(find(~tday1))=[];

    for i=2:n_dim
        tday2=dates(:, i+1); 
        px2=prices(:, i+1);
        rtn2_1d=rtns_1d(:,i+1);
        tday2(isnan(px2))=[];
        rtn2_1d(isnan(px2))=[];
        px2(isnan(px2))=[];
        px2(find(~tday2))=[];
        rtn2_1d(find(~tday2))=[];
        tday2(find(~tday2))=[];
    
        [n1n2, idx1, idx2]=intersect(tday1, tday2);
        tday1=tday1(idx1);
        px1=[px1(idx1,:) px2(idx2)];
        rtn1_1d=[rtn1_1d(idx1,:) rtn2_1d(idx2)];
    end
    
    [ndnw, idxd, idxw]=intersect(tday1, date_5d);
    tday1=tday1(idxd);
    px1=[px1(idxd,:) fpx(idxw)];
    rtn1_1d=[rtn1_1d(idxd,:) rtn_5d(idxw)];
    
    Px_Y=px1;
    Px_Y(Px_Y<0)=0.01;

    rtn_Y=rtn1_1d/100;

    M=220;
    N=20;
    Ypred=zeros(size(rtn_Y,1),1);
    Ypred(1:M-1,1)=Px_Y(1:M-1,1);
    j=M;

    mat_inmodel=[];
    v_whole_rsqr=[];

    while j<=size(rtn_Y,1)
          X=rtn_Y(j-M+1:j,2:end);
          Y=rtn_Y(j-M+1:j,1);
          [b,se,pval,inmodel,stats,nextstep,history]=stepwisefit(X,Y,'penter',0.10,'premove',0.31,'display','off');
      
          temp_quasi_rsqr=[];
          for j1=1:M
              new_quasi_rsqr=[];
              r_temp=[rtn_Y(j-M+j1,2:end)'.*(inmodel'.*b);stats.intercept];
              if rtn_Y(j-M+j1,1)~=0
                 new_quasi_rsqr=r_temp./rtn_Y(j-M+j1,1);
              end
              temp_quasi_rsqr=[temp_quasi_rsqr new_quasi_rsqr];
          end
          v_quasi_rsqr=mean(temp_quasi_rsqr,2);
          temp_whole_rsqr=(stats.SStotal-stats.SSresid)/stats.SStotal;
          v_whole_rsqr=[v_whole_rsqr temp_whole_rsqr];
          mat_inmodel=[mat_inmodel;inmodel];
      
          if j<=size(rtn_Y,1)-N         
             temp=rtn_Y(j+1:j+N,2:end)*(inmodel'.*b)+stats.intercept;         
         
             reverse_diff=cumsum([log(Px_Y(j+1,1));temp]);
             reverse_log=exp(reverse_diff);
             Ypred(j:j+N,1)=reverse_log;
          else
             T_pred=size(rtn_Y,1)-j;
             temp=rtn_Y(j+1:end,2:end)*(inmodel'.*b)+stats.intercept;
         
             reverse_diff=cumsum([log(Px_Y(end-T_pred,1));temp]);
             reverse_log=exp(reverse_diff);
             Ypred(j:end,1)=reverse_log; 
          end
          j=j+N;
    end

    spread=Px_Y(M:end,1)-Ypred(M:end,1);

    Zspread=zeros(size(Px_Y,1)-M+1,1);
    Zspread(1:window-1)=zscore(spread(1:window-1));
    for i=window : size(spread,1)
        temp_z=zscore(spread(i-window+1:i,1));
        Zspread(i,1)=temp_z(end);
    end

    mat_pval=[mat_pval pval];
    mat_quasi_rsqr=[mat_quasi_rsqr v_quasi_rsqr];
    mat_whole_rsqr=[mat_whole_rsqr;mean(v_whole_rsqr)];
    
    date_b=dates_b(:, q+1); 
    rtn_b=rtns_b(:,q+1);
    date_b(isnan(rtn_b))=[];
    rtn_b(isnan(rtn_b))=[];    
    rtn_b(find(~date_b))=[];
    date_b(find(~date_b))=[];
    [nenb, idxe, idxb]=intersect(tday1, date_b);
    
    tday1=tday1(idxe);
    rtn_eb=[rtn_Y(idxe,1) rtn_b(idxb)];
    
    Metrics_p=[];
    for Signal_p=1:0.1:2.5
        [metric_p,s_p,ret_v_p,r_trade_p]=z_backtest_oneside(1,rtn_eb(M:end,:),Zspread,Signal_p,hp_TH,tday1(M:end));
        Metrics_p=[Metrics_p;metric_p];
    end
    
    mean_metric_p=mean(Metrics_p,1);
    mean_Metrics_p=[mean_Metrics_p;mean_metric_p];
    [C_p,I_p]=max(Metrics_p(:,7));
    best_metric_p=Metrics_p(I_p,:);
    best_Metrics_p=[best_Metrics_p;best_metric_p];
    
    Metrics_n=[];
    for Signal_n=-2.5:0.1:-1
        [metric_n,sn,ret_v_n,r_trade_n]=z_backtest_oneside(-1,rtn_eb(M:end,:),Zspread,Signal_n,hp_TH,tday1(M:end));
        Metrics_n=[Metrics_n;metric_n];
    end
    
    mean_metric_n=mean(Metrics_n,1);
    mean_Metrics_n=[mean_Metrics_n;mean_metric_n];
    [C_n,I_n]=max(Metrics_n(:,7));
    best_metric_n=Metrics_n(I_n,:);
    best_Metrics_n=[best_Metrics_n;best_metric_n];

    [current_metric,s1,ret_v1,r_trade1]=z_backtest_oneside(direction(q),rtn_eb(M:end,:),Zspread,v_TH(q),hp_TH,tday1(M:end));
    current_metric=[current_metric mean(v_whole_rsqr)];
    current_Metrics=[current_Metrics;current_metric];
end



% plot(1:size(Ypred,1),Ypred(:,1),'--r')
% hold on
% plot(1:size(Ypred,1),Px_Y(:,1),'k')
