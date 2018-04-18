% Time indexing method on single factor
%% generate Data
clearvars;
input_ranges={'c1:c1000','d1:d1000','e1:e1000','f1:f1000','g1:g1000','h1:h1000','i1:i1000','j1:j1000'};
index_names={'OEX', 'NKY', 'HSI', 'HSCEI', 'SHCSI100', 'KOSPI2', 'TAMSCI', 'E100'};
%1-OEX, 2-NKY, 3-HSI, 4-HSCEI, 5-SHCSI100, 6-KOSPI2, 7-TAMSCI, 8-E100
input_idx=1;
input_range=char(input_ranges(input_idx));
index_name=char(index_names(input_idx));
% calculate_dispersion_v5_add_volume(input_range,index_name);

%% Loading Data from database
cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/dispersion');
Srtn=load(strcat('rtn_Y_',index_name));
rtn_Y=Srtn.rtn_Y;
rtn_tgt=rtn_Y(:,1);

Sz_px=load(strcat('z_px_',index_name));
z_px=Sz_px.z_px;

Sz_turnover_mov=load(strcat('z_turnover_mov_',index_name));
z_turnover_mov=Sz_turnover_mov.z_turnover_mov;

Sz_disp_mov=load(strcat('z_disp_mov_',index_name));
z_disp_mov=Sz_disp_mov.z_disp_mov;

Sdisp_col=load(strcat('disp_col_',index_name));
disp_col=Sdisp_col.disp_col;

Stday=load(strcat('tday1_',index_name));
tday1=Stday.tday1;

%% Other Factor input
javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar')
txt1={'.USSLOP Index';'VIX Index';'CVIX Index'};
startdate='2007/6/1';
per={'daily','non_trading_weekdays','previous_value'};
enddate=today();
c=blp;
    for loop=1:size(txt1,1)
        new=char(txt1(loop));
        [d1, sec1] = history(c, new,'CHG_PCT_1D',startdate,enddate,per);
        [d2, sec2] = history(c, new,'Last_Price',startdate,enddate,per);
        dates(1:size(d1,1),loop)=d1(1:size(d1,1),1);
        rtns(1:size(d1,1),loop)=d1(1:size(d1,1),2);
        prices(1:size(d2,1),loop)=d2(1:size(d2,1),2);
        
    end;
close(c);

c_dates1=cellstr(datestr(dates(:,1)));%.USSLOP Index
c_dates2=cellstr(datestr(dates(:,2)));%VIX Index
c_dates3=cellstr(datestr(dates(:,3)));%CVIX Index
c_dates4=cellstr(datestr(tday1)); %dispersion

t1=fints(c_dates1,prices(:,1),'t1');
t2=fints(c_dates2,prices(:,2),'t2');
t3=fints(c_dates3,prices(:,3),'t3');
t4=fints(c_dates4,disp_col,'t4');
t5=fints(c_dates4,rtn_tgt,'t5');

newfts=merge(t1,t2,t3,t4,t5,'DateSetMethod','Intersection');
new_t1=fts2mat(newfts.t1,1);
new_t2=fts2mat(newfts.t2);
new_t3=fts2mat(newfts.t3);
new_t4=fts2mat(newfts.t4);
new_t5=fts2mat(newfts.t5);
new_dates=new_t1(:,1);

v_factor1=new_t1(:,2);%.USSLOP Index
v_factor2=new_t2(:,1);%VIX Index
v_factor3=new_t3(:,1);%CVIX Index
new_disp=new_t4(:,1);%dispersion
new_rtn_tgt=new_t5(:,1);%OEX return

%% Time warping
char_date=datestr(new_dates);
ex_date=m2xdate(new_dates,0);

M=2500; %lookback_window
N=1; %rebalance_window
l_pattern=10;%length of pattern
l_np=10; %length of next period

prc=10;

