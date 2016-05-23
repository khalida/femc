%% Loss function for selected lossType, given current parameter settings

function [loss] = lossSarma (cfg, parameterValues, demand, lossType)

% parameters:   current values of forecast parameters
% demand:       historic time series on which to base loss
% lossType:     handle to loss function
% k:            horizon of forecast to evaluate

% For all time-steps in demand for which forecast can be evaluated, make a
% forecast over k-steps, and compute the loss

% First find featureVectors (to feed to SARMA forecaster), and
% responseVectors (actual performance)

if ~cfg.fc.useHyndmanModel
    [ featureVectors, responseVectors ] = ...
        computeFeatureResponseVectors( demand, cfg.sim.k,...
        cfg.sim.k);
else
    [ featureVectors, responseVectors ] = ...
        computeFeatureResponseVectors( demand, cfg.sim.k+3,...
        cfg.sim.k);
end

nObservations = size(featureVectors, 2);
forecasts = zeros(nObservations, cfg.sim.k);

parameters.coefficients = parameterValues;
parameters.k = cfg.sim.k;

for iObservation = 1:nObservations
    forecasts(iObservation,:) = forecastSarma(cfg, parameters, ...
        featureVectors(:, iObservation));
end

% loss functions expect [nDimensions x nObservations], as produced by
% computeFeatureResponseVectors
loss = lossType(responseVectors(1:cfg.fc.minimiseOverFirst, :),...
    forecasts(:, 1:cfg.fc.minimiseOverFirst)');

end
