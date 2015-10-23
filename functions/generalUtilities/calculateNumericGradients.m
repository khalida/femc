% file: calculateNumericGradients.m
% auth: Khalid Abdulla
% date: 21/10/2015
% brief: Calculate numerical gradients of a function at a given point

function [ gradients ] = calculateNumericGradients( functionHandle,...
    x0, nSided, varargin ) %#codegen

% calculateNumericGradients Calculate numeric gradients of a function

% INPUTS
% functionHandle: handle for the function (must output a number)
% x0:             points about which to compute gradient (vector of points)
%                   must be in form: [nDimensions x nPoints]
% nSided:         1 for 1-sided gradient, 2 for 2-sided gradient
% gradEps:        optional difference used to calc. grads (a number)

% OUTPUTS
% gradients: w.r.t. each dimension for each point in x0
%           (has same dimensions as x0; [nDimensions x nPoints])

if isempty(varargin)
    gradEps = eps.^0.5;
elseif length(varargin)==1
    gradEps = varargin{1};
else
    error('Too many input argments');
end

% Pre-allocate grads
gradients = zeros(size(x0));

if nSided == 2
    for x_idx = 1:size(x0, 1)
        x_plus = x0;
        x_minus = x0;
        x_plus(x_idx, :) = x_plus(x_idx, :) + gradEps;
        x_minus(x_idx, :) = x_minus(x_idx, :) - gradEps;
        gradients(x_idx, :) = (functionHandle(x_plus) - ...
            functionHandle(x_minus))./(2*gradEps);
    end
    
elseif nSided == 1
    
    centralValue = functionHandle(x0);
    for x_idx = 1:size(x0, 1)
        x_plus = x0;
        x_plus(x_idx, :) = x_plus(x_idx, :) + gradEps;
        gradients(x_idx, :) = (functionHandle(x_plus) - ...
            centralValue)./(gradEps);
    end

else
    error('Only valid values for nSided argument are 1 or 2');
end

end