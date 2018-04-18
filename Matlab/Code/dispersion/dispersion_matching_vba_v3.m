%% TODO: How to generate BAddPeriods in Bloomberg
% DONE:clear contents on each excel sheet before writing
% change n_yr_trades to n_trades
% add n_trades threshold
% add global optimization

% function calculate_dispersion_v5_add_volume(input_range,index_name)
% only test for last day's dispersion level
clearvars;
javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');
% [~,txt]=xlsread('dispersion_matlab_v1','universe','c1:j1000');%All
[num,txt]=xlsread('dispersion_matlab_v1','universe','c1:c1000');%OEX
% [~,txt]=xlsread('dispersion_matlab_v1','universe','d1:d1000');%NKY
% [~,txt]=xlsread('dispersion_matlab_v1','universe','e1:e1000');%HSI
% [num,txt]=xlsread('dispersion_matlab_v1','universe','f1:f1000');%HSCEI
% [~,txt]=xlsread('dispersion_matlab_v1','universe','g1:g1000');%SHCSI100
% [num,txt]=xlsread('dispersion_matlab_v1','universe','h1:h1000');%KOSPI2
% [num,txt]=xlsread('dispersion_matlab_v1','universe','i1:i1000');%TAMSCI
% [~,txt]=xlsread('dispersion_matlab_v1','universe','j1:j1000');%E100
%% generate Data
enddate=today()-1;
days_back=1800;
startdate=enddate-days_back;

per={'daily','non_trading_weekdays','previous_value'};
fields={'CHG_PCT_1D','Last_Price','CHG_PCT_5D','TURNOVER'};

z_window=60;
corr_window=20;
mov_window=5;

% processing time started
% tic
n_universe=size(txt,2);
full_metrics=[];%corresponding to the table on tab "list"
full_metrics_gl=[];
%backtesting parameter
step_disp=0.1;
step_corr=0.2;
TH_ntrades=5;
is_corr=0;

max_exit_corr=2;
min_exit_corr=0.2;
itr_exit_corr=(max_exit_corr-min_exit_corr)/step_corr;
    
max_enter_corr=-0.2;
min_enter_corr=-2;
itr_enter_corr=(max_enter_corr-min_enter_corr)/step_corr;

