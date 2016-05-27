function [ cfg, results ] = testAllForecasts( cfg, pars, allDemandValues)

% testAllForecasts: Test the performance of all trained (and non-trained)
% forecasts. First the parameterised forecasts are run to select the
% best parameters. Then these best selected ones are compared to other
% methods, on an unseen data-set.

%% Pre-Allocation
% Index of the best forecasts for each instance (within cfg.sim.lossTypes)
bestPfemIdx = zeros(cfg.sim.nInstances, 1);
bestPemdIdx = zeros(cfg.sim.nInstances, 1);

cfg.sim.forecastSelectionIdxs = (1:...
    (cfg.sim.stepsPerHour*cfg.sim.nHoursSelect)) + cfg.sim.trainIdxs(end);

cfg.sim.testIdxs = (1:(cfg.sim.stepsPerHour*cfg.sim.nHoursTest)) + ...
    cfg.sim.forecastSelectionIdxs(end);

cfg.sim.hourNumberSelection = ...
    cfg.sim.hourNumber(cfg.sim.forecastSelectionIdxs, :);

cfg.sim.hourNumberTest = cfg.sim.hourNumber(cfg.sim.testIdxs, :);

peakReductions = cell(cfg.sim.nInstances, 1);
peakPowers = cell(cfg.sim.nInstances, 1);
smallestExitFlag = cell(cfg.sim.nInstances, 1);
meanKWhs = zeros(cfg.sim.nInstances, 1);
lossTestResults = cell(cfg.sim.nInstances, 1);

for instance = 1:cfg.sim.nInstances
    peakReductions{instance} = zeros(cfg.fc.nMethods,1);
    peakPowers{instance} = zeros(cfg.fc.nMethods,1);
    smallestExitFlag{instance} = zeros(cfg.fc.nMethods,1);
    lossTestResults{instance} = zeros(cfg.fc.nMethods, cfg.fc.nTrainMethods);
    meanKWhs(instance) = mean(allDemandValues{instance});
end

cfg.fc = setDefaultValues(cfg.fc, {'forecastModels', 'FFNN'});

%% Run Models for Forecast selection

% Extract data required from cfg.sim structure for efficiency of parfor
% communications
batteryCapacityRatio = cfg.sim.batteryCapacityRatio;
trainIdxs = cfg.sim.trainIdxs;
forecastSelectionIdxs = cfg.sim.forecastSelectionIdxs;
testIdxs = cfg.sim.testIdxs;
pfemRange = cfg.fc.Pfem.range;
pemdRange = cfg.fc.Pemd.range;
lossTypes = cfg.fc.lossTypes;
allMethodStrings = cfg.fc.allMethodStrings;
forecastModels = cfg.fc.forecastModels;

% hourNumberSelection = cfg.sim.hourNumberSelection;
% stepsPerHour = cfg.sim.stepsPerHour;
stepsPerDay = cfg.sim.stepsPerDay;
nInstances = cfg.sim.nInstances;

% Set any default values of cfg.opt structure that aren't already set:
cfg.opt = setDefaultValues(cfg.opt, {'billingPeriodDays', 1, ...
    'maxParForTypes', 4});

forecastSelectionTic = tic;

allForecastsToSelectFrom = [pfemRange, pemdRange];
forecastOffset = 1;

nRuns = ceil(length(allForecastsToSelectFrom)/cfg.opt.maxParForTypes);

disp('===== Forecast Selection =====')

for iRun = 1:nRuns
    
    theseForecasts = allForecastsToSelectFrom(forecastOffset:...
        min(forecastOffset + cfg.opt.maxParForTypes - 1, end));
    
    forecastOffset = forecastOffset + cfg.opt.maxParForTypes;
    
    poolobj = gcp('nocreate');
    delete(poolobj);
    
