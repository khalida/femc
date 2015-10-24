function [ Pfem, Pemd, Sim, pars ] = trainBestForecasts( Pfem, Pemd, ...
    MPC, Sim, allDemandValues, trainControl, k, bestPfemIdx, bestPemdIdx)

% trainBestForecasts: Train forecasts to minimise stochastically
% selected parameters

tic;

%% Pre-Allocation
pars = cell(Sim.nInstances, Sim.nMethods);
timeTaken = zeros(Sim.nInstances, Sim.nMethods);

Sim.hourNumber = mod((1:size(allDemandValues{1}, 1))', k);
Sim.hourNumberTrain = Sim.hourNumber(Sim.trainIdxs, :);
trainControl.hourNumberTrain = Sim.hourNumberTrain;

%% Extract local variables for efficiency (parfor comms overhead)
nInstances = Sim.nInstances;
nMethods = Sim.nMethods;

lossTypes = Sim.lossTypes;
trainIdxs = Sim.trainIdxs;
hoursPerDay = Sim.hoursPerDay;
stepsPerHour = Sim.stepsPerHour;
batteryCapacityRatio = Sim.batteryCapacityRatio;
nHoursTrain = Sim.nHoursTrain;
batteryChargingFactor = Sim.batteryChargingFactor;
hourNumber = Sim.hourNumber;
nTrainShuffles = Sim.nTrainShuffles;
nDaysSwap = Sim.nDaysSwap;
nHidden = Sim.nHidden;
lossTypesStrings = Sim.lossTypesStrings;
stepsPerDay = Sim.stepsPerDay;
nDaysInitialization = 1;
initializationIdxs = (0:(nDaysInitialization*stepsPerDay-1)) +...
    min(trainIdxs);
trainForecastFreeIdxs = setdiff(trainIdxs, initializationIdxs);

hourNumbersTrainForecastFree = hourNumber(trainForecastFreeIdxs);
simRangeTrainForecastFree = [0 nHoursTrain - ...
    hoursPerDay*nDaysInitialization - 1/stepsPerHour];

%% Train Models
parfor instance = 1:nInstances
    
    % Extract aggregated demand
    demandValuesTrain = allDemandValues{instance}(trainIdxs);
    
    % Fore fcastfree controller seperate train data into init and training
    demandValuesTrainForecastFree = ...
        allDemandValues{instance}(trainForecastFreeIdxs);
    demandValuesInitializationForecastFree = ...
        allDemandValues{instance}(initializationIdxs, :);
    
    thisTimeTaken = zeros(1, nMethods);
    
    for forecastType = 1:nMethods
        
        thisForecastTypeString = lossTypesStrings{forecastType};%#ok<PFBNS>
        
        % No need to produce forecasts for non-trained types:
        if strcmp(thisForecastTypeString, 'naivePeriodic'); continue; end;
        if strcmp(thisForecastTypeString, 'godCast'); continue; end;
        if strcmp(thisForecastTypeString, 'setPoint'); continue; end;
        
        tempTic = tic;
        
        if ~strcmp(thisForecastTypeString, 'fcastFree')
            
            % Train conventional forecast
            if strcmp(thisForecastTypeString, 'bestPFEM')
                thisLossType = lossTypes{bestPfemIdx(instance)};                %#ok<PFBNS>
            elseif strcmp(thisForecastTypeString, 'bestEMD')
                thisLossType = lossTypes{bestPemdIdx(instance)};
            else
                thisLossType = lossTypes{forecastType};
            end
            
            pars{instance, forecastType} = trainFfnnMultipleStarts( ...
                demandValuesTrain, thisLossType, trainControl);
            
            thisTimeTaken(1, forecastType) = toc(tempTic);
            
        else
            % Train forecast free model
            meanKWh = mean(demandValuesTrain);
            
            % Create 'historical load pattern' for initialization etc.
            loadPatternInitialization = mean(reshape(...
                demandValuesInitializationForecastFree, ...
                [k, length(demandValuesInitializationForecastFree)/k]), 2);
            
            % Create the 'god forecast' for training data
            godCast = zeros(size(demandValuesTrainForecastFree, 1), k);
            for ii = 1:k
                godCast(:, ii) = circshift(demandValuesTrainForecastFree, -[ii-1, 0]);
            end
            
            % Set-up parameters for on-line simulation
            batteryCapacity = meanKWh*batteryCapacityRatio*stepsPerDay;
            maximumChargingRate = batteryChargingFactor*batteryCapacity;
            
            runControl = [];
            runControl.MPC = MPC;
            
            % Run On-line Model to create training examples
            [ featureVectors, decisionVectors] = ...
                mpcGenerateForecastFreeExamples( ...
                simRangeTrainForecastFree, godCast, ...
                demandValuesTrainForecastFree, batteryCapacity, ...
                maximumChargingRate, loadPatternInitialization, ...
                hourNumbersTrainForecastFree, stepsPerHour, k, MPC);
            
            allFeatureVectors = zeros(size(featureVectors, 1), length(...
                demandValuesTrainForecastFree)*(nTrainShuffles + 1));
            
            allDecisionVectors = zeros(size(decisionVectors, 1), length(...
                demandValuesTrainForecastFree)*(nTrainShuffles + 1));
            
            allFeatureVectors(:, ...
                1:length(demandValuesTrainForecastFree)) = featureVectors;
            allDecisionVectors(:, ...
                1:length(demandValuesTrainForecastFree)) = decisionVectors;
            offset = length(demandValuesTrainForecastFree);
            
            % Continue generating examples with suffled versions of
            % training data:
            for eachShuffle = 1:nTrainShuffles
                newDemandValuesTrain = demandValuesTrainForecastFree;
                for eachSwap = 1:nDaysSwap
                    thisSwapStart = randi(length(demandValuesTrainForecastFree) - 2*k);
                    tmp = newDemandValuesTrain(thisSwapStart + (1:k));
                    newDemandValuesTrain(thisSwapStart + (1:k)) = ...
                        newDemandValuesTrain(thisSwapStart + (1:k) + k);
                    newDemandValuesTrain(thisSwapStart + (1:k) + k) = tmp;
                end
                [ featureVectors, decisionVectors] = ...
                    mpcGenerateForecastFreeExamples( ...
                    simRangeTrainForecastFree, godCast, ...
                    newDemandValuesTrain, batteryCapacity, ...
                    maximumChargingRate, loadPatternInitialization, ...
                    hourNumbersTrainForecastFree, stepsPerHour, k, MPC);
                
                allFeatureVectors(:, offset + ...
                    (1:length(demandValuesTrainForecastFree))) = ...
                    featureVectors;
                allDecisionVectors(:, offset + ...
                    (1:length(demandValuesTrainForecastFree))) = ...
                    decisionVectors;
                offset = offset + length(demandValuesTrainForecastFree);
            end
            
            % Train forecast-free NN model based on these examples
            pars{instance, forecastType} = ...
                generateForecastFreeController(allFeatureVectors,...
                allDecisionVectors, nHidden, trainControl.nStart);
            
            thisTimeTaken(1, forecastType) = toc(tempTic);
            
        end
        disp('Forecast Type complete: ');
        disp(lossTypesStrings{forecastType});
    end
    timeTaken(instance, :) = thisTimeTaken;
    disp(' ====== Instance completed ===== ');
    disp(instance);
end

Sim.timeTaken = timeTaken;
Sim.timeForecastTrain = toc;

disp('Time to end forecast training:'); disp(Sim.timeFcastTrain);

end