for i=1:n_universe
    temp_txt=txt(:,i);
    temp_txt=temp_txt(~cellfun('isempty',temp_txt));
    %Bloomberg Part starts
    fprintf('getting data from Bloomberg\n');
    tic
    c=blp;
    for loop=1:size(temp_txt,1)
        new=char(temp_txt(loop));
        [d, sec] = history(c, new,fields,startdate,enddate,per);
        dates(1:size(d,1),loop)=d(1:size(d,1),1);
        rtns(1:size(d,1),loop)=d(1:size(d,1),2);
        prices(1:size(d,1),loop)=d(1:size(d,1),3);
        rtns_5d(1:size(d,1),loop)=d(1:size(d,1),4);
        turnovers(1:size(d,1),loop)=d(1:size(d,1),5);
    end;
    close(c);
    % end of Bloomberg Part
    toc
    
    n_dim=size(rtns,2);
    tday1=dates(:, 1);
    rtn1=rtns(:, 1);
    px1=prices(:, 1);
    rtn1_5d=rtns_5d(:,1);
    turnover1=turnovers(:,1);
    
    rtn1(find(~tday1))=[];
    px1(find(~tday1))=[];
    rtn1_5d(find(~tday1))=[];
    tday1(find(~tday1))=[];
    turnover1(find(~tday1))=[];
    
    for k=2:n_dim
        tday2=dates(:, k); 
        rtn2=rtns(:, k);
        px2=prices(:, k);
        rtn2_5d=rtns_5d(:, k);
        turnover2=turnovers(:, k);
        
        rtn2(find(~tday2))=[];
        px2(find(~tday2))=[];
        rtn2_5d(find(~tday2))=[];
        tday2(find(~tday2))=[];
        turnover2(find(~tday2))=[];
        
        [n1n2, idx1, idx2]=intersect(tday1, tday2);
        tday1=tday1(idx1);
        
        rtn1=[rtn1(idx1,:) rtn2(idx2)];
        px1=[px1(idx1,:) px2(idx2)];
        rtn1_5d=[rtn1_5d(idx1,:) rtn2_5d(idx2)];
        turnover1=[turnover1(idx1,:) turnover2(idx2)];
    end
    
    rtn_Y=rtn1;
    px_Y=px1;
    rtn_5dY=rtn1_5d;
    turnover_Y=turnover1;
    
    excel_date=m2xdate(tday1,0);

    %% Calculate Dispersion
    fprintf('calculate disp, correlation, volume\n');
    tic
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
%     disp_row=tsmovavg(disp_row,'e',mov_window);
    disp_row=tsmovavg(disp_row,'s',mov_window); %simple moving average
    disp_row=[reshape(v_disp(1:(mov_window-1)),1,(mov_window-1)) disp_row(mov_window:end)];
    disp_mov_col=reshape(disp_row,size(disp_row,2),1);
    
    %calculate 5d_moving average turnover
    turnover_row=reshape(turnover_Y(:,1),1,size(rtn_Y,1));
    turnover_row=tsmovavg(turnover_row,'s',mov_window);
    turnover_row=[reshape(turnover_Y(1:(mov_window-1),1),1,(mov_window-1)) turnover_row(mov_window:end)];
    turnover_mov=reshape(turnover_row,size(turnover_row,2),1);
    
    %calculate 5d_dispersion
    for j=1:size(rtn_Y,1)
        temp_rtn=rtn_5dY(j,2:end);
        temp_rtn(isnan(temp_rtn))=[];
        temp_avg=mean(temp_rtn);
        temp_diff=abs(temp_rtn-repmat(temp_avg,1,size(temp_rtn,2)));
        v_disp_5d(j)=mean(temp_diff,2);
    end
    
    %calculate z-score and correlation
    z_px=zeros(size(rtn_Y,1),1);
    z_turnover=zeros(size(rtn_Y,1),1);
    z_turnover_mov=zeros(size(rtn_Y,1),1);
    z_disp=zeros(size(rtn_Y,1),1);
    z_disp_mov=zeros(size(rtn_Y,1),1);
    z_disp_5d=zeros(size(rtn_Y,1),1);
    v_corr=zeros(size(rtn_Y,1)-corr_window+1,1);
    v_corr_diff2=zeros(size(rtn_Y,1)-corr_window+1,1);
    z_corr=zeros(size(rtn_Y,1)-corr_window+1,1);
    z_corr_diff2=zeros(size(rtn_Y,1)-corr_window+1,1);
    
    z_disp(1:z_window-1)=zscore(v_disp(1:z_window-1));
    z_disp_mov(1:z_window-1)=zscore(disp_mov_col(1:z_window-1));
    z_disp_5d(1:z_window-1)=zscore(v_disp_5d(1:z_window-1));
    z_px(1:z_window-1)=zscore(px_Y(1:z_window-1,1));
    z_turnover(1:z_window-1)=zscore(turnover_Y(1:z_window-1,1));
    z_turnover_mov(1:z_window-1)=zscore(turnover_mov(1:z_window-1,1));
    
    for j=corr_window:size(rtn_Y,1)
        v_corr(j-corr_window+1)=corr(disp_mov_col(j-corr_window+1:j),px_Y(j-corr_window+1:j,1));
        if j<=corr_window+1
            v_corr_diff2(j-corr_window+1)=0;
        else
            v_corr_diff2(j-corr_window+1)=v_corr(j-corr_window+1)-v_corr(j-corr_window-1);
        end
    end
    
    z_corr(1:z_window-1)=zscore(v_corr(1:z_window-1));
    for j=z_window:size(v_corr,1)
        tempz=zscore(v_corr(j-z_window+1:j,1));
        z_corr(j)=tempz(end);
    end
    
    z_corr_diff2(1:z_window-1)=zscore(v_corr_diff2(1:z_window-1));
    for j=z_window:size(v_corr,1)
        tempz=zscore(v_corr_diff2(j-z_window+1:j,1));
        z_corr_diff2(j)=tempz(end);
    end
    
    for j=z_window:size(rtn_Y,1)
        tempz=zscore(v_disp(j-z_window+1:j));
        z_disp(j)=tempz(end);
    end
    
    for j=z_window:size(rtn_Y,1)
        tempz=zscore(disp_mov_col(j-z_window+1:j));
        z_disp_mov(j)=tempz(end);
    end
    
    for j=z_window:size(rtn_Y,1)
        tempz=zscore(v_disp_5d(j-z_window+1:j));
        z_disp_5d(j)=tempz(end);
    end
    
    %price
    for j=z_window:size(rtn_Y,1)
        tempz=zscore(px_Y(j-z_window+1:j,1));
        z_px(j)=tempz(end);
    end
    
    %turnover
    for j=z_window:size(rtn_Y,1)
        tempz=zscore(turnover_Y(j-z_window+1:j,1));
        z_turnover(j)=tempz(end);
    end
    
    for j=z_window:size(rtn_Y,1)
        tempz=zscore(turnover_mov(j-z_window+1:j,1));
        z_turnover_mov(j)=tempz(end);
    end
    sea_zdisp=(z_disp_mov(end-260)+z_disp_mov(end-260*2)+z_disp_mov(end-260*3)+z_disp_mov(end-260*4))/4;
    
    cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/dispersion');
    universe_name=char(temp_txt(1));
    xlswrite('dispersion_backtest.xlsm',excel_date,universe_name,'A2');
    xlswrite('dispersion_backtest.xlsm',px_Y(:,1),universe_name,'B2');
    xlswrite('dispersion_backtest.xlsm',z_turnover,universe_name,'F2');
    xlswrite('dispersion_backtest.xlsm',z_disp_mov,universe_name,'J2');
    xlswrite('dispersion_backtest.xlsm',z_corr,universe_name,'AA21');   
    toc
    %% current optimization
    fprintf(' current optimization, fix correlation\n');
    tic
    enter_disp=z_disp_mov(end);
    if enter_disp>0
        min_exit_disp=-1;
        max_exit_disp=0;
    elseif enter_disp<0
        min_exit_disp=0;
        max_exit_disp=1;
    end
    itr_exit_disp=(max_exit_disp-min_exit_disp)/step_disp;
    v_exit=[];
    v_expret=[];
    v_ntrades=[];
    v_std=[];
    v_HP=[];
    v_Omega=[];
    v_WL=[];
    clong=cell(500,1);
    cshort=cell(500,1);
    cexit=cell(500,1);
    count_feasible=0;
    Ometrics_single_universe=[];
    % current optimization, no correlation
    if is_corr==0
       for j=1:(itr_exit_disp+1)
        exit_disp=min_exit_disp+step_disp*(j-1);
        [newlong,newshort,newexit,newmetric]=disp_backtest_nocorr(rtn_Y(corr_window:end,1),z_disp_mov(corr_window:end),enter_disp,exit_disp,tday1(corr_window:end)); 
        Ometrics_single_universe=[Ometrics_single_universe;newmetric];
        ntrades=newmetric(5);
        if  ntrades>=TH_ntrades
           count_feasible=count_feasible+1;
           v_exit=[v_exit;exit_disp];
           v_expret=[v_expret;newmetric(3)];
           v_std=[v_std;newmetric(4)];
           v_ntrades=[v_ntrades;newmetric(5)];
           v_HP=[v_HP;newmetric(6)];
           v_Omega=[v_Omega;newmetric(7)];
           v_WL=[v_WL;newmetric(8)];
           
           clong{count_feasible,1}=newlong;
           cshort{count_feasible,1}=newshort;
           cexit{count_feasible,1}=newexit;
        end
      end
      if count_feasible>=1
        optiVector=v_WL;
        [C,I]=max(optiVector);
        opti_exit_disp_current=v_exit(I);

        opti_long=clong{I,1};
        opti_short=cshort{I,1};
        opti_exit=cexit{I,1};
        cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/dispersion');
        universe_name=char(temp_txt(1));
        xlswrite('dispersion_backtest.xlsm',opti_short,universe_name,'M21');
        xlswrite('dispersion_backtest.xlsm',opti_long,universe_name,'N21');
        xlswrite('dispersion_backtest.xlsm',opti_exit,universe_name,'O21');
        opti_expret=v_expret(I);
        opti_std=v_std(I);
        opti_ntrades=v_ntrades(I);
        opti_HP=v_HP(I);
        opti_WL=v_WL(I);
        opti_Omega=v_Omega(I);
      else
        opti_exit_disp_current=NaN;
        opti_expret=NaN;
        opti_std=NaN;
        opti_ntrades=NaN;
        opti_HP=NaN;
        opti_WL=NaN;
        opti_Omega=NaN;
      end
    
      single_backtest_metrics=[opti_expret opti_std opti_ntrades opti_HP opti_WL opti_Omega];
      single_metrics=nan(1,16);
      single_metrics(1:8)=[disp_mov_col(end) z_disp_mov(end) z_disp_5d(end) z_disp(end) sea_zdisp opti_exit_disp_current z_corr(end) v_corr(end)];
      single_metrics(11:16)=single_backtest_metrics;
      full_metrics=[full_metrics;single_metrics];
      toc
    else
  % current optimization, choose best correlation
      fprintf('current optimization, choose best correlation\n')
      tic
 %have to use vector instead of matrix, because has to filter on ntrades   
      v_enter_corr=[];
      v_exit_corr=[];