%     for instance = 1:nInstances
    parfor instance = 1:nInstances
        % Battery properties
        batteryCapacity = meanKWhs(instance)*batteryCapacityRatio*...
            stepsPerDay;
        
        % Separate Data into training and parameter selection sets
        demandValuesTrain = allDemandValues{instance}(trainIdxs, :);
        
        demandValuesSelection = allDemandValues{instance}(...
            forecastSelectionIdxs, :);
        
        peakLocalPower = max(demandValuesSelection);
        
        % Create 'historical load pattern' used for initialization etc.
        loadPattern = mean(reshape(demandValuesTrain, [cfg.sim.k,...
            length(demandValuesTrain)/cfg.sim.k]), 2); %#ok<*PFBNS>
        
        godCastValues = createGodCast(demandValuesSelection, ...
            cfg.sim.horizon);
        
        %% For each parametrized method run simulation
        for iForecastType = theseForecasts
            
            runControl = [];
            runControl.forecastModels = forecastModels;
            
            if strcmp(allMethodStrings{iForecastType},...
                    'setPoint');
                error(['Should not have found setPoint method during' ...
                    'parameter selection']);
            else
                runControl.setPoint = false;
            end
            
            runControl.naivePeriodic = false;
            runControl.godCast = false;
            runControl.skipRun = false;
            
            % Create a battery and run optimal control:
            battery = Battery(cfg, batteryCapacity);
            
            [ runningPeak, exitFlag, forecastUsed, ~, ~, ~ ] = ...
                mpcController(cfg, pars{instance, iForecastType},...
                godCastValues, demandValuesSelection, loadPattern,...
                battery, runControl);
            
            %% Extract simulation results
            peakReductions{instance}(iForecastType) = ...
                extractSimulationResults(runningPeak',...
                demandValuesSelection, cfg.sim.k*...
                cfg.opt.billingPeriodDays);
            
            peakPowers{instance}(iForecastType) = peakLocalPower;
            smallestExitFlag{instance}(iForecastType) = min(exitFlag);
            
            if strcmp(allMethodStrings{iForecastType}, 'forecastFree');
                error(['Should not have found forecastFree method ' ...
                    'during parameter selection']);
            end
            
            if strcmp(allMethodStrings{iForecastType}, 'setPoint');
                error(['Should not have found setPoint method ' ...
                    'during parameter selection']);
            end
            
            % Compute the performance of the forecast by all metrics
            for iMetric = 1:length(lossTypes)
                lossTestResults{instance}(iForecastType, iMetric)...
                    = mean(lossTypes{iMetric}(godCastValues',...
                    forecastUsed));
            end
        end
        
        disp(' ===== Completed instance: ===== ');
        disp(instance);
        
    end
    
    poolobj = gcp('nocreate');
    delete(poolobj);
    
    disp(' ===== Completed Forecast Types: ===== ');
    disp(theseForecasts);
    
end

timeSelection = toc(forecastSelectionTic);
disp('Time to Select Forecast Parameters:'); disp(timeSelection);

% Find the best forecast metrics from the parameter grid search
for instance = 1:nInstances
    if ~isempty(pfemRange)
        [~, idx] = max(peakReductions{instance}(pfemRange));
        bestPfemIdx(instance) = idx + min(pfemRange) - 1;
    end
    
    if ~isempty(pemdRange)
        [~, idx] = max(peakReductions{instance}(pemdRange));
        bestPemdIdx(instance) = idx + min(pemdRange) - 1;
    end
end

%% Extend relevant variables to accomodate the 2 'new' forecasts
% If they exist:

if cfg.fc.Pfem.num > 0
    cfg.fc.allMethodStrings = [cfg.fc.allMethodStrings,...
        {'bestPfemSelected'}];
end
if cfg.fc.Pemd.num > 0
    cfg.fc.allMethodStrings = [cfg.fc.allMethodStrings,...
        {'bestPemdSelected'}];
end

cfg.fc.nMethods = length(cfg.fc.allMethodStrings);

for instance = 1:nInstances
    peakReductions{instance} = zeros(cfg.fc.nMethods,1);
    peakPowers{instance} = zeros(cfg.fc.nMethods,1);
    smallestExitFlag{instance} = zeros(cfg.fc.nMethods,1);
    lossTestResults{instance} = zeros(cfg.fc.nMethods, cfg.fc.nTrainMethods);
end

%% Run Models for Performance Testing

% Extract data from Sim struct for efficiency in parfor communication
nMethods = cfg.fc.nMethods;
nTrainMethods = cfg.fc.nTrainMethods;
allMethodStrings = cfg.fc.allMethodStrings;

testingTic = tic;

poolobj = gcp('nocreate');
delete(poolobj);

disp('===== Forecast Testing =====')

