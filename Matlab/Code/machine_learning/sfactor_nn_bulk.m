
% clearvars;
javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');
%% generate Data
cd('Y:/working_directory/Matlab/Code/machine_learning');
sh_idx=5;
[txt1,txt2,txt3,effect,edates,eprices,ertns,fdates,fprices,frtns,bdates,bprices,brtns]= sf_datafeed(sh_idx);
%% Initialize parameters
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
cell_ret=cell(n_equity,n_factor);
cell_exret=cell(n_equity,n_factor);
cell_date=cell(n_equity,n_factor);
cell_ob=cell(n_equity,n_factor);
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
        date=tday1;
        cell_ob{m,n}=size(rtn_Y,1);
        cell_px{m,n}=Px_Y;
        cell_ret{m,n}=rtn_Y;
        cell_exret{m,n}=ex_fullrtn;
        cell_date{m,n}=date;
    end
end
cd('Y:/working_directory/Matlab/Data/ML');
save (strcat('ob', num2str(sh_idx)), 'cell_ob');
save (strcat('px', num2str(sh_idx)), 'cell_px');
save (strcat('ret', num2str(sh_idx)), 'cell_ret');
save (strcat('exret', num2str(sh_idx)), 'cell_exret');
save (strcat('date', num2str(sh_idx)), 'cell_date');
%% Neural Network
net=cell(n_equity,n_factor);
trainY=cell(n_equity,n_factor);
inX=cell(n_equity,n_factor);
tr=cell(n_equity,n_factor);
new_net = fitnet(10);
N=10;
lag=0;

for m=1:n_equity %equity and market
    for n=1:n_factor %factor
        nob=cell_ob{m,n};
        Px_Y=cell_px{m,n};
        rtn_Y=cell_ret{m,n};
        input_fpx=zeros(nob-N-lag,N);
        for t=1:N
            input_fpx(:,t)=Px_Y(t:nob-N-lag+t-1,2);
        end       
        er_row=reshape(rtn_Y(:,1),1,size(rtn_Y,1));
        temp_emov=tsmovavg(er_row,'e',N);
        er_mov=N*[er_row(1:(N-1)) temp_emov(N:end)];        
        if ~strcmpi(char(txt2(n)),char(txt3(m))) && ~strcmpi(char(txt1(m)),char(txt2(n)))
           fr_row=reshape(rtn_Y(:,2),1,size(rtn_Y,1));
           temp_fmov=tsmovavg(fr_row,'e',N);
           fr_mov=N*[fr_row(1:(N-1)) temp_fmov(N:end)];                      
           br_row=reshape(rtn_Y(:,3),1,size(rtn_Y,1));
           temp_bmov=tsmovavg(br_row,'e',N);
           br_mov=N*[br_row(1:(N-1)) temp_bmov(N:end)];
        elseif strcmpi(char(txt2(n)),char(txt3(m))) || strcmpi(char(txt1(m)),char(txt2(n)))
           br_mov=fr_mov;
        else
        end       
        ex_mov_rtn=transpose(er_mov(N+lag+1:end)-br_mov(N+lag+1:end));
        %nn matlab, observations are by column
        inX{m,n}=transpose(input_fpx);
        T=transpose(ex_mov_rtn);
        %% nn training
        
        net{m,n}=new_net;
        [net{m,n},tr{m,n}] = train(net{m,n},inX{m,n},T);
        trainY{m,n}=net{m,n}(inX{m,n});

    end
end
cd('Y:/working_directory/Matlab/Data/ML');
save (strcat('in', num2str(sh_idx)), 'inX');
save (strcat('out', num2str(sh_idx)), 'trainY');
save (strcat('net', num2str(sh_idx)), 'net');
save (strcat('px', num2str(sh_idx)), 'cell_px');
save (strcat('ret', num2str(sh_idx)), 'cell_ret');
save (strcat('exret', num2str(sh_idx)), 'cell_exret');
save (strcat('date', num2str(sh_idx)), 'cell_date');

%% test new data
cd('Y:/working_directory/Matlab/Data/ML');
Sin=load('inku1');
Sout=load('outku1');
Snet=load('netku1');
cX=Sin.inX;
cnet=Snet.net;
Y=Sout.trainY;
TestY=cell(n_equity,n_factor);
cdiff=cell(n_equity,n_factor);

M=260;
TH_prc=95;
Metrics=[];
Names=[];

cd('Y:/working_directory/Matlab/Code');
for m=n_equity:n_equity
    for n=n_factor:n_factor
%         if size(rtn_Y,1)<M
%            M=size(rtn_Y,1)-N;
%         end
%         j=M;          
           in_test=zeros(N,M);
           for t=1:N
               in_test(t,:)=transpose(Px_Y(nob-M-N+t+1:nob-N+t,2));
           end
           TestY{m,n} = sim(cnet{m,n},in_test);
%         cdiff{m,n}=sum(TestY{m,n}-Y{m,n});
          date_backtest=date(nob-M+1:end);
          y_TH=prctile(TestY{m,n},TH_prc);
          ex_rtn=ex_fullrtn(nob-M+1:end);
          [s,ret_v,newmetric]=nn_backtest_v1(ex_rtn,TestY{m,n},y_TH,date_backtest);
          Metrics=[Metrics; newmetric];
          Names=[Names; transpose(new_txt1)];
        
    end
end