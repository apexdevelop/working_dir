%optimize based on column opti_idx
function [max_idx,respmax,varmax,resp,V_var] = parameterSweep_v3(fun,range,opti_idx)
%PARAMETERSWEEP performs a parameters sweep for a given function
%   RESPMAX = PARAMETERSWEEP(FUN,RANGE) takes as input a function handle in
%   FUN and the range of allowable values for inputs in RANGE.
%
%   FUN is a function handle that accepts one input and returns one output,
%   F = FUN(X), where X is an array of size N x M.  N is the number of
%   observations (rows) and M is the number of variables (columns).  F is
%   the response of size N x 1, a column vector;
%
%   RANGE is a cell array of length M that contains a vector of ranges for
%   each variable.
%
%   [RESPMAX,VARMAX,RESP,VAR] = PARAMETERSWEEP(FUN,RANGE) returns the
%   maximum response value in RESPMAX, the location of the maximum value in
%   VARMAX, an N-D array of the response values in RESP, and and N-D array
%   where the size of the N-D array depends upon the values in RANGE.
%   NDGRID is used to generate the arrays.
%
%   Examples:
%   % Example 1: peaks function
%     range = {-3:0.1:3, -3:0.2:3};  % range of x and y variables
%     fun = @(x) deal( peaks(x(:,1),x(:,2)) ); % peaks as a function handle
%     [respmax,varmax,resp,var] = parameterSweep(fun,range);
%     surf(var{1},var{2},resp)
%     hold on, grid on
%     plot3(varmax(1),varmax(2),respmax,...
%         'MarkerFaceColor','k', 'MarkerEdgeColor','k',...
%         'Marker','pentagram', 'LineStyle','none',...
%         'MarkerSize',20, 'Color','k');
%     hold off
%     xlabel('x'),ylabel('y')
%     legend('Surface','Max Value','Location','NorthOutside')
%
%   See also ndgrid

%%
% Copyright 2010, The MathWorks, Inc.
% All rights reserved.

%% Check inputs
if nargin == 0
   %error
else
    %% Generate expression for ndgrid
    N1 = length(range);
    if N1 == 1
        var = range;
    else
        var = cell(1,N1);
        [var{:}] = ndgrid(range{:});
    end
    %% Perform parameter sweep
    sz = size(var{1});
    V_var=[];%V is the matrix form of grid of parameters
    for i = 1:N1
        new_v_var=var{i}(:);
        V_var=[V_var new_v_var];
        var{i} = var{i}(:);
    end
    mat_var=cell2mat(var);
    resp = fun(mat_var);
    
    %% Find maximum value and location
    [respmax,max_idx]   = max(resp(:,opti_idx));
    for i = 1:N1
        varmax(i) = var{i}(max_idx);
    end
    
    %% Reshape output only if requested
    if nargout > 2
        n_col=size(resp,2);
        c_resp=cell(1,n_col);
        for j=1:n_col
            c_resp{1,j} = reshape(resp(:,j),sz);
        end
        
        for i = 1:N1
            var{i} = reshape(var{i},sz);
        end
    end %if
    
end %if

%% Examples
% function example()
% 
% figure(1), clf
% range = {-3:0.1:3, -3:0.2:3};  % range of x and y variables
% fun = @(x) deal( peaks(x(:,1),x(:,2)) ); % peaks as a function handle
% [respmax,varmax,resp,var] = parameterSweep(fun,range);
% surf(var{1},var{2},resp)
% hold on, grid on
% plot3(varmax(1),varmax(2),respmax,...
%     'MarkerFaceColor','k', 'MarkerEdgeColor','k',...
%     'Marker','pentagram', 'LineStyle','none',...
%     'MarkerSize',20, 'Color','k');
% hold off
% xlabel('x'),ylabel('y')
% legend('Surface','Max Value','Location','NorthOutside')