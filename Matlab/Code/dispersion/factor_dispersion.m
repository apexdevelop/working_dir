
clear all;
cd('C:\Users\ychen\Documents\MATLAB');
[num1,txt1]=xlsread('dispersion matlab','Universe','c1:c1000');
[num2,txt2]=xlsread('dispersion matlab','Universe','a3:a3'); %equity which dispersion may be correlated with
javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar')

%% generate Data
startdate='2012/11/14';
enddate=today();
per={'daily','non_trading_weekdays','previous_value'};
cd('C:\Users\ychen\Documents\MATLAB');
%VAR parameters
%#of lags
p=2; 
window=120;
M=window;
N=15;

tic
    temp_txt1=txt1(:,1);
    temp_txt1=temp_txt1(~cellfun('isempty',temp_txt1));
    temp_txt2=txt2;
%     temp_txt2=temp_txt2(~cellfun('isempty',temp_tx2));
    c=blp;
    for loop=1:size(temp_txt1,1)
        new=char(temp_txt1(loop));
        [d1, sec1] = history(c, new,'CHG_PCT_1D',startdate,enddate,per);
        [d2, sec1] = history(c, new,'Last_Price',startdate,enddate,per);
        [d3, sec1] = history(c, new,'CHG_PCT_5D',startdate,enddate,per);
        dates1(1:size(d1,1),loop)=d1(1:size(d1,1),1);
        rtns1(1:size(d1,1),loop)=d1(1:size(d1,1),2);
        prices1(1:size(d2,1),loop)=d2(1:size(d2,1),2);
        rtns_5d1(1:size(d3,1),loop)=d3(1:size(d3,1),2);
    end;
    
    for loop=1:size(temp_txt2,1)
        new=char(temp_txt2(loop));
        [d1, sec2] = history(c, new,'CHG_PCT_1D',startdate,enddate,per);
        [d2, sec2] = history(c, new,'Last_Price',startdate,enddate,per);
        [d3, sec2] = history(c, new,'CHG_PCT_5D',startdate,enddate,per);
        dates2(1:size(d1,1),loop)=d1(1:size(d1,1),1);
        rtns2(1:size(d1,1),loop)=d1(1:size(d1,1),2);
        prices2(1:size(d2,1),loop)=d2(1:size(d2,1),2);
        rtns_5d2(1:size(d3,1),loop)=d3(1:size(d3,1),2);
    end;
    close(c);

    n_dim1=size(rtns1,2);
    
    tday1=dates1(:, 1);
    rtn1=rtns1(:, 1);
    px1=prices1(:, 1);
    rtn1_5d=rtns_5d1(:,1);    
    
    tday1(find(~tday1))=[];
    rtn1(find(~tday1))=[];
    px1(find(~tday1))=[];
    rtn1_5d(find(~tday1))=[];
    
  for k=2:n_dim1
        tday2=dates1(:, k); 
        rtn2=rtns1(:, k);
        px2=prices1(:, k);
        rtn2_5d=rtns_5d1(:, k);
        
        rtn2(find(~tday2))=[];
        px2(find(~tday2))=[];
        rtn2_5d(find(~tday2))=[];
        tday2(find(~tday2))=[];
        
        [n1n2, idx1, idx2]=intersect(tday1, tday2);
        tday1=tday1(idx1);
        
        rtn1=[rtn1(idx1,:) rtn2(idx2)];
        px1=[px1(idx1,:) px2(idx2)];
        rtn1_5d=[rtn1_5d(idx1,:) rtn2_5d(idx2)];
        
   end
   rtn_Y=rtn1;
   px_Y=px1;
   rtn_5dY=rtn1_5d;  
   excel_date=m2xdate(tday1,0);

    %% Calculate Dispersion
    v_disp=zeros(size(rtn_Y,1),1);
    v_disp_5d=zeros(size(rtn_Y,1),1);
    for j=1:size(rtn_Y,1)
        temp_rtn=rtn_Y(j,2:end);
        temp_rtn(isnan(temp_rtn))=[];
        temp_avg=mean(temp_rtn);
        temp_diff=abs(temp_rtn-repmat(temp_avg,1,size(temp_rtn,2)));
        v_disp(j)=mean(temp_diff,2);
    end
    
    %calculate 5d_moving average
    disp_row=reshape(v_disp,1,size(rtn_Y,1));
    disp_row=tsmovavg(disp_row,'e',5);
    disp_row=[reshape(v_disp(1:4),1,4) disp_row(5:end)];
    v_disp_mov=reshape(disp_row,size(disp_row,2),1);
    
    %calculate 5d_dispersion
    for j=1:size(rtn_Y,1)
        temp_rtn=rtn_5dY(j,2:end);
        temp_rtn(isnan(temp_rtn))=[];
        temp_avg=mean(temp_rtn);
        temp_diff=abs(temp_rtn-repmat(temp_avg,1,size(temp_rtn,2)));
        v_disp_5d(j)=mean(temp_diff,2);
    end
    
    v_corr=zeros(size(rtn_Y,1),1);
    v_corr(1:window-1)=repmat(100,window-1,1);
    for j=window:size(rtn_Y,1)       
        v_corr(j)=corr(v_disp(j-window+1:j),px_Y(j-window+1:j,1));
    end
   

