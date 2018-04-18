
clearvars;
cd('Y:/working_directory/Matlab');
javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');
v_names={'oil','shipping','utility','hitachi','steel','coal','display','sony','solar','jp_bond','kr_bond','softbank','aluminum','auto','spx','machinery','insurance'};
d_ranges={'b6:b39','b6:b39','b6:b29','b6:b32','b6:b37','b6:b34','b6:b39','b6:b40','b6:b36','b6:b46','b6:b43','b6:b10','b6:b28','b6:b22','b6:b37','b6:b28','b6:b23'};
w_ranges={'b40:b46','b40:b47','b30:b30','b33:b33','b38:b41','b35:b35','b40:b41','b41:b42','b37:b42','b50:b50','b44:b44','b11:b11','b29:b42','b23:b38','b39:b39','b29:b29','b24:b29'};

direction_ranges={'d15:g15','d15:n15','d15:h15','d15:d15','d15:i15','d15:f15','d15:g15','d15:d15','d15:i15','d15:p15','d15:g15','d15:d15','d15:e15','d15:g15'};
TH_ranges={'d3:g3','d3:n3','d3:h3','d3:d3','d3:i3','d3:f3','d3:g3','d3:d3','d3:i3','d3:p3','d3:g3','d3:d3','d3:e3','d3:g3'};
para_ranges={'d4:g14','d4:n14','d4:h14','d4:d14','d4:i14','d4:f14','d4:g14','d4:d14','d4:i14','d4:p14','d4:g14','d4:d14','d4:e14','d4:g14'};
exit_ranges={'d16:g16','d16:n16','d16:h16','d16:d16','d16:i16','d16:f16','d16:g16','d16:d16','d16:i16','d16:p16','d16:g16','d16:d16','d16:e16','d16:g16'};
enter_ranges={'d17:g17','d17:n17','d17:h17','d17:d17','d17:i17','d17:f17','d17:g17','d17:d17','d17:i17','d17:p17','d17:g17','d17:d17','d17:e17','d17:g17'};

v_nab=[0,2,0,0,2,0,0,0,0,0,0,0,0,0];
p_enter=[0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10];
p_exit=[0.31,0.31,0.31,0.31,0.31,0.31,0.31,0.31,0.31,0.31,0.31,0.31,0.31,0.31];
sh_idx=6;
filename1='factors_multi_coint.xlsx';
filename2='stepwise_para.xlsx';

shname=char(v_names(sh_idx));
[~,txt1]=xlsread(filename1,shname,char(d_ranges(sh_idx))); %factor
[~,txt2]=xlsread(filename1,shname,'d1:zz1'); %equity
[~,txt3]=xlsread(filename1,shname,'d2:zz2'); %market

[v_direction,~]=xlsread(filename2,shname,'d15:zz15'); 
[v_TH,~]=xlsread(filename2,shname,'d3:zz3');
[v_para,~]=xlsread(filename2,shname,'d4:zz14');
[excel_exit,~]=xlsread(filename2,shname,'d16:zz16');
[excel_enter,~]=xlsread(filename2,shname,'d17:zz17');
v_exit=x2mdate(excel_exit,0);
v_enter=x2mdate(excel_enter,0);

[v_inmodel,~]=xlsread(filename1,shname,'a6:a100');
v_inmodel=logical(v_inmodel);
v_inmodel=transpose(v_inmodel);
v_keep=v_inmodel;
% v_keep=ones(1,size(v_inmodel,2));
n_ab=v_nab(sh_idx); % number of abnormal returns which have to be calcualted from prices
% for steel factor CDSPDRAV and CDSPHRAV

mat_pval=[];
mat_quasi_rsqr=[];
mat_whole_rsqr=[];
window=66; % for calculating z for factor move
lag=0;
mat_inmodel=[];
mat_b=[];

