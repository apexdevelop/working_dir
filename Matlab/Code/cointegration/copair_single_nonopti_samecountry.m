
% clear all;
% cd('C:\Users\ychen\Documents\MATLAB');
% javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar')
% txt={'9984 JP Equity';'TPX Index';'9437 JP Equity';'TPX Index'};
% is_opti={'Y'};

% if matlabpool('size') ~= 0
%    matlabpool close;
% end
function [tday_excel,logY1,logY2,v_Alpha,v_Beta,v_Beta2,v_spread,z_spread,v_residual,z_residual,v_pADF,signal_long,signal_short,signal_exit,r,CPnL,metric]=copair_single_nonopti_samecountry(txt1,txt2)
%% import data set from bloomberg and generate pairs


enddate=today();
startdate=char(txt2(1));
c=blp;
for loop=1:size(txt1,1)
    new=char(txt1(loop));
    [d sec] = history(c, new,'Last_Price',startdate,enddate);
    date(1:size(d,1),loop+1)=d(1:size(d,1),1);
    price(1:size(d,1),loop+1)=d(1:size(d,1),2);
end;
close(c);
for n_time=1:size(date,1)
    date(n_time,1)=n_time;
end

for n_stk=1:size(price,1)
    price(n_stk,1)=n_stk;
end

%% Initialize parameters and metrics
is_adf=char(txt2(5));
window = 220;
freq   = 20;

scaling=1;
cost=0;
Signal_TH=cell2mat(txt2(3));
current_pADF_TH=cell2mat(txt2(3));
hp_TH=66;

beta_idx=cell2mat(txt2(2));
%beta_idx=1 log price
%beta_idx=2 demean log price
%beta_idx=3 normalize log price

if matlabpool('size') == 0
   matlabpool local
end
%% resample stock1 and stock2
tday1=date(:, 2); 
adjcls1=price(:, 2);
tday1(find(~tday1))=[];
adjcls1(find(~adjcls1))=[];

tday2=date(:, 4); 
adjcls2=price(:, 4); 
tday2(find(~tday2))=[];
adjcls2(find(~tday2))=[];
                     
[n1n2, idx1, idx2]=intersect(tday1, tday2); 
tday=tday2(idx2);
           
equity_Y=zeros(size(n1n2,1),2);

equity_Y(:,1)=adjcls1(idx1);%stock1
equity_Y(:,2)=adjcls2(idx2);%stock2           
logY=log(equity_Y);
                     
%%
% We can use our existing parameter sweep framework to identify the best
% combination of calibration window and rebalancing frequency.


[metric,v_Alpha,v_Beta,v_Beta2,v_spread,z_spread,v_residual,z_residual,v_pADF,signal_long,signal_short,signal_exit,r,CPnL]=copair_tsoutput1(is_adf,beta_idx,logY,window,freq,Signal_TH,current_pADF_TH,hp_TH,scaling,cost,tday);

tday_excel=m2xdate(tday(window:end),0);
logY1=logY(window:end,1);
logY2=logY(window:end,2);



% %fix window, freq,pADF,sweep spread
% range_idx=3;
% range2=range1(range_idx);
% pfun2 = @(x) pairsFun2(x, logY, param1,scaling, cost,range_idx);
% [respmax2,param2,resp2] = parameterSweep(pfun2,range2);
% plot(cell2mat(range2),resp2);
% title(['PnL Optimization on Z-residual, best Z-residual = ',num2str(param2)])
% ylabel('PnL')
% xlabel('Z-residual')



% file=strcat(char(txt(2)),'_',char(txt(3)),'.txt');
% cd('X:\Yan\updated Model');
% cell_zscr=num2cell(metric(param1(1):end,1));
% cell_px=num2cell(Y(param1(1):end,1));
% Mat_output=[output_tday(param1(1):end) cell_px cell_zscr];
% fileID = fopen(file,'w');
% fprintf(fileID,'%6s\t%12s\t%12s\r\n','Date','Close_Px','Z_residual');
% formatSpec='%6s\t%12.2f\t%12.2f\r\n';
% for i= 1 : size(tday,1)-param1(1)+1
%     fprintf(fileID,formatSpec,Mat_output{i,:});
% end
% fclose(fileID);
