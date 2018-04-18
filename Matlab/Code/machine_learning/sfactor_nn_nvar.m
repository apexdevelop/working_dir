%% Neural Network
function [net,cOutputs,inX,ctr,v_test_perf,v_total_perf]= sfactor_nn_nvar(txt1,txt2,txt3,sh_idx,opt_save_train,mov_window,N,size_hidden)
cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/ML');
Sob=load(strcat('ob', num2str(sh_idx)));
Spx=load(strcat('px', num2str(sh_idx)));
Sret=load(strcat('ret', num2str(sh_idx)));
cell_ob=Sob.cell_ob;
cell_px=Spx.cell_px;
cell_ret=Sret.cell_ret;

[n_equity,n_factor]=size(cell_px);
net=cell(n_equity,n_factor);
cOutputs=cell(n_equity,n_factor);
inX=cell(n_equity,n_factor);
inStates=cell(n_equity,n_factor);
clayerStates=cell(n_equity,n_factor);
ctr=cell(n_equity,n_factor);
cTargets=cell(n_equity,n_factor);
cTestperf=cell(n_equity,n_factor); %[R,Beta,Alpha,Err]
cTotalperf=cell(n_equity,n_factor); %[R,Beta,Alpha,Err]
inputDelays=N;
feedbackDelays=N;
new_net =narxnet(inputDelays,feedbackDelays,size_hidden);
v_test_perf=[];
v_total_perf=[];
for m=1:n_equity %equity and market
    for n=1:n_factor %factor
        nob=cell_ob{m,n};
        Px_Y=cell_px{m,n};
        rtn_Y=cell_ret{m,n};
%         input_fpx=Px_Y(:,2);
%         input_frtn=rtn_Y(:,2);
      
        er_row=reshape(rtn_Y(:,1),1,size(rtn_Y,1));
        temp_emov=tsmovavg(er_row,'e',mov_window);
        er_mov=mov_window*[er_row(1:(mov_window-1)) temp_emov(mov_window:end)];        
        if ~strcmpi(char(txt2(n)),char(txt3(m))) && ~strcmpi(char(txt1(m)),char(txt2(n)))
           fr_row=reshape(rtn_Y(:,2),1,size(rtn_Y,1));
           temp_fmov=tsmovavg(fr_row,'e',mov_window);
           fr_mov=mov_window*[fr_row(1:(mov_window-1)) temp_fmov(mov_window:end)];                      
           br_row=reshape(rtn_Y(:,3),1,size(rtn_Y,1));
           temp_bmov=tsmovavg(br_row,'e',mov_window);
           br_mov=mov_window*[br_row(1:(mov_window-1)) temp_bmov(mov_window:end)];
        elseif strcmpi(char(txt2(n)),char(txt3(m))) || strcmpi(char(txt1(m)),char(txt2(n)))
           br_mov=fr_mov;
        else
        end       
        ex_mov_rtn=er_mov-br_mov;
        %nn matlab, observations are by column
        
        % Prepare the Data for Training and Simulation
        % The function PREPARETS prepares time series data 
        % for a particular network, shifting time by the minimum 
        % amount to fill input states and layer states.
        % Using PREPARETS allows you to keep your original 
        % time series data unchanged, while easily customizing it 
        % for networks with differing numbers of delays, with
        % open loop or closed loop feedback modes.
        inputSeries=num2cell(fr_mov);
        targetSeries=num2cell(ex_mov_rtn);
       [inputs,inputStates,layerStates,targets] = preparets(new_net,inputSeries,{},targetSeries);
        
        inX{m,n}=inputs;
        cTargets{m,n}=targets;
        inStates{m,n}=inputStates;
        clayerStates{m,n}=layerStates;
        %% nn training
        
        [new_net,tr] = train(new_net,inputs,targets,inputStates,layerStates);
        net{m,n}=new_net;
        ctr{m,n}=tr;
        % Test the Network
        outputs=new_net(inputs,inputStates,layerStates);
        cOutputs{m,n}=outputs;
        %performance data
        testT = targets(:,tr.testInd);
        testY = outputs(:,tr.testInd);
        [testR,testBeta,testAlpha] = regression(targets,outputs);
        testErr= mse(new_net,testT,testY,'normalization','standard');
        test_perf=[testR testBeta testAlpha testErr];
        v_test_perf = [v_test_perf;test_perf];
        cTestperf{m,n}=test_perf;
        
        [totalR,totalBeta,totalAlpha] = regression(targets,outputs);
        totalErr= mse(new_net,targets,outputs,'normalization','standard');
        total_perf=[totalR totalBeta totalAlpha totalErr];
        v_total_perf = [v_total_perf;total_perf];
        cTotalperf{m,n}=total_perf;
    end
end
if opt_save_train==1
cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/ML');
save (strcat('in', num2str(sh_idx), '_lag_',num2str(N)), 'inX');
save (strcat('out', num2str(sh_idx), '_lag_',num2str(N)), 'cOutputs');
save (strcat('net', num2str(sh_idx), '_lag_',num2str(N)), 'net');
save (strcat('target', num2str(sh_idx), '_lag_',num2str(N)), 'cTargets');
save (strcat('cTestperf', num2str(sh_idx), '_lag_',num2str(N)), 'cTestperf');
save (strcat('cTotalperf', num2str(sh_idx), '_lag_',num2str(N)), 'cTotalperf');
end