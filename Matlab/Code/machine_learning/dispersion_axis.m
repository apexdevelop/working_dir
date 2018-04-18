% Time indexing method on single factor
%% generate Data
clearvars;
input_ranges={'c1:c1000','d1:d1000','e1:e1000','f1:f1000','g1:g1000','h1:h1000','i1:i1000','j1:j1000'};
index_names={'OEX', 'NKY', 'HSI', 'HSCEI', 'SHCSI100', 'KOSPI2', 'TAMSCI', 'E100'};
%1-OEX, 2-NKY, 3-HSI, 4-HSCEI, 5-SHCSI100, 6-KOSPI2, 7-TAMSCI, 8-E100
input_idx=1;
input_range=char(input_ranges(input_idx));
index_name=char(index_names(input_idx));
calculate_dispersion_v5_add_volume(input_range,index_name);

%% Loading Data from database
cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/dispersion');
Srtn=load(strcat('rtn_Y_',index_name));
rtn_Y=Srtn.rtn_Y;

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

newfts=merge(t1,t2,t3,t4,'DateSetMethod','Intersection');
new_t1=fts2mat(newfts.t1,1);
new_t2=fts2mat(newfts.t2);
new_t3=fts2mat(newfts.t3);
new_t4=fts2mat(newfts.t4);
new_dates=new_t1(:,1);

%% Time warping
char_date=datestr(tday1);
ex_date=m2xdate(tday1,0);

M=2500; %lookback_window
N=1; %rebalance_window
l_pattern=10;%length of pattern
l_np=10; %length of next period

weights=[0.2;0.2;0.2;0.2;0.1;0.1];

prc=10;
% prc=ones(1,6);
% prc(1)=20; %distance between dispersion
% prc(2)=100; %distance between velocity of dispersion
% prc(3)=100; %distance between relative rank of dispersion
% prc(4)=100; %position difference of max point
% prc(5)=100; %position difference of min point
% prc(6)=20; %degree difference between slope of starting point to end point

[cfitDates,cfitValues,rebalance_current_day,rebalance_test_next_ret,rebalance_train_ret,rebalance_train_extrem,rebalance_train_extrem_idx,rebalance_output,TestpatternMetrics]=backtest_patterns_v2(rtn_Y,disp_col,z_px,z_turnover_mov,z_disp_mov,tday1,M,N,l_pattern,l_np,prc,weights);
% accuracy=corr_train_test_ret(rtn_Y,disp_col,z_px,z_turnover_mov,z_disp_mov,tday1,M,N,l_pattern,l_np,prc,w1,w2,w3,w4,w5,w6);
fun = @(x) accuracy_medium(rtn_Y,disp_col,z_px,z_turnover_mov,z_disp_mov,tday1,M,N,l_pattern,l_np,prc,x);
w1=0.1:0.2:0.5;
w2=0.1:0.2:0.5;
w3=0.1:0.2:0.5;
w4=0.1:0.2:0.5;
w5=0.1:0.2:0.5;
w6=0.1:0.2:0.5;
range = {w1,w2,w3,w4,w5,w6};
opti_idx=1;
[max_idx,respmax1,param1,resp,V_var] = parameterSweep_v3(fun,range,opti_idx);
% x0=[0;0;0;0;0;0];
% A=[];
% b=[];
% Aeq=[1 1 1 1 1 1];
% beq=1;
% lb = [0.1; 0.1; 0.1; 0.1; 0.1; 0.1];
% ub = [0.5; 0.5; 0.5; 0.5; 0.5; 0.5];
% [x,fval] = fmincon(dfun1,x0,A,b,Aeq,beq,lb,ub);

% [X,fit_np_ret,fit_np_zret,fit_np_max,fit_np_volume,TH_idx,lookback_fit_date,lookback_fit,new_output,new_win_output,new_loss_output,new_big_output,new_small_output]=analyze_lastpattern(rtn_Y,disp_col,z_px,z_turnover_mov,z_disp_mov,tday1,M,N,l_pattern,l_np,prc,weights);



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