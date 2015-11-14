function [ Sim, results ] = testAllForecastsParallel( pars,...
    allDemandValues, Sim, Pemd, Pfem, MPC, k)

% testAllParameterizedForecasts: Test the performance of all trained
% (and non-trained) fcasts. First the parameterised forecasts are run
% to select the best parameters. Then these best selected ones are
% compared to other methods.

%% Pre-Allocation
bestPfemIdx = zeros(Sim.nInstances, 1);
bestPemdIdx = zeros(Sim.nInstances, 1);

Sim.forecastSelectionIdxs = (1:(Sim.stepsPerHour*Sim.nHoursSelect)) + ...
    Sim.trainIdxs(end);
Sim.testIdxs = (1:(Sim.stepsPerHour*Sim.nHoursTest)) + ...
    Sim.forecastSelectionIdxs(end);

Sim.hourNumberSelection = Sim.hourNumber(Sim.forecastSelectionIdxs, :);
Sim.hourNumberTest = Sim.hourNumber(Sim.testIdxs, :);

% Sim time (& range) for forecast selection and testing
simRangeSelection = [0 Sim.nHoursSelect - 1/Sim.stepsPerHour];
simRangeTest = [0 Sim.nHoursTest - 1/Sim.stepsPerHour];

peakReductions = cell(Sim.nInstances, 1);
peakPowers = cell(Sim.nInstances, 1);
smallestExitFlag = cell(Sim.nInstances, 1);
allKWhs = zeros(Sim.nInstances, 1);
lossTestResults = cell(Sim.nInstances, 1);

%% Run Models for Forecast Parameter Selection

% Extract data from Sim structure for efficiency:
batteryCapacityRatio = Sim.batteryCapacityRatio;
batteryChargeFactor = Sim.batteryChargeFactor;
trainIdxs = Sim.trainIdxs;
forecastSelectionIdxs = Sim.forecastSelectionIdxs;
testIdxs = Sim.testIdxs;
pfemRange = Pfem.range; pemdRange = Pemd.range;
lossTypesStrings = Sim.lossTypesStrings;
lossTypes = Sim.lossTypes;

hourNumberSelection = Sim.hourNumberSelection;
stepsPerHour = Sim.stepsPerHour;
stepsPerDay = Sim.stepsPerDay;
nInstances = Sim.nInstances;

MPC = setDefaultValues(MPC, {'billingPeriodDays', 1});

selectionTic = tic;

poolobj = gcp('nocreate');
delete(poolobj);

