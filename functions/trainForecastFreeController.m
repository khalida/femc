function [ pars ] = trainForecastFreeController( ...
    demandValuesTrain, Sim, trainControl, MPC)
% trainForecastFreeController: Train a forecast free controller
%   Given the trainControl parameters, details of the plant to be
%   controlled and a time-series of historic data.

meanKWh = mean(demandValuesTrain);
k = trainControl.horizon;

%% Seperate training data into initialization (1-day) and training (rest)
nDaysInitialization = 1;
initializationIdxs = 1:(nDaysInitialization*stepsPerDay);
demandValuesInitialization = demandValuesTrain(initializationIdxs, :);
demandValuesTrainOnly = demandValuesTrain(setdiff(trainIdxs,...
    initializationIdxs), :);

% Create 'historical load pattern' used for initialization etc.
loadPatternInitialization = mean(reshape( demandValuesInitialization, ...
    [k, length(demandValuesInitialization)/k]), 2);

%% Create the godCast for training data
godCast = zeros(size(demandValuesTrainOnly, 1), k);
for ii = 1:k
    godCast(:, ii) = circshift(demandValuesTrainOnly, -[ii-1, 0]);
end

%% Set-up parameters for on-line simulation
batteryCapacity = meanKWh*Sim.batteryCapacityRatio*Sim.stepsPerDay;
maximumChargingRate = Sim.batteryChargingFactor*batteryCapacity;
simRangeTrain = [0 Sim.nHoursTrain - ...
    Sim.hoursPerDay*Sim.nDaysInitialization - 1/Sim.stepsPerHour];

hourNumbersTrainOnly = Sim.hourNumbersTrain(setdiff(trainIdxs,...
    initializationIdxs));

%% Run On-line Model to create training examples
[ featureVectors, decisionVectors] = ...
    mpcGenerateForecastFreeExamples( simRangeTrain, godCast,...
    demandValuesTrainOnly, batteryCapacity, ...
    maximumChargingRate, loadPatternInitialization, ...
    hourNumbersTrainOnly, Sim.stepsPerHour, k, MPC);

allFeatureVectors = zeros(size(featureVectors, 1), length(...
    demandValuesTrainOnly)*(Sim.nTrainShuffles + 1));

allDecisionVectors = zeros(size(decisionVectors, 1), length(...
    demandValuesTrainOnly)*(Sim.nTrainShuffles + 1));

allFeatureVectors(:, 1:length(demandValuesTrainOnly)) = featureVectors;
allDecisionVectors(:, 1:length(demandValuesTrainOnly)) = decisionVectors;
offset = length(demandValuesTrainOnly);

%% Continue generating examples with suffled versions of training data:
for eachShuffle = 1:Sim.nTrainShuffles
    newDemandValuesTrain = demandValuesTrainOnly;
    for eachSwap = 1:Sim.nDaysSwap
        thisSwapStart = randi(length(demandValuesTrainOnly) - 2*k);
        tmp = newDemandValuesTrain(thisSwapStart + (1:k));
        newDemandValuesTrain(thisSwapStart + (1:k)) = ...
            newDemandValuesTrain(thisSwapStart + (1:k) + k);
        newDemandValuesTrain(thisSwapStart + (1:k) + k) = tmp;
    end
    [ featureVectors, decisionVectors] = ...
        mpcGenerateForecastFreeExamples( simRangeTrain, ...
        godCast, newDemandValuesTrain, batteryCapacity, ...
        maximumChargingRate, loadPatternInitialization, ...
        hourNumbersTrainOnly, Sim.stepsPerHour, k, MPC);
    
    allFeatureVectors(:, offset + (1:length(demandValuesTrainOnly))) = ...
        featureVectors;
    
    allDecisionVectors(:, offset + (1:length(demandValuesTrainOnly))) = ...
        decisionVectors;
    
    offset = offset + length(demandValuesTrainOnly);
end

%% Train forecast free NN model based on examples generated
pars = generateForecastFreeController( allFeatureVectors, ...
    allDecisionVectors, nHidden, trainControl.nStart);

end
