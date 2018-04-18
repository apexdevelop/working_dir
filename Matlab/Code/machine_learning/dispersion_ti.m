% Time indexing method on single factor

% clearvars;
%% generate Data
calculate_dispersion_v5_add_volume;
%% Initialize parameters
M=500; %lookback_window
N=5; %rebalance_window
l_pattern=5;%length of pattern
n_testp=N/l_pattern; %n of test pattern
TH_prc=5:5; %percentile of distance TH
nob=size(rtn_Y,1);
s = zeros(nob,1);

%% Calculate inputs        
n_pattern=floor(M/l_pattern); %training data
adj_M=n_pattern*l_pattern;

X=z_px;
Y=z_turnover_mov;
Z=z_disp_mov;

mat_exp_ret=[];
mat_act_ret=[];
mat_distance=[];
v_actual_pnl=[];
v_exp_pnl=[];
count_trade=0;

t=adj_M;

while t<=nob-2*l_pattern
  pattern_X=reshape(X(t-adj_M+1:t,1),n_pattern,l_pattern);
  pattern_Y=reshape(Y(t-adj_M+1:t,1),n_pattern,l_pattern);
  pattern_Z=reshape(Z(t-adj_M+1:t,1),n_pattern,l_pattern);

  temp_return=reshape(rtn_Y(t-adj_M+l_pattern+1:l_pattern+t,1),n_pattern,l_pattern);
  next_period_ret=sum(temp_return,2);
        
  temp_X=X(t+1:t+n_testp*l_pattern);
  temp_Y=Y(t+1:t+n_testp*l_pattern);
  temp_Z=Z(t+1:t+n_testp*l_pattern);

  test_X=reshape(temp_X,n_testp,l_pattern);
  test_Y=reshape(temp_Y,n_testp,l_pattern);
  test_Z=reshape(temp_Z,n_testp,l_pattern);

%   temp_actual_ret=reshape(X(t+1+l_pattern:t+n_testp*l_pattern),n_testp-1,l_pattern);
  temp_actual_ret=reshape(rtn_Y(t+1+l_pattern:t+2*l_pattern,1),1,l_pattern);
  test_actual_ret=sum(temp_actual_ret,2);
        
  temp_distance=zeros(n_pattern,n_testp);
  v_expret=zeros(size(TH_prc,2),n_testp);
  c_THidx=cell(size(TH_prc,2),n_testp);
  %calculate distance
  for j=1:n_testp
      distance_X=pattern_X-repmat(test_X(j,:),n_pattern,1);
      distance_Y=pattern_Y-repmat(test_Y(j,:),n_pattern,1);
      distance_Z=pattern_Z-repmat(test_Z(j,:),n_pattern,1);
      for i=1:n_pattern
          temp_distance(i,j)=sumsqr(distance_X(i,:))+sumsqr(distance_Y(i,:))+sumsqr(distance_Z(i,:));
      end
      mat_distance=[mat_distance temp_distance];
  end
  
%   for p=1:size(TH_prc,2)
%         for j=1:n_testp
%             TH_idx=find(temp_distance(:,j)<=TH_distance);
%             c_THidx{p,j}=TH_idx;
%             v_expret(p,j)=mean(next_period_ret(TH_idx));
%         end
%   end
%   mat_exp_ret=[mat_exp_ret;v_expret];

  [min_distance,c_THidx2]=min(temp_distance);
  ret_TH=mean(next_period_ret)+std(next_period_ret);
  if next_period_ret(c_THidx2)>ret_TH
     s(t+N+1:t+2*N)=1;
     count_trade=count_trade+1;
     new_pnl=sum(rtn_Y(t+N+1:t+2*N,1).*s(t+N+1:t+2*N));
     v_actual_pnl=[v_actual_pnl;new_pnl];
     v_exp_pnl=[v_exp_pnl;next_period_ret(c_THidx2)];
  end
  mat_act_ret=[mat_act_ret;test_actual_ret];
  t=t+N;
end

v_daily_pnl=rtn_Y(:,1).*s;
mean_ret=mean(v_actual_pnl);
% plot3(pattern_X(c_THidx{1,1},:),pattern_Y(c_THidx{1,1},:),pattern_Z(c_THidx{1,1},:));
% xlabel('z disp move');
% ylabel('z px');
% zlabel('z turnover');