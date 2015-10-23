function [ loss ] = lossEmd( t, y )
% lossEmd: Compute loss metric for k x nObservations matrices of target,
            % t, and forecast values, y.

% If nObservations == 1; return a single loss value

% Otherwise return a 1 x nObservations row vector of costs for each k-step
% forecast

k = size(t,1);
if size(y,1) ~= k;
    error('Target and forecast must have same # of steps');
end

% if k ~= 48; warning('Forecast doesnt have 48 steps'); end

nObservations = size(t, 2);
if size(y,2) ~= nObservations;
    error('Target and forecast must have same nObservations');
end

loss = emd_hat_gd_metric_mex_vec(t, y);

end
