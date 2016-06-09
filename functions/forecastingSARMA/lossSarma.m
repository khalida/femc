%% Loss function for selected lossType, given current parameter settings

function [loss] = lossSarma (cfg, parameterValues, demand, lossType)

% INPUT
% cfg:              structure with all of the running options
% parameterValues:  current values of forecast parameters
% demand:           historic time series on which to base loss
% lossType:         handle to loss function

% For all time-steps in demand for which forecast can be evaluated, make a
% forecast over cfg.sim.horizon steps ahead and compute the loss

% First find featureVectors (to feed to SARMA forecaster), and
% responseVectors (actual demand)

if ~cfg.fc.useHyndmanModel
    [ featureVectors, responseVectors ] = ...
        computeFeatureResponseVectors( demand, cfg.fc.season,...
        cfg.sim.horizon);
else
    [ featureVectors, responseVectors ] = ...
        computeFeatureResponseVectors( demand, cfg.fc.season+3,...
        cfg.sim.horizon);
end

nObservations = size(featureVectors, 2);
forecasts = zeros(nObservations, cfg.sim.horizon);

parameters.coefficients = parameterValues;
parameters.k = cfg.fc.season;

for iObservation = 1:nObservations
    forecasts(iObservation,:) = forecastSarma(cfg, parameters, ...
        featureVectors(:, iObservation));
end

% loss functions expect [nDimensions x nObservations], as produced by
% computeFeatureResponseVectors
loss = lossType(responseVectors(1:cfg.fc.minimiseOverFirst, :),...
    forecasts(:, 1:cfg.fc.minimiseOverFirst)');

end
