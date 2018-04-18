% Time indexing method on single factor
%% generate Data
clearvars;
new_data=1;
sh_idx=1;
startdate='2012/3/12';
enddate='2018/1/5';
% enddate=today();
% cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/factor/single_factor');
% filename='factors_v2.xlsx';
% % oil,shipping,utility,hitachi,steel,coal,display,solar,jp_bond,kr_bond,aluminum,machinery
v_shnames={'oil','shipping','utility','hitachi','steel','coal','display','solar','jp_bond','kr_bond','aluminum1','aluminum2','machinery','semi','sugar','aapl','shenzhou'};
% e_ranges={'d1:s1','d1:n1','d1:j1','d1:d1','d1:m1','d1:f1','d1:i1','d1:h1','d1:p1','d1:g1','d1:e1','d1:e1','d1:h1','d1:h1','d1:g1','d1:o1','d1:d1'};
% b_ranges={'d2:s2','d2:n2','d2:j2','d2:d2','d2:m2','d2:f2','d2:i2','d2:h2','d2:p2','d2:g2','d2:e2','d2:e2','d2:h2','d2:h2','d2:g2','d2:o2','d2:d2'};
% d_ranges={'d5:s51','d5:n39','d5:j31','d5:d18','d5:m38','d5:i28','d5:i32','d5:h30','d5:p29','d5:g23','d5:e27','d5:e27','d5:h24','d5:h15','d5:g19','d5:o5','d5:d9'};
sh_name=char(v_shnames(sh_idx));
% [~,txt2]=xlsread(filename,sh_name,'b5:b100'); %factor
% [~,txt1]=xlsread(filename,sh_name,char(e_ranges(sh_idx)));  %equity
% [~,txt3]=xlsread(filename,sh_name,char(b_ranges(sh_idx)));  %benchmark
% [effect,~]=xlsread(filename,sh_name,char(d_ranges(sh_idx)));  %effect

if new_data==1
   disp('pulling data time');
   tic
   opt_save_generate=1; % save
   [cXret,cYret,cell_ob,cDate]= sfactor_generateData_v3(sh_idx,opt_save_generate,startdate,enddate);
   toc
else

% Loading Data from database

cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/ML');
Sob=load(strcat('ob', num2str(sh_idx)));
cell_ob=Sob.cell_ob;

%factor's return
SXret=load(strcat('Xret', num2str(sh_idx)));
cXret=SXret.cXret;

%stock's return
SYret=load(strcat('Yret', num2str(sh_idx)));
cYret=SYret.cYret;

%date
SDate=load(strcat('Date', num2str(sh_idx)));
cDate=SDate.cDate;
end

%% Time warping
M=1200; %lookback_window
N=5; %rebalance_window
l_pattern=15;%length of pattern
l_np=15; %length of next period
prc=20;

w1=0.1:0.2:0.5;
w2=0.1:0.2:0.5;
w3=0.1:0.2:0.5;
w4=0.1:0.2:0.5;
w5=0.1:0.2:0.5;
w6=0.1:0.2:0.5;
range = {w1,w2,w3,w4,w5,w6};
opti_idx=1;

n_equity=size(cXret,1);
n_factor=size(cXret,2);
mat_exp_ret=zeros(n_factor,n_equity);
mat_exp_std=zeros(n_factor,n_equity);
mat_exp_wl=zeros(n_factor,n_equity);
mat_actual_ret=zeros(n_factor,n_equity);
mat_accuracy=zeros(n_factor,n_equity);

mat_opti_weights=[];
% i=6;
% j=42;
%for oil, 857 HK, 1605 JP factor 25: Brent/WTI ratio, factor 42: WPL AU
for i=1:n_equity
% for i=1:1
    for j=1:n_factor
