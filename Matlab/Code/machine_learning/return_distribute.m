% function[mat_current_day,mat_test_next_ret,mat_train_wl,mat_train_omega]=return_distribute(rtn_Y,z_px,z_turnover_mov,z_disp_mov,ex_date)
%% Initialize parameters
M=2500; %lookback_window
N=5; %rebalance_window
l_pattern=5;%length of pattern
n_testp=1; %n of test pattern
TH_prc=10; %percentile of distance TH
nob=size(rtn_Y,1);

%% Calculate inputs        
n_group=floor(M/l_pattern); %training data
adj_M=n_group*l_pattern;

X=z_px;
Y=z_turnover_mov;
Z=z_disp_mov;

mat_train_wl=[];
mat_train_omega=[];
mat_distance=[];
mat_test_next_ret=[];
mat_current_day=[];

mat_pattern_X=[];
mat_pattern_Y=[];
mat_pattern_Z=[];

% t=adj_M;
t=nob-l_np;
% while t<=nob-l_pattern
while t>=adj_M
  mat_current_day=[mat_current_day;ex_date(t+l_pattern)];
  pattern_X=reshape(X(t-adj_M+1:t,1),n_group,l_pattern);
  pattern_Y=reshape(Y(t-adj_M+1:t,1),n_group,l_pattern);
  pattern_Z=reshape(Z(t-adj_M+1:t,1),n_group,l_pattern);
  
  temp_return=reshape(rtn_Y(t-adj_M+l_pattern+1:l_pattern+t,1),n_group,l_pattern);
  train_next_ret=sum(temp_return,2);
  
  temp_X=X(t+1:t+n_testp*l_pattern);
  temp_Y=Y(t+1:t+n_testp*l_pattern);
  temp_Z=Z(t+1:t+n_testp*l_pattern);

  test_X=reshape(temp_X,n_testp,l_pattern);
  test_Y=reshape(temp_Y,n_testp,l_pattern);
  test_Z=reshape(temp_Z,n_testp,l_pattern);
  
  mat_pattern_X=[mat_pattern_X;test_X];
  mat_pattern_Y=[mat_pattern_Y;test_Y];
  mat_pattern_Z=[mat_pattern_Z;test_Z];
  
  if t<=nob-2*l_pattern
     temp_next_ret=reshape(rtn_Y(t+1+l_pattern:t+2*l_pattern,1),1,l_pattern);
     test_next_ret=sum(temp_next_ret,2);
     mat_test_next_ret=[mat_test_next_ret;test_next_ret];
  end
  
  temp_distance=zeros(n_group,n_testp);
  exp_wl=zeros(size(TH_prc,2),n_testp);
  exp_omega=zeros(size(TH_prc,2),n_testp);
  %calculate distance
  for j=1:n_testp
      distance_X=pattern_X-repmat(test_X(j,:),n_group,1);
      distance_Y=pattern_Y-repmat(test_Y(j,:),n_group,1);
      distance_Z=pattern_Z-repmat(test_Z(j,:),n_group,1);
      for i=1:n_group
          temp_distance(i,j)=sumsqr(distance_X(i,:))+sumsqr(distance_Y(i,:))+sumsqr(distance_Z(i,:));
      end
      
      TH_distance=prctile(temp_distance,TH_prc);
      TH_idx=find(temp_distance(:,j)<=TH_distance);
      temp_np_ret=train_next_ret(TH_idx);
      upside_np_ret=temp_np_ret(temp_np_ret>0);
      downside_np_ret=temp_np_ret(temp_np_ret<=0);
      exp_wl(j)=sum(temp_np_ret>0)/size(temp_np_ret,1);
      exp_omega(j)=sum(upside_np_ret)/(-sum(downside_np_ret)+sum(upside_np_ret));     
  end
  mat_distance=[mat_distance temp_distance];
  mat_train_wl=[mat_train_wl;exp_wl];
  mat_train_omega=[mat_train_omega;exp_omega];
  
  temp_turnover=pattern_Y(TH_idx);
  
%   t=t+N;
  t=t-N;
end
scatter(temp_np_ret,temp_turnover)
xlabel('return');
ylabel('z-turnover');
title(strcat('next ', num2str(l_pattern),'day return distribution'));
y_mu=mean(temp_turnover);
hline = refline([0 y_mu]);
hline.Color = 'r';
x_mu=mean(temp_np_ret);
yl = ylim;
line([x_mu x_mu], [yl(1) yl(2)],'Color','r');
% plot3(pattern_X(c_THidx{1,1},:),pattern_Y(c_THidx{1,1},:),pattern_Z(c_THidx{1,1},:));
% xlabel('z disp move');
% ylabel('z px');
% zlabel('z turnover');