
clear all;
cd('C:\Users\ychen\Documents\MATLAB');
[num,txt]=xlsread('dispersion matlab','Universe','d1:d1000');

javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar')

%% generate Data
% list1={'HSCI Index';'HSCICG Index';'HSCICO Index';'HSCIEN Index';'HSCIFN Index'};
% list2={'TPX Index';'TP17BNK Index';'TP17TPEQ Index';'TP17ITSV Index';'TP17ELPR Index';'TP17REAL Index'};
% range={list1,list2};
startdate='2011/2/7';
enddate=today();
per={'daily','non_trading_weekdays','previous_value'};

z_window=60;
corr_window=20;
mov_window=5;

% last_zdisp=zeros(1,size(txt,2));
% last_corr=zeros(1,size(txt,2));
% v_avgret=zeros(1,size(txt,2));
% v_trades=zeros(1,size(txt,2));
% v_hp=zeros(1,size(txt,2));

method='engle';
N=10;

pADF_TH=0.40;
hp_TH=44;

tic
Metrics=[];

for i=1:size(txt,2)
    temp_txt=txt(:,i);
    temp_txt=temp_txt(~cellfun('isempty',temp_txt));
    c=blp;
    for loop=1:size(temp_txt,1)
        new=char(temp_txt(loop));
        [d1, sec] = history(c, new,'Last_Price',startdate,enddate,per);
        [d2, sec] = history(c, new,'PX_HIGH',startdate,enddate,per);
        [d3, sec] = history(c, new,'PX_LOW',startdate,enddate,per);
        dates(1:size(d1,1),loop)=d1(1:size(d1,1),1);
        prices(1:size(d1,1),loop)=d1(1:size(d1,1),2);
        highs(1:size(d2,1),loop)=d2(1:size(d2,1),2);
        lows(1:size(d3,1),loop)=d3(1:size(d3,1),2);
    end;
    close(c);

    n_dim=size(dates,2);

    tday1=dates(:, 1);
    px1=prices(:, 1);
    hi1=highs(:, 1);
    lo1=lows(:,1);
    
%     tday1(isnan(px1))=[];
%     rtn1(isnan(px1))=[];
%     rtn1_5d(isnan(px1))=[];
%     px1(isnan(px1))=[];
    px1(find(~tday1))=[];
    hi1(find(~tday1))=[];
    lo1(find(~tday1))=[];
    tday1(find(~tday1))=[];
    
    for k=2:n_dim
        tday2=dates(:, k); 
        px2=prices(:, k);
        hi2=highs(:, k);        
        lo2=lows(:, k);
        
        px2(find(~tday2))=[];
        hi2(find(~tday2))=[];
        lo2(find(~tday2))=[];
        tday2(find(~tday2))=[];
        
        [n1n2, idx1, idx2]=intersect(tday1, tday2);
        tday1=tday1(idx1);
        
        px1=[px1(idx1,:) px2(idx2)];
        hi1=[hi1(idx1,:) hi2(idx2)];
        lo1=[lo1(idx1,:) lo2(idx2)];
        
    end
    
    px_Y=px1;
    hi_Y=hi1;    
    lo_Y=lo1;
    
    excel_date=m2xdate(tday1,0);

    %% Calculate Dispersion
    v_disp=zeros(size(hi_Y,1),1);
    v_disp_mov=zeros(size(hi_Y,1),1);
    range_Y=hi_Y./lo_Y;
    for j=1:size(hi_Y,1)
        temp_rg=range_Y(j,2:end);
        temp_rg(isnan(temp_rg))=[];
        temp_avg=mean(temp_rg);
        temp_diff=abs(temp_rg-repmat(temp_avg,1,size(temp_rg,2)));
        v_disp(j)=mean(temp_diff,2);
    end
    
    %calculate 5d_moving average
    disp_row=reshape(v_disp,1,size(hi_Y,1));
    disp_row=tsmovavg(disp_row,'e',mov_window);
    disp_row=[reshape(v_disp(1:4),1,4) disp_row(5:end)];
    disp_col=reshape(disp_row,size(disp_row,2),1);
    
    %calculate z-score and correlation
    z_disp=zeros(size(hi_Y,1),1);
    z_disp_mov=zeros(size(hi_Y,1),1);
    
    v_corr=zeros(size(hi_Y,1)-corr_window+1,1);
    v_corr_diff2=zeros(size(hi_Y,1)-corr_window+1,1);
    z_px=zeros(size(hi_Y,1),1);
    z_corr=zeros(size(hi_Y,1)-corr_window+1,1);
    z_corr_diff2=zeros(size(hi_Y,1)-corr_window+1,1);
    
    z_disp(1:z_window-1)=zscore(v_disp(1:z_window-1));
    z_disp_mov(1:z_window-1)=zscore(disp_col(1:z_window-1));
    z_px(1:z_window-1)=zscore(px_Y(1:z_window-1,1));
    
    for j=corr_window:size(hi_Y,1)
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
    
    
    for j=z_window:size(hi_Y,1)
        tempz=zscore(v_disp(j-z_window+1:j));
        z_disp(j)=tempz(end);
    end
    
    for j=z_window:size(hi_Y,1)
        tempz=zscore(disp_col(j-z_window+1:j));
        z_disp_mov(j)=tempz(end);
    end
    
    sea_zdispmov=(z_disp_mov(end-261)+z_disp_mov(end-261*2)+z_disp_mov(end-261*3)+z_disp_mov(end-261*4))/4;
    
    for j=z_window:size(hi_Y,1)
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
        newmetric=backtest(hi_Y(corr_window:end,1),z_disp_mov(corr_window:end),enter_disp,exit_disp,v_corr,enter_corr,exit_corr,tday1); 
        mat_ret=[mat_ret;newmetric(1)];
        Ometrics=[Ometrics;newmetric];
        [C,I]=max(mat_ret);
    end
    opti_disp_exit=min_exit+step*(I-1);
    opti_metric=Ometrics(I,:);
    opti_metric=[disp_col(end) z_disp_mov(end) z_disp_5d(end) z_disp(end) sea_zdispmov opti_disp_exit v_corr_diff2(end) z_corr_diff2(end) v_corr(end) z_corr(end) opti_metric];
    Metrics=[Metrics;opti_metric];
    
end
toc

str_dates=datestr(tday1);
str_legend=strvcat('z disp mov','z px');
c_dates=cellstr(str_dates);
secname=[char(txt(1)) ' Dispersion'];
% ts1=timeseries([z_disp_mov(corr_window:end) v_corr_diff2],c_dates(corr_window:end),'name',secname);
ts1=timeseries([z_disp_mov(end-260:end) z_px(end-260:end)],c_dates(end-260:end),'name',secname);
ts1.TimeInfo.StartDate=str_dates(1,:); %must be string
ts1.TimeInfo.Format='mmm yy';
plot(ts1,'LineWidth',2)
legend(str_legend,'Location','NW')
% legend(char(txt(1)),'Location','NW')
title([secname, ' Dispersion'])
xlabel('Date')
ylabel('z_score')
axis tight
grid on
% 
% 
% Metrics2=[excel_date disp_col excel_date z_disp_mov excel_date v_disp excel_date z_disp];
% xlswrite('dispersion matlab',Metrics2,'upload','a2');