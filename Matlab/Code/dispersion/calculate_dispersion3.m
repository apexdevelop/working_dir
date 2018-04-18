
clear all;
cd('C:\Users\ychen\Documents\MATLAB');
[num,txt]=xlsread('dispersion matlab','Universe','c1:c1000');

javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.8.8.2\lib\blpapi3.jar');

%% generate Data
% list1={'HSCI Index';'HSCICG Index';'HSCICO Index';'HSCIEN Index';'HSCIFN Index'};
% list2={'TPX Index';'TP17BNK Index';'TP17TPEQ Index';'TP17ITSV Index';'TP17ELPR Index';'TP17REAL Index'};
% range={list1,list2};
startdate='2011/3/8';
enddate=today();
per={'daily','non_trading_weekdays','previous_value'};

z_window=60;
corr_window=20;
mov_window=5;
filter_factor=0.25;
mode='ascend';
% mode='descend';

% last_zdisp=zeros(1,size(txt,2));
% last_corr=zeros(1,size(txt,2));
% v_avgret=zeros(1,size(txt,2));
% v_trades=zeros(1,size(txt,2));
% v_hp=zeros(1,size(txt,2));

tic
g_Metrics=[];
c_Metrics=[];

for i=1:size(txt,2)
    temp_txt=txt(:,i);
    temp_txt=temp_txt(~cellfun('isempty',temp_txt));
    c=blp;
    for loop=1:size(temp_txt,1)
        new=char(temp_txt(loop));
        [d1, sec] = history(c, new,'CHG_PCT_1D',startdate,enddate,per);
        [d2, sec] = history(c, new,'Last_Price',startdate,enddate,per);
        [d3, sec] = history(c, new,'CHG_PCT_5D',startdate,enddate,per);
        [d4, sec] = history(c, new,'PX_VOLUME',startdate,enddate,per);
        dates(1:size(d1,1),loop)=d1(1:size(d1,1),1);
        rtns(1:size(d1,1),loop)=d1(1:size(d1,1),2);
        prices(1:size(d2,1),loop)=d2(1:size(d2,1),2);
        rtns_5d(1:size(d3,1),loop)=d3(1:size(d3,1),2);
        volumes(1:size(d4,1),loop)=d4(1:size(d4,1),2);
    end;
    close(c);

    n_dim=size(rtns,2);

    tday1=dates(:, 1);
    rtn1=rtns(:, 1);
    px1=prices(:, 1);
    rtn1_5d=rtns_5d(:,1);
    volume1=volumes(:,1);
%     tday1(isnan(px1))=[];
%     rtn1(isnan(px1))=[];
%     rtn1_5d(isnan(px1))=[];
%     px1(isnan(px1))=[];
    
    rtn1(find(~tday1))=[];
    px1(find(~tday1))=[];
    rtn1_5d(find(~tday1))=[];
    volume1(find(~tday1))=[];
    tday1(find(~tday1))=[];    
    
    for k=2:n_dim
        tday2=dates(:, k); 
        rtn2=rtns(:, k);
        px2=prices(:, k);
        rtn2_5d=rtns_5d(:, k);
        volume2=volumes(:,k);
        
        rtn2(find(~tday2))=[];
        px2(find(~tday2))=[];
        rtn2_5d(find(~tday2))=[];
        volume2(find(~tday2))=[];
        tday2(find(~tday2))=[];
        
        [n1n2, idx1, idx2]=intersect(tday1, tday2);
        tday1=tday1(idx1);
        
        rtn1=[rtn1(idx1,:) rtn2(idx2)];
        px1=[px1(idx1,:) px2(idx2)];
        rtn1_5d=[rtn1_5d(idx1,:) rtn2_5d(idx2)];
        volume1=[volume1(idx1,:) volume2(idx2)];
    end
    
    rtn_Y=rtn1;
    px_Y=px1;
    rtn_5dY=rtn1_5d;
    volume_Y=volume1;
    
    excel_date=m2xdate(tday1,0);
%% Calculate zscore for px and volume
    z_rtn=zeros(size(rtn_Y,1),size(rtn_Y,2));
    z_px=zeros(size(rtn_Y,1),size(rtn_Y,2));
    z_volume=zeros(size(rtn_Y,1),size(rtn_Y,2));
    z_rtn(1:z_window-1,:)=zscore(rtn_Y(1:z_window-1,:));
    z_px(1:z_window-1,:)=zscore(px_Y(1:z_window-1,:));
    z_volume(1:z_window-1,:)=zscore(volume_Y(1:z_window-1,:));
    
    for j=z_window:size(rtn_Y,1)
        tempz0=zscore(rtn_Y(j-z_window+1:j,:));
        tempz1=zscore(px_Y(j-z_window+1:j,:));
        tempz2=zscore(volume_Y(j-z_window+1:j,:));
        z_rtn(j,:)=tempz0(end,:);
        z_px(j,:)=tempz1(end,:);
        z_volume(j,:)=tempz2(end,:);
    end
    
    %% Calculate Dispersion
    v_disp=zeros(size(rtn_Y,1),1);
    v_disp_mov=zeros(size(rtn_Y,1),1);
    v_disp_5d=zeros(size(rtn_Y,1),1);
    for j=1:size(rtn_Y,1)
        temp_rtn=rtn_Y(j,2:end);
        temp_zvolume=z_volume(j,2:end);
        temp_zvolume(isnan(temp_rtn))=[];
        temp_rtn(isnan(temp_rtn))=[];
        [B,IX]=sort(temp_zvolume,mode);
        n_top_vol=round(size(IX,2)*filter_factor);
