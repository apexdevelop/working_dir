% clearvars;
% sh_idx=5;
function[cXret,cYret,cell_ob,cDate]= sfactor_generateData_v3(sh_idx, opt_save,startdate,enddate)
%% generate Data
javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');
[txt1,txt2,txt3,edates,eprices,ertns,fdates,fprices,frtns,bdates,bprices,brtns]= sf_datafeed(sh_idx,startdate,enddate);
n_ab=0; % number of abnormal returns which have to be calcualted from prices
% for steel factor CDSPDRAV and CDSPHRAV, for shipping BDIY,BIDY
if n_ab>0
   frtns(1,(end-n_ab+1):end)=0;
   frtns(2:end-1,(end-n_ab+1):end)=(fprices(2:end-1,(end-n_ab+1):end)./fprices(1:end-2,(end-n_ab+1):end)-1)*100;
end
%% Re-align Data
n_equity=size(txt1,2);
n_factor=size(txt2,1);
cell_px=cell(n_equity,n_factor);
cXret=cell(n_equity,n_factor);
cYret=cell(n_equity,n_factor);
cDate=cell(n_equity,n_factor);
cell_ob=cell(n_equity,n_factor);
cell_target=cell(n_equity,n_factor);
for m=1:n_equity %equity and market
    for n=1:n_factor %factor
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
           v_fullrtn=[rtn_Y(:,1) rtn_Y(:,3)];
           ex_fullrtn=rtn1-rtn3;
        elseif strcmpi(char(txt2(n)),char(txt3(m)))
           n_dim=2;
           Px_Y=[px1 px2]; %[equity, factor(benchmark)]
           rtn_Y=[rtn1 rtn2];
           v_fullrtn=rtn_Y;
           ex_fullrtn=rtn1-rtn2;
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
           Px_Y=[px1 px3]; %[equity(factor), benchmark]
           rtn_Y=[rtn1 rtn3];
           v_fullrtn=rtn_Y;
           ex_fullrtn=rtn1-rtn3;
        else
        end
        
%         er_row=reshape(rtn_Y(:,1),1,size(rtn_Y,1));
%         temp_emov=tsmovavg(er_row,'e',N);
%         er_mov=N*[er_row(1:(N-1)) temp_emov(N:end)];        
%         if ~strcmpi(char(txt2(n)),char(txt3(m))) && ~strcmpi(char(txt1(m)),char(txt2(n)))
%            fr_row=reshape(rtn_Y(:,2),1,size(rtn_Y,1));
%            temp_fmov=tsmovavg(fr_row,'e',N);
%            fr_mov=N*[fr_row(1:(N-1)) temp_fmov(N:end)];                      
%            br_row=reshape(rtn_Y(:,3),1,size(rtn_Y,1));
%            temp_bmov=tsmovavg(br_row,'e',N);
%            br_mov=N*[br_row(1:(N-1)) temp_bmov(N:end)];
%         elseif strcmpi(char(txt2(n)),char(txt3(m))) || strcmpi(char(txt1(m)),char(txt2(n)))
%            br_mov=fr_mov;
%         else
%         end       
%         ex_mov_rtn=transpose(er_mov(N+1:end)-br_mov(N+1:end));
%         cell_target{m,n}=ex_mov_rtn;
        date=tday1;
        cell_ob{m,n}=size(rtn_Y,1);
        cell_px{m,n}=Px_Y;
        cXret{m,n}=rtn_Y;
        cYret{m,n}=ex_fullrtn;
        cDate{m,n}=date;
    end
end
if opt_save==1
   cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/ML');
   save (strcat('ob', num2str(sh_idx)), 'cell_ob');
   save (strcat('px', num2str(sh_idx)), 'cell_px');
   save (strcat('Xret', num2str(sh_idx)), 'cXret');
   save (strcat('Yret', num2str(sh_idx)), 'cYret');
   save (strcat('Date', num2str(sh_idx)), 'cDate');
else
end