M=220;
N=20;
startdate='2012/01/04';
enddate=today();
per_n={'daily','non_trading_weekdays','nil_value'};
per_p={'daily','non_trading_weekdays','previous_value'};
field1='Last_Price';
field2='CHG_PCT_1D';
%% generate weekly factor data
[~,txt_f]=xlsread(filename1,shname,char(w_ranges(sh_idx))); %weekly factor
if ~isempty(txt_f)
c=blp;
for loop=1:size(txt_f,1)
    new=char(txt_f(loop));
    [d1, sec] = history(c, new,field2,startdate,enddate,per_n);
    [d2, sec] = history(c, new,field1,startdate,enddate,per_n);
    dates_w5d(1:size(d1,1),loop)=d1(1:size(d1,1),1);
    rtns_w5d(1:size(d1,1),loop)=d1(1:size(d1,1),2);
    dates_fwpx(1:size(d1,1),loop)=d2(1:size(d1,1),1);
    fwpxs(1:size(d2,1),loop)=d2(1:size(d2,1),2);
end
close(c);
re_rtns_5d=zeros(size(rtns_w5d,1),size(txt_f,1));
re_fwpxs=zeros(size(fwpxs,1),size(txt_f,1));
crtns_w5d=zeros(1,size(txt_f,1));
z_rtns_w5d=zeros(1,size(txt_f,1));
z_fpxs=zeros(1,size(txt_f,1));

for loop=1:size(txt_f,1)
    % calculate zscore for weekly factor data
    rtn_w5d=rtns_w5d(:,loop);
    rtn_w5d_forz=rtn_w5d(~isnan(rtn_w5d));
    date_w5d_forz=dates_w5d(~isnan(rtn_w5d),loop);
    rtn_w5d_forz(find(~date_w5d_forz))=[];
    crtns_w5d(loop)=rtn_w5d_forz(end);
    
    fwpx=fwpxs(:,loop);
    fwpx_forz=fwpx(~isnan(fwpx));
    date_fwpx_forz=dates_fwpx(~isnan(fwpx),loop);
    fwpx_forz(find(~date_fwpx_forz))=[];

    if window<size(rtn_w5d_forz,1)
       z_window=window;
    else
       z_window=size(rtn_w5d_forz,1);
    end
    
    temp_zw5d=zscore(rtn_w5d_forz(end-z_window+1:end));
    z_rtns_w5d(loop)=temp_zw5d(end);

    temp_zfwpx=zscore(fwpx_forz(end-z_window+1:end));
    z_fpxs(loop)=temp_zfwpx(end);
    
    % resample weekly factor data
    v_idx_nemp=find(~isnan(rtns_w5d(:,loop)));
    d0=floor(mean(diff(v_idx_nemp)));
    v_d=[d0;diff(v_idx_nemp)];
    idx=1;
    for j=1:v_idx_nemp(end)
        if j<=v_idx_nemp(idx)
           re_rtns_5d(j,loop)=rtns_w5d(v_idx_nemp(idx),loop)/v_d(idx);
        else
           idx=idx+1;
           re_rtns_5d(j,loop)=rtns_w5d(v_idx_nemp(idx),loop)/v_d(idx);
        end
    end
    
    v_idx_nemp2=find(~isnan(fwpxs(:,loop)));
    d0_2=floor(mean(diff(v_idx_nemp2)));
    v_d2=[d0_2;diff(v_idx_nemp2)];
    idx2=1;
    for j=1:v_idx_nemp2(end)
        if j<=v_idx_nemp2(idx2+1)           
           re_fwpxs(j,loop)=fwpxs(v_idx_nemp2(idx2),loop);
        else
           idx2=idx2+1;
           re_fwpxs(j,loop)=fwpxs(v_idx_nemp2(idx2),loop);           
        end
    end
    
    for j=v_idx_nemp2(end):size(fwpxs,1)
        re_fwpxs(j,loop)=fwpxs(v_idx_nemp2(end),loop);
    end
    if re_fwpxs(end,loop)==0
       re_fwpxs(end,loop)=re_fwpxs(end-1,loop);
    end
end
end
%% generate Equity and other factor's Data
% curr='USD';
curr=[];
[~, dates_b, rtns_b]=blp_data(transpose(txt3),field2,startdate,enddate,per_p,curr);
hp_TH=44;

