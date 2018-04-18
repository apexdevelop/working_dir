
clearvars;
cd('Y:/working_directory/Matlab');
javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');
filename='factors-copy.xlsx';
% oil,shipping,utility,hitachi,steel,coal,display,solar,jp_bond,kr_bond,aluminum,machinery
v_shnames={'oil','shipping','utility','hitachi','steel','coal','display','solar','jp_bond','kr_bond','aluminum1','aluminum2','machinery','semi','sugar','aapl','shenzhou'};
e_ranges={'d1:s1','d1:n1','d1:j1','d1:d1','d1:m1','d1:f1','d1:i1','d1:h1','d1:p1','d1:g1','d1:e1','d1:e1','d1:h1','d1:h1','d1:g1','d1:o1','d1:d1'};
b_ranges={'d2:s2','d2:n2','d2:j2','d2:d2','d2:m2','d2:f2','d2:i2','d2:h2','d2:p2','d2:g2','d2:e2','d2:e2','d2:h2','d2:h2','d2:g2','d2:o2','d2:d2'};
d_ranges={'d5:s51','d5:n39','d5:j31','d5:d18','d5:m38','d5:i28','d5:i32','d5:h30','d5:p29','d5:g23','d5:e27','d5:e27','d5:h24','d5:h15','d5:g19','d5:o5','d5:d9'};
sh_idx=5;
shname=char(v_shnames(sh_idx));
[~,txt2]=xlsread(filename,shname,'b5:b100'); %factor
[~,txt1]=xlsread(filename,shname,char(e_ranges(sh_idx)));  %equity
[~,txt3]=xlsread(filename,shname,char(b_ranges(sh_idx)));  %benchmark
[effect,~]=xlsread(filename,shname,char(d_ranges(sh_idx)));  %effect


%% generate Data

startdate='2012/3/12';
enddate=today();
per={'daily','non_trading_weekdays','previous_value'};
curr=[];
field1='LAST_PRICE';
field2='CHG_PCT_1D';
[~, edates, eprices]=blp_data(transpose(txt1),field1,startdate,enddate,per,curr);
[~, ~, ertns]=blp_data(transpose(txt1),field2,startdate,enddate,per,curr);
[~, fdates, fprices]=blp_data(txt2,field1,startdate,enddate,per,curr);
[~, ~, frtns]=blp_data(txt2,field2,startdate,enddate,per,curr);
[~, bdates, bprices]=blp_data(transpose(txt3),field1,startdate,enddate,per,curr);
[~, ~, brtns]=blp_data(transpose(txt3),field2,startdate,enddate,per,curr);

%% Initialize parameters
M=40;
N=10;
z_window=M;
mov_window=N;
n_ab=0; % number of abnormal returns which have to be calcualted from prices
% for steel factor CDSPDRAV and CDSPHRAV, for shipping BDIY,BIDY
if n_ab>0
   frtns(1,(end-n_ab+1):end)=0;
   frtns(2:end-1,(end-n_ab+1):end)=(fprices(2:end-1,(end-n_ab+1):end)./fprices(1:end-2,(end-n_ab+1):end)-1)*100;
end
%% Re-align Data
mat_kendall=zeros(size(txt2,1),size(txt1,2));
mat_frtn=zeros(size(txt2,1),1); %daily factor move
mat_zfrtn=zeros(size(txt2,1),1);
mat_zfpx=zeros(size(txt2,1),1);
mat_factor=zeros(size(txt2,1),1); %nday mov rtn
mat_zfactor=zeros(size(txt2,1),1); %zscore nday mov rtn

