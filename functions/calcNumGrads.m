% file: calcNumGrads.m
% auth: Khalid Abdulla
% date: 6/01/2015
% brief: Calculate numerical gradients of a function at a given point

function [ grads ] = calcNumGrads( func, x0, nSided, varargin ) %#codegen
%CALCNUMGRADS Calculate numerical gradients of a function passed in
% func:     handle for the function (must output a number)
% x0:       points about which to compute gradients (vector of points)
%           MUST BE IN FORM: [nDim x nObs]
% nSided:   1 for 1-sided gradient, 2 for 2-sided gradient
% gradEps:  optional difference used to calc. grads (a number)

% grads: output of gradients w.r.t. each of x0 (has same dimensions as x0)

if isempty(varargin)
    % gradEps = sqrt(eps);
    % TODO: This parameter has not been thoroughly trained!
    gradEps = eps.^0.5;
elseif length(varargin)==1
    gradEps = varargin{1};
else
    error('Too many input argments');
end

% Pre-allocate grads
grads = zeros(size(x0));

if nSided == 2
    for x_idx = 1:size(x0, 1)
        x_plus = x0;
        x_minus = x0;
        x_plus(x_idx, :) = x_plus(x_idx, :) + gradEps;
        x_minus(x_idx, :) = x_minus(x_idx, :) - gradEps;
        grads(x_idx, :) = (func(x_plus) - func(x_minus))./(2*gradEps);
    end
    
elseif nSided == 1
    
    centValue = func(x0);
    for x_idx = 1:size(x0, 1)
        x_plus = x0;
        x_plus(x_idx, :) = x_plus(x_idx, :) + gradEps;
        grads(x_idx, :) = (func(x_plus) - centValue)./(gradEps);
    end

else
    error('Only valid values for nSided argument are 1 or 2');
end

end