% accuracy=corr_train_test_ret_multif(rtn_Y,disp_col,v_factor1,z_turnover_mov,tday1,M,N,l_pattern,l_np,prc,w1,w2,w3,w4,w5,w6);
fun = @(x) accuracy_medium_multif(rtn_Y,new_disp,v_factor1,z_turnover_mov,tday1,M,N,l_pattern,l_np,prc,x);
w1=0.1:0.2:0.5;
w2=0.1:0.2:0.5;
w3=0.1:0.2:0.5;
w4=0.1:0.2:0.5;
w5=0.1:0.2:0.5;
w6=0.1:0.2:0.5;
% w7=0.1:0.2:0.5;
% w8=0.1:0.2:0.5;
% w9=0.1:0.2:0.5;
% w10=0.1:0.2:0.5;
% w11=0.1:0.2:0.5;
% w12=0.1:0.2:0.5;
% range = {w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12};
range = {w1,w2,w3,w4,w5,w6};
opti_idx=1;
[max_idx,respmax1,param1,resp,V_var] = parameterSweep_v3(fun,range,opti_idx);
weights=param1'; %optimal weights
weights=[0.1;0.1;0.1;0.1;0.1;0.1];
weights=[0.1;0.1;0.1;1.1;0.1;0.1;0.1;0.1;0.1;0.1;0.1;0.1];
[cfitDates,cfitValuesX,cfitValuesY,rebalance_current_day,rebalance_test_next_ret,rebalance_train_ret,rebalance_train_extrem,rebalance_train_extrem_idx,rebalance_output,accuracy,TestpatternMetrics]=backtest_patterns_multif(rtn_Y,disp_col,v_factor1,z_turnover_mov,tday1,M,N,l_pattern,l_np,prc,weights);


%% Analyse Result
% tree = linkage(mat_fit,'average');
% figure()
% dendrogram(tree)
% c = cluster(tree,'maxclust',2);

%scatter chart of next period return distribution
chart_ret=rebalance_train_ret(:,1);
chart_extrem=rebalance_train_extrem(:,1);
chart_extrem_idx=rebalance_train_extrem_idx(:,1);

% [b,bint,r,rint,stats] = regress(y,X) returns a 1-by-4 vector stats that contains, in order, the R2 statistic, the F statistic and its p value, and an estimate of the error variance.
[b,bint,r,rint,stats] = regress(chart_extrem,[ones(size(chart_ret,1),1) chart_ret]);
beta=b(2);
rsqures=stats(1);

mat_fit=[chart_ret chart_extrem];
pd=pdist(mat_fit);
sum_pd=sum(pd);


% % cumulative return and extreme level
% scatter(chart_ret,chart_extrem)
% % xlim([-8 6]);
% xlabel('np return');
% ylabel('np max level');
% title(strcat('next', [' ', num2str(l_np)],' day return distribution', ' for', [' ', index_name]));
% % y_mu=mean(fit_np_max);
% y_mu=0;
% hline = refline([0 y_mu]);
% hline.Color = 'r';
% % x_mu=mean(fit_np_ret);
% x_mu=0;
% yl = ylim;
% line([x_mu x_mu], [yl(1) yl(2)],'Color','r');
% 
% % cumulative return and extreme day
% scatter(chart_ret,chart_extrem_idx)
% xlabel('np return');
% ylabel('np max day');
% title(strcat('next', [' ', num2str(l_np)],' day return distribution', ' for', [' ', index_name]));
% y_mu=0;
% hline = refline([0 y_mu]);
% hline.Color = 'r';
% x_mu=0;
% yl = ylim;
% line([x_mu x_mu], [yl(1) yl(2)],'Color','r');
% 
% fitting chart
% X=disp_col;
% lookback_fit_date=cell2mat(cfitDates(1));
% lookback_fit=cell2mat(cfitValues(1));
% plot(tday1,X,'color','k')%black
% hold on
% plot(tday1(end-l_pattern+1:end),X(end-l_pattern+1:end),'color','g','LineWidth',1.5)
% hold on
% plot(lookback_fit_date,lookback_fit,'color','r','LineWidth',1.5)
% datetick('x','mmmyy','keepticks')
% title(strcat('capture', [' ', num2str(l_pattern)],' day dispersion pattern', ' for', [' ', index_name]));
% hold off