for m=1:1 %equity and market
    for n=3:3 %factor
        new_txt1=[txt1(m);txt2(n);txt3(m)];
        
        tday1=edates(:, m+1);
        px1=eprices(:, m+1);
        rtn1=ertns(:, m+1);
        tday1(isnan(px1))=[];
        rtn1(isnan(px1))=[];
        px1(isnan(px1))=[];
        rtn1(isnan(rtn1))=0;
        rtn1(find(~tday1))=[];
        px1(find(~tday1))=[];
        tday1(find(~tday1))=[];

        tday2=fdates(:, n+1); 
        px2=fprices(:, n+1);
        rtn2=frtns(:, n+1);
        tday2(isnan(px2))=[];
        rtn2(isnan(px2))=[];
        px2(isnan(px2))=[];
        rtn2(isnan(rtn2))=0;
        rtn2(find(~tday2))=[];
        px2(find(~tday2))=[];
        tday2(find(~tday2))=[];
        
        mat_frtn(n)=rtn2(end);
        temp_zfrtn=zscore(rtn2(end-z_window:end));
        mat_zfrtn(n)=temp_zfrtn(end);
        temp_zfpx=zscore(px2(end-z_window:end));
        mat_zfpx(n)=temp_zfpx(end);
        
        [n1n2, idx1, idx2]=intersect(tday1, tday2);
        tday1=tday1(idx1);
        px1=px1(idx1);
        px2=px2(idx2);
        rtn1=rtn1(idx1);
        rtn2=rtn2(idx2);
        
        
        if ~strcmpi(char(txt2(n)),char(txt3(m))) && ~strcmpi(char(txt1(m)),char(txt2(n)))
           n_dim=3;
           tday3=bdates(:, m+1); 
           px3=bprices(:, m+1);
           rtn3=brtns(:, m+1);
           tday3(isnan(px3))=[];
           rtn3(isnan(px3))=[];
           px3(isnan(px3))=[];
           px3(find(~tday3))=[];
           rtn3(find(~tday3))=[];
           tday3(find(~tday3))=[];
           [n1n3, idx1, idx3]=intersect(tday1, tday3);
           tday1=tday1(idx1);
           px1=px1(idx1);
           px2=px2(idx1);
           rtn1=rtn1(idx1);
           rtn2=rtn2(idx1);
           px3=px3(idx3);
           rtn3=rtn3(idx3);
           Px_Y=[px1 px2 px3]; %[equity, factor, benchmark]
           rtn_Y=[rtn1 rtn2 rtn3];
           v_rtn=[rtn_Y(M+1:end,1) rtn_Y(M+1:end,3)];
           v_fullrtn=[rtn_Y(:,1) rtn_Y(:,3)];
        elseif strcmpi(char(txt2(n)),char(txt3(m)))
           n_dim=2;
           Px_Y=[px1 px2]; %[equity, factor(benchmark)]
           rtn_Y=[rtn1 rtn2];
           v_rtn=rtn_Y(M+1:end,:);% rnt_Y(:,2)=rtn_Y(:,3)
           v_fullrtn=rtn_Y;
        elseif strcmpi(char(txt1(m)),char(txt2(n)))
           n_dim=2;
           tday3=bdates(:, m+1); 
           px3=bprices(:, m+1);
           rtn3=brtns(:, m+1);
           tday3(isnan(px3))=[];
           rtn3(isnan(px3))=[];
           px3(isnan(px3))=[];
           px3(find(~tday3))=[];
           rtn3(find(~tday3))=[];
           tday3(find(~tday3))=[];
           [n1n3, idx1, idx3]=intersect(tday1, tday3);
           tday1=tday1(idx1);
           px1=px1(idx1);
           rtn1=rtn1(idx1);
           px3=px3(idx3);
           rtn3=rtn3(idx3);
           Px_Y=[px1 px3]; %[equity, factor(benchmark)]
           rtn_Y=[rtn1 rtn3];
           v_rtn=rtn_Y(M+1:end,:);% rnt_Y(:,1)=rtn_Y(:,2)
           v_fullrtn=rtn_Y;
        else
        end
        date=tday1;
        rho=corr(rtn_Y(:,1),rtn_Y(:,2));
        nob=size(rtn_Y,1);