Metrics=[];
%% VAR process
factor=v_disp_mov;
n_dim2=size(rtns2,2);
for k=1:n_dim2
% the element chosen to do VAR with dispersion    
    Spec = vgxset('n',2,'nAR',p);
    dep_rtn=rtns2(:,k);
    dep_px=prices2(:,k);
    dep_tday=dates2(:,k);
    baddata=find(isnan(dep_rtn));
    dep_rtn(baddata)=[];
    dep_px(baddata)=[];
    dep_tday(baddata)=[];
    [ndisndep, idx_dis, idx_dep]=intersect(tday1, dep_tday);
    factor=factor(idx_dis);
    dep_rtn=dep_rtn(idx_dep);
    dep_px=dep_px(idx_dep);
    rtn_Yvar=[factor dep_rtn];
    px_Yvar=[factor dep_px];
    
    Ymodel=zeros(size(rtn_Yvar,1),2);
    Ymodel(1:M-1,:)=px_Yvar(1:M-1,:);
    
    v_causal=zeros(size(rtn_Yvar,1)-M+1,1);
    
    j=M;

    while j<size(rtn_Yvar,1)
      Ypre=rtn_Yvar(j-M+1:j-M+p,:);
      Yest=rtn_Yvar(j-M+p+1:j,:);
      [EstSpec,EstStdErrors,LLF,W] = vgxvarx(Spec,Yest,[],Ypre);
      
      if j<=size(rtn_Yvar,1)-N
         [rtn_FY,FYCov]=vgxpred(EstSpec,N,[],Yest);
         reverse_diff=cumsum([log(px_Yvar(j+1,2));rtn_FY(:,2)]);
         reverse_log=exp(reverse_diff);
         Ymodel(j:j+N,1)=reverse_log;

      else
         T_pred=size(rtn_Yvar,1)-j;
         [rtn_FY,FYCov]=vgxpred(EstSpec,T_pred,[],Yest);
         reverse_diff=cumsum([log(px_Yvar(end-T_pred,2));rtn_FY(:,2)]);
         reverse_log=exp(reverse_diff);
         Ymodel(j:end,1)=reverse_log; 
      end
      
      cd('C:\Users\ychen\Documents\MATLAB');
      [F,c_v,p_F] =granger_cause(rtn_Yvar(j-M+p+1:j,1),rtn_Yvar(j-M+p+1:j,2),0.05,p);
      v_causal(j-M+1:j-M+1+N)=p_F;
      j=j+N;
    end

%     spread=px_Yvar(M:end,1)-Ymodel(M:end,1);
%     Zspread=zscore(spread);
    
 %% backtesting
%     enter_disp=2;
%     exit_disp=-2;
%     enter_corr=0.20;
%     exit_corr=0.40;
%     
%     temp_zdisp=z_disp;
%     temp_zdisp(baddata)=[];
%     temp_date=tday1;
%     temp_date(baddata)=[];
%     
%     equity_return=rtn_Yvar(window:end,2);   
%     v_factor=temp_zdisp(window:end);
%     v_date=temp_date(window:end);
%     
%     newmetric=backtest(equity_return,v_factor,enter_disp,exit_disp,v_causal,enter_corr,exit_corr,v_date);
%    
%     newmetric=[z_disp(end) v_causal(end) newmetric];
%     Metrics=[Metrics;newmetric];
    
end
%     plot(1:size(Ymodel,1),Ymodel(:,1),'--r')
%     hold on
%     plot(1:size(Px_Y,1)-1,Px_Y(2:end,1),'k')

% v_rtn=equity_return;
% Y=v_factor;
% v_corr=v_causal;
% tday=v_date;
 
cd('C:\Users\ychen\Documents\MATLAB');
toc