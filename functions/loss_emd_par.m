function [ loss ] = loss_emd_par( t, y, pars )
%LOSS_EMD_PAR Compute loss metric for a k x numObs matrices of target, t,
% and forecast values, y, using a parameterised version of the EMD:

% INPUTS:
% t: matrix of targets (actuals) [nHorzn x nObs]
% y: matrix of fcast values [nHorzn x nObs]
% pars: vector of loss_emd parameters (a, b, c, d)

% OUTPUTS:
% loss: row vector of losses for each forecast [1 x nObs]

nHorzn = size(t,1);
if size(y,1) ~= nHorzn
    error('Target and forecast must have same # of steps in horizon')
end
    
if nHorzn > 200
    error('Horizon too long - training will take forever!');
end

loss = emd_hat_gd_metric_mex_vec_par(t, y, pars);

end