%% Calculate inputs        
        temp_z_ndfrtn=zeros(size(rtn_Y,1),1);
        temp_kendall=zeros(size(rtn_Y,1),1);
        
        if size(rtn_Y,1)<M
           M=size(rtn_Y,1)-N;
        end
        
        er_row=reshape(rtn_Y(:,1),1,size(rtn_Y,1));
        temp_emov=tsmovavg(er_row,'e',mov_window);
        er_mov=mov_window*[er_row(1:(mov_window-1)) temp_emov(mov_window:end)];
        
        if ~strcmpi(char(txt2(n)),char(txt3(m))) && ~strcmpi(char(txt1(m)),char(txt2(n)))
           fr_row=reshape(rtn_Y(:,2),1,size(rtn_Y,1));
           temp_fmov=tsmovavg(fr_row,'e',mov_window);
           fr_mov=mov_window*[fr_row(1:(mov_window-1)) temp_fmov(mov_window:end)];
           
           input_frtn=zeros(nob,N);
           for t=1:N
            input_frtn(:,t)=rtn_Y(t:nob-2*N+t-1,2);
           end
           
           br_row=reshape(rtn_Y(:,3),1,size(rtn_Y,1));
           temp_bmov=tsmovavg(br_row,'e',mov_window);
           br_mov=mov_window*[br_row(1:(mov_window-1)) temp_bmov(mov_window:end)];
        elseif strcmpi(char(txt2(n)),char(txt3(m))) || strcmpi(char(txt1(m)),char(txt2(n)))
           fr_row=reshape(rtn_Y(:,2),1,size(rtn_Y,1));
           temp_fmov=tsmovavg(fr_row,'e',mov_window);
           fr_mov=mov_window*[fr_row(1:(mov_window-1)) temp_fmov(mov_window:end)];
           br_mov=fr_mov;
        else
        end
        
        temp_kendall(1:M-1)=corr(rtn_Y(1:M-1,1),rtn_Y(1:M-1,2),'type','kendall')*ones(M-1,1);
        j=M;

        while j<size(rtn_Y,1)
             if j<=size(rtn_Y,1)-N
                temp_z_ndfrtn(j:j+N)=(fr_mov(j:j+N)-mean(fr_mov(j-M+1:j)))/std(fr_mov(j-M+1:j));
                temp_kendall(j:j+N)=corr(rtn_Y(j-M+1:j,1),rtn_Y(j-M+1:j,2),'type','kendall')*ones(N+1,1);
             else
                n2end=size(rtn_Y,1)-j+1;
                temp_z_ndfrtn(j:end)=(fr_mov(j:end)-mean(fr_mov(j-M+1:j)))/std(fr_mov(j-M+1:j));
                temp_kendall(j:end)=corr(rtn_Y(j-M+1:j,1),rtn_Y(j-M+1:j,2),'type','kendall')*ones(n2end,1);
             end
             j=j+N;
        
        end
        mat_kendall(n,m)=temp_kendall(end);
        mat_factor(n)=fr_mov(end);
        mat_zfactor(n)=temp_z_ndfrtn(end);
        v_factor=temp_z_ndfrtn(M+1:end-mov_window);
        v_kendall=temp_kendall(M+1:end-mov_window);
        
        z_fpx=zeros(size(Px_Y,1)-M-mov_window,1);
        zpx=zeros(size(Px_Y,1)-M-mov_window,1);
        zrtn=zeros(size(Px_Y,1)-M-mov_window,1);
        ex_rtn=transpose(er_mov(mov_window+1:end)-br_mov(mov_window+1:end));
        if z_window>=size(Px_Y,1)-M-mov_window
           z_window=size(Px_Y,1)-M-mov_window;
           z_fpx=zscore(Px_Y(M+1:end-mov_window,2));
           zpx=zscore(Px_Y(M+1:end-mov_window,1));
           zrtn=zscore(ex_rtn);
        else
           z_fpx(1:z_window-1)=zscore(Px_Y(M+1:M+z_window-1,2));
           zpx(1:z_window-1)=zscore(Px_Y(M+1:M+z_window-1,1));
           zrtn(1:z_window-1)=zscore(ex_rtn(1:z_window-1));
           for j=z_window : size(v_factor,1)
               temp_zfpx=zscore(Px_Y(M+j-z_window+1:M+j,2));
               temp_zpx=zscore(Px_Y(M+j-z_window+1:M+j,1));
               temp_zrtn=zscore(ex_rtn(j-z_window+1:j,1));
               z_fpx(j)=temp_zfpx(end);
               zpx(j)=temp_zpx(end);
               zrtn(j)=temp_zrtn(end);
           end
        end
        input=[v_factor v_kendall z_fpx zpx];
    end
end
