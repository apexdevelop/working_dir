clearvars;
javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');
cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/factor');
v_names={'oil','shipping','utility','hitachi','steel','coal','display','sony','solar','jp_bond','kr_bond','softbank','aluminum','auto','spx','machinery','insurance'};
d_ranges={'b6:b39','b6:b39','b6:b29','b6:b32','b6:b37','b6:b34','b6:b39','b6:b40','b6:b37','b6:b52','b6:b43','b6:b10','b6:b28','b6:b22','b6:b37','b6:b28','b6:b23'};
w_ranges={'b40:b46','b40:b47','b30:b30','b33:b33','b38:b41','b35:b35','b40:b41','b41:b42','b38:b43','b44:b44','b53:b53','b11:b11','b29:b43','b23:b38','b39:b39','b29:b29','b24:b29'};
v_nab=[0,2,0,0,2,0,0,0,0,0,0,0,0,0];
sh_idx=1;
filename='factors_pca.xlsx';
shname=char(v_names(sh_idx));
[~,txt1]=xlsread(filename,shname,char(d_ranges(sh_idx))); %factor
[~,txt2]=xlsread(filename,shname,'d1:d1'); %equity
[~,txt3]=xlsread(filename,shname,'d2:d2'); %market
[direction,~]=xlsread(filename,shname,'d3:d3'); 
[v_TH,~]=xlsread(filename,shname,'d4:d4');
[v_inmodel,~]=xlsread(filename,shname,'a6:a100');
v_inmodel=logical(v_inmodel);
v_inmodel=transpose(v_inmodel);
v_keep=v_inmodel;
n_ab=v_nab(sh_idx);

window=66; % for calculating z for factor move
lag=0;
M=220;
N=20;

startdate='2012/01/04';
enddate=today();
per_n={'daily','non_trading_weekdays','nil_value'};
per_p={'daily','non_trading_weekdays','previous_value'};
field1='Last_Price';
field2='CHG_PCT_1D';
curr=[];
[~, dates_b, rtns_b]=blp_data(transpose(txt3),field2,startdate,enddate,per_p,curr);
[~, dates_fdpx, prices_f]=blp_data(txt1,field1,startdate,enddate,per_p,curr);
[~, dates_1d_f, rtns_1d_f]=blp_data(txt1,field2,startdate,enddate,per_p,curr);
[~, dates_d5d_f, rtns_d5d_f]=blp_data(txt1,'CHG_PCT_5D',startdate,enddate,per_p,curr);

if n_ab>0
   rtns_1d_f(1,(end-n_ab+1):end)=0;
   rtns_1d_f(2:end-1,(end-n_ab+1):end)=(prices_f(2:end-1,(end-n_ab+1):end)./prices_f(1:end-2,(end-n_ab+1):end)-1)*100;
   rtns_d5d_f(1:5,(end-n_ab+1):end)=0;
   rtns_d5d_f(6:end,(end-n_ab+1):end)=(prices_f(6:end,(end-n_ab+1):end)./prices_f(1:end-5,(end-n_ab+1):end)-1)*100;
end
n_dim=size(txt1,1);

%generate equity data
[~, ~, prices_e]=blp_data(transpose(txt2),field1,startdate,enddate,per_p,curr);
[~, dates_e, rtns_1d_e]=blp_data(transpose(txt2),field2,startdate,enddate,per_p,curr);

best_Metrics_p=[];
mean_Metrics_p=[];
best_Metrics_n=[];
mean_Metrics_n=[];
current_Metrics=[];
hp_TH=44;

for q=1:size(txt2,2)
    tday1=dates_e(:, q+1); 
    px1=prices_e(:, q+1);
    rtn1_1d=rtns_1d_e(:,q+1);
    tday1(isnan(rtn1_1d))=[];
    px1(isnan(rtn1_1d))=[];
    rtn1_1d(isnan(rtn1_1d))=[];   
    px1(find(~tday1))=[];
    rtn1_1d(find(~tday1))=[];
    tday1(find(~tday1))=[];
    
    min_px1=min(px1);
    if min_px1<=1 && min_px1>0  
       px1=exp(px1);
    end
    
    for p=1:n_dim
        tday2=dates_fdpx(:, p+1); 
        px2=prices_f(:, p+1);
        rtn2_1d=rtns_1d_f(:,p+1);
        tday2(isnan(rtn2_1d))=[];
        px2(isnan(rtn2_1d))=[];
        rtn2_1d(isnan(rtn2_1d))=[];       
        px2(find(~tday2))=[];
        rtn2_1d(find(~tday2))=[];
        tday2(find(~tday2))=[];
        
        min_px2=min(px2);
        if min_px2<=1 && min_px2>0  
           px2=exp(px2);
        end
        
        [n1n2, idx1, idx2]=intersect(tday1, tday2);
        tday1=tday1(idx1);
        px1=[px1(idx1,:) px2(idx2)];
        rtn1_1d=[rtn1_1d(idx1,:) rtn2_1d(idx2)];
    end
    
    date_b=dates_b(:, q+1); 
    rtn_b=rtns_b(:,q+1);
    date_b(isnan(rtn_b))=[];
    rtn_b(isnan(rtn_b))=[];    
    rtn_b(find(~date_b))=[];
    date_b(find(~date_b))=[];
    [nenb, idxe, idxb]=intersect(tday1, date_b);
    
    tday1=tday1(idxe);
    px1=px1(idxe,:);
    rtn1_1d=rtn1_1d(idxe,:);
    rtn_b=rtn_b(idxb);
    rtn_eb=[rtn1_1d((lag+1):end,1) rtn_b((lag+1):end)];
    
    excel_date=m2xdate(tday1((lag+1):end),0);
    
    Px_Y=[px1((lag+1):end,1) px1(1:(end-lag),2:end)];
    Px_Y(Px_Y<=1)=1.01;
    Px=Px_Y(:,2:end);
    rtn_Y=[rtn1_1d((lag+1):end,1) rtn1_1d(1:(end-lag),2:end)]/100;
    
    if M>size(rtn1_1d,1)
       M=round(size(rtn1_1d,1)/3);
       N=round(M/10);
    end
    
    z_Px=zeros(size(Px_Y,1),size(Px,2));
    z_Py=zeros(size(Px_Y,1),1);
    %% calculate zscore
    z_Px(1:M-1,:)=zscore(Px(1:M-1,:));
    z_Py(1:M-1,:)=zscore(Px_Y(1:M-1,1));
    for j=M:size(Px_Y,1)
       temp_zpx=zscore(Px(j-M+1:j,:));
       z_Px(j,:)=temp_zpx(end,:);
       temp_zpy=zscore(Px_Y(j-M+1:j,1));
       z_Py(j,:)=temp_zpy(end,:);
    end

    v_fnames=char(txt1);
    C = corr(z_Px,z_Px);
    w = 1./var(z_Px);
    [wcoeff,score,latent,tsquared,explained] = pca(z_Px,...
    'VariableWeights',w);
    %score is the map of X in the principal component space. 
    %Rows of score correspond to observations, 
    %and columns correspond to components.
    
    coefforth = diag(sqrt(w))*wcoeff;
    %each column respond to principle component sorted by explained
    %each row is like a regression beta between each original factor and all the
    %priciple compnents.