%         temp_rtn(IX(1:n_top_vol))=[]; %remove top or bottom
%         temp_rtn(IX(n_top_vol+1:end-n_top_vol+1))=[]; % remove middle
        temp_rtn=temp_rtn(IX(n_top_vol+1:end-n_top_vol+1)); %keep middle
        temp_avg=mean(temp_rtn);
        temp_diff=abs(temp_rtn-repmat(temp_avg,1,size(temp_rtn,2)));
        v_disp(j)=mean(temp_diff,2);
    end
    
    %calculate moving average
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
    
    z_corr=zeros(size(rtn_Y,1)-corr_window+1,1);
    z_corr_diff2=zeros(size(rtn_Y,1)-corr_window+1,1);
    
    z_disp(1:z_window-1)=zscore(v_disp(1:z_window-1));
    z_disp_mov(1:z_window-1)=zscore(disp_col(1:z_window-1));
    z_disp_5d(1:z_window-1)=zscore(v_disp_5d(1:z_window-1));
    
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
    
    sea_zdispmov=(z_disp_mov(end-261)+z_disp_mov(end-261*2)+z_disp_mov(end-261*3)+z_disp_mov(end-261*4))/4;
    
    for j=z_window:size(rtn_Y,1)
        tempz=zscore(v_disp_5d(j-z_window+1:j));
        z_disp_5d(j)=tempz(end);
    end
    

    
%% backtesting
    last_disp=z_disp_mov(end);
%     last_disp=1;
    if last_disp>0
        min_enter=1;
        max_enter=2.5;
        min_exit=-1;
        max_exit=0;
    elseif last_disp<0
        min_enter=-2.5;
        max_enter=-1;
        min_exit=0;
        max_exit=1;
    end
    
    step=0.1;
    itr_exit=(max_exit-min_exit)/step;
    itr_enter=(max_enter-min_enter)/step;
    
    min_corr_enter=-0.8;
    max_corr_enter=-0.1;
    
    min_corr_exit=0.1;
    max_corr_exit=0.8;
    
    itr_corr=(max_corr_exit-min_corr_exit)/step;
    
    g_mat_winp=[];
    g_Ometrics=[];
    for i1=1:(itr_enter+1)
        enter_disp=min_enter+step*(i1-1);
    for j=1:(itr_exit+1)
        exit_disp=min_exit+step*(j-1);
        for p=1:(itr_corr+1)
            enter_corr=min_corr_enter+step*(p-1);
            for q=1:(itr_corr+1)
                exit_corr=min_corr_exit+step*(q-1);
                newmetric=backtest(rtn_Y(corr_window:end,1),z_disp_mov(corr_window:end),enter_disp,exit_disp,z_corr,enter_corr,exit_corr,tday1); 
                if newmetric(7)>=4
                g_mat_winp=[g_mat_winp;newmetric(9)];
                g_Ometrics=[g_Ometrics;newmetric];
                end
            end
        end
    end
    end
    [g_C,g_I]=max(g_mat_winp);
    g_metric=g_Ometrics(g_I,:);
    g_Metrics=[g_Metrics;g_metric];
    
    g_corr_enter=g_Ometrics(g_I,3);
    g_corr_exit=g_Ometrics(g_I,4);
    
    enter_disp=last_disp;
    c_mat_winp=[];
    c_Ometrics=[];
    for j1=1:(itr_exit+1)
        exit_disp=min_exit+step*(j1-1);
        for p=1:(itr_corr+1)
            enter_corr=min_corr_enter+step*(p-1);
            for q=1:(itr_corr+1)
                exit_corr=min_corr_exit+step*(q-1);
                newmetric2=backtest(rtn_Y(corr_window:end,1),z_disp_mov(corr_window:end),enter_disp,exit_disp,z_corr,enter_corr,exit_corr,tday1); 
                c_mat_winp=[c_mat_winp;newmetric2(9)];
                c_Ometrics=[c_Ometrics;newmetric2];
            end
        end
    end
    [c_C,c_I]=max(c_mat_winp);
    c_metric=c_Ometrics(c_I,:);
    c_metric=[disp_col(end) z_disp_mov(end) z_disp_5d(end) z_disp(end) sea_zdispmov v_corr_diff2(end) z_corr_diff2(end) v_corr(end) z_corr(end) c_metric];
    c_Metrics=[c_Metrics;c_metric];
    
end
toc

% str_dates=datestr(tday1);
% str_legend=strvcat('z disp mov','z px');
% c_dates=cellstr(str_dates);
% secname=char(txt(1));
% % secname=[char(txt(1)) ' Dispersion'];
% ts1=timeseries([z_disp_mov(end-260:end) z_px(end-260:end,1)],c_dates(end-260:end),'name',secname);
% ts1.TimeInfo.StartDate=str_dates(1,:); %must be string
% ts1.TimeInfo.Format='mmm yy';
% plot(ts1,'LineWidth',2)
% legend(str_legend,'Location','NW')
% title([secname, ' Dispersion'])
% xlabel('Date')
% ylabel('z_score')
% axis tight
% grid on

% Metrics2=[excel_date disp_col z_disp_mov v_disp z_disp v_disp_5d z_disp_5d];
% Metrics3=[Metrics2(corr_window:end,:) v_corr,z_corr,v_corr_diff2,z_corr_diff2];