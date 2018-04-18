% fit criteria
% 1 %distance between factor
% 2 %distance between velocity of factor
% 3 %distance between relative rank of factor
% 4 %position difference of max point
% 5 %position difference of min point
% 6 %degree difference between slope of starting point to end point
% how to combine different criteria
% how to set how many to choose

function[cfitDates,cfitValues,rebalance_current_day,rebalance_test_next_ret,rebalance_train_ret,rebalance_train_extrem,rebalance_train_extrem_idx,rebalance_output,TestpatternMetrics]=backtest_patterns_sf(vYret,vXret,vDate,M,N,l_pattern,l_np,prc,weights)
%% Calculate inputs


X=vXret;
% X_ve=[0;diff(X)./X(2:end)];%X is zscore based,denominator could be positive, velocity could be wrong
X_ve=[0;diff(vXret)./vXret(2:end)];%velocity

%% Initialize parameters
% char_date=datestr(tday1);
% c_date=cellstr(char_date);
ex_date=m2xdate(vDate,0);
n_testp=1; %n of test pattern
nob=size(vYret,1);
if M>nob-l_pattern-l_np
   M=nob-l_pattern-l_np;
end       
n_group=floor(M/l_pattern); %training data
adj_M=n_group*l_pattern;
lim_rebalance=ceil((nob-adj_M)/N);
cell_train_next_ret=cell(1,lim_rebalance);

rebalance_train_ret=[];
rebalance_train_extrem=[];
rebalance_train_extrem_idx=[];
rebalance_test_next_ret=[];

rebalance_current_day=[];
rebalance_output=[];

%targeted(test) pattern features
rebalance_test_X=[];
rebalance_test_X_ve=[];
rebalance_test_X_rank=[];

rebalance_test_sum=[]; %total return over 10 day for each pattern
rebalance_imaxtest_X=[];
rebalance_imintest_X=[];
rebalance_start_end_test=[];
rebalance_test_ve_avg=[];

count_rebalance=0;
t=nob-l_pattern; %start date of latest pattern

approx_n_balance=ceil((t-adj_M)/N);
cfitDates=cell(1,approx_n_balance);
cfitValues=cell(1,approx_n_balance);

while t>=adj_M
  count_rebalance=count_rebalance+1;
  rebalance_current_day=[rebalance_current_day;ex_date(t+l_pattern)]; %end day of the pattern
  pattern_dates=reshape(vDate(t-adj_M+1:t,1),l_pattern,n_group);
  pattern_X=reshape(X(t-adj_M+1:t,1),l_pattern,n_group); %reshape function reshape by column
  pattern_X_ve=reshape(X_ve(t-adj_M+1:t,1),l_pattern,n_group);
  
  v_train_next_ret=zeros(1,n_group); %cumulative ret of the whole l_pattern period 
  v_train_next_max=zeros(1,n_group);
  v_train_next_min=zeros(1,n_group);
  v_train_next_max_idx=zeros(1,n_group);
  v_train_next_min_idx=zeros(1,n_group);
  
  v_start_date=zeros(1,n_group);
  count_group=0;
  for t1=t-adj_M:l_pattern:t-l_pattern
      count_group=count_group+1;
      v_start_date(count_group)=vDate(t1+1);
      v_train_next_ret(count_group)=sum(vYret(t1+l_pattern+1:t1+l_pattern+l_np,1));
