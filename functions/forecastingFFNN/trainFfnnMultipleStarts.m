% file: trainFfnnMultipleStarts.m
% auth: Khalid Abdulla
% date: 21/10/2015
% brief: run trainFfnn multiple times and return best performing model

function bestNet = trainFfnnMultipleStarts(cfg, demand, lossType)

% INPUTS
% demand:       is the time-history of demands on which to train the model
%                divided into training and CV as required
% lossType:     a handle to the loss function to train in order to minimise
% trainControl: structure of train control parameters

% OUTPUTS
% bestNet:      best NN found

trainControl = cfg.fc;

trainRatio = trainControl.trainRatio;

% Set default values for optional train control pars
trainControl = setDefaultValues(trainControl,...
    {'nStart', 3, 'minimiseOverFirst', trainControl.horizon,...
    'suppressOutput', true, 'nHidden', 50, 'mseEpochs', 1000});

% Produce data formated for NN training
[ featureVectors, responseVectors ] = ...
    computeFeatureResponseVectors( demand, trainControl.nLags, ...
    trainControl.horizon);

nObservations = size(featureVectors,2);
nObservationsTrain = floor(nObservations*trainRatio);
nObservationsTest = nObservations - nObservationsTrain;

idxs = randperm(nObservations);
idxsTrain = idxs(1:nObservationsTrain);
idxsTest = idxs(nObservationsTrain+(1:nObservationsTest));
featureVectorsTrain = featureVectors(:,idxsTrain);
responseVectorsTrain = responseVectors(:,idxsTrain);
featureVectorsTest = featureVectors(:,idxsTest);
responseVectorsTest = responseVectors(:,idxsTest);

nStart = trainControl.nStart;

performance = zeros(1, nStart);
allNets = cell(1, nStart);
allForecasts = cell(1, nStart);

for iStart = 1:nStart
    allNets{1, iStart} = trainFfnn( featureVectorsTrain,...
        responseVectorsTrain, lossType, trainControl);
    allForecasts{1, iStart} = forecastFfnn(cfg, allNets{1, iStart},...
        featureVectorsTest);
    
    performance(1, iStart) = mean(lossType(responseVectorsTest( ...
        1:trainControl.minimiseOverFirst, :), ...
        allForecasts{1, iStart}(1:trainControl.minimiseOverFirst, :)), 2);
end

[~, idxBest] = min(performance);

% Output performance of each model if difference is > threshold
percentageDifference = (max(performance) - min(performance)) / ...
    min(performance);

if percentageDifference > trainControl.performanceDifferenceThreshold
    
    disp(['Percentage Difference: ' num2str(100*percentageDifference)...
        '. Performances: ' num2str(performance) ...
        '. Loss Fcn: ' func2str(lossType)]);
end

bestNet = allNets{1, idxBest};

end