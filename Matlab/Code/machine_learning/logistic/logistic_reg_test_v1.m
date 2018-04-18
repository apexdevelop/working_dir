clearvars;
%% ==================== Part 1: Load Data ====================
cd('C:/Users/YChen/Documents/git/working_dir/Matlab/Data/ML');
filename='alum_factor_rtn.xlsx';
shname='alum_factor_rtn';
[data,~]=xlsread(filename,shname,'c2:g5000'); %factor
lag=0;
X = data(1:end-lag, 1:4); y = data(lag+1:end, 5);

%% ============ Part 2: Compute Cost and Gradient ============
%  In this part of the exercise, you will implement the cost and gradient
%  for logistic regression. You neeed to complete the code in 
%  costFunction.m
%  Setup the data matrix appropriately, and add ones for the intercept term
[m, n] = size(X);
% Add intercept term to x and X_test
X1 = [ones(m, 1) X];

% Initialize fitting parameters
initial_theta1 = zeros(n + 1, 1);
% Compute and display initial cost and gradient
[cost1, grad1] = costFunction(initial_theta1, X1, y);

fprintf('Cost at initial theta (zeros): %f\n', cost1);
fprintf('Expected cost (approx): 0.693\n');
fprintf('Gradient at initial theta (zeros): \n');
fprintf(' %f \n', grad1);
% fprintf('Expected gradients (approx):\n -0.1000\n -12.0092\n -11.2628\n');


%% ============= Part 3: Optimizing using fminunc  =============
%  In this exercise, you will use a built-in function (fminunc) to find the
%  optimal parameters theta.

%  Set options for fminunc
options1 = optimset('GradObj', 'on', 'MaxIter', 400);

%  Run fminunc to obtain the optimal theta
%  This function will return theta and the cost 
[theta1, cost1] = ...
	fminunc(@(t)(costFunction(t, X1, y)), initial_theta1, options1);

% Print theta to screen
fprintf('Cost at theta found by fminunc: %f\n', cost1);
fprintf('Expected cost (approx): 0.203\n');
fprintf('theta: \n');
fprintf(' %f \n', theta1);
fprintf('Expected theta (approx):\n');
% fprintf(' -25.161\n 0.206\n 0.201\n');

%% ============== Part 4: Predict and Accuracies ==============
%  After learning the parameters, you'll like to use it to predict the outcomes
%  on unseen data. 
%
%  Furthermore, you will compute the training and test set accuracies of 
%  our model.

% prob = sigmoid([1 data(end,1:4)] * theta);
% fprintf(['For the return of other aluminum stocks, we predict the ' ...
%          'probability of chalco's return is up is %f\n'], prob);
% fprintf('Expected value: 0.775 +/- 0.002\n\n');

% Compute accuracy on our training set
p1 = predict(theta1, X1);

accuracy1=mean(double(p1 == y)) * 100;
fprintf('Train Accuracy: %f\n', accuracy1);
fprintf('Expected accuracy (approx): 89.0\n');
fprintf('\n');


%% Logistic Regression

%  To do so, you introduce more features to use -- in particular, you add
%  polynomial features to our data matrix (similar to polynomial
%  regression).
%

% Add Polynomial Features

% Note that mapFeature also adds a column of ones for us, so the intercept
% term is handled
X2 = mapFeature(X(:,1), X(:,2),6);
X2 = mapFeature3D(X(:,1), X(:,2), X(:,3),4);
X2 = mapFeature4D(X(:,1), X(:,2), X(:,3), X(:,4),5);

% Initialize fitting parameters
initial_theta2 = zeros(size(X2, 2), 1);

% Set regularization parameter lambda to 1
lambda = 1;

% Compute and display initial cost and gradient for regularized logistic
% regression
[cost2, grad2] = costFunctionReg(initial_theta2, X2, y, lambda);
% ============= Part 2: Regularization and Accuracies =============

% Set Options
options2 = optimset('GradObj', 'on', 'MaxIter', 400);

% Optimize
[theta2, J, exit_flag] = ...
	fminunc(@(t)(costFunctionReg(t, X2, y, lambda)), initial_theta2, options2);


% Compute accuracy on our training set
p2 = predict(theta2, X2);
accuracy2=mean(double(p2 == y)) * 100;
fprintf('Train Accuracy: %f\n', accuracy2);
fprintf('Expected accuracy (with lambda = 1): 83.1 (approx)\n');