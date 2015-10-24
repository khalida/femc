function [ loss ] = lossPfem( t, y, parameters)  %#codegen
% lossPfem: Compute loss metric for [k x nObservations] matrices of
% target, t, and forecast values, y.

% INPUTS:
% t:            matrix of target (actual) values; [horizon x nObservations]
% y:            matrix of forecast values; [horizon x nObservations]
% parameters:   vector of PFEM parameters

% OUTPUTS:
% loss:         row vector of loss values [ 1 x nObservations]

alpha = parameters(1);    % Weighting of underforecasts to overforecasts
beta = parameters(2);     % Error exponent (>>1; large errors matter more)
gamma = parameters(3);    % Ratio of 1st to final interval error weighting
delta = parameters(4);    % Allowable permutation radius (in time-steps)

horizon = size(t,1);
nObservations = size(t, 2);

if size(y,1) ~= horizon
    error('Target and forecast must have same # of steps in horizon');
end

if size(y,2) ~= nObservations
    error('Need same nObservations (columns) for target and forecast');
end

if alpha <= 0, error('alpha must be a positive real number'); end
if beta <= 0, error('beta must be a positive real number'); end
if gamma < 1, error('gamma should be >=1'); end
if delta < 0 || ~isWholeNumber(delta)
    error('delta must be a non-negative integer');
end
if delta > horizon, error('delta must be smaller than (or equal) k'); end

limitedPermutations = adjacentPairSwapLimitedPermutations(horizon, delta);
nLimitedPermutations = size(limitedPermutations, 2);

allLosses = zeros(nLimitedPermutations, nObservations);

for iPermutation = 1:nLimitedPermutations;
    yPermuted = y(limitedPermutations(:, iPermutation), :);
    
    % Apply additional penalty for underforcasts
    temporaryLoss = (abs(t - yPermuted).*((t - yPermuted)<=0) + ...
        abs(t - yPermuted).*((t - yPermuted)>0).*alpha)./((1+alpha)/2);
    
    % Apply additional weight to earlier intervals
    weights = linspace(gamma, 1, horizon)';
    weights = weights./(sum(weights)/horizon);    % So weights sum up to k
    weights = repmat(weights, [1, nObservations]);
    temporaryLoss = temporaryLoss.*weights;
    
    % Take mean using appropriate exponent for errors
    allLosses(iPermutation, :) = ...
        mean(temporaryLoss.^beta, 1).^(1/beta);
end

% Find minimum losses (lowest-loss permutation) over all observations
allMinimumLosses = min(allLosses,[], 1);

% And return these losses
loss = allMinimumLosses;

end
