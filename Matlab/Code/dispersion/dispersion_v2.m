% cross-sectional disperion to time series variance mean reverting
% back-testing
clear all;
cd('C:\Users\ychen\Documents\MATLAB');
[num,txt]=xlsread('dispersion matlab','Universe','c1:c1000');

javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar')

%% generate Data
% list1={'HSCI Index';'HSCICG Index';'HSCICO Index';'HSCIEN Index';'HSCIFN Index'};
% list2={'TPX Index';'TP17BNK Index';'TP17TPEQ Index';'TP17ITSV Index';'TP17ELPR Index';'TP17REAL Index'};
% range={list1,list2};
startdate='2012/11/14';
enddate=today();
per={'daily','non_trading_weekdays','previous_value'};

window=60;

method='engle';
N=10;
Signal_TH=1.5;
pADF_TH=0.20;
hp_TH=44;

tic
Metrics=[];

for i=1:size(txt,2)
    temp_txt=txt(:,i);
    temp_txt=temp_txt(~cellfun('isempty',temp_txt));
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
    disp_row=tsmovavg(disp_row,'e',5);
    disp_row=[reshape(v_disp(1:4),1,4) disp_row(5:end)];
    disp_col=reshape(disp_row,size(disp_row,2),1);
    
    %calculate 5d_dispersion
    for j=1:size(rtn_Y,1)
        temp_rtn=rtn_5dY(j,2:end);
        temp_rtn(isnan(temp_rtn))=[];
        temp_avg=mean(temp_rtn);
        temp_diff=abs(temp_rtn-repmat(temp_avg,1,size(temp_rtn,2)));
        v_disp_5d(j)=mean(temp_diff,2);
    end
    
    v_var=zeros(size(rtn_Y,1)-window+1,1);
    z_px=zeros(size(rtn_Y,1),1);
    z_px(1:window-1)=zscore(px_Y(1:window-1,1));
    
    for j=window:size(rtn_Y,1)
        v_var(j-window+1)=var(rtn_Y(j-window+1:j));
        tempz=zscore(px_Y(j-window+1:j,1));
        z_px(j)=tempz(end);
    end
    
    coint_Y=[v_var disp_col(window:end)];
    
    [metric_e,adf_e,z_res_e]=copair_test(method,coint_Y,window,N,Signal_TH,pADF_TH,hp_TH,tday1(window:end));
end
toc

v_spread=disp_col(window:end)-v_var;
z_spread=zeros(size(v_spread,1),1);
z_spread(1:window-1)=zscore(v_spread(1:window-1,1));


for j=window:size(v_spread,1)
    tempz=zscore(v_spread(j-window+1:j,1));
    z_spread(j)=tempz(end);
end

z_disp_mov=zeros(size(rtn_Y,1),1);
z_disp_mov(1:window-1)=zscore(disp_col(1:window-1));
for j=window:size(rtn_Y,1)
    tempz=zscore(disp_col(j-window+1:j));
    z_disp(j)=tempz(end);    
end

str_dates=datestr(tday1(window:end));
c_dates=cellstr(str_dates);
secname=[char(txt(1)) ' Dispersion'];
ts1=timeseries(z_disp(window:end),c_dates,'name',secname);
ts1.TimeInfo.StartDate=str_dates(1,:); %must be string
ts1.TimeInfo.Format='mmm yy';
COrd = get(gca,'ColorOrder');
plot(ts1,'LineWidth',2,'Color',COrd(4,:))

ts2=timeseries(z_px(window:end,1),c_dates,'name',secname);
ts2.TimeInfo.StartDate=str_dates(1,:); %must be string
ts2.TimeInfo.Format='mmm yy';
hold on
plot(ts2,'LineWidth',2,'Color',COrd(5,:))
legend('Dispersion','Price','Location','NW')

title([secname, ' Cointegrating Relation'])
xlabel('Time')
ylabel('z_residual')
axis tight
grid on