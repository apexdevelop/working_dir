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
        [d1, sec1] = history(c, new,'TURNOVER',startdate,enddate,per);
        [d2, sec2] = history(c, new,'Last_Price',startdate,enddate,per);
        dates(1:size(d1,1),loop)=d1(1:size(d1,1),1);
        values(1:size(d1,1),loop)=d1(1:size(d1,1),2);
        prices(1:size(d2,1),loop)=d2(1:size(d2,1),2);
    end;
    close(c);
    %% Calculate turnover weighted price    
    w_px=[];
    v_idx=zeros(size(values,1),1);
    
    for j=1:size(values,1)
        temp_value=values(j,2:end);
        temp_price=prices(j,2:end).*100./prices(1,2:end);
        price_idx=isnan(temp_price);
        
        if sum(price_idx)~=size(prices,2)-1
        
           price1=temp_price;
           value1=temp_value;
           price1(price_idx)=[];
           value1(price_idx)=[];
           
           value_idx=isnan(value1);
           if sum(value_idx)~=size(value1,2)
              price2=price1;
              value2=value1;
          
              price2(value_idx)=[];
              value2(value_idx)=[];
        
              weights=value2./sum(value2);
              col_weights=reshape(weights,size(weights,2),1);
              w_px=[w_px;price2*col_weights];
           else
              v_idx(j)=1; 
           end
        else
           v_idx(j)=1;
        end
    end
    
    v_idx=logical(v_idx);
    
    index_px=prices(:,1).*(100/prices(1,1));
    index_px(v_idx)=[];
    v_spread=w_px-index_px;
    
    tday1=dates(:,1);
    tday1(v_idx)=[];
    excel_date=m2xdate(tday1,0);
    
    z_spread=zeros(size(w_px,1),1);
    v_corr=zeros(size(w_px,1)-window+1,1);
    z_px=zeros(size(w_px,1),1);
    
    z_spread(1:window-1)=zscore(v_spread(1:window-1));
    z_px(1:window-1)=zscore(index_px(1:window-1));
    
    for j=window:size(w_px,1)
        tempz=zscore(v_spread(j-window+1:j));
        z_spread(j)=tempz(end);
        temppx=zscore(index_px(j-window+1:j));
        z_px(j)=temppx(end);
        v_corr(j-window+1)=corr(v_spread(j-window+1:j),index_px(j-window+1:j));
    end
    
    Metrics=[index_px z_px w_px v_spread z_spread];
    

COrd = get(gca,'ColorOrder');
plot(tday1,index_px,'LineWidth',2,'Color',COrd(4,:))
hold on
plot(tday1,z_px,'--','LineWidth',2,'Color',COrd(5,:))
legend('index','z_index','Location','NW')
title(['Compare cap and turnover weighted ',char(temp_txt(1))])
axis tight
grid on
hold off