for instance = 1:nInstances
    
    allKWhs(instance) = mean(allDemandValues{instance});
    
    % Battery properties
    batteryCapacity = allKWhs(instance)*batteryCapacityRatio*stepsPerDay;
    maximumChargeRate = batteryChargeFactor*batteryCapacity;
    
    % Separate Data into training and testing
    demandValuesTrain = allDemandValues{instance}(trainIdxs, :);
    demandValuesSelection = allDemandValues{instance}(forecastSelectionIdxs, :);
    peakLocalPower = max(demandValuesSelection);
    
    % Create 'historical load pattern' used for initialization etc.
    loadPattern = mean(reshape(demandValuesTrain, ...
        [k, length(demandValuesTrain)/k]), 2);
    
    godCastValues = zeros(length(testIdxs), k);
    for jj = 1:k
        godCastValues(:, jj) = circshift(demandValuesSelection,...
            -[jj-1, 0]);
    end
    
    thisInstancePeakReductions = zeros(Sim.nMethods,1);
    thisInstancePeakPower = zeros(Sim.nMethods,1);
    thisInstanceSmallestExitFlag = zeros(Sim.nMethods,1);
    thisInstanceLossTestResults = ...
        zeros(Sim.nMethods, length(Sim.lossTypes));
    
    %% For each parameterized method run simulation
    parfor forecastType = [pfemRange, pemdRange]
        
        runControl = [];
        runControl.MPC = MPC;
        
        runControl.MPC.setPoint = ...
            strcmp(lossTypesStrings{forecastType}, 'setPoint');
        
        % If method is set-point then show it current demand
        if(runControl.MPC.setPoint)
            runControl.MPC.knowCurrentDemandNow = true
        end
        
        runControl.naivePeriodic = false;
        runControl.godCast = false;
        runControl.skipRun = false;
        
        [runningPeak, exitFlag, fcUsed] = mpcController( ...
            simRangeSelection, pars{instance, forecastType}, ...
            godCastValues, demandValuesSelection, batteryCapacity, ...
            maximumChargeRate, loadPattern, hourNumberSelection, ...
            stepsPerHour, k, runControl);
        
        % Extract simulation results
        gridPowerTimeSeries = runningPeak';
        gridBillingPeriodColumns = reshape(gridPowerTimeSeries,...
            [k*MPC.billingPeriodDays,...
            length(gridPowerTimeSeries)/(k*MPC.billingPeriodDays)]);
        
        gridBillingPeriodPeaks = max(gridBillingPeriodColumns);
        
        demandBillingPeriodColumns = reshape(demandValuesSelection,...
            [k*MPC.billingPeriodDays, ...
            length(demandValuesSelection)/(k*MPC.billingPeriodDays)]);
        
        demandBillingPeriodPeaks = max(demandBillingPeriodColumns);
        
        billingPeriodRatios = ...
            gridBillingPeriodPeaks./demandBillingPeriodPeaks;
        
        thisInstancePeakReductions(forecastType) = ...
            1 - mean(billingPeriodRatios);
        thisInstancePeakPower(forecastType) = peakLocalPower;
        thisInstanceSmallestExitFlag(forecastType) = min(exitFlag);
        
        % Compute the performance of the forecast by all metrics
        tempLossResults = zeros(1, length(lossTypes));
        for iError = 1:length(lossTypes)
            tempLossResults(iError) = ...
                mean(lossTypes{iError}(godCastValues', fcUsed));
        end
        thisInstanceLossTestResults(forecastType, :) = tempLossResults;
    end
    
    peakReductions{instance} = thisInstancePeakReductions;
    peakPowers{instance} = thisInstancePeakPower;
    smallestExitFlag{instance} = thisInstanceSmallestExitFlag;
    lossTestResults{instance} = thisInstanceLossTestResults;
    
    disp('Instance Completed: ');
    disp(instance);
end

poolobj = gcp('nocreate');
delete(poolobj);

timeSelection = toc(selectionTic);
disp('Time to Select Forecast Parameters:'); disp(timeSelection);

% Find the best forecast parameters from the grid search
for instance = 1:nInstances
    [~, idx] = max(peakReductions{instance}(pfemRange));
    bestPfemIdx(instance) = idx + min(pfemRange) - 1;
    
    [~, idx] = max(peakReductions{instance}(pemdRange));
    bestPemdIdx(instance) = idx + min(pemdRange) - 1;
end

% Extend relevant variables to accomodate the two new forecasts
Sim.lossTypesStrings = [Sim.lossTypesStrings, {'bestPfemSelected',...
    'bestPemdSelected'}];
Sim.nMethods = length(Sim.lossTypesStrings);

for instance = 1:nInstances
    peakReductions{instance} = [peakReductions{instance}; ...
        zeros(2,1)];
    peakPowers{instance} = [peakPowers{instance};
        zeros(2,1)];
    smallestExitFlag{instance} = [smallestExitFlag{instance}; ...
        zeros(2,1)];
    lossTestResults{instance} = [lossTestResults{instance}; ...
        zeros(2, length(Sim.lossTypes))];
end

%% Run Models for performance testing
% Extract data from Sim struct for efficiency
nMethods = Sim.nMethods;
nTrainMethods = Sim.nTrainMethods;
lossTypesStrings = Sim.lossTypesStrings;
hourNumberTest = Sim.hourNumberTest;
stepsPerHour = Sim.stepsPerHour;

testingTic = tic;

poolobj = gcp('nocreate');
delete(poolobj);

disp('==== Forecast Testing ===')
for instance = 1:nInstances
    
    % Battery properties
    batteryCapacity = allKWhs(instance)*batteryCapacityRatio*stepsPerDay;
    maximumChargeRate = batteryChargeFactor*batteryCapacity;
    
    % Separate Data into selection and testing sets
    demandValuesSelection = allDemandValues{instance}(forecastSelectionIdxs);
    demandValuesTest = allDemandValues{instance}(testIdxs);
    peakLocalPower = max(demandValuesTest);
    
    % Create 'historical load pattern' used for initialization etc.
    loadPattern = mean(reshape(demandValuesSelection, ...
        [k, length(demandValuesSelection)/k]), 2);
    
    % Create test demand time-series object
    godCastValues = zeros(length(testIdxs), k);
    for jj = 1:k
        godCastValues(:, jj) = circshift(demandValuesTest, -[jj-1, 0]);
    end
    
    %% For each method evaluate the performance
    % (except non selected parameterised forecasts ones)
    thisInstancePeakReductions = zeros(size(peakReductions{1}));
    thisInstancePeakPower = zeros(size(peakPowers{1}));
    thisInstanceSmallestExitFlag = zeros(size(smallestExitFlag{1}));
    thisInstanceLossTestResults = zeros(size(lossTestResults{1}));
    thisInstanceBestPfemForecast = bestPfemIdx(instance);
    thisInstanceBestPemdForecast = bestPemdIdx(instance);
    
    demandValuesTrain = allDemandValues{instance}(trainIdxs, :);
    
    parfor forecastTypeIn = 1:nMethods
        
        if any(forecastTypeIn == [pfemRange, pemdRange])
            continue;
        end
        
        % Avoid parfor errors
        fcUsed = []; exitFlag = 1;
        runControl = [];
        runControl.MPC = MPC;
        
        if strcmp(lossTypesStrings{forecastTypeIn}, 'fcastFree')
            % Implement fcastFree controller
            
            % Create 'historical load pattern' used for initialization etc.
            loadPatternTrain = mean(reshape(demandValuesTrain, ...
                [k, length(demandValuesTrain)/k]), 2);
            
            % Evaluate performance of controller
            [ runningPeak ] = mpcControllerForecastFree( simRangeTest,...
                pars{instance, forecastTypeIn}, demandValuesTest,...
                batteryCapacity, maximumChargeRate, loadPatternTrain,...
                hourNumberTest, stepsPerHour, MPC);
        else
            % Implement a normal forecast-driven or set-point controller
            
            % If using 'bestSelected' forecast then set forecastType:
            if strcmp(lossTypesStrings{forecastTypeIn}, 'bestPfemSelected')
                forecastType = thisInstanceBestPfemForecast;
            elseif strcmp(lossTypesStrings{forecastTypeIn}, 'bestPemdSelected')
                forecastType = thisInstanceBestPemdForecast;
            else
                forecastType = forecastTypeIn;
            end
            
            % Check if we are on godCast or naivePeriodic
            runControl.naivePeriodic = ...
                strcmp(lossTypesStrings{forecastTypeIn}, 'naivePeriodic');
            
            runControl.godCast = ...
                strcmp(lossTypesStrings{forecastTypeIn}, 'godCast');
            
            runControl.MPC.setPoint = ...
                strcmp(lossTypesStrings{forecastTypeIn}, 'setPoint');
            
            % If method is set-point then show it current demand
            if(runControl.MPC.setPoint)
                runControl.MPC.knowCurrentDemandNow = true
            end
            
            [runningPeak, exitFlag, fcUsed] = mpcController( ...
                simRangeTest, pars{instance, min(forecastType, ...
                nTrainMethods)}, godCastValues, demandValuesTest, ...
                batteryCapacity, maximumChargeRate, loadPattern, ...
                hourNumberTest, stepsPerHour, k, runControl); %#ok<PFBNS>
        end
        
        % Extract simulation results
        gridPowerTimeSeries = runningPeak';
        gridBillingPeriodColumns = reshape(gridPowerTimeSeries, ...
            [k*MPC.billingPeriodDays,...
            length(gridPowerTimeSeries)/(k*MPC.billingPeriodDays)]);
        
        gridBillingPeriodPeaks = max(gridBillingPeriodColumns);
        
        demandBillingPeriodColumns = reshape(demandValuesTest, ...
            [k*MPC.billingPeriodDays,...
            length(demandValuesTest)/(k*MPC.billingPeriodDays)]);
        demandBillingPeriodPeaks = max(demandBillingPeriodColumns);
        
        billingPeriodRatios = ...
            gridBillingPeriodPeaks./demandBillingPeriodPeaks;
        
        thisInstancePeakReductions(forecastTypeIn) = ...
            1 - mean(billingPeriodRatios);
        thisInstancePeakPower(forecastTypeIn) = peakLocalPower;
        thisInstanceSmallestExitFlag(forecastTypeIn) = min(exitFlag);
        
        % Compute the performance of the forecast by all metrics
        isForecastFree = ...
            strcmp(lossTypesStrings{forecastTypeIn}, 'forecastFree');
        isSetPoint = ...
            strcmp(lossTypesStrings{forecastTypeIn}, 'setPoint');
        if ~isSetPoint && ~isForecastFree
            tempLossResults = zeros(1, length(lossTypes));
            for iError = 1:length(lossTypes)
                tempLossResults(iError) = ...
                    mean(lossTypes{iError}(godCastValues', fcUsed));
            end
            
            thisInstanceLossTestResults(forecastTypeIn, :) = tempLossResults;
        end
    end
    
    peakReductions{instance} = thisInstancePeakReductions;
    peakPowers{instance} = thisInstancePeakPower;
    smallestExitFlag{instance} = thisInstanceSmallestExitFlag;
    lossTestResults{instance} = thisInstanceLossTestResults;
    
    disp('Instance Completed: ');
    disp(instance);
end

poolobj = gcp('nocreate');
delete(poolobj);

timeEval = toc(testingTic);
disp('Time for Testing Forecasts:'); disp(timeEval);


%% Convert to array from cellArrays
peakReductions = reshape(cell2mat(peakReductions), ...
    [nMethods, Sim.nAggregates, length(Sim.nCustomers)]);

peakPowers = reshape(cell2mat(peakPowers), ...
    [nMethods, Sim.nAggregates, length(Sim.nCustomers)]);

smallestExitFlag = reshape(cell2mat(smallestExitFlag), ...
    [nMethods, Sim.nAggregates, length(Sim.nCustomers)]);

allKWhs = reshape(allKWhs, ...
    [Sim.nAggregates, length(Sim.nCustomers)]);

lossTestResults = reshape(cell2mat(lossTestResults), ...
    [nMethods, Sim.nAggregates, length(Sim.nCustomers), nTrainMethods]);


%% Fromatting
% Collapse Trial Dimension
peakReductionsTrialFlattened = reshape(peakReductions, ...
    [nMethods, length(Sim.nCustomers)*Sim.nAggregates]);

peakPowersTrialFlattened = reshape(peakPowers, ...
    [nMethods, length(Sim.nCustomers)*Sim.nAggregates]);

%% Put results together in structure for passing out
results.peakReductions = peakReductions;
results.peakReductionsTrialFlattened = peakReductionsTrialFlattened;
results.peakPowers = peakPowers;
results.peakPowersTrialFlattened = peakPowersTrialFlattened;
results.smallestExitFlag = smallestExitFlag;
results.allKWhs = allKWhs;
results.lossTestResults = lossTestResults;
results.bestParForecast = bestPfemIdx;
results.bestEMDForecast = bestPemdIdx;

end
