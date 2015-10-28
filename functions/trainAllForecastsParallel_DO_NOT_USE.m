function [ Pfem, Pemd, Sim, pars ] = trainAllForecastsParallel( Pfem, ...
    Pemd, MPC, Sim, allDemandValues, trainControl, k)

% trainAllForecastsParallel: Train parameters for all trained fcasts
%   Run through each instance and each error metric and output
%   parameters of trained NN forecasts.

tic;

Sim.stepsPerDay = Sim.stepsPerHour*Sim.hoursPerDay;
Sim.nHoursTrain = Sim.hoursPerDay*Sim.nDaysTrain;
Sim.nHoursTest = Sim.hoursPerDay*Sim.nDaysTest;
Sim.nHoursSelect = Sim.hoursPerDay*Sim.nDaysSelect;

%% Generate PFEM grid-search rows

Pfem.loss = cell(Pfem.num, 1);
Pfem.allValues = zeros(Pfem.num, 4);
thisParameterization = 1;
for alpha = Pfem.alphas
    for beta = Pfem.betas
        for gamma = Pfem.gammas
            for delta = Pfem.deltas
                Pfem.loss{thisParameterization} = @(t, y) lossPfem(t, y,...
                    [alpha, beta, gamma, delta]);
                Pfem.allValues(thisParameterization, :) = ...
                    [alpha, beta, gamma, delta];
                thisParameterization = thisParameterization + 1;
            end
        end
    end
end

%% Generate PEMD grid-serach rows
Pemd.loss = cell(Pemd.num, 1);
Pemd.allValues = zeros(Pemd.num, 4);
thisParameterization = 1;
for a = Pemd.as
    for b = Pemd.bs
        for c = Pemd.cs
            for d = Pemd.ds
                Pemd.loss{thisParameterization} = @(t, y) lossPemd(t, y,...
                    [a, b, c, d]);
                Pemd.allValues(thisParameterization, :) = [a, b, c, d];
                thisParameterization = thisParameterization + 1;
            end
        end
    end
end

%% Generate list of loss fcn handles and labels
Sim.lossTypes = [{@loss_mse, @loss_mape}, Pfem.loss', Pemd.loss'];
Sim.lossTypesStrings = cell(1, length(Sim.lossTypes)+4);
Pfem.range = (1:Pfem.num) + (length(Sim.lossTypes)-Pemd.num-Pfem.num);
Pemd.range = (1:Pemd.num) + (length(Sim.lossTypes)-Pemd.num);

Sim.lossTypesStrings(1, 1:length(Sim.lossTypes)) = ...
    cellfun(@func2str, Sim.lossTypes, 'UniformOutput', false);

counter1 = 1;
counter2 = 1;
for ii = 1:length(Sim.lossTypes)
    if ii > (length(Sim.lossTypes) - Pfem.num - Pemd.num)
        if ii <= (length(Sim.lossTypes) - Pemd.num)
            Sim.lossTypesStrings{ii} = [Sim.lossTypesStrings{ii} num2str(counter1)];
            counter1 = counter1 + 1;
        else
            Sim.lossTypesStrings{ii} = [Sim.lossTypesStrings{ii} num2str(counter2)];
            counter2 = counter2 + 1;
        end
    end
end

Sim.lossTypesStrings(1, length(Sim.lossTypes)+(1:4)) = ...
    {'forecastFree', 'naivePeriodic', 'godCast', 'setPoint'};

Sim.nTrainMethods = length(Sim.lossTypes);
Sim.nMethods = length(Sim.lossTypesStrings);

%% Pre-Allocation
timeTaken = cell(Sim.nInstances, 1);
pars = cell(Sim.nInstances, Sim.nTrainMethods+1);

