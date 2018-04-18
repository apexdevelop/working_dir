
% clear all;
% cd('C:\Users\ychen\Documents\MATLAB');
% txt1={'MAERSKB DC Equity';'1919 HK Equity'};
% txt2={'KFX Index';'HSI Index'};
% javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');
% txt3={'06/03/2010'};
function [M_corr,M_PnL,M_lag1,M_lag2]=trade_right_tail(txt1,txt2,txt3)
%% GET Bloomberg DATA

% if ischar(txt3)==1;
%    startdate=txt3;
% else
%    startdate=char(txt3);
% end

startdate=char(txt3(1));

per='daily';
[names1, btxt1, bbpx1]=blp_test(txt1,startdate,per);
[names2, btxt2, bbpx2]=blp_test(txt2,startdate,per);

%% initialize parameters
M=cell2mat(txt3(3));
N=cell2mat(txt3(4));
nlags=10;
ext_corr_TH=0.2;
M_PnL=[];
M_lag1=[];
M_lag2=[];
M_corr=[];
%% resample factor 1 and factor 2
old_tday1=btxt1(:,2);
old_px1=bbpx1(:,2);
baddata0=find(~old_tday1);
old_tday1(baddata0)=[];
old_px1(baddata0)=[];

if strcmp(char(txt3(2)),'Equity')==1
   old_tday_f1=btxt2(:,2);
   old_px_f1=bbpx2(:,2);%index1 price
   old_tday_f1(find(~old_tday_f1))=[];
   old_px_f1(find(~old_tday_f1))=[];
   [f1n1,idx1,idxf1]=intersect(old_tday1,old_tday_f1);

   old_px1=old_px1(idx1);
   old_px_f1=old_px_f1(idxf1);
   old_tday1=old_tday1(idx1);
end

for n=2:size(txt1,1)    
    tday2=btxt1(:,n+1);
    px2=bbpx1(:,n+1);
    tday2(find(~tday2))=[];
    px2(find(~tday2))=[];
    
    tday_f2=btxt2(:,n+1);
    px_f2=bbpx2(:,n+1);%index price
    tday_f2(find(~tday_f2))=[];
    px_f2(find(~px_f2))=[];
    [f2n2,idx2,idxf2]=intersect(tday2,tday_f2);
           
    px2=px2(idx2);
    px_f2=px_f2(idxf2);
    tday2=tday2(idx2);
    
    [fn1n2, idxn1, idxn2]=intersect(old_tday1, tday2);
   
    tday=tday2(idxn2);
    px1=old_px1(idxn1);%stock1
    if strcmp(char(txt3(2)),'Equity')==1
       px_f1=old_px_f1(idxn1);%index1
    end
    px2=px2(idxn2);%stock2
    px_f2=px_f2(idxn2);%index2 
    
    logPx=[log(px1) log(px2)];
    
%     if strcmp(char(txt3(2)),'Equity')==1
%        rel_Rtn1=extract_country_single(rtn(px1),rtn(px_f1),1,1);
%        factor1=[0;rel_Rtn1];
%     else
%      factor1=[0;rtn(px1)];
%     end
%     
%     rel_Rtn2=extract_country_single(rtn(px2),rtn(px_f2),1,1);
%     factor2=[0;rel_Rtn2];

if strcmp(char(txt3(2)),'Equity')==1
   rel_px1=extract_country_single(px1,px_f1,3,3);
   factor1=rel_px1;
else
   factor1=px1;

end   
rel_px2=extract_country_single(px2,px_f2,3,3);
factor2=rel_px2;    

    s1=length(factor1);
    m1=zeros(s1,1); %momentum for factor
    m2=zeros(s1,1); %momentum for stock

    v_PnL=zeros(nlags,1);
    v_meanCorr=zeros(nlags,1);
    v_lastCorr=zeros(nlags,1);
    for lag=1:nlags
        v_ext_corr=zeros(s1,1);
        v_signal=zeros(s1,2);
        j=M;
        v_R1=[];
        while j<=s1
          R1=yan_right_tail(factor1(j-M+1:j),factor2(j-M+1:j),lag);
          if j<=s1-N
             v_ext_corr(j:j+N-1)=R1;
             m1(j)=100*(px1(j)/px1(j-N)-1);
             m2(j)=100*(px2(j)/px2(j-N)-1);
             for t=j+1:j+N-1
                 m1(t)=100*(px1(t)/min(px1(j:t-1))-1);
                 m2(t)=100*(px2(t)/min(px2(j:t-1))-1);
             end
             
             if R1>ext_corr_TH
                for t=j:j+N-1
                    if (v_signal(t,2)==0 && m1(t)>1 && m2(t)<1)...
                        || (v_signal(t-1,2)==1 && m1(t)>-1)
                        v_signal(t,2)=1;
                        v_signal(t,1)=-1;
                    end
                end
             end
             
          else
             v_ext_corr(j:end)=R1;
             m1(j)=100*(px1(j)/px1(j-N)-1);
             m2(j)=100*(px2(j)/px2(j-N)-1);
             for t=j+1:s1
                 m1(t)=100*(px1(t)/min(px1(j:t-1))-1);
                 m2(t)=100*(px2(t)/min(px2(j:t-1))-1);
             end
             if R1>ext_corr_TH
                for t=j:s1
                    if (v_signal(t,2)==0 && m1(t)>1 && m2(t)<1)...
                        || (v_signal(t-1,2)==1 && m1(t)>-1)
                        v_signal(t,2)=1;
                        v_signal(t,1)=-1;
                    end
                end
             end
          end
          j=j+N;
          v_R1=[v_R1;R1];
        end
        r  = sum([0 0; v_signal(1:end-1, :) .* diff(logPx)] ,2);
        v_PnL(lag)=sum(r);
        v_meanCorr(lag)=mean(v_R1);
        v_lastCorr(lag)=R1;
    end
    
    if mean(v_meanCorr)>=0    
       [C1,I1]=max(v_meanCorr);
    else %negative correlation in a whole
       [C1,I1]=min(v_meanCorr);
    end
    
    M_corr=[M_corr;C1];
    M_lag1=[M_lag1;I1];

    [C2,I2]=max(v_PnL);
    M_PnL=[M_PnL;C2];
    M_lag2=[M_lag2;I2];
end

% plot(0:nlags-1,v_meanCorr,'--or',0:nlags-1,v_lastCorr);
% legend('mean Corr','last Corr')
% title(['Right Tail Dependence between ',char(names1(1)),' and ',char(names1(2))])
% ylabel('Right Tail Correlation')
% xlabel('nlag')