% Time indexing method on single factor

% clearvars;
cd('Y:/working_directory/Matlab');
javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');

%% generate Data
sh_idx=5;
[txt1,txt2,txt3,effect,edates,eprices,ertns,fdates,fprices,frtns,bdates,bprices,brtns]= sf_datafeed(sh_idx);
%% Initialize parameters
M=66;
l_pattern=5;%length of pattern
n_testp=5; %n of test pattern
TH_prc=1:20; %percentile of distance TH
Metrics=[];
Names=[];

n_ab=0; % number of abnormal returns which have to be calcualted from prices
% for steel factor CDSPDRAV and CDSPHRAV, for shipping BDIY,BIDY
if n_ab>0
   frtns(1,(end-n_ab+1):end)=0;
   frtns(2:end-1,(end-n_ab+1):end)=(fprices(2:end-1,(end-n_ab+1):end)./fprices(1:end-2,(end-n_ab+1):end)-1)*100;
end
%% Re-align Data
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
        date=tday1;
        
        nob=size(rtn_Y,1);
%% Calculate inputs        
        n_pattern=floor((nob-n_testp*l_pattern)/l_pattern); %training data
        n_1d_ob=n_pattern*l_pattern;
        z_epx=zeros(nob,1);
        z_fpx=zeros(nob,1);
        z_epx(1:M)=zscore(Px_Y(1:M,1));
        z_fpx(1:M)=zscore(Px_Y(1:M,2));
        
        for i=M+1:nob
            temp_zepx=zscore(Px_Y(i-M+1:i,1));
            z_epx(i)=temp_zepx(end);
            temp_zfpx=zscore(Px_Y(i-M+1:i,2));
            z_fpx(i)=temp_zfpx(end);
        end
        
        raw_spread=z_epx-z_fpx;
        daily_spread=raw_spread(1:n_1d_ob);
        
        pattern_spread=reshape(daily_spread,n_pattern,l_pattern);
        
        temp_return=reshape(ex_fullrtn(l_pattern+1:l_pattern+n_1d_ob),n_pattern,l_pattern);
        pattern_return=sum(temp_return,2);
        
        temp_testp=raw_spread(n_1d_ob+1:n_1d_ob+n_testp*l_pattern);
        test_pattern=reshape(temp_testp,n_testp,l_pattern);
        temp_actual_ret=reshape(ex_fullrtn(n_1d_ob+1+l_pattern:n_1d_ob+n_testp*l_pattern),n_testp-1,l_pattern);
        test_actual_ret=sum(temp_actual_ret,2);
        
        v_distance=zeros(n_pattern,n_testp);
        v_expret=zeros(size(TH_prc,2),n_testp);
        c_THidx=cell(size(TH_prc,2),n_testp);
        for t=1:size(TH_prc,2)
        for j=1:n_testp
            temp_distance=pattern_spread-repmat(test_pattern(j,:),n_pattern,1);
            for i=1:n_pattern
                v_distance(i,j)=sumsqr(temp_distance(i,:));
            end
            TH_distance=prctile(v_distance(:,j),TH_prc(t));
            TH_idx=find(v_distance(:,j)<=TH_distance);
            c_THidx{t,j}=TH_idx;
            v_expret(t,j)=mean(pattern_return(TH_idx));
        end
        end
        %% 
%         date_backtest=date(N+lag+1:end);
%         y_TH=3;
%         ex_rtn=ex_fullrtn(N+lag+1:end);
%         [s,ret_v,newmetric]=nn_backtest_v1(ex_rtn,Y,y_TH,date_backtest);
%         Metrics=[Metrics; newmetric];
%         Names=[Names; transpose(new_txt1)];
    end
end

