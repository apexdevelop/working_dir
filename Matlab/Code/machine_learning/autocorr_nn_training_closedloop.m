%https://www.mathworks.com/help/nnet/gs/neural-network-time-series-prediction-and-modeling.html
%% Neural Network on autocorrelation
%for now the data is calculated from crosspod_v2.m under cross_border
%folder

% crosspod_v2;

enddate=today();
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
cnet=cell(n_pair,1);
ctr=cell(n_pair,1);
cTrainY=cell(n_pair,1);
cnewY=cell(n_pair,1);
cInput=cell(n_pair,1);
cdelayedInput=cell(n_pair,1);
cInput_firststeps=cell(n_pair,1);
cai=cell(n_pair,1);
cTarget=cell(n_pair,1);
cdelayedTarget=cell(n_pair,1);
callPerf=cell(n_pair,1);
ctestPerf=cell(n_pair,1);
cpredictPerf=cell(n_pair,1);
cell_ob=cell(n_pair,1);
cell_exrtn=cell(n_pair,1);

% Create a Time Delay Network
inputDelays = 1:2;
hiddenLayerSize = 10;
trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.
new_net = timedelaynet(inputDelays,hiddenLayerSize,trainFcn);

% Test_perf=[];
% m=1;
new_window=20;
for m=1:n_pair
        nob=size(c_anbpx{m,1},1);
        cell_ob{m,1}=nob;
        v_opx=c_onbpx{m,1}(:,1);
        v_ortn=diff(v_opx)./v_opx(1:end-1);
        v_obpx=c_onbpx{m,1}(:,2);
        v_obrtn=diff(v_obpx)./v_obpx(1:end-1);
        v_exrtn=(v_ortn-v_obrtn)*100;
        cell_exrtn{m,1}=v_exrtn;
        v_pod=c_repod{m,1};
           
        %nn matlab, observations are by column
        tempInput1=v_pod(2:end);
        tempTarget1=v_exrtn;
        % Prepare the Data for Training and Simulation
        X = tonndata(tempInput1(1:end-new_window),false,false);
        T = tonndata(tempTarget1(1:end-new_window),false,false);
        [x,xi,ai,t] = preparets(new_net,X,T);
        
        cInput{m,1}=X;
        cTarget{m,1}=T;
        cdelayedInput{m,1}=x;
        cInput_firststeps{m,1}=xi;
        cai{m,1}=ai;
        cdelayedTarget{m,1}=t;
        %% nn training
        cnet{m,1}=new_net;
        [cnet{m,1},ctr{m,1}] = train(cnet{m,1},x,t,xi,ai);
        [cTrainY{m,1},Xf,Af]=cnet{m,1}(x,xi,ai);
        callPerf{m,1}= mse(cnet{m,1},t,cTrainY{m,1},'normalization','standard');
%         callPerf{m,1} = perform(cnet{m,1},t,cTrainY{m,1});
        %performance data
        testT = cTarget{m,1}(:,ctr{m,1}.testInd);
        testY = cTrainY{m,1}(:,ctr{m,1}.testInd);
        ctestPerf{m,1} = mse(cnet{m,1},testT,testY,'normalization','standard');
        
        [netc,Xic,Aic] = closeloop(cnet{m,1},Xf,Af);
        Xnew=X(end-new_window+1:end);
        Tnew=T(end-new_window+1:end);
        Ynew = netc(Xnew,Xic,Aic);
        cnewY{m,1}=Ynew;
        cpredictPerf{m,1} = mse(cnet{m,1},Tnew,Ynew,'normalization','standard');
%         Test_perf = [Test_perf;ctestPerf{m,1}];
end
% if opt_save_train==1
% cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/ML');
% 
save (strcat('in', '_autocorr_',datestr(enddate)), 'cInput');
save (strcat('out', '_autocorr_',datestr(enddate)), 'cTrainY');
save (strcat('predictout', '_autocorr_',datestr(enddate)), 'cnewY');
save (strcat('net', '_autocorr_',datestr(enddate)), 'cnet');
save (strcat('target', '_autocorr_',datestr(enddate)), 'cTarget');
save (strcat('callPerf', '_autocorr_',datestr(enddate)), 'callPerf');
save (strcat('ctestPerf', '_autocorr_',datestr(enddate)), 'ctestPerf');
save (strcat('cpredictPerf', '_autocorr_',datestr(enddate)), 'cpredictPerf');
save (strcat('ob', '_autocorr_',datestr(enddate)), 'cell_ob');
save (strcat('exrtn', '_autocorr_',datestr(enddate)), 'cell_exrtn');
% end