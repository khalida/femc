%% Loss function for selected lossType, given current parameter settings

function [loss] = lossSarma (parameterValues, demand, lossType, k,...
    trainControl)

% parameters:   current values of forecast parameters
% demand:       historic time series on which to base loss
% lossType:     handle to loss function
% k:            horizon of forecast to evaluate

% For all time-steps in demand for which forecast can be evaluated, make a
% forecast over k-steps, and compute the loss

% First find featureVectors (to feed to SARMA forecaster), and
% responseVectors (actual performance)

if ~trainControl.useHyndmanModel
    [ featureVectors, responseVectors ] = ...
        computeFeatureResponseVectors( demand, k,...
        k);
else
    [ featureVectors, responseVectors ] = ...
        computeFeatureResponseVectors( demand, k+3,...
        k);
end

nObservations = size(featureVectors, 2);
forecasts = zeros(nObservations, k);

parameters.coefficients = parameterValues;
parameters.k = k;

for iObservation = 1:nObservations
    forecasts(iObservation,:) = forecastSarma(parameters, ...
        featureVectors(:, iObservation), trainControl);
end

% loss functions expect [nDimensions x nObservations], as produced by
% computeFeatureResponseVectors
loss = lossType(responseVectors(1:trainControl.minimiseOverFirst, :),...
    forecasts(:, 1:trainControl.minimiseOverFirst)');

end
