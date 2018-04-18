%% revised for Gina 06/06/2017
% only test for last day's dispersion level
clearvars;
cd('Y:/working_directory/Matlab/Data/dispersion');
% addpath(genpath('Y:/working_directory/Matlab'))
javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');
[num,txt]=xlsread('dispersion_gina_jul10','universe','c1:c1000');

%% generate Data
startdate='2014/6/1';
% enddate=today();
enddate='2017/6/6';
per={'daily','non_trading_weekdays','previous_value'};

z_window=60;
corr_window=20;
mov_window=10;

% processing time started
tic
Metrics=[];

for i=1:size(txt,2)
    temp_txt=txt(:,i);
    temp_txt=temp_txt(~cellfun('isempty',temp_txt));
    %Bloomberg Part starts
    c=blp;
    for loop=1:size(temp_txt,1)
        new=char(temp_txt(loop));
        [d1, sec] = history(c, new,'CHG_PCT_1D',startdate,enddate,per);
        [d2, sec] = history(c, new,'Last_Price',startdate,enddate,per);
        [d3, sec] = history(c, new,'CHG_PCT_5D',startdate,enddate,per);
        dates(1:size(d1,1),loop)=d1(1:size(d1,1),1);
        rtns(1:size(d1,1),loop)=d1(1:size(d1,1),2);
        prices(1:size(d2,1),loop)=d2(1:size(d2,1),2);
        rtns_5d(1:size(d3,1),loop)=d3(1:size(d3,1),2);
    end;
    close(c);
    % end of Bloomberg Part
    
%     xlswrite('dispersion_gina',dates,'dates','a2');
%     xlswrite('dispersion_gina',rtns,'rtns','a2');
%     xlswrite('dispersion_gina',prices,'prices','a2');
%     xlswrite('dispersion_gina',rtns_5d,'rtns_5d','a2');
    
    n_dim=size(rtns,2);

    tday1=dates(:, 1);
    rtn1=rtns(:, 1);
    px1=prices(:, 1);
    rtn1_5d=rtns_5d(:,1);
    
    rtn1(find(~tday1))=[];
    px1(find(~tday1))=[];
    rtn1_5d(find(~tday1))=[];
    tday1(find(~tday1))=[];
    
    for k=2:n_dim
        tday2=dates(:, k); 
        rtn2=rtns(:, k);
        px2=prices(:, k);
        rtn2_5d=rtns_5d(:, k);
        
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
    v_disp_mov=zeros(size(rtn_Y,1),1);
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
    
    %calculate 5d_dispersion
    for j=1:size(rtn_Y,1)
        temp_rtn=rtn_5dY(j,2:end);
        temp_rtn(isnan(temp_rtn))=[];
        temp_avg=mean(temp_rtn);
        temp_diff=abs(temp_rtn-repmat(temp_avg,1,size(temp_rtn,2)));
        v_disp_5d(j)=mean(temp_diff,2);
    end
    
    %calculate z-score and correlation
    z_disp=zeros(size(rtn_Y,1),1);
    z_disp_mov=zeros(size(rtn_Y,1),1);
    z_disp_5d=zeros(size(rtn_Y,1),1);
    v_corr=zeros(size(rtn_Y,1)-corr_window+1,1);
    v_corr_diff2=zeros(size(rtn_Y,1)-corr_window+1,1);
    z_px=zeros(size(rtn_Y,1),1);
    z_corr=zeros(size(rtn_Y,1)-corr_window+1,1);
    z_corr_diff2=zeros(size(rtn_Y,1)-corr_window+1,1);
    
    z_disp(1:z_window-1)=zscore(v_disp(1:z_window-1));
    z_disp_mov(1:z_window-1)=zscore(disp_col(1:z_window-1));
    z_disp_5d(1:z_window-1)=zscore(v_disp_5d(1:z_window-1));
    z_px(1:z_window-1)=zscore(px_Y(1:z_window-1,1));
    
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
    
    for j=z_window:size(rtn_Y,1)
        tempz=zscore(px_Y(j-z_window+1:j,1));
        z_px(j)=tempz(end);
    end
    
%% backtesting
    enter_disp=z_disp_mov(end);
    min_exit=-1;
    max_exit=0;
    if enter_disp>0
        min_exit=-1;
        max_exit=0;
    elseif enter_disp<0
        min_exit=0;
        max_exit=1;
    end
    
    step=0.1;
    itr_exit=(max_exit-min_exit)/step;
    
    exit_corr=0.4;
    enter_corr=-0.1;
    
    mat_ret=[];
    Ometrics=[];
    for j=1:(itr_exit+1)
        exit_disp=min_exit+step*(j-1);
        newmetric=backtest(rtn_Y(corr_window:end,1),z_disp_mov(corr_window:end),enter_disp,exit_disp,v_corr,enter_corr,exit_corr,tday1(corr_window:end)); 
        mat_ret=[mat_ret;newmetric(5)];
        Ometrics=[Ometrics;newmetric];        
    end
    [C,I]=max(mat_ret);
    opti_disp_exit=min_exit+step*(I-1);
    opti_metric=Ometrics(I,:);
    opti_metric=[disp_col(end) z_disp_mov(end) z_disp_5d(end) z_disp(end) opti_disp_exit v_corr_diff2(end) z_corr_diff2(end) v_corr(end) z_corr(end) opti_metric];
    Metrics=[Metrics;opti_metric];
    
end
toc
% processing time ends
%% Plotting and Output
% str_dates=datestr(tday1);
% str_legend=strvcat('z disp mov','z px');
% c_dates=cellstr(str_dates);
% secname=[char(txt(1)) ' Dispersion'];
% ts1=timeseries([z_disp_mov(end-260:end) z_px(end-260:end)],c_dates(end-260:end),'name',secname);
% ts1.TimeInfo.StartDate=str_dates(1,:); %must be string
% ts1.TimeInfo.Format='mmm yy';
% plot(ts1,'LineWidth',2)
% legend(str_legend,'Location','NW')
% title([secname, ' Dispersion'])
% xlabel('Date')
% ylabel('z_score')
% axis tight
% grid on
% 
Metrics2=[excel_date disp_col excel_date z_disp_mov excel_date v_disp excel_date z_disp excel_date v_disp_5d excel_date z_disp_5d];
Metrics3=[Metrics2(corr_window:end,:) v_corr,z_corr,v_corr_diff2,z_corr_diff2];
% xlswrite('dispersion_gina',Metrics3,'output','a2');