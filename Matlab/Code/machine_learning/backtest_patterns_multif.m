% fit criteria
% 1 %distance between dispersion
% 2 %distance between velocity of dispersion
% 3 %distance between relative rank of dispersion
% 4 %position difference of max point
% 5 %position difference of min point
% 6 %degree difference between slope of starting point to end point
% how to combine different criteria
% how to set how many to choose

function[cfitDates,cfitValuesX,cfitValuesY,rebalance_current_day,rebalance_test_next_ret,rebalance_train_ret,rebalance_train_extrem,rebalance_train_extrem_idx,rebalance_output,accuracy,TestpatternMetrics]=backtest_patterns_multif(rtn_Y,disp_col,v_factor1,z_turnover_mov,tday1,M,N,l_pattern,l_np,prc,weights)
%% Calculate inputs
% weights=[w1;w2;w3;w4;w5;w6;w7;w8;w9;w10;w11;w12];

X=disp_col;
X_ve=[0;diff(X)./X(2:end)];%if X is zscore based,denominator could be positive, velocity could be wrong

Y=v_factor1;
Y_ve=[0;diff(Y)./Y(2:end)];
%% Initialize parameters
ex_date=m2xdate(tday1,0);
n_testp=1; %n of test pattern
nob=size(rtn_Y,1);
       
n_group=floor(M/l_pattern); %training data
adj_M=n_group*l_pattern;
lim_rebalance=ceil((nob-adj_M)/N);

rebalance_train_ret=[];
rebalance_train_volume=[];
rebalance_train_extrem=[];
rebalance_train_extrem_idx=[];

rebalance_test_next_ret=[];
rebalance_test_next_volume=[];

rebalance_current_day=[];
rebalance_output=[];

rebalance_test_X=[];
rebalance_test_X_ve=[];
rebalance_test_X_rank=[];

rebalance_test_Y=[];
rebalance_test_Y_ve=[];
rebalance_test_Y_rank=[];

rebalance_test_Xlevel=[]; %average level points in the pattern
rebalance_test_Xve_avg=[];
rebalance_imaxtest_X=[];
rebalance_imintest_X=[];
rebalance_Xstart_end_test=[];
rebalance_Xstart_max_test=[];

rebalance_test_Ylevel=[]; %average level points in the pattern
rebalance_test_Yve_avg=[];
rebalance_imaxtest_Y=[];
rebalance_imintest_Y=[];
rebalance_Ystart_end_test=[];
rebalance_Ystart_max_test=[];

count_rebalance=0;
t=nob-l_pattern; %start date of latest pattern

approx_n_balance=ceil((t-adj_M)/N);
cfitDates=cell(1,approx_n_balance);
cfitValuesX=cell(1,approx_n_balance);
cfitValuesY=cell(1,approx_n_balance);

