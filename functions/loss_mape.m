function [ loss ] = loss_mape( t, y ) %#codegen
%LOSS_MAPE Compute loss metric for a k x numObs matrices of target, t, and
%       forecast values, y.

% If numObs == 1; return a single loss value
% Otherwise return a 1 x numObs row vector of costs for each k-step
% forecast

k = size(t,1);
if size(y,1) ~= k
    error('Target and forecast must have same # of steps')
end

numObs = size(t,2);
if size(y,2) ~= numObs
    error('Target and forecast must have same # of observations')
end

% if k ~= 48; warning('Forecast doesnt have 48 steps'); end

loss = mean(abs(t-y)./(t+eps), 1);

end