%     for j=1:(itr_enter_corr+1)
      for j=6:6
        enter_corr=min_enter_corr+step_corr*(j-1);
%         for p=1:(itr_exit_corr+1)
        for p=1:1
            exit_corr=min_exit_corr+step_corr*(p-1);
            [newlong,newshort,newexit,newmetric_corr]=disp_backtest_corr(rtn_Y(corr_window:end,1),z_disp_mov(corr_window:end),enter_disp,opti_exit_disp_current,z_corr,enter_corr,exit_corr,tday1(corr_window:end)); 
            Ometrics_single_universe=[Ometrics_single_universe;newmetric_corr];
            if newmetric_corr(7)>=TH_ntrades
               count_feasible=count_feasible+1;
               v_enter=[v_enter;enter_corr];
               v_exit=[v_exit;exit_corr];
               v_expret=[v_expret;newmetric_corr(5)];
               v_std=[v_std;newmetric_corr(6)];
               v_ntrades=[v_ntrades;newmetric_corr(7)];
               v_HP=[v_HP;newmetric_corr(8)];
               v_Omega=[v_Omega;newmetric_corr(9)];
               v_WL=[v_WL;newmetric_corr(10)];
               
               clong{count_feasible,1}=newlong;
               cshort{count_feasible,1}=newshort;
               cexit{count_feasible,1}=newexit;
            end
        end
      end
    % find optimal point and Output  
      if count_feasible>=1
        optiV_corr=v_WL;
        [C_corr,I_corr]=max(optiV_corr);
        opti_enter_corr=v_enter_corr(I_corr);
        opti_exit_corr=v_exit_corr(I_corr);
        opti_long=clong{I_corr,1};
        opti_short=cshort{I_corr,1};
        opti_exit=cexit{I_corr,1};
        xlswrite('dispersion_backtest.xlsm',opti_short,universe_name,'M21');
        xlswrite('dispersion_backtest.xlsm',opti_long,universe_name,'N21');
        xlswrite('dispersion_backtest.xlsm',opti_exit,universe_name,'O21');
        opti_expret=v_expret(I_corr);
        opti_std=v_std(I_corr);
        opti_ntrades=v_ntrades(I_corr);
        opti_HP=v_HP(I_corr);
        opti_WL=v_WL(I_corr);
        opti_Omega=v_Omega(I_corr);
      else
        opti_enter_corr=NaN;
        opti_exit_corr=NaN;
        opti_expret=NaN;
        opti_std=NaN;
        opti_ntrades=NaN;
        opti_HP=NaN;
        opti_WL=NaN;
        opti_Omega=NaN;
      end
      single_backtest_metrics=[opti_expret opti_std opti_ntrades opti_HP opti_WL opti_Omega];
    
      single_metrics=nan(1,16);
      single_metrics=[disp_mov_col(end) z_disp_mov(end) z_disp_5d(end) z_disp(end) sea_zdisp opti_exit_disp_current z_corr(end) v_corr(end) opti_enter_corr opti_exit_corr single_backtest_metrics];
      full_metrics=[full_metrics;single_metrics];
      toc
    end
    %% global optimization, fix correlation
    fprintf('global optimization, fix correlation\n')
    tic
    exit_corr=1.0;
    enter_corr=-1.0;
    v_enter_gl=[];
    v_exit_gl=[];
    v_expret_gl=[];
    v_ntrades_gl=[];
    v_HP_gl=[];
    v_Omega_gl=[];
    v_WL_gl=[];
    Ometrics_gl=[];
    if z_disp_mov(end)>0
        max_enter_disp=2.50;
        min_enter_disp=0.40;
        min_exit_disp=-1;
        max_exit_disp=0;
    elseif z_disp_mov(end)<0
        min_enter_disp=-2.50;
        max_enter_disp=-0.40;
        min_exit_disp=0;
        max_exit_disp=1;
    end
    itr_enter_disp=(max_enter_disp-min_enter_disp)/step_disp;
    for j=1:(itr_enter_disp+1)
        enter_disp_gl=min_enter_disp+step_disp*(j-1);
        for p=1:(itr_exit_disp+1)
            exit_disp_gl=min_exit_disp+step_disp*(p-1);
            [~,~,~,newmetric_gl]=disp_backtest_nocorr(rtn_Y(corr_window:end,1),z_disp_mov(corr_window:end),enter_disp_gl,exit_disp_gl,tday1(corr_window:end)); 
            Ometrics_gl=[Ometrics_gl;newmetric_gl];
            v_exit_gl=[v_exit_gl;exit_disp_gl];
            v_enter_gl=[v_enter_gl;enter_disp_gl];
            v_expret_gl=[v_expret_gl;newmetric_gl(5)];
            v_ntrades_gl=[v_ntrades_gl;newmetric_gl(7)];
            v_HP_gl=[v_HP_gl;newmetric_gl(8)];
            v_Omega_gl=[v_Omega_gl;newmetric_gl(9)];
            v_WL_gl=[v_WL_gl;newmetric_gl(10)];
        end
    end
