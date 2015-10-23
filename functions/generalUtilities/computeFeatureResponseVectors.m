function [ featureVectors, responseVectors ] = ...
    computeFeatureResponseVectors( inputTimeSeries, nLags, horizon)

% computeFeatureResponseVectors: Produce arrays of feature and response
% vectors from a time-series of values

% INPUTS
% inputTimeSeries: [1 x time series length] of values
% nLags:           No. of lags to include in feature vector
% horizon:         Legnth of horizon to include as output

% OUTPUTS
% featureVectors: [nLags x nObservations], matrix of feature vectors
% responseVectors: [horizon x nObservations], matrix of response vectors

% nObserverations is determined from the length of the original time-series

% Check for invalid values:
if nLags <= 0, error('nLags must be postive'); end
if ~isWholeNumber(nLags), error('nLags must be an integer'); end
if horizon <= 0, error('horizon must be postive'); end
if ~isWholeNumber(horizon), error('horizon must be an integer'); end
    
timeSeriesLength = length(inputTimeSeries);
nObservations = timeSeriesLength - nLags - horizon + 1;
if nObservations <= 0, error('Insufficient Data'); end

lagIndices = repmat(1:nLags, [nObservations, 1]) + ...
    repmat((0:(nObservations-1))', [1, nLags]);

responseIndices = repmat(nLags + (1:horizon), [nObservations, 1]) + ...
    repmat((0:(nObservations-1))', [1, horizon]);

if max(responseIndices(:)) ~= timeSeriesLength
    error('Problem with extracting indices');
end

featureVectors = inputTimeSeries(lagIndices)';
responseVectors = inputTimeSeries(responseIndices)';

end
