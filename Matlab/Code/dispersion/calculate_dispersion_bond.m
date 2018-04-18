
clear all;
cd('C:\Users\ychen\Documents\MATLAB');
[num,txt]=xlsread('dispersion matlab','Universe','ab1:ab1000');

javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar')

%% generate Data
% list1={'HSCI Index';'HSCICG Index';'HSCICO Index';'HSCIEN Index';'HSCIFN Index'};
% list2={'TPX Index';'TP17BNK Index';'TP17TPEQ Index';'TP17ITSV Index';'TP17ELPR Index';'TP17REAL Index'};
% range={list1,list2};
startdate='2012/11/14';
enddate=today();
per={'daily','non_trading_weekdays','previous_value'};

window=60;

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
        [d1, sec] = history(c, new,'PX_LAST',startdate,enddate,per);
        dates(1:size(d1,1),loop)=d1(1:size(d1,1),1);
        prices(1:size(d1,1),loop)=d1(1:size(d1,1),2);
        
    end;
    close(c);
    n_dim=size(prices,2);
    tday1=dates(:, 1);
    px1=prices(:, 1);
    
    tday1(isnan(px1))=[];
    px1(isnan(px1))=[];
    
    px1(find(~tday1))=[];
    tday1(find(~tday1))=[];
    
    for k=2:n_dim
        tday2=dates(:, k); 
        px2=prices(:, k);
        
        tday2(isnan(px2))=[];
        px2(isnan(px2))=[];
        
        px2(find(~tday2))=[];
        tday2(find(~tday2))=[];
        [n1n2, idx1, idx2]=intersect(tday1, tday2);
        tday1=tday1(idx1);
        px1=[px1(idx1,:) px2(idx2)];
    end
    
    px_Y=px1;
    chg_Y=diff(px1);
    
    rtn_row=reshape(chg_Y,size(chg_Y,2),size(chg_Y,1));
    temp_mov=tsmovavg(rtn_row,'e',5);
    row_chg_5dY=5*[rtn_row(:,1:4) temp_mov(:,5:end)];
    chg_5dY=transpose(row_chg_5dY);
    
    excel_date=m2xdate(tday1(2:end),0);

    %% Calculate Dispersion
    v_disp=zeros(size(chg_Y,1),1);
    v_disp_mov=zeros(size(chg_Y,1),1);
    v_disp_5d=zeros(size(chg_Y,1),1);
    for j=1:size(chg_Y,1)
        temp_rtn=chg_Y(j,2:end);
        temp_rtn(isnan(temp_rtn))=[];
        temp_avg=mean(temp_rtn);
        temp_diff=abs(temp_rtn-repmat(temp_avg,1,size(temp_rtn,2)));
        v_disp(j)=mean(temp_diff,2);
    end
    
    
    %calculate 5d_moving average
    disp_row=reshape(v_disp,1,size(chg_Y,1));
    disp_row=tsmovavg(disp_row,'e',5);
    disp_row=[reshape(v_disp(1:4),1,4) disp_row(5:end)];
    disp_col=reshape(disp_row,size(disp_row,2),1);
    
    %calculate 5d_dispersion
    for j=1:size(chg_Y,1)
        temp_rtn=chg_5dY(j,2:end);
        temp_rtn(isnan(temp_rtn))=[];
        temp_avg=mean(temp_rtn);
        temp_diff=abs(temp_rtn-repmat(temp_avg,1,size(temp_rtn,2)));
        v_disp_5d(j)=mean(temp_diff,2);
    end
    
    %calculate z-score and correlation
    z_disp=zeros(size(chg_Y,1),1);
    z_disp_mov=zeros(size(chg_Y,1),1);
    z_disp_5d=zeros(size(chg_Y,1),1);
    v_corr=zeros(size(chg_Y,1),1);
    z_px=zeros(size(chg_Y,1),1);
    
    z_disp(1:window-1)=zscore(v_disp(1:window-1));
    z_disp_mov(1:window-1)=zscore(disp_col(1:window-1));
    z_disp_5d(1:window-1)=zscore(v_disp_5d(1:window-1));
    z_px(1:window-1)=zscore(px_Y(1:window-1,1));
    v_corr(1:window-1)=repmat(100,window-1,1);
    
    for j=window:size(chg_Y,1)
        tempz=zscore(v_disp(j-window+1:j));
        z_disp(j)=tempz(end);
        v_corr(j)=corr(v_disp(j-window+1:j),px_Y(j-window+1:j,1));
    end
    
    for j=window:size(chg_Y,1)
        tempz=zscore(disp_col(j-window+1:j));
        z_disp_mov(j)=tempz(end);
    end
    
    for j=window:size(chg_Y,1)
        tempz=zscore(v_disp_5d(j-window+1:j));
        z_disp_5d(j)=tempz(end);
    end
    
    for j=window:size(chg_Y,1)
        tempz=zscore(px_Y(j-window+1:j,1));
        z_px(j)=tempz(end);
    end
    
    
end

str_dates=datestr(tday1(2:end));
str_legend=strvcat('z disp mov','z px');
c_dates=cellstr(str_dates);
secname=char(txt(1));
ts1=timeseries([z_disp_mov z_px],c_dates,'name',secname);
ts1.TimeInfo.StartDate=str_dates(1,:); %must be string
ts1.TimeInfo.Format='mmm yy';
plot(ts1,'LineWidth',2)
legend(str_legend,'Location','NW')
title([secname, ' High Yield Dispersion'])
xlabel('Date')
ylabel('z_score')
axis tight
grid on
