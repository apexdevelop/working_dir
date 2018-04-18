clearvars;
%% ==================== Part 1: Load Data ====================
cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/ML');
filename='alum_factor_rtn.xlsx';
shname='alum_factor_rtn';
[data,~]=xlsread(filename,shname,'c2:g5000'); %factor
v_lag=0:10;
v_accuracy=zeros(size(v_lag,2),1);
for i=1:size(v_lag,2)
    lag=v_lag(i);
    v_accuracy(i)=logistic_reg_with_map_feature(lag,data);
end