%     optiVector_gl=v_Omega_gl;
    optiVector_gl=v_WL_gl;
    [C_gl,I_gl]=max(optiVector_gl);
    opti_enter_disp_gl=v_enter_gl(I_gl);
    opti_exit_disp_gl=v_exit_gl(I_gl);
    toc
    %% global optimization, choose best correlation 
    fprintf('global optimization, choose best correlation\n')
    tic
    v_enter_glcorr=[];
    v_exit_glcorr=[];
    v_expret_glcorr=[];
    v_std_glcorr=[];
    v_ntrades_glcorr=[];
    v_HP_glcorr=[];
    v_Omega_glcorr=[];
    v_WL_glcorr=[];
    clong_gl=cell(500,1);
    cshort_gl=cell(500,1);
    cexit_gl=cell(500,1);
    Ometrics_single_universe_glcorr=[];
    count_feasible_glcorr=0;
    for j=1:(itr_enter_corr+1)
        enter_glcorr=min_enter_corr+step_corr*(j-1);
        for p=1:(itr_exit_corr+1)
            exit_glcorr=min_exit_corr+step_corr*(p-1);
            [newlong_gl,newshort_gl,newexit_gl,newmetric_glcorr]=disp_backtest_corr(rtn_Y(corr_window:end,1),z_disp_mov(corr_window:end),opti_enter_disp_gl,opti_exit_disp_gl,z_corr,enter_glcorr,exit_glcorr,tday1(corr_window:end)); 
            Ometrics_single_universe_glcorr=[Ometrics_single_universe_glcorr;newmetric_glcorr];
            if newmetric_glcorr(7)>=TH_ntrades
               count_feasible_glcorr=count_feasible_glcorr+1;
               v_enter_glcorr=[v_enter_glcorr;enter_glcorr];
               v_exit_glcorr=[v_exit_glcorr;exit_glcorr];
               v_expret_glcorr=[v_expret_glcorr;newmetric_glcorr(5)];
               v_std_glcorr=[v_std_glcorr;newmetric_glcorr(6)];
               v_ntrades_glcorr=[v_ntrades_glcorr;newmetric_glcorr(7)];
               v_HP_glcorr=[v_HP_glcorr;newmetric_glcorr(8)];
               v_Omega_glcorr=[v_Omega_glcorr;newmetric_glcorr(9)];
               v_WL_glcorr=[v_WL_glcorr;newmetric_glcorr(10)];
               
               clong_gl{count_feasible_glcorr,1}=newlong_gl;
               cshort_gl{count_feasible_glcorr,1}=newshort_gl;
               cexit_gl{count_feasible_glcorr,1}=newexit_gl;
            end
        end
    end
    
    if count_feasible_glcorr>=1
