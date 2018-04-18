%% TODO: How to generate BAddPeriods in Bloomberg
function calculate_dispersion_v5_add_volume(input_range,index_name)
% only test for last day's dispersion level
% clearvars;
javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');
% [num,txt]=xlsread('dispersion_matlab_v1','universe','c1:c1000');%OEX
[~,txt]=xlsread('dispersion_matlab_v1','universe',input_range);%NKY
% [num,txt]=xlsread('dispersion_matlab_v1','universe','e1:e1000');%HSI
% [num,txt]=xlsread('dispersion_matlab_v1','universe','f1:f1000');%HSCEI
% [num,txt]=xlsread('dispersion_matlab_v1','universe','g1:g1000');%SHCSI100
% [num,txt]=xlsread('dispersion_matlab_v1','universe','h1:h1000');%KOSPI2
% [num,txt]=xlsread('dispersion_matlab_v1','universe','i1:i1000');%TAMSCI
% [num,txt]=xlsread('dispersion_matlab_v1','universe','j1:j1000');%E100
%% generate Data
startdate='2013/2/26';
enddate=today();
% enddate='2017/6/6';
per={'daily','non_trading_weekdays','previous_value'};
fields={'CHG_PCT_1D','Last_Price','CHG_PCT_5D','TURNOVER'};

z_window=60;
corr_window=20;
mov_window=5;

% processing time started
tic
Metrics_full_universe=[];
n_universe=size(txt,2);
clong={n_universe,100};
cshort={n_universe,100};
cexit={n_universe,100};
opti_long=zeros(n_universe,1);
opti_short=zeros(n_universe,1);
opti_exit=zeros(n_universe,1);
%backtesting parameter
step_disp=0.1;
step_corr=0.2;

for i=1:n_universe
    temp_txt=txt(:,i);
    temp_txt=temp_txt(~cellfun('isempty',temp_txt));
    %Bloomberg Part starts
    c=blp;
    for loop=1:size(temp_txt,1)
        new=char(temp_txt(loop));
%         [d1, sec] = history(c, new,'CHG_PCT_1D',startdate,enddate,per);
%         [d2, sec] = history(c, new,'Last_Price',startdate,enddate,per);
%         [d3, sec] = history(c, new,'CHG_PCT_5D',startdate,enddate,per);
%         [d4, sec] = history(c, new,'TURNOVER',startdate,enddate,per);
        [d, sec] = history(c, new,fields,startdate,enddate,per);
        dates(1:size(d,1),loop)=d(1:size(d,1),1);
        rtns(1:size(d,1),loop)=d(1:size(d,1),2);
        prices(1:size(d,1),loop)=d(1:size(d,1),3);
        rtns_5d(1:size(d,1),loop)=d(1:size(d,1),4);
        turnovers(1:size(d,1),loop)=d(1:size(d,1),5);
    end;
    close(c);
    % end of Bloomberg Part    
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
    disp_row=tsmovavg(disp_row,'e',mov_window);
    disp_row=[reshape(v_disp(1:(mov_window-1)),1,(mov_window-1)) disp_row(mov_window:end)];
    disp_col=reshape(disp_row,size(disp_row,2),1);
    
    %calculate 5d_moving average turnover
    turnover_row=reshape(turnover_Y(:,1),1,size(rtn_Y,1));
    turnover_row=tsmovavg(turnover_row,'e',mov_window);
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
    z_disp_mov(1:z_window-1)=zscore(disp_col(1:z_window-1));
    z_disp_5d(1:z_window-1)=zscore(v_disp_5d(1:z_window-1));
    z_px(1:z_window-1)=zscore(px_Y(1:z_window-1,1));
    z_turnover(1:z_window-1)=zscore(turnover_Y(1:z_window-1,1));
    z_turnover_mov(1:z_window-1)=zscore(turnover_mov(1:z_window-1,1));
    
    for j=corr_window:size(rtn_Y,1)
        v_corr(j-corr_window+1)=corr(disp_col(j-corr_window+1:j),px_Y(j-corr_window+1:j,1));
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
        tempz=zscore(disp_col(j-z_window+1:j));
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
    
%% backtesting
    enter_disp=z_disp_mov(end);
    if enter_disp>0
        min_exit_disp=-1;
        max_exit_disp=0;
    elseif enter_disp<0
        min_exit_disp=0;
        max_exit_disp=1;
    end
    itr_exit=(max_exit_disp-min_exit_disp)/step_disp;
    
    exit_corr=0.4;
    enter_corr=-0.1;
    
    mat_ret=[];
    Ometrics_single_universe=[];
%     for j=1:(itr_exit+1)
%         exit_disp=min_exit+step*(j-1);
%         [clong{i,j},cshort{i,j},cexit{i,j},newmetric]=disp_backtest_v2(rtn_Y(corr_window:end,1),z_disp_mov(corr_window:end),enter_disp,exit_disp,v_corr,enter_corr,exit_corr,tday1(corr_window:end)); 
%         mat_ret=[mat_ret;newmetric(5)];
%         Ometrics_single_universe=[Ometrics_single_universe;newmetric];
%     end
%     [C,I]=max(mat_ret);
%     opti_disp_exit=min_exit+step*(I-1);
%     opti_long(i)=clong{i,I};
%     opti_short(i)=cshort{i,I};
%     opti_exit(i)=cexit{i,I};
%     opti_metric1=Ometrics_single_universe(I,:);
%     opti_metric2=[disp_col(end) z_disp_mov(end) z_disp_5d(end) z_disp(end) opti_disp_exit v_corr_diff2(end) z_corr_diff2(end) v_corr(end) z_corr(end) opti_metric1(3:end)];
%     Metrics_full_universe=[Metrics_full_universe;opti_metric2];
    
end
toc
% processing time ends
% Metrics2=[excel_date disp_col excel_date z_disp_mov excel_date v_disp excel_date z_disp excel_date v_disp_5d excel_date z_disp_5d];
% Metrics3=[Metrics2(corr_window:end,:) v_corr,z_corr,v_corr_diff2,z_corr_diff2 z_turnover(corr_window:end,:) z_turnover_mov(corr_window:end,:) z_px(corr_window:end,:)];

% plot3(z_disp_mov(1:5),rtn_5dY(1:5,1),z_turnover_mov(1:5));
% % str_legend=strvcat('z disp mov','z rtn','z turnover');
% % legend(str_legend,'Location','NW')
% xlabel('z disp move');
% ylabel('z rtn');
% zlabel('z turnover');
cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/dispersion');
save (strcat('rtn_Y_',index_name), 'rtn_Y');
save (strcat('z_px_',index_name), 'z_px');
save (strcat('z_turnover_mov_',index_name),'z_turnover_mov');
save (strcat('z_disp_mov_',index_name),'z_disp_mov');
save (strcat('disp_col_',index_name),'disp_col');
save (strcat('tday1_',index_name),'tday1');