function accuracy=logistic_reg_with_map_feature(lag,data)
X = data(1:end-lag, 1:4); y = data(lag+1:end, 5);


%% Logistic Regression

%  To do so, you introduce more features to use -- in particular, you add
%  polynomial features to our data matrix (similar to polynomial
%  regression).
%

% Add Polynomial Features

% Note that mapFeature also adds a column of ones for us, so the intercept
% term is handled
% X2 = mapFeature(X(:,1), X(:,2),6);
% X2 = mapFeature3D(X(:,1), X(:,2), X(:,3),4);
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
accuracy=mean(double(p2 == y)) * 100;
% fprintf('Train Accuracy: %f\n', accuracy2);
% fprintf('Expected accuracy (with lambda = 1): 83.1 (approx)\n');