best_Metrics_p=[];
mean_Metrics_p=[];
best_Metrics_n=[];
mean_Metrics_n=[];
current_Metrics=[];

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
rtns_1d=zeros(1,n_dim+size(txt_f,1));
z_rtns_1d=zeros(1,n_dim+size(txt_f,1));
crtns_d5d=zeros(1,n_dim);
z_rtns_d5d=zeros(1,n_dim);
z_fdpxs=zeros(1,n_dim);
%% calculate zscore for daily factors
for p=1:n_dim
    rtnd_1d=rtns_1d_f(:,p+1);
    rtnd_1d_forz=rtnd_1d(~isnan(rtnd_1d));
    date_1d_forz=dates_1d_f(~isnan(rtnd_1d),p+1);
    rtnd_1d_forz(find(~date_1d_forz))=[];
    rtns_1d(p)=rtnd_1d_forz(end);
    
    rtnd_5d=rtns_d5d_f(:,p+1);
    rtnd_5d_forz=rtnd_5d(~isnan(rtnd_5d));
    date_d5d_forz=dates_d5d_f(~isnan(rtnd_5d),p+1);
    rtnd_5d_forz(find(~date_d5d_forz))=[];
    crtns_d5d(p)=rtnd_5d_forz(end);
    
    fdpx=prices_f(:,p+1);
    fdpx_forz=fdpx(~isnan(fdpx));
    date_fdpx_forz=dates_fdpx(~isnan(fdpx),p+1);
    fdpx_forz(find(~date_fdpx_forz))=[];

    if window<size(rtnd_1d_forz,1)
       z_window=window;
    else
       z_window=size(rtnd_1d_forz,1);
    end
    
    temp_zd1d=zscore(rtnd_1d_forz(end-z_window+1:end));
    z_rtns_1d(p)=temp_zd1d(end);
    
    temp_zd5d=zscore(rtnd_5d_forz(end-z_window+1:end));
    z_rtns_d5d(p)=temp_zd5d(end);
    
    temp_zdfpx=zscore(fdpx_forz(end-z_window+1:end));
    z_fdpxs(p)=temp_zdfpx(end);
end
col_1d=transpose(rtns_1d);
z_col_1d=transpose(z_rtns_1d);
if ~isempty(txt_f)
   z_col_fpxs=transpose([z_fdpxs z_fpxs]);
   col_last=transpose([crtns_d5d crtns_w5d]);
   z_col_last=transpose([z_rtns_d5d z_rtns_w5d]);
else
   z_col_fpxs=transpose(z_fdpxs);
   col_last=transpose(crtns_d5d);
   z_col_last=transpose(z_rtns_d5d);
end
mat_fchg=[col_1d z_col_1d col_last z_col_last z_col_fpxs];

%% back to main theme
[~, ~, prices_e]=blp_data(transpose(txt2),field1,startdate,enddate,per_p,curr);
[~, dates_e, rtns_1d_e]=blp_data(transpose(txt2),field2,startdate,enddate,per_p,curr);

for q=1:size(txt2,2)
% for q=4:4
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
    
    if ~isempty(txt_f)
       [ndnw, idxd, idxw]=intersect(tday1, dates_w5d(:,1));
       tday1=tday1(idxd);
       px1=[px1(idxd,:) re_fwpxs(idxw,:)];
       rtn1_1d=[rtn1_1d(idxd,:) re_rtns_5d(idxw,:)];
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
    
    v_residual=zeros(size(Px_Y,1)-M+1,1);
    zscr=zeros(size(Px_Y,1)-M+1,1);
    
    j=M;
    v_whole_rsqr=[];
    hist_inmodel=[];
    while j<=size(rtn_Y,1)
          X=rtn_Y(j-M+1:j,2:end);
          Y=rtn_Y(j-M+1:j,1);
          [b,se,pval,inmodel,stats,nextstep,history]=stepwisefit(X,Y,'penter',p_enter(sh_idx),'premove',p_exit(sh_idx),'display','off','inmodel',v_inmodel,'keep',v_keep);
          if sum(inmodel)==0
             step=0.1;
             while sum(inmodel)==0 && p_enter(sh_idx)+step<1 && p_exit(sh_idx)+step<1
                   [b,se,pval,inmodel,stats,nextstep,history]=stepwisefit(X,Y,'penter',p_enter(sh_idx)+step,'premove',p_exit(sh_idx)+step,'display','off','inmodel',v_inmodel,'keep',v_keep);   
                   step=step+0.1;
             end
          elseif sum(inmodel)>11
             in_idx=find(inmodel);
             in_pval=pval(in_idx);
             [sin_pval,IX]=sort(in_pval,'descend');
             cut=sum(inmodel)-11;
             inmodel(in_idx(IX(1:cut)))=0;
          else
          end
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
          hist_inmodel=[hist_inmodel;inmodel];
          j=j+N;
    end
    
    mat_inmodel=[mat_inmodel transpose(inmodel)];
    mat_b=[mat_b b];
    %% calculating spread
    mat_coint_b=[];