Sim.trainIdxs = 1:(Sim.stepsPerHour*Sim.nHoursTrain);
Sim.hourNumbers = mod((1:size(allDemandValues{1}, 1))', k);
Sim.hourNumbersTrain = Sim.hourNumbers(Sim.trainIdxs, :);

trainControl.hourNumbersTrain = Sim.hourNumbersTrain;

% Extract data to local variables for efficiency:
nInstances = Sim.nInstances;
nTrainMethods = Sim.nTrainMethods;
lossTypes = Sim.lossTypes;
trainIdxs = Sim.trainIdxs;
hoursPerDay = Sim.hoursPerDay;
stepsPerHour = Sim.stepsPerHour;
batteryCapacityRatio = Sim.batteryCapacityRatio;
nHoursTrain = Sim.nHoursTrain;
batteryChargingFactor = Sim.batteryChargingFactor;  % ratio of charge rate to batt_cap
hourNumbersTrain = Sim.hourNumbersTrain;
nTrainShuffles = Sim.nTrainShuffles;
nDaysSwap = Sim.nDaysSwap;
nHidden = Sim.nHidden;
lossTypesStrings = Sim.lossTypesStrings;
stepsPerDay = Sim.stepsPerDay;

%% Train Models
poolobj = gcp('nocreate');
delete(poolobj);

for instance = 1:nInstances
    % Extract aggregated demand
    demandValuesTrain = allDemandValues{instance}(trainIdxs);
    thisInstanceTimeTaken = zeros(nTrainMethods+1, 1);
    tempTic = tic;
    
    % Create new pars cellArray for each instance (avoid parfor bugs)
    thisInstancePars = cell(1, Sim.nTrainMethods+1);
    
    parfor forecastType = 1:(nTrainMethods+1)
        if ~strcmp(lossTypesStrings{forecastType}, 'forecastFree')
            thisInstancePars{forecastType} = trainFfnnMultipleStarts( ...
                demandValuesTrain, lossTypes{min(forecastType,...
                nTrainMethods)}, trainControl); %#ok<PFBNS>
            thisInstanceTimeTaken(forecastType) = toc(tempTic);
        else
            
            % Train forecastFree model
            meanKWh = mean(demandValuesTrain);
            
            % Seperate training data into initialisation (1-day)
            % and training (rest)
            nDaysInitialization = 1;
            initializationIdxs = 1:(nDaysInitialization*stepsPerDay);
            demandValuesInitialization = ...
                demandValuesTrain(initializationIdxs, :);
            demandValuesTrainOnly = demandValuesTrain(setdiff(trainIdxs,...
                initializationIdxs), :);
            
            % Create 'historical load pattern' used for initialization etc.
            loadPatternInitialization = mean(reshape(...
                demandValuesInitialization, ...
                [k, length(demandValuesInitialization)/k]), 2);
            
            % Create the 'godCast' for training data
            godCast = zeros(size(demandValuesTrainOnly, 1), k);
            for ii = 1:k
                godCast(:, ii) = circshift(demandValuesTrainOnly, -[ii-1, 0]);
            end
            
            % Set-up parameters for on-line simulation
            batteryCapacity = meanKWh*batteryCapacityRatio*stepsPerDay;
            maxChargingRate = batteryChargingFactor*batteryCapacity;
            simRangeTrain = [0 nHoursTrain - ...
                hoursPerDay*nDaysInitialization - 1/stepsPerHour];
            
            hourNumbersTrainOnly = hourNumbersTrain(setdiff(trainIdxs,...
                initializationIdxs)); %#ok<PFBNS>
            
            runControl = [];
            runControl.MPC = MPC;
            
            % Run On-line Model to create training examples
            [ featureVectors, decisionVectors] = ...
                mpcGenerateForecastFreeExamples( simRangeTrain, godCast,...
                demandValuesTrainOnly, batteryCapacity, maxChargingRate,...
                loadPatternInitialization, hourNumbersTrainOnly, ...
                stepsPerHour, k, MPC);
            
            allFeatureVectors = zeros(size(featureVectors, 1), length(...
                demandValuesTrainOnly)*(nTrainShuffles + 1));
            
            allDecisionVectors = zeros(size(decisionVectors, 1), length(...
                demandValuesTrainOnly)*(nTrainShuffles + 1));
            
            allFeatureVectors(:, 1:length(demandValuesTrainOnly)) = ...
                featureVectors;
            
            allDecisionVectors(:, 1:length(demandValuesTrainOnly)) = ...
                decisionVectors;
            
            offset = length(demandValuesTrainOnly);
            
            % Continue generating examples with suffled versions of
            % training data:
            for eachShuffle = 1:nTrainShuffles
                newDemandValuesTrain = demandValuesTrainOnly;
                for eachSwap = 1:nDaysSwap
                    thisSwapStart = randi(length(demandValuesTrainOnly)-...
                        2*k);
                    tmp = newDemandValuesTrain(thisSwapStart + (1:k));
                    newDemandValuesTrain(thisSwapStart + (1:k)) = ...
                        newDemandValuesTrain(thisSwapStart + (1:k) + k);
                    newDemandValuesTrain(thisSwapStart + (1:k) + k) = tmp;
                end
                [ featureVectors, decisionVectors] = ...
                    mpcGenerateForecastFreeExamples( simRangeTrain, ...
                    godCast, newDemandValuesTrain, batteryCapacity, ...
                    maxChargingRate, loadPatternInitialization, ...
                    hourNumbersTrainOnly, stepsPerHour, k, MPC);
                
                allFeatureVectors(:, offset + ...
                    (1:length(demandValuesTrainOnly))) = featureVectors;
                
                allDecisionVectors(:, offset + ...
                    (1:length(demandValuesTrainOnly))) = decisionVectors;
                
                offset = offset + length(demandValuesTrainOnly);
            end
            
            % Train forecast-free NN model based on these examples
            thisInstancePars{forecastType} = ...
                generateForecastFreeController(allFeatureVectors,...
                allDecisionVectors, nHidden, trainControl.nStart);
            
            thisInstanceTimeTaken(forecastType) = toc(tempTic);
        end
        disp('Forecast Types:');
        disp(forecastType);
        disp('Time Taken [s]:');
        disp(toc(tempTic));
    end
    timeTaken{instance} = thisInstanceTimeTaken;
    pars(instance, :) = thisInstancePars;
    disp(' ====== Instance completed ===== ');
    disp(instance);
end

poolobj = gcp('nocreate');
delete(poolobj);

Sim.timeTaken = timeTaken;
Sim.timeForecastTrain = toc;

disp('Time to train Forecasts [s]: '); disp(Sim.timeFcastTrain);

end
