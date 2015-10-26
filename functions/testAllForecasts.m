function [ Sim, results ] = testAllForecasts( pars, allDemandValues, ...
    Sim, Pemd, Pfem, MPC, k)

% testAllForecasts: Test the performance of all trained (and non-trained)
    % forecasts. First the parameterised forecasts are run to select the
    % best parameters. Then these best selected ones are compared to other
    % methods.

%% Pre-Allocation
% Index of the best forecasts for each instance
bestPfemIdx = zeros(Sim.nInstances, 1);
bestPemdIdx = zeros(Sim.nInstances, 1);

Sim.forecastSelectionIdxs = (1:(Sim.stepsPerHour*Sim.nHoursSelect)) + ...
    Sim.trainIdxs(end);
Sim.testIdxs = (1:(Sim.stepsPerHour*Sim.nHoursTest)) + ...
    Sim.forecastSelectionIdxs(end);

Sim.hourNumbersSelection = Sim.hourNumbers(Sim.forecastSelectionIdxs, :);
Sim.hourNumbersTest = Sim.hourNumbers(Sim.testIdxs, :);

% Sim time (& range) for forecast selection and testing
simRangeSelection = [0 Sim.nHoursSelect - 1/Sim.stepsPerHour];
simRangeTest = [0 Sim.nHoursTest - 1/Sim.stepsPerHour];

peakReductions = cell(Sim.nInstances, 1);
peakPowers = cell(Sim.nInstances, 1);
smallestExitFlag = cell(Sim.nInstances, 1);
allKWhs = zeros(Sim.nInstances, 1);
lossTestResults = cell(Sim.nInstances, 1);

for instance = 1:Sim.nInstances
    peakReductions{instance} = zeros(Sim.nMethods,1);
    peakPowers{instance} = zeros(Sim.nMethods,1);
    smallestExitFlag{instance} = zeros(Sim.nMethods,1);
    lossTestResults{instance} = ...
        zeros(Sim.nMethods, length(Sim.lossTypes));
end

%% Run Models for Forecast selection

% Extract data required from Sim structure for efficiency:
batteryCapacityRatio = Sim.batteryCapacityRatio;
batteryChargeFactor = Sim.batteryChargeFactor;
trainIdxs = Sim.trainIdxs;
forecastSelectionIdxs = Sim.forecastSelectionIdxs;
testIdxs = Sim.testIdxs;
pfemRange = Pfem.range;
pemdRange = Pemd.range;
lossTypesStrings = Sim.lossTypesStrings;
lossTypes = Sim.lossTypes;

hourNumbersSelection = Sim.hourNumbersSelection;
stepsPerHour = Sim.stepsPerHour;
stepsPerDay = Sim.stepsPerDay;
nInstances = Sim.nInstances;

% Set any default values of MPC that aren't set:
MPC = setDefaultValues(MPC, {'billingPeriodDays', 1, ...
    'maxParForTypes', 4});

forecastSelectionTic = tic;

allForecastTypes = [pfemRange, pemdRange];
forecastTypesOffset = 1;

nRuns = ceil(length(allForecastTypes)/MPC.maxParForTypes);

disp('==== Forecast Selection ===')

