function [ loss ] = loss_par( t, y, pars)  %#codegen
%LOSS_PAR Compute loss metric for a k x numObs matrices of target, t, and
%forecast values, y.

% INPUTS:
% t: matrix of target (actual) values; [nHorzn x nObs]
% y: matrix of forecast values; [nHorzn x nObs]
% pars: vector of PFEM parameters

% OUTPUTS:
% loss: row vector of loss values [ 1 x nObs]

alpha = pars(1);        % Weighting of underforecasts to overforecasts
beta = pars(2);         % Error exponent (>>1; large errors matter more)
gamma = pars(3);        % Ratio of 1st to final-step error weighting
delta = pars(4);        % Allowable permutation radius (in time-steps)

maxPermSize = 10000;    % Maximum number of ltd radius permutations

nHorzn = size(t,1);
nObs = size(t, 2);

if size(y,1) ~= nHorzn
    error('Target and forecast must have same # of steps in horizon'); end

if size(y,2) ~= nObs
    error('Need same # of observations (columns) for target and forecast'); end

if alpha <= 0; error('alpha must be a positive real number'); end
if beta <= 0; error('beta must be a positive real number'); end
if gamma < 1; error('gamma should be >=1'); end
if delta < 0 || mod(delta, 1) ~= 0;
    error('delta must be a non-negative integer');
end
if delta > nHorzn; error('delta must be smaller than (or equal) k'); end

if delta <= 1   % 0 and 1-permutation mean no permutation radius
    
    % Apply additional penalty for underforcasts
    loss = (abs(t - y).*((t - y)<=0) + ...
        abs(t - y).*((t - y)>0).*alpha)./(1+alpha);
    
    % Apply additional weight to earlier time-steps
    weights = linspace(gamma, 1, nHorzn)';
    weights = weights./(sum(weights)/nHorzn);    % So weights sum up to k
    weights = repmat(weights, [1, nObs]);
    loss = loss.*weights;
    
    % Take mean using appropriate exponent for errors
    loss = mean(loss.^beta, 1).^(1/beta);
else
    original = (1:nHorzn)';
    allPerms = zeros(nHorzn, maxPermSize);
    allPermsIdx = 1;
    
    for index = 1:(nHorzn-delta+1)
        before = original(1:(index-1));
        after = original((index + delta):nHorzn);
        toPermute = original(index:(index+delta-1));
        newPerms = perms(toPermute)';
        
        % Get rid of duplicate permuatations (those in which
        % last index has not moved)
        if index>1
            toKeep = newPerms(end, :) ~= toPermute(end);
            newPerms = newPerms(:, toKeep);
        end
        
        for eachCol = 1:size(newPerms, 2)
            allPerms(:, allPermsIdx) = ...
                [before; newPerms(:, eachCol); after];
            allPermsIdx = allPermsIdx + 1;
        end
    end
    if allPermsIdx > maxPermSize
        error('Too many permutations; reduce delta');
    end
    
    % now compute loss for each permutation
    allLosses = zeros((allPermsIdx-1), nObs);
    
    for index = 1:size(allLosses, 1);
        t_perm = t(allPerms(:, index), :);
        y_perm = y(allPerms(:, index), :);
        
        % Apply additional penalty for underforcasts
        loss_temp = (abs(t_perm - y_perm).*((t_perm - y_perm)<=0) + ...
            abs(t_perm - y_perm).*((t_perm - y_perm)>0).*alpha)./(1+alpha);
        
        % Apply additional weight to earlier time-steps
        weights = linspace(gamma, 1, nHorzn)';
        weights = weights./(sum(weights)/nHorzn);    % So weights sum up to k
        weights = repmat(weights, [1, nObs]);
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
