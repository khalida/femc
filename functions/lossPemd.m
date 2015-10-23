function [ loss ] = lossPemd( t, y, parameters )
% lossPemd: Compute loss metric for [k x nObservations] matrices of
            % target, t, and forecast values, y, using PEMD

% INPUTS:
% t:            matrix of targets (actuals) [horizon x nObservations]
% y:            matrix of forecast values [horizon x nObservations]
% parameters:   vector of PEMD parameters (a, b, c, d)

% OUTPUTS:
% loss:         row vector of losses for each forecast [1 x nObservations]

horizon = size(t, 1);
if size(y,1) ~= horizon
    error('Target and forecast must have same # of steps in horizon')
end
    
if horizon > 200
    error('Horizon too long - training will take forever!');
end

nObservations = size(t, 2);
if size(y,1) ~= nObservations
    error('Target and forecast must have same nObservations')
end

loss = emd_hat_gd_metric_mex_vec_par(t, y, parameters);

end
