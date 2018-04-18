
% clear all;
% cd('C:\Users\ychen\Documents\MATLAB');
% javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.6.1.0\lib\blpapi3.jar')
% txt3={'01/01/2010'};
% txt2={'KFX Index';'TPX Index';'TPX Index';'TPX Index';'HSI Index';'HSI Index'};
% txt1={'MAERSKB DC Equity';'9107 JP Equity';'9104 JP Equity';'9101 JP Equity';'1919 HK Equity';'2866 HK Equity'};
function [v_tday,M_rolling,v_lastCorr,Mat_meanIC]=single_left_tail(txt1,txt2,txt3)
%% GET Bloomberg DATA

startdate=char(txt3(1));
per='daily';
[names1, btxt1, bbpx1]=blp_test(txt1,startdate,per);
[names2, btxt2, bbpx2]=blp_test(txt2,startdate,per);

%% initialize parameters
M=cell2mat(txt3(3));
N=cell2mat(txt3(4));
nlags=10;
ext_corr_TH=0.6;
M_PnL=[];
M_lag1=[];
M_lag2=[];
M_max=[];
M_rolling=[];

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

    
tday2=btxt1(:,3);
px2=bbpx1(:,3);
tday2(find(~tday2))=[];
px2(find(~tday2))=[];
    
tday_f2=btxt2(:,3);
px_f2=bbpx2(:,3);%index price
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
v_lastCorr=zeros(nlags,1);

for lag=1:nlags
        v_ext_corr=zeros(s1,1);
        v_signal=zeros(s1,2);
        j=M;
        v_R1=[];
        while j<=s1
          R1=left_tail(factor1(j-M+1:j),factor2(j-M+1:j),lag);
          if j<=s1-N
             v_ext_corr(j:j+N-1)=R1;
             m1(j)=100*(px1(j)/px1(j-N)-1);
             m2(j)=100*(px2(j)/px2(j-N)-1);
             for t=j+1:j+N-1
                 m1(t)=100*(px1(t)/max(px1(j:t-1))-1);
                 m2(t)=100*(px2(t)/max(px2(j:t-1))-1);
             end
             
             if R1>ext_corr_TH
                for t=j:j+N-1
                    if (v_signal(t,2)==0 && m1(t)<-1 && m2(t)>-1)...
                        || (v_signal(t-1,2)==-1 && m1(t)<1)
                        v_signal(t,2)=-1;
                        v_signal(t,1)=1;
                    end
                end
             end
             
          else
             v_ext_corr(j:end)=R1;
             m1(j)=100*(px1(j)/px1(j-N)-1);
             m2(j)=100*(px2(j)/px2(j-N)-1);
             for t=j+1:s1
                 m1(t)=100*(px1(t)/max(px1(j:t-1))-1);
                 m2(t)=100*(px2(t)/max(px2(j:t-1))-1);
             end
             if R1>ext_corr_TH
                for t=j:s1
                    if (v_signal(t,2)==0 && m1(t)<-1 && m2(t)>-1)...
                        || (v_signal(t-1,2)==-1 && m1(t)<1)
                        v_signal(t,2)=-1;
                        v_signal(t,1)=1;
                    end
                end
             end
          end
          j=j+N;
          v_R1=[v_R1;R1];
        end
        r  = sum([0 0; v_signal(1:end-1, :) .* diff(logPx)] ,2);
        v_PnL(lag)=sum(r);
        v_lastCorr(lag)=R1;
        M_rolling=[M_rolling v_R1];
end

[C2,I2]=max(v_PnL);
M_PnL=[M_PnL;C2];
M_lag2=[M_lag2;I2];

%% generate Date
v_tday=[];
j=M;
while j<=s1
      v_tday=[v_tday;tday(j)];
      j=j+N;
end
v_tday=m2xdate(v_tday);        
v_meanCorr=zeros(nlags,1);
v_lookback=125:125:1250;
Mat_meanIC=zeros(size(v_lookback,2),nlags);

for i=1:size(v_lookback,2)
    M_varied=v_lookback(1,i);
    for lag=1:nlags
        j=M_varied;
        v_R1=[];
        while j<=s1
          R1=yan_left_tail(factor1(j-M_varied+1:j),factor2(j-M_varied+1:j),lag);
          j=j+N;
          v_R1=[v_R1;R1];
        end
        Mat_meanIC(i,lag)=mean(v_R1);
        
    end
end
[C1,I1]=max(v_meanCorr);
M_max=[M_max;C1];
M_lag1=[M_lag1;I1];