while t>=adj_M
  count_rebalance=count_rebalance+1;
  rebalance_current_day=[rebalance_current_day;ex_date(t+l_pattern)]; %end day of the pattern
  pattern_dates=reshape(tday1(t-adj_M+1:t,1),l_pattern,n_group);
  pattern_X=reshape(X(t-adj_M+1:t,1),l_pattern,n_group); %reshape function reshape by column
  pattern_X_ve=reshape(X_ve(t-adj_M+1:t,1),l_pattern,n_group);
  
  pattern_Y=reshape(Y(t-adj_M+1:t,1),l_pattern,n_group); %reshape function reshape by column
  pattern_Y_ve=reshape(Y_ve(t-adj_M+1:t,1),l_pattern,n_group);
  
  v_train_next_ret=zeros(1,n_group); %cumulative ret of the whole l_pattern period 
  v_train_next_max=zeros(1,n_group);
  v_train_next_min=zeros(1,n_group);
  v_train_next_max_idx=zeros(1,n_group);
  v_train_next_min_idx=zeros(1,n_group);
  v_train_next_volume=zeros(1,n_group);
  
  v_start_date=zeros(1,n_group);
  count_group=0;
  for t1=t-adj_M:l_pattern:t-l_pattern
      count_group=count_group+1;
      v_start_date(count_group)=tday1(t1+1);
      v_train_next_ret(count_group)=sum(rtn_Y(t1+l_pattern+1:t1+l_pattern+l_np,1));
      %calculate cumulative ret for each day in next period
      v_train_next_cumret_perday=zeros(1,l_np);
      for t2=1:l_np
          v_train_next_cumret_perday(t2)=sum(rtn_Y(t1+l_pattern+1:t1+l_pattern+t2,1));
      end
      %max price is the max cumulative ret
      [next_max_px,next_max_px_idx]=max(v_train_next_cumret_perday);
      [next_min_px,next_min_px_idx]=min(v_train_next_cumret_perday);
      v_train_next_max(count_group)=next_max_px;
      v_train_next_min(count_group)=next_min_px;
      v_train_next_max_idx(count_group)=next_max_px_idx;
      v_train_next_min_idx(count_group)=next_min_px_idx;
      v_train_next_volume(count_group)=mean(z_turnover_mov(t1+l_pattern+1:t1+l_pattern+l_np,1));
  end
  z_train_next_ret=zscore(v_train_next_ret);
  
  test_X=X(t+1:t+n_testp*l_pattern);
  test_X_ve=X_ve(t+1:t+n_testp*l_pattern);
  test_Y=Y(t+1:t+n_testp*l_pattern);
  test_Y_ve=Y_ve(t+1:t+n_testp*l_pattern);
  
  rebalance_test_X=[rebalance_test_X test_X];
  rebalance_test_X_ve=[rebalance_test_X_ve test_X_ve];
  rebalance_test_Y=[rebalance_test_Y test_Y];
  rebalance_test_Y_ve=[rebalance_test_Y_ve test_Y_ve];
  
  avg_test_Xlevel=mean(test_X);
  rebalance_test_Xlevel=[rebalance_test_Xlevel avg_test_Xlevel];
  avg_test_Xve=mean(test_X_ve);
  rebalance_test_Xve_avg=[rebalance_test_Xve_avg avg_test_Xve];
  
  avg_test_Ylevel=mean(test_Y);
  rebalance_test_Ylevel=[rebalance_test_Ylevel avg_test_Ylevel];
  avg_test_Yve=mean(test_Y_ve);
  rebalance_test_Yve_avg=[rebalance_test_Yve_avg avg_test_Yve];
  
  if t<=nob-l_pattern-l_np
     temp_next_ret=rtn_Y(t+1+l_pattern:t+l_pattern+l_np,1);
     test_next_ret=sum(temp_next_ret);
     temp_next_volume=z_turnover_mov(t+1+l_pattern:t+l_pattern+l_np,1);
     test_next_volume=mean(temp_next_volume);
     rebalance_test_next_ret=[rebalance_test_next_ret;test_next_ret];
     rebalance_test_next_volume=[rebalance_test_next_volume;test_next_volume];
  end
  
  % calculate matching criterie
  
  %3-1 find relative rank of each point in pattern_X and pattern_Y
  pattern_X_rank=zeros(l_pattern,n_group);
  pattern_Y_rank=zeros(l_pattern,n_group);
  for i=1:n_group
      sorted_pattern_X = sort(pattern_X(:,i));
      sorted_pattern_Y = sort(pattern_Y(:,i));
      for r=1:l_pattern
          %Assignment has more non-singleton rhs dimensions than non-singleton subscripts
          temp_rank_Xidx=find(pattern_X(:,i)==sorted_pattern_X(r));
          if size(temp_rank_Xidx,1)>1
              pattern_X_rank(r,i)=temp_rank_Xidx(1);
          else
              pattern_X_rank(r,i)=temp_rank_Xidx;
          end
          
          temp_rank_Yidx=find(pattern_Y(:,i)==sorted_pattern_Y(r));
          if size(temp_rank_Yidx,1)>1
              pattern_Y_rank(r,i)=temp_rank_Yidx(1);
          else
              pattern_Y_rank(r,i)=temp_rank_Yidx;
          end
      end
  end    
  
  %3-2 find relative rank of each point in test_X and test_Y
  test_X_rank=zeros(l_pattern,1);
  [sorted_test_X,~] = sort(test_X);
  
  test_Y_rank=zeros(l_pattern,1);
  [sorted_test_Y,~] = sort(test_Y);
  for r=1:l_pattern
      test_rank_Xidx=find(test_X==sorted_test_X(r));
      if size(test_rank_Xidx,1)>1
         test_X_rank(r)=test_rank_Xidx(1);
      else
         test_X_rank(r)=test_rank_Xidx;
      end
      test_rank_Yidx=find(test_Y==sorted_test_Y(r));
      if size(test_rank_Yidx,1)>1
         test_Y_rank(r)=test_rank_Yidx(1);
      else
         test_Y_rank(r)=test_rank_Yidx;
      end
  end
  rebalance_test_X_rank=[rebalance_test_X_rank test_X_rank];
  rebalance_test_Y_rank=[rebalance_test_Y_rank test_Y_rank];
  
  %4&5-1.calculate max point and min point in train_X and train_Y
  v_imaxtrainX=zeros(1,n_group);
  v_imintrainX=zeros(1,n_group);
  v_imaxtrainY=zeros(1,n_group);
  v_imintrainY=zeros(1,n_group);
  for i=1:n_group
      [~,v_imaxtrainX(i)]=max(pattern_X(:,i));
      [~,v_imintrainX(i)]=min(pattern_X(:,i));
      [~,v_imaxtrainY(i)]=max(pattern_Y(:,i));
      [~,v_imintrainY(i)]=min(pattern_Y(:,i));
  end
  %4&5-2.find maxmum and min point in text_X and test_Y
  [~,imaxtest_X]=max(test_X);
  [~,imintest_X]=min(test_X);
  [~,imaxtest_Y]=max(test_Y);
  [~,imintest_Y]=min(test_Y);
  
  rebalance_imaxtest_X=[rebalance_imaxtest_X imaxtest_X];
  rebalance_imintest_X=[rebalance_imintest_X imintest_X];
  rebalance_imaxtest_Y=[rebalance_imaxtest_Y imaxtest_Y];
  rebalance_imintest_Y=[rebalance_imintest_Y imintest_Y];
  
  %6. calculate shape related degree
  degree_Xstart_max_test=test_X(1)-test_X(imaxtest_X);
  rebalance_Xstart_max_test=[rebalance_Xstart_max_test degree_Xstart_max_test];
  degree_Ystart_max_test=test_Y(1)-test_Y(imaxtest_Y);
  rebalance_Ystart_max_test=[rebalance_Ystart_max_test degree_Ystart_max_test];
  
  degree_Xstart_end_test=atand((test_X(1)-test_X(end))/l_pattern);
  rebalance_Xstart_end_test=[rebalance_Xstart_end_test degree_Xstart_end_test];
  degree_Ystart_end_test=atand((test_Y(1)-test_Y(end))/l_pattern);
  rebalance_Ystart_end_test=[rebalance_Ystart_end_test degree_Ystart_end_test];
  
  v_degree_Xstart_end_train=zeros(1,n_group);
  v_degree_Xstart_max_train=zeros(1,n_group);
  v_degree_Ystart_end_train=zeros(1,n_group);
  v_degree_Ystart_max_train=zeros(1,n_group);
  for i=1:n_group
      v_degree_Xstart_max_train(1,i)=atand(pattern_X(1,i)-pattern_X(v_imaxtrainX(i),i)/(v_imaxtrainX(i)-1));
      v_degree_Xstart_end_train(1,i)=atand((pattern_X(1,i)-pattern_X(end,i))/l_pattern);
      v_degree_Ystart_max_train(1,i)=atand(pattern_Y(1,i)-pattern_Y(v_imaxtrainY(i),i)/(v_imaxtrainY(i)-1));
      v_degree_Ystart_end_train(1,i)=atand((pattern_Y(1,i)-pattern_Y(end,i))/l_pattern);
  end
  
  
  % calculate distance or difference
  distance_X=pattern_X-repmat(test_X,1,n_group);
  distance_X_ve=pattern_X_ve-repmat(test_X_ve,1,n_group);
  distance_X_rank=pattern_X_rank-repmat(test_X_rank,1,n_group);
  v_distance_X=zeros(1,n_group);
  v_distance_X_ve=zeros(1,n_group);
  v_distance_X_rank=zeros(1,n_group);
  v_diff_degree_Xstart_max=zeros(1,n_group);
  v_diff_Xmax_loc=zeros(1,n_group);
  v_diff_Xmin_loc=zeros(1,n_group);
  
  distance_Y=pattern_Y-repmat(test_Y,1,n_group);
  distance_Y_ve=pattern_Y_ve-repmat(test_Y_ve,1,n_group);
  distance_Y_rank=pattern_Y_rank-repmat(test_Y_rank,1,n_group);
  v_distance_Y=zeros(1,n_group);
  v_distance_Y_ve=zeros(1,n_group);
  v_distance_Y_rank=zeros(1,n_group);
  v_diff_degree_Ystart_max=zeros(1,n_group);
  v_diff_Ymax_loc=zeros(1,n_group);
  v_diff_Ymin_loc=zeros(1,n_group);
  for i=1:n_group
      v_distance_X(i)=sumsqr(distance_X(:,i));
      v_distance_X_ve(i)=sumsqr(distance_X_ve(:,i));
      v_distance_X_rank(i)=sumsqr(distance_X_rank(:,i));
      v_diff_Xmax_loc(i)=abs(v_imaxtrainX(i)-imaxtest_X);
      v_diff_Xmin_loc(i)=abs(v_imintrainX(i)-imintest_X);
      v_diff_degree_Xstart_max(1,i)=abs(v_degree_Xstart_max_train(1,i)-degree_Xstart_max_test);
      
      v_distance_Y(i)=sumsqr(distance_Y(:,i));
      v_distance_Y_ve(i)=sumsqr(distance_Y_ve(:,i));
      v_distance_Y_rank(i)=sumsqr(distance_Y_rank(:,i));
      v_diff_Ymax_loc(i)=abs(v_imaxtrainY(i)-imaxtest_Y);
      v_diff_Ymin_loc(i)=abs(v_imintrainY(i)-imintest_Y);
      v_diff_degree_Ystart_max(1,i)=abs(v_degree_Ystart_max_train(1,i)-degree_Ystart_max_test);
  end
  mat_distanceX=[v_distance_X' v_distance_X_ve' v_distance_X_rank' v_diff_Xmax_loc' ...
      v_diff_Xmin_loc' v_diff_degree_Xstart_max'];
  mat_distanceY=[v_distance_Y' v_distance_Y_ve' v_distance_Y_rank' v_diff_Ymax_loc' ...
      v_diff_Ymin_loc' v_diff_degree_Ystart_max'];
  
  mat_distance=[mat_distanceX mat_distanceY];