%     inmodel=v_inmodel;
    [~,lt_coint_p,~,~,~] = egcitest(log([Px_Y(:,1) Px(:,inmodel)]),'test','t2');
    j=M;
    while j<=size(rtn_Y,1)
          log_XY1=log([Px_Y(j-M+1:j,1) Px(j-M+1:j,inmodel)]);
          
          if j<=size(rtn_Y,1)-N
             [h,coint_p,~,~,reg] = egcitest(log_XY1,'test','t2');
             coint_b=[1;-reg.coeff(2:end)];
             mat_coint_b=[mat_coint_b coint_b];
             log_XY2=log([Px_Y(j:j+N-1,1) Px(j:j+N-1,inmodel)]);
             v_residual(j-M+1:j-M+N)=log_XY2*coint_b-reg.coeff(1);
             temp_avg_res=mean(v_residual(j-M+1:j-M+N));
             zscr(j-M+1:j-M+N)=(v_residual(j-M+1:j-M+N)-temp_avg_res)/reg.RMSE;
             
          else
             log_XY2=log([Px_Y(j:end,1) Px(j:end,inmodel)]);
             v_residual(j-M+1:end)=log_XY2*coint_b-reg.coeff(1);
%              zscr(j-M+1:end)=(v_residual(j-M+1:end)-mean(reg.res))/reg.RMSE;
             zscr(j-M+1:end)=(v_residual(j-M+1:end)-temp_avg_res)/reg.RMSE;
          end
          j=j+N;
    end
    
    mat_pval=[mat_pval pval];
    mat_quasi_rsqr=[mat_quasi_rsqr v_quasi_rsqr];
    mat_whole_rsqr=[mat_whole_rsqr;mean(v_whole_rsqr)];
    
    Metrics_p=[];
    for Signal_p=-3:0.1:-0.5
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
    for Signal_n=0.5:0.1:2.5
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
    
    [current_metric,s1,ret_v1,r_trade1]=z_backtest_oneside1(v_para(:,q),v_direction(q),rtn_eb(M:end,:),zscr,v_TH(q),hp_TH,tday1(M:end),v_exit(q),v_enter(q));    
    current_metric=[current_metric(1) zscr(end-30) zscr(end-20) zscr(end-10) zscr(end-5) current_metric(2:end) mean(v_whole_rsqr) lt_coint_p];
    current_Metrics=[current_Metrics;current_metric];
end

% inmodel beta
inmodel_b=mat_inmodel.*mat_b;

Z_TH=transpose(current_Metrics(:,1));
c_direction=transpose(current_Metrics(:,17));
c_para=transpose(current_Metrics(:,6:16));
c_exit=transpose(current_Metrics(:,18));
c_enter=transpose(current_Metrics(:,19));

xlswrite(filename2,Z_TH,shname,char(TH_ranges(sh_idx))); %current threshold
xlswrite(filename2,c_direction,shname,char(direction_ranges(sh_idx))); %current direction
xlswrite(filename2,c_para,shname,char(para_ranges(sh_idx))); %current parameters
xlswrite(filename2,c_exit,shname,char(exit_ranges(sh_idx))); %current exit date
xlswrite(filename2,c_enter,shname,char(enter_ranges(sh_idx))); %current enter date

%R0 = corrcoef(X);
%VIF = diag(inv(R0))';
%kappa0 = cond(X);
%[sValue,condIdx,VarDecomp] = collintest(X,'display','off');

% plot(1:size(Ypred,1),Ypred(:,1),'--r')
% hold on
% plot(1:size(Ypred,1),Px_Y(:,1),'k')

