%% Machine Learning Online Class - Exercise 3 | Part 1: One-vs-all

%  Instructions
%  ------------
%
%  This file contains code that helps you get started on the
%  linear exercise. You will need to complete the following functions
%  in this exericse:
%
%     lrCostFunction.m (logistic regression cost function)
%     oneVsAll.m
%     predictOneVsAll.m
%     predict.m
%
%  For this exercise, you will not need to change any code in this file,
%  or any other files other than those mentioned above.
%

%% Initialization
clearvars;

%% =========== Part 1: Loading and Visualizing Data =============
%  We start the exercise by first loading and visualizing the dataset.
%  You will be working with a dataset that contains handwritten digits.
%

% Load Training Data

cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/ML');
filename='logistic_factor_rtn.xlsx';
shname='alum_factor_rtn';
[X,~]=xlsread(filename,shname,'c2:f5000'); %factor

[y,~]=xlsread(filename,shname,'j2:j5000'); %leveled result

%% ============ Part 2a: Vectorize Logistic Regression ============
%  In this part of the exercise, you will reuse your logistic regression
%  code from the last exercise. You task here is to make sure that your
%  regularized logistic regression implementation is vectorized. After
%  that, you will implement one-vs-all classification for the handwritten
%  digit dataset.
%

% Test case for lrCostFunction
fprintf('\nTesting lrCostFunction() with regularization');

theta_t = [-2; -1; 1; 2];
X_t = [ones(5,1) reshape(1:15,5,3)/10];
y_t = ([1;0;1;0;1] >= 0.5);
lambda_t = 3;
[J grad] = lrCostFunction(theta_t, X_t, y_t, lambda_t);

fprintf('\nCost: %f\n', J);
fprintf('Expected cost: 2.534819\n');
fprintf('Gradients:\n');
fprintf(' %f \n', grad);
fprintf('Expected gradients:\n');
fprintf(' 0.146561\n -0.548558\n 0.724722\n 1.398003\n');

%% ============ Part 2b: One-vs-All Training ============
fprintf('\nTraining One-vs-All Logistic Regression...\n')
tempX = mapFeature4D(X(:,1), X(:,2), X(:,3), X(:,4),5);
X2=tempX(:,2:end);

%if only use X as input, instead of map feature, accuracy is lower
% X2=X; 

% Setup the parameters you will use for this part of the exercise
num_labels = 10;          % 10 labels, from 1 to 10
                          % (note that we have mapped "0" to label 10)

lambda = 0.1;
[all_theta] = oneVsAll(X2, y, num_labels, lambda);


%% ================ Part 3: Predict for One-Vs-All ================

pred = predictOneVsAll(all_theta, X2);
accuracy=mean(double(pred == y)) * 100;
fprintf('\nTraining Set Accuracy: %f\n', accuracy);

