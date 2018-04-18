
function [output1,output2]=copair_sweep_current(beta_idx,Y,M,N,Signal_TH,pADF_TH,is_open,direction,enter_date,exit_date)

% Very often, the pairs will be convincingly cointegrated, or convincingly
% NOT cointegrated.  In these cases, a warning is issued not to read too
% much into the test statistic.  Since we don't use the test statistic, we
% can suppress these warnings.
warning('off', 'econ:egcitest:LeftTailStatTooSmall')
warning('off', 'econ:egcitest:LeftTailStatTooBig')
%% Sweep across the entire time series           
%Conduct Regression to calculate residual and compute ADF stat

v_spread=Y(:,1)-Y(:,2);
z_spread=zeros(size(Y,1),1);

if M<size(Y,1)
   z_spread(1:M-1)=zscore(v_spread(1:M-1));
   for j=M : size(Y,1)
       temp_z=zscore(v_spread(j-M+1:j));
       z_spread(j)=temp_z(M);
   end
else
   z_spread=zscore(v_spread);
end

last_zspread=z_spread(size(Y,1));

zscr=zeros(size(Y,1),1);
v_h = zeros(size(Y,1),1);         
v_residual=zeros(size(Y,1),1);

%% Calculate long-term Beta and ADF

if size(Y,1)>=250
%    [~,pValue1,~,~,reg1] = egcitest(Y(end-250:end,:),'creg','c','alpha',0.05);
   diff_1yr=diff(Y(end-250:end,:));
   [~,~,~,~,reg1] = egcitest(diff_1yr,'creg','c','alpha',0.05);
   [~,pValue1,~,~,~] = egcitest(Y(end-250:end,:),'creg','c','alpha',0.05);
   m_ADF1=pValue1;
   m_Beta1=reg1.coeff(2);
else
    m_ADF1=2;
    m_Beta1=100;
end

if size(Y,1)>=500
   diff_2yr=diff(Y(end-500:end,:));
   [~,~,~,~,reg2] = egcitest(diff_2yr,'creg','c','alpha',0.05);
   [~,pValue2,~,~,~] = egcitest(Y(end-500:end,:),'creg','c','alpha',0.05);
   m_ADF2=pValue2;
   m_Beta2=reg2.coeff(2);
else
    m_ADF2=2;
    m_Beta2=100;
end

if size(Y,1)>=1000
   diff_4yr=diff(Y(end-1000:end,:));
   [~,~,~,~,reg4] = egcitest(diff_4yr,'creg','c','alpha',0.05);
   [~,pValue4,~,~,~] = egcitest(Y(end-1000:end,:),'creg','c','alpha',0.05);
   m_ADF4=pValue4;
   m_Beta4=reg4.coeff(2);
else
    m_ADF4=2;
    m_Beta4=100; 
end

%% Calculate Z-residual
if M< size(Y,1)
   j=M;
   while j<=size(Y,1)
      NY1=[];
      NY2=[];
      diff_NY1=diff(Y(j-M+1:j,:)); %diff log is log return
%       diff_NY1=diff_NY1-repmat(mean(diff_NY1),M-1,1);
      [~,~,~,~,reg1_rtn] = egcitest(diff_NY1,'creg','c','alpha',0.05);
      
      switch beta_idx
          case 1
              NY1=Y(j-M+1:j,:);
          case 2
              NY1=Y(j-M+1:j,:)-repmat(mean(Y(j-M+1:j,:)),M,1);
          case 3
              NY1=zscore(Y(j-M+1:j,:));
      end
      [h,pValue,~,~,reg1_log] = egcitest(NY1,'creg','c','alpha',0.05);
      b=reg1_log.coeff(2:end);
      v_h(j:j+N-1)=h*ones(N,1);
      
      if j<=size(Y,1)-N
         switch beta_idx
          case 1
              NY2=Y(j:j+N-1,:);
          case 2
              NY2=Y(j:j+N-1,:)-repmat(mean(Y(j:j+N-1,:)),N,1);
          case 3
              NY2=zscore(Y(j:j+N-1,:));
         end
         v_residual(j:j+N-1)=NY2*[1;-b]-reg1_log.coeff(1);
         zscr(j:j+N-1)=(v_residual(j:j+N-1)-mean(v_residual(j-M+1:j)))/reg1_log.RMSE;
     
      else
          switch beta_idx
          case 1
              NY2=Y(j:end,:);
          case 2
              NY2=Y(j:end,:)-repmat(mean(Y(j:end,:)),size(Y,1)-j+1,1);
          case 3
              NY2=zscore(Y(j:end,:));
         end
         v_residual(j:end)=NY2*[1;-b]-reg1_log.coeff(1);
         zscr(j:end)=(v_residual(j:end)-mean(v_residual(j-M+1:j)))/reg1_log.RMSE; 
      end
      j=j+N;
  end 
else
   diff_NY1=diff(Y); %diff log is log return
   rtn_NY1=diff_NY1-repmat(mean(diff_NY1),size(Y,1)-1,1);
   [~,~,~,~,reg1_rtn] = egcitest(rtn_NY1,'alpha',pADF_TH);
   
   [h,pValue,~,~,reg1_log] = egcitest(Y,'alpha',pADF_TH);
   b=reg1_log.coeff(2:end);
   v_Beta(1:end)=b*ones(size(Y,1),1);
   v_h(1:end)=h*ones(size(Y,1),1);
   v_pADF(1:end)=pValue*ones(size(Y,1),1);
   v_residual=reg1_log.res;
   zscr=zscore(v_residual);
end

signal_l2=zscr(end-2);
signal_l=zscr(end-1);
signal_c=zscr(end);

last_enter=m2xdate(datenum(enter_date),0);
last_exit=m2xdate(datenum(exit_date),0);
%% find open status, open direction, enter date and exit date
if is_open~=0 
     last_enter=m2xdate(datenum(enter_date),0);
     if (direction==-1 && signal_c<-0.25*Signal_TH) || (direction==1 && signal_c>0.25*Signal_TH)|| pValue > pADF_TH
         last_exit=m2xdate(today(),0);
         is_open=0;
     end
elseif Signal_TH>=0.5 && pADF_TH<=0.4  
     if  direction==0 && signal_l>Signal_TH && signal_c<Signal_TH && signal_c>0.30*signal_l ... 
     && pValue <= pADF_TH 
         direction = -1;
         is_open=1;
         last_enter=m2xdate(today(),0);
     elseif direction==0 && signal_l<-Signal_TH && signal_c>-Signal_TH && signal_c<0.30*signal_l ...
     && pValue <= pADF_TH 
         direction = 1;
         is_open=1;
         last_enter=m2xdate(today(),0);
     else
     end
else
end

%% build output
output1=[last_zspread,signal_l2,signal_l,signal_c];
output2=[is_open,direction,last_exit,last_enter,reg1_rtn.coeff(2),m_Beta1,m_Beta2,m_Beta4,pValue,m_ADF1,m_ADF2,m_ADF4];