%         optiV_glcorr=v_Omega_glcorr;
        optiV_glcorr=v_WL_glcorr;
        [C_glcorr,I_glcorr]=max(optiV_glcorr);
        opti_enter_corr_gl=v_enter_glcorr(I_glcorr);
        opti_exit_corr_gl=v_exit_glcorr(I_glcorr);
        opti_long_gl=clong_gl{I_glcorr,1};
        opti_short_gl=cshort_gl{I_glcorr,1};
        opti_exit_gl=cexit_gl{I_glcorr,1};
        xlswrite('dispersion_backtest.xlsm',opti_short_gl,universe_name,'S21');
        xlswrite('dispersion_backtest.xlsm',opti_long_gl,universe_name,'T21');
        xlswrite('dispersion_backtest.xlsm',opti_exit_gl,universe_name,'U21');
        opti_expret_gl=v_expret_glcorr(I_glcorr);
        opti_std_gl=v_std_glcorr(I_glcorr);
        opti_ntrades_gl=v_ntrades_glcorr(I_glcorr);
        opti_HP_gl=v_HP_glcorr(I_glcorr);
        opti_WL_gl=v_WL_glcorr(I_glcorr);
        opti_Omega_gl=v_Omega_glcorr(I_glcorr);
    else
        opti_enter_corr_gl=NaN;
        opti_exit_corr_gl=NaN;
        opti_expret_gl=NaN;
        opti_std_gl=NaN;
        opti_ntrades_gl=NaN;
        opti_HP_gl=NaN;
        opti_WL_gl=NaN;
        opti_Omega_gl=NaN;
    end
    single_backtest_metrics_gl=[opti_expret_gl opti_std_gl opti_ntrades_gl opti_HP_gl opti_WL_gl opti_Omega_gl];
    single_metrics_gl=nan(1,16);
    single_metrics_gl(2)=opti_enter_disp_gl;
    single_metrics_gl(6)=opti_exit_disp_gl;
    single_metrics_gl(9)=opti_enter_corr_gl;
    single_metrics_gl(10)=opti_exit_corr_gl;
    single_metrics_gl(11:16)=single_backtest_metrics_gl;
    full_metrics_gl=[full_metrics_gl;single_metrics_gl];
    toc
