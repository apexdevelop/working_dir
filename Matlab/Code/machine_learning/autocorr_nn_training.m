%https://www.mathworks.com/help/nnet/gs/neural-network-time-series-prediction-and-modeling.html
%% Neural Network on autocorrelation
%for now the data is calculated from crosspod_v2.m under cross_border
%folder
enddate=today()-4;
% function [net,trainY,inX,tr,Test_perf]= sfactor_nn_training(sh_idx,opt_x,opt_save_train,txt1,txt2,txt3,N)
%choices of how to get input data
% if opt_x==1
%    %option 1 pull data from Bloomberg
%    cd('Y:/working_directory/Matlab/Code/machine_learning');
%    opt_save_generate=2; %don't save
%    [txt1,txt2,txt3,cell_px,cell_ret,cell_exret,cell_ob,cell_date,cell_target]= sfactor_generateData(sh_idx, opt_save_generate);
% elseif opt_x==2
   %option 2 load data from saved database
   cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/ML');
   S_anbpx=load(strcat('c_anbpx', '_autocorr_',datestr(enddate)));
   S_onbpx=load(strcat('c_onbpx', '_autocorr_',datestr(enddate)));
   S_repod=load(strcat('c_repod', '_autocorr_',datestr(enddate)));
   
   c_anbpx=S_anbpx.c_anbpx;
   c_onbpx=S_onbpx.c_onbpx;
   c_repod=S_repod.c_repod;
% end

n_pair=size(c_anbpx,1);
net=cell(n_pair,1);
trainY=cell(n_pair,1);
inX=cell(n_pair,1);
tr=cell(n_pair,1);
targetY=cell(n_pair,1);
cPerf=cell(n_pair,1);
cell_ob=cell(n_pair,1);
cell_exrtn=cell(n_pair,1);
% new_net = fitnet(10);
N=10;
Test_perf=[];
m=1;
% for m=1:n_pair
        nob=size(c_anbpx{m,1},1);
        cell_ob{m,1}=nob;
        v_opx=c_onbpx{m,1}(:,1);
        v_ortn=diff(v_opx)./v_opx(1:end-1);
        v_obpx=c_onbpx{m,1}(:,2);
        v_obrtn=diff(v_obpx)./v_obpx(1:end-1);
        v_exrtn=(v_ortn-v_obrtn)*100;
        cell_exrtn{m,1}=v_exrtn;
        v_pod=c_repod{m,1};
        input_fpx=zeros(nob-N,N);
        for t=1:N
            input_fpx(:,t)=v_pod(t:nob-N+t-1);
        end            
        %nn matlab, observations are by column
        tempInput1=v_pod(2:end);
        tempTarget1=v_exrtn;
        tempInput=transpose(input_fpx);
        inX{m,1}=tempInput;
        tempTarget=transpose(v_exrtn(N:end));
        targetY{m,1}=tempTarget;
        %% nn training
        net{m,1}=new_net;
        [net{m,1},tr{m,1}] = train(net{m,1},inX{m,1},targetY{m,1});
        trainY{m,1}=net{m,1}(inX{m,1});
        %performance data
        testT = targetY{m,1}(:,tr{m,1}.testInd);
        testY = trainY{m,1}(:,tr{m,1}.testInd);
        cPerf{m,1} = mse(net{m,1},testT,testY,'normalization','standard');
        Test_perf = [Test_perf;cPerf{m,1}];
% end
% if opt_save_train==1
cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/ML');

save (strcat('in', '_autocorr_',datestr(enddate)), 'inX');
save (strcat('out', '_autocorr_',datestr(enddate)), 'trainY');
save (strcat('net', '_autocorr_',datestr(enddate)), 'net');
save (strcat('target', '_autocorr_',datestr(enddate)), 'targetY');
save (strcat('cPerf', '_autocorr_',datestr(enddate)), 'cPerf');
save (strcat('ob', '_autocorr_',datestr(enddate)), 'cell_ob');
save (strcat('exrtn', '_autocorr_',datestr(enddate)), 'cell_exrtn');
% end