% for instance = 1:nInstances
parfor instance = 1:nInstances
    
    %% Battery properties
    batteryCapacity = meanKWhs(instance)*batteryCapacityRatio*stepsPerDay;
    
    % Separate data for parameter selection and testing
    demandValuesSelection = allDemandValues{instance}(...
        forecastSelectionIdxs);
    demandValuesTest = allDemandValues{instance}(testIdxs);
    peakLocalPower = max(demandValuesTest);
    
    % Create 'historical load pattern' used for initialization etc.
    loadPattern = mean(reshape(demandValuesSelection, ...
        [cfg.sim.k, length(demandValuesSelection)/cfg.sim.k]), 2);
    
    % Create godCast forecasts
    godCastValues = createGodCast(demandValuesTest, cfg.sim.horizon);
    
    %% Test performance of all methods
    
    for methodType = 1:nMethods
        
        runControl = [];
        runControl.forecastModels = forecastModels;
        thisMethodString = allMethodStrings{methodType};
        
        %% Normal forecast-driven or set-point controller
        
        % If we are using 'bestSelected' forecast then set forecast
        % index
        if strcmp(thisMethodString, 'bestPfemSelected')
            iForecastType = bestPfemIdx(instance);
            
        elseif strcmp(thisMethodString, 'bestPemdSelected')
            iForecastType = bestPemdIdx(instance);
            
        else
            iForecastType = methodType;
        end
        
        % Check for godCast or naivePeriodic
        runControl.naivePeriodic = strcmp(thisMethodString,...
            'naivePeriodic');
        
        runControl.godCast = strcmp(thisMethodString, 'godCast');
        
        runControl.setPoint = strcmp(thisMethodString, 'setPoint');
        
        % If method is set-point then show it current demand
        if(runControl.setPoint)
            runControl.knowCurrentDemandNow = true;
        end
        
        % Check if forecast is in the set of {Pfem, Pemd} forecasts
        % in which case produce forecast but don't run simulation
        if ismember(methodType, [pfemRange, pemdRange])
            runControl.skipRun = true;
        else
            runControl.skipRun = false;
        end
        
        % Create a battery and run optimal control:
        battery = Battery(cfg, batteryCapacity);
        
        [ runningPeak, exitFlag, forecastUsed, ~, ~, ~ ] = ...
            mpcController(cfg, pars{instance, iForecastType}, ...
            godCastValues, demandValuesTest, loadPattern, battery, ...
            runControl);
        
        if ~runControl.skipRun
            
            % ====== DEBUGGING ====== :
            % plot([runningPeak', demandValuesTest]);
            % legend('Running Peak [kW]', 'Local Demand [kWh]');
            % ====== ======
            
            % Extract simulation results
            peakReductions{instance}(methodType) = ...
                extractSimulationResults(runningPeak',...
                demandValuesTest, cfg.sim.k*cfg.opt.billingPeriodDays);
            
            peakPowers{instance}(methodType) = peakLocalPower;
            smallestExitFlag{instance}(methodType) = min(exitFlag);
        end
        
        % Compute the performance of the forecast by all metrics
        isForecastFree = strcmp(thisMethodString, 'forecastFree');
        isSetPoint = strcmp(thisMethodString, 'setPoint');
        
        if (~isForecastFree && ~isSetPoint)
            for iMetric = 1:length(lossTypes)
                lossTestResults{instance}(methodType, iMetric)...
                    = mean(lossTypes{iMetric}(godCastValues', ...
                    forecastUsed));
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
% Use for loops to avoid the confusion of reshape statements

peakPowersArray = zeros(nMethods, cfg.sim.nAggregates, length(cfg.sim.nCustomers));
peakReductionsArray = peakPowersArray;
smallestExitFlagArray = peakPowersArray;
meanKWhsArray = zeros(cfg.sim.nAggregates, length(cfg.sim.nCustomers));
lossTestResultsArray = zeros([nMethods, cfg.sim.nAggregates, ...
    length(cfg.sim.nCustomers), nTrainMethods]);

bestPfemIdxArray = zeros(cfg.sim.nAggregates, length(cfg.sim.nCustomers));
bestPemdIdxArray = bestPfemIdxArray;

instance = 0;
for nCustomerIdx = 1:length(cfg.sim.nCustomers)
    for trial = 1:cfg.sim.nAggregates
        
        instance = instance + 1;
        meanKWhsArray(trial, nCustomerIdx) = meanKWhs(instance, 1);
        bestPfemIdxArray(trial, nCustomerIdx) = bestPfemIdx(instance);
        bestPemdIdxArray(trial, nCustomerIdx) = bestPemdIdx(instance);
        
        for iMethod = 1:nMethods
            
            peakPowersArray(iMethod, trial, nCustomerIdx) = ...
                peakPowers{instance}(iMethod, 1);
            
            peakReductionsArray(iMethod, trial, nCustomerIdx) = ...
                peakReductions{instance}(iMethod, 1);
            
            smallestExitFlagArray(iMethod, trial, nCustomerIdx) = ...
                smallestExitFlag{instance}(iMethod, 1);
            
            
            
            for metric = 1:nTrainMethods
                
                lossTestResultsArray(iMethod, trial, nCustomerIdx, ...
                    metric) = lossTestResults{instance}(iMethod, metric);
                
            end
        end
    end
end

%% Fromatting
% Collapse Trial Dimension
peakReductionsTrialFlattened = reshape(peakReductionsArray, ...
    [nMethods, length(cfg.sim.nCustomers)*cfg.sim.nAggregates]);

peakPowersTrialFlattened = reshape(peakPowersArray, ...
    [nMethods, length(cfg.sim.nCustomers)*cfg.sim.nAggregates]);

%% Put results together in structure for passing out
results.peakReductions = peakReductionsArray;
results.peakReductionsTrialFlattened = peakReductionsTrialFlattened;
results.peakPowers = peakPowersArray;
results.peakPowersTrialFlattened = peakPowersTrialFlattened;
results.smallestExitFlag = smallestExitFlagArray;
results.meanKWhs = meanKWhsArray;
results.lossTestResults = lossTestResultsArray;
results.bestPfemForecast = bestPfemIdx;
results.bestPemdForecast = bestPemdIdx;
results.bestPfemForecastArray = bestPfemIdxArray;
results.bestPemdForecastArray = bestPemdIdxArray;

end