for iRun = 1:nRuns
    
    theseForecastTypes = allForecastTypes(...
        forecastTypesOffset:min(forecastTypesOffset + ...
        MPC.maxParForTypes - 1, end));
    forecastTypesOffset = forecastTypesOffset + MPC.maxParForTypes;
    
    poolobj = gcp('nocreate');
    delete(poolobj);
    
    parfor instance = 1:nInstances
        
        allKWhs(instance) = mean(allDemandValues{instance});
        
        % Battery properties
        batteryCapacity = allKWhs(instance)*batteryCapacityRatio*...
            stepsPerDay;
        maximumChargeRate = batteryChargeFactor*batteryCapacity;
        
        % Separate Data into training and parameter selection sets
        demandValuesTrain = allDemandValues{instance}(trainIdxs, :);
        demandValuesSelection = allDemandValues{instance}(...
            forecastSelectionIdxs, :);
        peakLocalPower = max(demandValuesSelection);
        
        % Create 'historical load pattern' used for initialization etc.
        loadPattern = mean(reshape(demandValuesTrain, ...
            [k, length(demandValuesTrain)/k]), 2);
        
        godCastValues = zeros(length(testIdxs), k);
        for jj = 1:k
            godCastValues(:, jj) = ...
                circshift(demandValuesSelection, -[jj-1, 0]);
        end
        
        %% For each parameterized method run simulation
        for iForecastType = theseForecastTypes
            
            runControl = [];
            runControl.MPC = MPC;
            
            runControl.MPC.setPoint = ...
                strcmp(lossTypesStrings{iForecastType}, 'setPoint'); %#ok<PFBNS>
            
            % If method is set-point then show it current demand
            if(runControl.MPC.setPoint)
                runControl.MPC.knowCurrentDemandNow = true
            end
            
            runControl.naivePeriodic = false;
            runControl.godCast = false;
            
            [runningPeak, exitFlag, forecastUsed] = mpcController( ...
                simRangeSelection, pars{instance, iForecastType},...
                godCastValues, demandValuesSelection, batteryCapacity, ...
                maximumChargeRate, loadPattern, hourNumbersSelection, ...
                stepsPerHour, k, runControl);
            
            % Extract simulation results
            gridPowerTimeSeries = runningPeak';
            gridBillingPeriodColumns = reshape(gridPowerTimeSeries,...
                [k*MPC.billingPeriodDays, ...
                length(gridPowerTimeSeries)/(k*MPC.billingPeriodDays)]);
            
            gridBillingPeriodPeaks = max(gridBillingPeriodColumns);
            
            demandBillingPeriodColumns = reshape(demandValuesSelection,...
                [k*MPC.billingPeriodDays,...
                length(demandValuesSelection)/(k*MPC.billingPeriodDays)]);
            
            demandBillingPeriodPeaks = max(demandBillingPeriodColumns);
            
            billingPeriodRatios = ...
                gridBillingPeriodPeaks./demandBillingPeriodPeaks;
            
            peakReductions{instance}(iForecastType) = ...
                1 - mean(billingPeriodRatios);
            
            peakPowers{instance}(iForecastType) = peakLocalPower;
            smallestExitFlag{instance}(iForecastType) = min(exitFlag);
            
            % Compute the performance of the forecast by all metrics
            isForecastFree = ...
                strcmp(lossTypesStrings{iForecastType}, 'forecastFree');
            isSetPoint = ...
                strcmp(lossTypesStrings{iForecastType}, 'setPoint');
            
            if (~isForecastFree && ~isSetPoint)
                for iMetric = 1:length(lossTypes)
                    lossTestResults{instance}(iForecastType, iMetric)...
                        = mean(lossTypes{iMetric}(godCastValues',...
                        forecastUsed));
                end
            end
        end
        
        disp(' ===== Completed instance: ===== ');
        disp(instance);
        
    end
    
    poolobj = gcp('nocreate');
    delete(poolobj);
    
    disp(' ===== Completed Forecast Types: ===== ');
    disp(theseForecastTypes);
    
end

timeSelection = toc(forecastSelectionTic);
disp('Time to Select Forecast Parameters:'); disp(timeSelection);

% Find the best forecast metrics from the parameter grid search
for instance = 1:nInstances
    [~, idx] = max(peakReductions{instance}(pfemRange));
    bestPfemIdx(instance) = idx + min(pfemRange) - 1;
    
    [~, idx] = max(peakReductions{instance}(pemdRange));
    bestPemdIdx(instance) = idx + min(pemdRange) - 1;
end

% Extend relevant variables to accomodate the 2 new forecasts
Sim.lossTypesStrings = [Sim.lossTypesStrings, {'bestPfemSelected',...
    'bestEmdSelected'}];
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

%% Run Models for Performance Testing
% Extract data from Sim struct for efficiency
nMethods = Sim.nMethods;
nTrainMethods = Sim.nTrainMethods;
lossTypesStrings = Sim.lossTypesStrings;
hourNumbersTest = Sim.hourNumbersTest;
stepsPerHour = Sim.stepsPerHour;

testingTic = tic;

poolobj = gcp('nocreate');
delete(poolobj);

disp('==== Forecast Testing ===')