%   mat_distance=[mat_distanceX(:,1:3) mat_distanceY(:,1:3)];
  v_sum_distance=mat_distance*weights;

  
  % find matching pattern on certain TH
  TH_idx=[];
  TH_sum_distance=prctile(v_sum_distance,prc(1));
  
  for i=1:n_group
      if v_sum_distance(i)<=TH_sum_distance
         TH_idx=[TH_idx i];
      end
  end
  
  %caculate return distribution of fitted patterns
  nfit=size(TH_idx,2);
  cfitDates{1,count_rebalance}=pattern_dates(:,TH_idx);
  cfitValuesX{1,count_rebalance}=pattern_X(:,TH_idx);
  cfitValuesY{1,count_rebalance}=pattern_Y(:,TH_idx);
  
  fit_np_max=v_train_next_max(TH_idx);
  exp_max=mean(fit_np_max);
  disp_max=std(fit_np_max);
  fit_np_min=v_train_next_min(TH_idx);
  
  fit_np_max_idx=v_train_next_max_idx(TH_idx);
  exp_max_idx=mean(fit_np_max_idx);
  disp_max_idx=std(fit_np_max_idx);
  
  fit_np_min_idx=v_train_next_min_idx(TH_idx);
  
  fit_np_volume=v_train_next_volume(TH_idx);
  exp_volume=mean(fit_np_volume);
  disp_volume=std(fit_np_volume);
  
  fit_np_ret=v_train_next_ret(TH_idx);
  exp_ret=mean(fit_np_ret);
  exp_std=std(fit_np_ret);
  
  %classify return by return
  upside_np_ret=fit_np_ret(fit_np_ret>0);
  downside_np_ret=fit_np_ret(fit_np_ret<=0);
  
  %get max for postive return and min for negative return
  fit_np_extrem_idx=zeros(size(fit_np_ret,1),size(fit_np_ret,2));
  fit_np_extrem=zeros(size(fit_np_ret,1),size(fit_np_ret,2));
  for m=1:nfit
      if fit_np_ret(m)>0
         fit_np_extrem_idx(m)=fit_np_max_idx(m);
         fit_np_extrem(m)=fit_np_max(m);
      else
         fit_np_extrem_idx(m)=fit_np_min_idx(m);
         fit_np_extrem(m)=fit_np_min(m);
      end
  end