%     for j=15:15   
        vXret=cXret{i,j}(:,2);
        vYret=cYret{i,j};
        vDate=cDate{i,j};

        char_date=datestr(vDate);
        ex_date=m2xdate(vDate,0);
        % accuracy=corr_train_test_ret_sf(vYret,vXret,vDate,M,N,l_pattern,l_np,prc,w1,w2,w3,w4,w5,w6);
        fun = @(x) accuracy_medium_sf(vYret,vXret,vDate,M,N,l_pattern,l_np,prc,x);
        
        [max_idx,respmax1,param1,resp,V_var] = parameterSweep_v3(fun,range,opti_idx);
        mat_accuracy(j,i)=respmax1;
        
        %param1 is the optimal weights
        opti_weights=param1';
        mat_opti_weights=[mat_opti_weights opti_weights];
        [cfitDates,cfitValues,rebalance_current_day,rebalance_test_next_ret,rebalance_train_ret,rebalance_train_extrem,rebalance_train_extrem_idx,rebalance_output,TestpatternMetrics]=backtest_patterns_sf(vYret,vXret,vDate,M,N,l_pattern,l_np,prc,opti_weights);
        mat_exp_ret(j,i)=rebalance_output(1,2);
        mat_exp_std(j,i)=rebalance_output(1,3);
        mat_exp_wl(j,i)=rebalance_output(1,6);
%         mat_actual_ret(j,i)=rebalance_test_next_ret;
% n_test_ret=size(rebalance_test_next_ret,1);
% rebalance_exp_ret=rebalance_output((end-n_test_ret+1):end,2);
% 
% isbuy_rebalance_exp_ret=rebalance_exp_ret>0;
% issell_rebalance_exp_ret=rebalance_exp_ret<0;
% 
% isbuy_rebalance_test_ret=rebalance_test_next_ret>0;
% issell_rebalance_test_ret=rebalance_test_next_ret<0;
% 
% accuracy_buy=mean(double(isbuy_rebalance_test_ret==isbuy_rebalance_exp_ret))*100;
% accuracy_sell=mean(double(issell_rebalance_test_ret==issell_rebalance_exp_ret))*100;
% 
% accuracy=accuracy_buy+accuracy_sell;
    end
end

%% Analyse Result
%Eculidean distance
pattern_dist = pdist(transpose(TestpatternMetrics),'seuclidean');
mat_p_dist=squareform(pattern_dist);
mat_linkage = linkage(pattern_dist);
%dendrogram(mat_linkage);
%Verify Dissimilarity, cophenetic correlation coefficient.
c = cophenet(mat_linkage,pattern_dist);
% T = cluster(mat_linkage,'cutoff',0.8);
T = cluster(mat_linkage,'maxclust',5);
%If there are more than 30 data points, then dendrogram collapses lower branches so that there are 30 leaf nodes. As a result, some leaves in the plot correspond to more than one data point.

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
% title(strcat('next', [' ', num2str(l_np)],' day return distribution', ' for', [' ', sh_name]));
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
% title(strcat('next', [' ', num2str(l_np)],' day return distribution', ' for', [' ', sh_name]));
% y_mu=0;
% hline = refline([0 y_mu]);
% hline.Color = 'r';
% x_mu=0;
% yl = ylim;
% line([x_mu x_mu], [yl(1) yl(2)],'Color','r');

% fitting chart
% X=vXret;
% lookback_fit_date=cell2mat(cfitDates(1));
% lookback_fit=cell2mat(cfitValues(1));
% plot(vDate,X,'color','k')%black
% hold on
% plot(vDate(end-l_pattern+1:end),X(end-l_pattern+1:end),'color','g','LineWidth',1.5)
% % plot(vDate(end-4*l_pattern+1:end-3*l_pattern),X(end-4*l_pattern+1:end-3*l_pattern),'color','g','LineWidth',1.5)
% hold on
% plot(lookback_fit_date,lookback_fit,'color','r','LineWidth',1.5)
% datetick('x','mmmyy','keepticks')
% title(strcat('capture', [' ', num2str(l_pattern)],' day dispersion pattern', ' for', [' ', sh_name]));
% hold off