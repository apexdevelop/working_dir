clear all;
cd('C:\Users\ychen\Documents\MATLAB');
txt1={'6301 JP Equity';'6305 JP Equity'};
txt2={'TPX Index';'TPX Index';'CAT Equity'};
javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.7.1.1\lib\blpapi3.jar')
txt3={'05/04/2012'};


% function [M_avgDF,M_right_corr,M_left_corr]=peak_single_factor_multi_equity(txt1,txt2,txt3)
%% GET Bloomberg DATA

if ischar(txt3)==1
   startdate=txt3;
else
   startdate=char(txt3);
end

per='daily';
[names1, btxt1, bbpx1]=blp_test(txt1,startdate,per);
[names2, btxt2, bbpx2]=blp_test(txt2,startdate,per); %index, factor in last column

%% initialize parameters
M_avgDF=[];
M_right_corr=[];
M_left_corr=[];
%% clean factor data
tday_f=btxt2(:,end);
px_f=bbpx2(:,end);
px_f(find(~tday_f))=[];
tday_f(find(~tday_f))=[];


for n=1:size(txt1,1)
    %equity data
    tday=btxt1(:,n+1);
    px=bbpx1(:,n+1);
    px(find(~tday))=[];
    tday(find(~tday))=[];
    
    %index data
    tday_b=btxt2(:,n+1);
    px_b=bbpx2(:,n+1);
    px_b(find(~tday_b))=[];
    tday_b(find(~tday_b))=[];
    
    %align equity and index
    [enb,idx1,idxb]=intersect(tday,tday_b);
    px=px(idx1);
    px_b=px_b(idxb);
    tday=tday(idx1);
    
    %align with factor
    [enf,idx2,idxf]=intersect(tday,tday_f);
           
    px=px(idx2);
    px_b=px_b(idx2);
    new_px_f=px_f(idxf);
    tday=tday(idx2);
        
    rel_px=extract_country_single([px px_b],3);
    
    %calculate average DF
    v_lag=2:20;
    [v_DF,rho]=find_dof(new_px_f,rel_px,v_lag);
    avgDF=mean(v_DF);
    M_avgDF=[M_avgDF;avgDF];   
    
    v_rightR=right_tail(new_px_f,rel_px,v_lag);
    Corr_right=mean(v_rightR);
    M_right_corr=[M_right_corr;Corr_right];
    
    v_leftR=left_tail(new_px_f,rel_px,v_lag);
    Corr_left=mean(v_leftR);
    M_left_corr=[M_left_corr;Corr_left];
    

end
