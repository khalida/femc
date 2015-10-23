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

if delta <= 1   % 0 and 1-permutation mean no permutation radius
    
    % Apply additional penalty for underforcasts
    loss = (abs(t - y).*((t - y)<=0) + ...
        abs(t - y).*((t - y)>0).*alpha)./(1+alpha);
    
    % Apply additional weight to earlier time-steps
    weights = linspace(gamma, 1, horizon)';
    weights = weights./(sum(weights)/horizon);    % So weights sum up to k
    weights = repmat(weights, [1, nObservations]);
    loss = loss.*weights;
    
    % Take mean using appropriate exponent for errors
    loss = mean(loss.^beta, 1).^(1/beta);
else
    allPerms = makeAllLimitedPermutations(horizon, nPermutationsMax, delta);
    
    % now compute loss for each permutation
    allLosses = zeros((allPermsIdx-1), nObservations);
    
    for index = 1:size(allLosses, 1);
        t_perm = t(allPerms(:, index), :);
        y_perm = y(allPerms(:, index), :);
        
        % Apply additional penalty for underforcasts
        loss_temp = (abs(t_perm - y_perm).*((t_perm - y_perm)<=0) + ...
            abs(t_perm - y_perm).*((t_perm - y_perm)>0).*alpha)./(1+alpha);
        
        % Apply additional weight to earlier time-steps
        weights = linspace(gamma, 1, horizon)';
        weights = weights./(sum(weights)/horizon);    % So weights sum up to k
        weights = repmat(weights, [1, nObservations]);
        loss_temp = loss_temp.*weights;
        
        % Take mean using appropriate exponent for errors
        allLosses(index, :) = mean(loss_temp.^beta, 1).^(1/beta);
    end
    
    % Find mean losses over all observations
    allMeanLosses = mean(allLosses, 2);
    [~, minIdx] = min(allMeanLosses);
    loss = allLosses(minIdx, :);
end

end