%       [next_max_ret,next_max_ret_idx]=max(rtn_Y(t1+l_pattern+1:t1+l_pattern+l_np,1));
%       [next_min_ret,next_min_ret_idx]=min(rtn_Y(t1+l_pattern+1:t1+l_pattern+l_np,1));
      %calculate cumulative ret for each day in next period
      v_train_next_cumret_perday=zeros(1,l_np);
      for t2=1:l_np
          v_train_next_cumret_perday(t2)=sum(vYret(t1+l_pattern+1:t1+l_pattern+t2,1));
      end
      %max price is the max cumulative ret
      [next_max_px,next_max_px_idx]=max(v_train_next_cumret_perday);
      [next_min_px,next_min_px_idx]=min(v_train_next_cumret_perday);
      v_train_next_max(count_group)=next_max_px;
      v_train_next_min(count_group)=next_min_px;
      v_train_next_max_idx(count_group)=next_max_px_idx;
      v_train_next_min_idx(count_group)=next_min_px_idx;
      
  end
  z_train_next_ret=zscore(v_train_next_ret);
  
  test_X=X(t+1:t+n_testp*l_pattern);
  test_X_ve=X_ve(t+1:t+n_testp*l_pattern);
  
  rebalance_test_X=[rebalance_test_X test_X];
  rebalance_test_X_ve=[rebalance_test_X_ve test_X_ve];
  
  sum_test_ret=sum(test_X);
  rebalance_test_sum=[rebalance_test_sum sum_test_ret];
  avg_test_ve=mean(test_X_ve);
  rebalance_test_ve_avg=[rebalance_test_ve_avg avg_test_ve];
  
  if t<=nob-l_pattern-l_np
     temp_next_ret=vYret(t+1+l_pattern:t+l_pattern+l_np,1);
     test_next_ret=sum(temp_next_ret);
     
     rebalance_test_next_ret=[rebalance_test_next_ret;test_next_ret];
     
  end
  
  % calculate matching criterie
  
  %3-1 find relative rank of each point in pattern_X
  pattern_X_rank=zeros(l_pattern,n_group);
  for i=1:n_group
      sorted_pattern_X = sort(pattern_X(:,i));
      for r=1:l_pattern
          %Assignment has more non-singleton rhs dimensions than non-singleton subscripts
          temp_rank_idx=find(pattern_X(:,i)==sorted_pattern_X(r));
          if size(temp_rank_idx,1)>1
              pattern_X_rank(r,i)=temp_rank_idx(1);
          else
              pattern_X_rank(r,i)=temp_rank_idx;
          end
      end
  end    
  
  %3-2 find relative rank of each point in test_X
  test_X_rank=zeros(l_pattern,1);
  [sorted_test_X,~] = sort(test_X);
  for r=1:l_pattern
      rank_idx=find(test_X==sorted_test_X(r));
      if size(rank_idx,1)>1
         test_X_rank(r)=rank_idx(1);
      else
         test_X_rank(r)=rank_idx;
      end
  end
  
  rebalance_test_X_rank=[rebalance_test_X_rank test_X_rank];
  
  %4&5-1.calculate max point and min point in train_X
  v_imaxtrain=zeros(1,n_group);
  v_imintrain=zeros(1,n_group);
  for i=1:n_group
      [~,v_imaxtrain(i)]=max(pattern_X(:,i));
      [~,v_imintrain(i)]=min(pattern_X(:,i));
  end
  %4&5-2.find maxmum and min point in text_X
  [~,imaxtest_X]=max(test_X);
  [~,imintest_X]=min(test_X);
  
  rebalance_imaxtest_X=[rebalance_imaxtest_X imaxtest_X];
  rebalance_imintest_X=[rebalance_imintest_X imintest_X];
  
  %6. calculate shape related degree
  start_max_test=test_X(1)-test_X(imaxtest_X);
  v_degree_start_end_train=zeros(1,n_group);
  
  degree_start_end_test=atand((test_X(1)-test_X(end))/l_pattern);
  rebalance_start_end_test=[rebalance_start_end_test degree_start_end_test];
  
  for i=1:n_group
      start_max_train=pattern_X(1,i)-pattern_X(v_imaxtrain(i),i);
      v_degree_start_end_train(1,i)=atand((pattern_X(1,i)-pattern_X(end,i))/l_pattern);
  end
  
  
  % calculate distance or difference
  distance_X=pattern_X-repmat(test_X,1,n_group);
  distance_X_ve=pattern_X_ve-repmat(test_X_ve,1,n_group);
  distance_X_rank=pattern_X_rank-repmat(test_X_rank,1,n_group);
  v_distance_X=zeros(1,n_group);
  v_distance_X_ve=zeros(1,n_group);
  v_distance_X_rank=zeros(1,n_group);
  v_diff_degree_start_end=zeros(1,n_group);
  v_diff_max_loc=zeros(1,n_group);
  v_diff_min_loc=zeros(1,n_group);
  for i=1:n_group
      v_distance_X(i)=sumsqr(distance_X(:,i));
      v_distance_X_ve(i)=sumsqr(distance_X_ve(:,i));
      v_distance_X_rank(i)=sumsqr(distance_X_rank(:,i));
      v_diff_max_loc(i)=abs(v_imaxtrain(i)-imaxtest_X);
      v_diff_min_loc(i)=abs(v_imintrain(i)-imintest_X);
      v_diff_degree_start_end(1,i)=abs(v_degree_start_end_train(1,i)-degree_start_end_test);
  end
  mat_distance=[v_distance_X' v_distance_X_ve' v_distance_X_rank' v_diff_max_loc' ...
      v_diff_min_loc' v_diff_degree_start_end'];
  
  v_sum_distance=mat_distance*weights;
  
  % find matching pattern on certain TH
  TH_idx=[];
  TH_sum_distance=prctile(v_sum_distance,prc(1));
  
  nfit=ceil(n_group*prc/100);
  
  [sort_sum_distance,idx_sum_distance]=sort(v_sum_distance);
  TH_idx=idx_sum_distance(1:nfit);
  
%   for i=1:n_group
%       if v_sum_distance(i)<=TH_sum_distance
%          TH_idx=[TH_idx i];
%       end
%   end
  
  %caculate return distribution of fitted patterns
%   nfit=size(TH_idx,2);
  cfitDates{1,count_rebalance}=pattern_dates(:,TH_idx);
  cfitValues{1,count_rebalance}=pattern_X(:,TH_idx);
  
  fit_np_max=v_train_next_max(TH_idx);
  exp_max=mean(fit_np_max);
  disp_max=std(fit_np_max);
  fit_np_min=v_train_next_min(TH_idx);
  
  fit_np_max_idx=v_train_next_max_idx(TH_idx);
  exp_max_idx=mean(fit_np_max_idx);
  disp_max_idx=std(fit_np_max_idx);
  
  fit_np_min_idx=v_train_next_min_idx(TH_idx);
  
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
  
  rebalance_train_extrem=[rebalance_train_extrem fit_np_extrem'];
  rebalance_train_extrem_idx=[rebalance_train_extrem_idx fit_np_extrem_idx'];
  
  t=t-N;
end

TestpatternMetrics=[rebalance_test_sum;rebalance_test_ve_avg;rebalance_imaxtest_X;rebalance_imintest_X;rebalance_start_end_test];