parfor instance = 1:nInstances
    
    % Battery properties
    batteryCapacity = allKWhs(instance)*batteryCapacityRatio*stepsPerDay;
    maximumChargeRate = batteryChargeFactor*batteryCapacity;
    
    % Separate data for parameter selection and testing
    demandValuesSelection = allDemandValues{instance}(...
        forecastSelectionIdxs);
    demandValuesTest = allDemandValues{instance}(testIdxs);
    peakLocalPower = max(demandValuesTest);
    
    % Create 'historical load pattern' used for initialization etc.
    loadPattern = mean(reshape(demandValuesSelection, ...
        [k, length(demandValuesSelection)/k]), 2);
    
    % Create godCast forecasts
    godCastValues = zeros(length(testIdxs), k);
    for jj = 1:k
        godCastValues(:, jj) = circshift(demandValuesTest, -[jj-1, 0]);
    end
    
    % Avoid parfor errors
    forecastUsed = []; exitFlag = []; iForecastType = [];
    
    %% Test performance of all forecasts
    % (except non selected parameterized ones)
    
    for forecastTypeIn = setdiff(1:nMethods, [pfemRange, pemdRange])
        
        runControl = [];
        runControl.MPC = MPC;
        
        if strcmp(lossTypesStrings{forecastTypeIn},'fcastFree') %#ok<PFBNS>
            % Implement forecast free controller
            demandValuesTrain = allDemandValues{instance}(trainIdxs, :);
            
            % Create 'historical load pattern' used for initialization etc.
            loadPatternTrain = mean(reshape(demandValuesTrain, ...
                [k, length(demandValuesTrain)/k]), 2);
            
            % Evaluate performance of controller
            [ runningPeak ] = mpcControllerForecastFree( simRangeTest, ...
                pars{instance, forecastTypeIn}, demandValuesTest,...
                batteryCapacity, maximumChargeRate, loadPatternTrain,...
                hourNumbersTest, stepsPerHour, MPC);
        else
            % Implement a normal forecast driven or set-point controller
            
            % If we are using 'bestSelected' forecast then set fcType:
            if strcmp(lossTypesStrings{forecastTypeIn}, 'bestPfemSelected')
                iForecastType = bestPfemIdx(instance);
            elseif strcmp(lossTypesStrings{forecastTypeIn},...
                    'bestEmdSelected')
                iForecastType = bestPemdIdx(instance);
            else
                iForecastType = forecastTypeIn;
            end
            
            % Check for godCast or naivePeriodic
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
            
            [runningPeak, exitFlag, forecastUsed] = mpcController( ...
                simRangeTest, pars{instance, min(iForecastType, ...
                nTrainMethods)}, godCastValues, demandValuesTest, ...
                batteryCapacity, maximumChargeRate, loadPattern, ...
                hourNumbersTest, stepsPerHour, k, runControl); %#ok<PFBNS>
        end
        
        % Extract simulation results
        gridPowerTimeSeries = runningPeak';
        gridBillingPeriodColumns = reshape(gridPowerTimeSeries,...
            [k*MPC.billingPeriodDays,...
            length(gridPowerTimeSeries)/(k*MPC.billingPeriodDays)]);
        
        gridBillingPeriodPeaks = max(gridBillingPeriodColumns);
        
        demandBillingPeriodColumns = reshape(demandValuesTest,...
            [k*MPC.billingPeriodDays, ...
            length(demandValuesTest)/(k*MPC.billingPeriodDays)]);
        
        demandBillingPeriodPeaks = max(demandBillingPeriodColumns);
        
        billingPeriodRatios = ...
            gridBillingPeriodPeaks./demandBillingPeriodPeaks;
        
        peakReductions{instance}(forecastTypeIn) = ...
            1 - mean(billingPeriodRatios);
        peakPowers{instance}(forecastTypeIn) = peakLocalPower;
        smallestExitFlag{instance}(forecastTypeIn) = min(exitFlag);
        
        % Compute the performance of the forecast by all metrics
        isForecastFree = strcmp(lossTypesStrings{iForecastType},...
            'forecastFree');
        isSetPoint = strcmp(lossTypesStrings{iForecastType}, 'setPoint');
        if (~isForecastFree && ~isSetPoint)
            for iMetric = 1:length(lossTypes)
                lossTestResults{instance}(forecastTypeIn, iMetric)...
                    = mean(lossTypes{iMetric}(godCastValues', forecastUsed));
            end
        end
    end
    
    disp(' ===== Completed Instance: ===== ');
    disp(instance);
    
end

poolobj = gcp('nocreate');
delete(poolobj);

timeTesting = toc(testingTic);
disp('Time for Testing Forecasts:'); disp(timeTesting);


%% Convert to arrays from cellArrays
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
results.bestPfemForecast = bestPfemIdx;
results.bestPemdForecast = bestPemdIdx;

end