% biplot(coefforth(:,1:2),'scores',score(:,1:2),'varlabels',v_fnames);
% biplot(coefforth(:,1:2),'varlabels',v_fnames);
biplot(coefforth(:,1:2));
%% calculating spread
    XY=[z_Py score(:,1:2)];
    mat_coint_b=[];
   [~,lt_coint_p,~,~,~] = egcitest(XY,'test','t2');

    v_residual=zeros(size(Px_Y,1)-M+1,1);
    zscr=zeros(size(Px_Y,1)-M+1,1);
    j=M;
    while j<=size(rtn_Y,1)
          XY1=XY(j-M+1:j,:);         
          if j<=size(rtn_Y,1)-N
             [h,coint_p,~,~,reg] = egcitest(XY1,'test','t2');
             coint_b=[1;-reg.coeff(2:end)];
             mat_coint_b=[mat_coint_b coint_b];
             XY2=XY(j:j+N-1,:);
             v_residual(j-M+1:j-M+N)=XY2*coint_b-reg.coeff(1);
             temp_avg_res=mean(v_residual(j-M+1:j-M+N));
             zscr(j-M+1:j-M+N)=(v_residual(j-M+1:j-M+N)-temp_avg_res)/reg.RMSE;
          else
             XY2=XY(j:end,:);
             v_residual(j-M+1:end)=XY2*coint_b-reg.coeff(1);
             zscr(j-M+1:end)=(v_residual(j-M+1:end)-temp_avg_res)/reg.RMSE;
          end
          j=j+N;
    end
    
    Metrics_p=[];
    for Signal_p=-2.5:0.1:-0.5
        [metric_p,s_p,ret_v_p,r_trade_p]=z_backtest_oneside(1,rtn_eb(M:end,:),zscr,Signal_p,hp_TH,tday1(M:end));
        if  metric_p(8)>=1 %n_trades
            Metrics_p=[Metrics_p;metric_p];
        end
    end
    
    mean_metric_p=mean(Metrics_p,1);
    mean_Metrics_p=[mean_Metrics_p;mean_metric_p];
    
    if size(Metrics_p,1)~=0
        [C_p,I_p]=max(Metrics_p(:,5)./Metrics_p(:,6));
        best_metric_p=Metrics_p(I_p,:);
        best_Metrics_p=[best_Metrics_p;best_metric_p];
    end
    
    Metrics_n=[];
    for Signal_n=0.5:0.1:2
        [metric_n,sn,ret_v_n,r_trade_n]=z_backtest_oneside(-1,rtn_eb(M:end,:),zscr,Signal_n,hp_TH,tday1(M:end));
        if  metric_n(8)>=1 %n_trades annually
            Metrics_n=[Metrics_n;metric_n];
        end
    end
    
    mean_metric_n=mean(Metrics_n,1);
    mean_Metrics_n=[mean_Metrics_n;mean_metric_n];
    if size(Metrics_n,1)~=0
       [C_n,I_n]=max(Metrics_n(:,5)./Metrics_n(:,6));
       best_metric_n=Metrics_n(I_n,:);
       best_Metrics_n=[best_Metrics_n;best_metric_n];
    end
    
    [current_metric,s1,ret_v1,r_trade1]=z_backtest_oneside(direction(q),rtn_eb(M:end,:),zscr,v_TH(q),hp_TH,tday1(M:end));    
    current_metric=[current_metric(1) zscr(end-30) zscr(end-20) zscr(end-10) zscr(end-5) current_metric(2:end) sum(explained(1:2)) lt_coint_p];
    current_Metrics=[current_Metrics;current_metric];
end

%probably better use subplot
%plot original factor
plot(tday1,z_Px)
xlim([tday1(1) tday1(end)])
set(gca,'xtick',datenum(2012:2017,1,1))
datetick('x','mmmyy','keeplimits','keepticks')

%plot pca factor
plot(tday1,score(:,1:2))
xlim([tday1(1) tday1(end)])
set(gca,'xtick',datenum(2012:2017,1,1))
datetick('x','mmmyy','keeplimits','keepticks')