%   
  nwin=size(upside_np_ret,2); 
  nloss=size(downside_np_ret,2);
  
  exp_wl=nwin/size(fit_np_ret,2);
  exp_omega=sum(upside_np_ret)/(-sum(downside_np_ret)+sum(upside_np_ret));      

  %clustering and consistency
  fit_np_avg_daily_ret=fit_np_ret/l_np;
  mat_fit=[fit_np_ret' fit_np_extrem_idx'];
  pd=pdist(mat_fit);
  sum_pd=sum(pd);
  [b,~,~,~,stats] = regress(fit_np_extrem_idx',[ones(size(fit_np_ret,2),1) fit_np_ret']);
  
  new_output=[nfit exp_ret exp_std exp_max disp_max exp_wl exp_omega sum_pd b(2) stats(1)];
  
  rebalance_output=[rebalance_output;new_output];
  
  rebalance_train_ret=[rebalance_train_ret fit_np_ret'];
  rebalance_train_volume=[rebalance_train_volume fit_np_volume'];
  rebalance_train_extrem=[rebalance_train_extrem fit_np_extrem'];
  rebalance_train_extrem_idx=[rebalance_train_extrem_idx fit_np_extrem_idx'];
  
  t=t-N;
end
rebalance_exp_ret=rebalance_output(:,2);
n_test_ret=size(rebalance_test_next_ret,1);
n_exp_ret=size(rebalance_exp_ret,1);
accuracy=corr(rebalance_exp_ret((n_exp_ret-n_test_ret+1):n_exp_ret),rebalance_test_next_ret);
TestpatternMetricsX=[rebalance_test_Xlevel;rebalance_test_Xve_avg;rebalance_imaxtest_X;rebalance_imintest_X;rebalance_Xstart_max_test];
TestpatternMetricsY=[rebalance_test_Ylevel;rebalance_test_Yve_avg;rebalance_imaxtest_Y;rebalance_imintest_Y;rebalance_Ystart_max_test];
TestpatternMetrics=[TestpatternMetricsX;TestpatternMetricsY];