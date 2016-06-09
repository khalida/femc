% file: trainFfnnMultipleStarts.m
% auth: Khalid Abdulla
% date: 21/10/2015
% brief: run trainFfnn multiple times and return best performing model

function bestNet = trainFfnnMultipleStarts(cfg, demand, lossType)

% INPUTS
% cfg:          structure with all of the running options
% demand:       time-history of demands on which to train the model
% lossType:     a handle to the loss function to train to minimise

% OUTPUTS
% bestNet:      best NN found

% Produce data formated for NN training
[ featureVectors, responseVectors ] = ...
    computeFeatureResponseVectors( demand, cfg.fc.nLags, cfg.sim.horizon);

nObservations = size(featureVectors,2);
nObservationsTrain = floor(nObservations*cfg.fc.trainRatio);
nObservationsTest = nObservations - nObservationsTrain;

idxs = randperm(nObservations);
idxsTrain = idxs(1:nObservationsTrain);
idxsTest = idxs(nObservationsTrain+(1:nObservationsTest));

featureVectorsTrain = featureVectors(:,idxsTrain);
featureVectorsTest = featureVectors(:,idxsTest);

responseVectorsTrain = responseVectors(:,idxsTrain);
responseVectorsTest = responseVectors(:,idxsTest);

performances = zeros(1, cfg.fc.nStart);
allNets = cell(1, cfg.fc.nStart);
allForecasts = cell(1, cfg.fc.nStart);

for iStart = 1:cfg.fc.nStart
    allNets{1, iStart} = trainFfnn( featureVectorsTrain,...
        responseVectorsTrain, lossType, cfg.fc);
    
    allForecasts{1, iStart} = forecastFfnn(cfg, allNets{1, iStart},...
        featureVectorsTest);
    
    performances(1, iStart) = mean(lossType(responseVectorsTest( ...
        1:cfg.fc.minimiseOverFirst, :), ...
        allForecasts{1, iStart}(1:cfg.fc.minimiseOverFirst, :)), 2);
end

[~, idxBest] = min(performances);

% Output performance of each model if difference is > threshold
percentageDifference = (max(performances) - min(performances)) / ...
    min(performances);

if percentageDifference > cfg.fc.perfDiffThresh
    
    disp(['Percentage Difference: ' num2str(100*percentageDifference)...
        '. Performances: ' num2str(performances) ...
        '. Loss Fcn: ' func2str(lossType)]);
end

bestNet = allNets{1, idxBest};

end
