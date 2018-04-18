
clear all;
cd('X:\Yan\Model 2.1');
[num,txt]=xlsread('Elasticity','list','a2:c1000');
javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar')

%% generate Data
startdate='2012/02/14';
enddate=today();
per={'daily','non_trading_weekdays','nil_value'};
window=30;

cd('C:\Users\ychen\Documents\MATLAB');
tic

    temp_txt=txt(:,1);
    c=blp;
    for loop=1:size(temp_txt,1)
        new=char(temp_txt(loop));
        [d1, sec1] = history(c, new,'3MO_CALL_IMP_VOL',startdate,enddate,per);
        [d2, sec2] = history(c, new,'Last_Price',startdate,enddate,per);
        dates(1:size(d1,1),loop)=d1(1:size(d1,1),1);
        vols(1:size(d1,1),loop)=d1(1:size(d1,1),2);
        prices(1:size(d2,1),loop)=d2(1:size(d2,1),2);
    end;
    close(c);
    %% Calculate Elasticity    
    component_vol=[];
    index_vol=vols(:,1);
    v_idx=zeros(size(vols,1),1);
    
    for j=1:size(vols,1)
        temp_vol=vols(j,2:end);
        temp_vol(isnan(temp_vol))=[];
        if ~isempty(temp_vol)
            component_vol=[component_vol;mean(temp_vol)];
        else
            v_idx(j)=1;
        end
    end
    v_idx=logical(v_idx);
    index_vol(v_idx)=[];
    v_spread=component_vol-index_vol;
    
    tday1=dates(:,1);
    tday1(v_idx)=[];
    excel_date=m2xdate(tday1,0);
    
    index_px=prices(:,1);
    index_px(v_idx)=[];
        
    z_spread=zeros(size(component_vol,1),1);
    v_corr=zeros(size(component_vol,1)-window+1,1);
    z_px=zeros(size(component_vol,1),1);
    
    z_spread(1:window-1)=zscore(v_spread(1:window-1));
    z_px(1:window-1)=zscore(index_px(1:window-1));
    
    for j=window:size(component_vol,1)
        tempz=zscore(v_spread(j-window+1:j));
        z_spread(j)=tempz(end);
        temppx=zscore(index_px(j-window+1:j));
        z_px(j)=temppx(end);
        v_corr(j-window+1)=corr(v_spread(j-window+1:j),index_px(j-window+1:j));
    end
    
    Metrics=[index_px z_px index_vol component_vol v_spread z_spread];
    
    
%     x2=num2cell(vols);
%     idx2=any(cellfun(@(x) any(isnan(x)),x2),2);
%     x2(any(cellfun(@(x) any(isnan(x)),x2),2),:) = [];
%     vols2=cell2mat(x2);
%     n_dim=size(vols2,2);
%     
%     dates2=dates;
%     dates2(idx2,:)=[];
%     excel_date=m2xdate(dates2(:,1),0);
%     
%     prices2=prices;
%     prices2(idx2,:)=[];
    
    

%     tday1=dates(:, 1);
%     rtn1=rtns(:, 1);
%     px1=prices(:, 1);
%     tday1(find(~tday1))=[];
%     rtn1(find(~tday1))=[];
%     px1(find(~tday1))=[];

%     for k=2:n_dim
%         tday2=dates(:, k); 
%         rtn2=rtns(:, k);
%         px2=prices(:, k);
%         tday2(find(~tday2))=[];
%         rtn2(find(~tday2))=[];
%         px2(find(~tday2))=[];
%         [n1n2, idx1, idx2]=intersect(tday1, tday2);
%         tday1=tday1(idx1);
%         rtn_Y=[rtns(idx1,1:k-1) rtns(idx2,k:end)];
%         px_Y=[prices(idx1,1:k-1) prices(idx2,k:end)];
%     end


    %% Calculate Elasticity
%     v_spread=zeros(size(vols,1),1);
%     for j=1:size(vols,1)
%         temp_rtn=vols(j,2:end);
%         temp_rtn(isnan(temp_rtn))=[];
%         temp_avg=mean(temp_rtn);
%         temp_diff=abs(temp_rtn-repmat(temp_avg,1,size(temp_rtn,2)));
%         v_spread(j)=mean(temp_diff,2);
%     end
%     
% 
%     
%     z_disp=zeros(size(rtn_Y,1)-window+1,1);
%     v_corr=zeros(size(rtn_Y,1)-window+1,1);
%     for j=window:size(rtn_Y,1)
%         tempz=zscore(v_disp(j-window+1:j));
%         z_disp(j-window+1)=tempz(end);
%         v_corr(j-window+1)=corr(v_disp(j-window+1:j),px_Y(j-window+1:j,1));
%     end
% 
% 
%     exit_disp=-z_disp(end);
%     exit_corr=0.4;
%     newmetric=backtest(rtn_Y(window:end,1),z_disp(window:end),z_disp(end),exit_disp,v_corr,v_corr(end),exit_corr,tday1);
%    
%     newmetric=[z_disp(end) v_corr(end) newmetric];
%     Metrics=[Metrics;newmetric];

toc