function [ loss ] = loss_emd( t, y )
%LOSS_EMD Compute loss metric for a k x numObs matrices of target, t, and
%forecast values, y.

% If numObs == 1; return a single loss value
% Otherwise return a 1 x numObs row vector of costs for each k-step
% forecast

k = size(t,1);
if size(y,1) ~= k; error('Target and forecast must have same # of steps'); end
% if k ~= 48; warning('Forecast doesnt have 48 steps'); end

loss = emd_hat_gd_metric_mex_vec(t, y);

end