end
% xlswrite('dispersion_backtest.xlsm',full_metrics,'list','d2');
% xlswrite('dispersion_backtest.xlsm',full_metrics_gl,'list','d15');
xlswrite('dispersion_backtest.xlsm',full_metrics,'list','d2');
xlswrite('dispersion_backtest.xlsm',full_metrics_gl,'list','d15');

% processing time ends
% Metrics2=[excel_date disp_mov_col excel_date z_disp_mov excel_date v_disp excel_date z_disp excel_date v_disp_5d excel_date z_disp_5d];
% Metrics3=[Metrics2(corr_window:end,:) v_corr,z_corr,v_corr_diff2,z_corr_diff2 z_turnover(corr_window:end,:) z_turnover_mov(corr_window:end,:) z_px(corr_window:end,:)];

% plot3(z_disp_mov(1:5),rtn_5dY(1:5,1),z_turnover_mov(1:5));
% % str_legend=strvcat('z disp mov','z rtn','z turnover');
% % legend(str_legend,'Location','NW')
% xlabel('z disp move');
% ylabel('z rtn');
% zlabel('z turnover');

% cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/dispersion');
% save (strcat('rtn_Y_',index_name), 'rtn_Y');
% save (strcat('z_px_',index_name), 'z_px');
% save (strcat('z_turnover_mov_',index_name),'z_turnover_mov');
% save (strcat('z_disp_mov_',index_name),'z_disp_mov');
% save (strcat('disp_mov_col_',index_name),'disp_mov_col');
% save (strcat('tday1_',index_name),'tday1');

csvwrite('rtn.csv',rtn_Y);