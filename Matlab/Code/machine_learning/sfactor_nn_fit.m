%% Neural Network
function [net,trainY,inX,tr,Test_perf]= sfactor_nn_fit(txt1,txt2,txt3,sh_idx,opt_save_train,N,size_hidden)
%choices of how to get input data
% if opt_x==1
%    %option 1 pull data from Bloomberg
%    cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Code/machine_learning');
%    opt_save_generate=2; %don't save
%    [txt1,txt2,txt3,cell_px,cell_ret,cell_exret,cell_ob,cell_date,cell_target]= sfactor_generateData(sh_idx, opt_save_generate,N);
% elseif opt_x==2
   %option 2 load data from saved database
   cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/ML');
   Sob=load(strcat('ob', num2str(sh_idx)));
   Spx=load(strcat('px', num2str(sh_idx)));
   Sret=load(strcat('ret', num2str(sh_idx)));
   cell_ob=Sob.cell_ob;
   cell_px=Spx.cell_px;
   cell_ret=Sret.cell_ret;
% end
[n_equity,n_factor]=size(cell_px);
net=cell(n_equity,n_factor);
trainY=cell(n_equity,n_factor);
inX=cell(n_equity,n_factor);
tr=cell(n_equity,n_factor);
targetY=cell(n_equity,n_factor);
cPerf=cell(n_equity,n_factor);
cR=cell(n_equity,n_factor);
cBeta=cell(n_equity,n_factor);
cAlpha=cell(n_equity,n_factor);
new_net = fitnet(size_hidden);
Test_perf=[];
for m=1:n_equity %equity and market
    for n=1:n_factor %factor
        nob=cell_ob{m,n};
        Px_Y=cell_px{m,n};
        rtn_Y=cell_ret{m,n};
        input_fpx=zeros(nob-N,N);
        for t=1:N
            input_fpx(:,t)=Px_Y(t:nob-N+t-1,2);
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
        ex_mov_rtn=transpose(er_mov(N+1:end)-br_mov(N+1:end));
        %nn matlab, observations are by column
        inX{m,n}=transpose(input_fpx);
        targetY{m,n}=transpose(ex_mov_rtn);
        %% nn training
        net{m,n}=new_net;
        [net{m,n},tr{m,n}] = train(net{m,n},inX{m,n},targetY{m,n});
        trainY{m,n}=net{m,n}(inX{m,n});
        %performance data
        testT = targetY{m,n}(:,tr{m,n}.testInd);
        testY = trainY{m,n}(:,tr{m,n}.testInd);
        cPerf{m,n} = mse(net{m,n},testT,testY,'normalization','standard');
        [cR{m,n},cBeta{m,n},cAlpha{m,n}] = regression(targetY{m,n},trainY{m,n});
        Test_perf = [Test_perf;cPerf{m,n}];
    end
end
if opt_save_train==1
cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/ML');
save (strcat('in', num2str(sh_idx), '_lag_',num2str(N)), 'inX');
save (strcat('out', num2str(sh_idx), '_lag_',num2str(N)), 'trainY');
save (strcat('net', num2str(sh_idx), '_lag_',num2str(N)), 'net');
save (strcat('target', num2str(sh_idx), '_lag_',num2str(N)), 'targetY');
save (strcat('cPerf', num2str(sh_idx), '_lag_',num2str(N)), 'cPerf');
save (strcat('cR', num2str(sh_idx), '_lag_',num2str(N)), 'cR');
save (strcat('cBeta', num2str(sh_idx), '_lag_',num2str(N)), 'cBeta');
save (strcat('cAlpha', num2str(sh_idx), '_lag_',num2str(N)), 'cAlpha');
end