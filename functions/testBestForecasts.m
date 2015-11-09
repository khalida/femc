function [ Sim, results ] = testBestForecasts( pars, allDemandValues,...
    Sim, MPC, k)

% testBestForecasts: Test the performance of forecasts that minimize error
            % metrics with paraemters selected using stochstic process.

%% Pre-Allocation
Sim.hourNumberTest = Sim.hourNumber(Sim.testIdxs, :);

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
        zeros(Sim.nMethods, Sim.nTrainMethods);
end

% Extract data from Sim for efficiency (parfor comms overhead)
batteryCapacityRatio = Sim.batteryCapacityRatio;
batteryChargingFactor = Sim.batteryChargingFactor;
trainIdxs = Sim.trainIdxs;
testIdxs = Sim.testIdxs;
lossTypes = Sim.lossTypes;

stepsPerDay = Sim.stepsPerDay;
nInstances = Sim.nInstances;

nMethods = Sim.nMethods;
nTrainMethods = Sim.nTrainMethods;
allMethodStrings = Sim.allMethodStrings;
hourNumberTest = Sim.hourNumberTest;
stepsPerHour = Sim.stepsPerHour;

testingTic = tic;

% Set any missing default values in MPC structure
MPC = setDefaultValues(MPC, {'billingPeriodDays', 1});


%% Run Models for performance evaluation
disp('==== Forecast Testing ===')

parfor instance = 1:nInstances
    
    allKWhs(instance) = mean(allDemandValues{instance});
    
    % Battery properties
    batteryCapacity = allKWhs(instance)*batteryCapacityRatio*stepsPerDay;
    maximumChargeRate = batteryChargingFactor*batteryCapacity;
    
    % Separate Data into training and testing
    demandValuesTrain = allDemandValues{instance}(trainIdxs);
    demandValuesTest = allDemandValues{instance}(testIdxs);
    peakLocalPower = max(demandValuesTest);
    
    % Create 'historical load pattern' used for initialisation etc.
    loadPattern = mean(reshape(demandValuesTrain, ...
        [k, length(demandValuesTrain)/k]), 2);
    
    godCastValues = zeros(length(testIdxs), k);
    for jj = 1:k
        godCastValues(:, jj) = circshift(demandValuesTest, -[jj-1, 0]);
    end
    
    %% For each method remaining
    for methodType = 1:nMethods
        
        runControl = [];
        runControl.MPC = MPC;
        thisMethodString = allMethodStrings{methodType}; %#ok<PFBNS>
        
        if strcmp(thisMethodString, 'forecastFree')
            % Evaluate performance of forecastFree controller
            [ runningPeak ] = mpcControllerForecastFree( ...
                pars{instance, methodType}, demandValuesTest,...
                batteryCapacity, maximumChargeRate, loadPattern,...
                hourNumberTest, stepsPerHour, MPC);
            
            exitFlag = 1;
            
        else
            % Implement a normal forecast-driven or set-point controller
            
            % Check if we are on godCast or naivePeriodic
            runControl.naivePeriodic = ...
                strcmp(thisMethodString, 'naivePeriodic');
            
            runControl.godCast = ...
                strcmp(thisMethodString, 'godCast');
            
            runControl.MPC.setPoint = ...
                strcmp(thisMethodString, 'setPoint');
            
            runControl.skipRun = false;
            
            % If method is set-point then show it current demand
            if(runControl.MPC.setPoint)
                runControl.MPC.knowCurrentDemandNow = true;
            end
            
            [runningPeak, exitFlag, fcUsed] = mpcController( ...
                pars{instance, methodType}, godCastValues, ...
                demandValuesTest, batteryCapacity, maximumChargeRate,...
                loadPattern, hourNumberTest, stepsPerHour, k, runControl);
            
            % Compute the performance of the forecast by all metrics
            isForecastFree = strcmp(thisMethodString, 'forecastFree');
            isSetPoint = strcmp(thisMethodString, 'setPoint');
            
            if (~isForecastFree && ~isSetPoint)
                for iMetric = 1:nTrainMethods
                    lossTestResults{instance}(methodType, iMetric)...
                        = mean(lossTypes{iMetric}(godCastValues', ...
                        fcUsed)); %#ok<PFBNS>
                end
            end
        end
        
        % Extract simulation results
        peakReductions{instance}(methodType) = ...
            extractSimulationResults(runningPeak',...
            demandValuesTest, k*MPC.billingPeriodDays);
        
        peakPowers{instance}(methodType) = peakLocalPower;
        smallestExitFlag{instance}(methodType) = min(exitFlag);
        
    end
    disp(' === Instance Completed: === ');
    disp(instance);
end

timeTesting = toc(testingTic);
disp('Time to Test Forecasts:'); disp(timeTesting);

%% Convert to arrays from cellArrays
% Use for loops to avoid the confusion of reshape statements

peakPowersArray = zeros(nMethods, Sim.nAggregates, length(Sim.nCustomers));
peakReductionsArray = peakPowersArray;
smallestExitFlagArray = peakPowersArray;
allKWhsArray = zeros(Sim.nAggregates, length(Sim.nCustomers));
lossTestResultsArray = zeros([nMethods, Sim.nAggregates, ...
    length(Sim.nCustomers), nTrainMethods]);

instance = 0;
for nCustomerIdx = 1:length(Sim.nCustomers)
    for trial = 1:Sim.nAggregates
        
        instance = instance + 1;
        allKWhsArray(trial, nCustomerIdx) = allKWhs(instance, 1);
        
        for iMethod = 1:nMethods
            
            peakPowersArray(iMethod, trial, nCustomerIdx) = ...
                peakPowers{instance}(iMethod, 1);
            
            peakReductionsArray(iMethod, trial, nCustomerIdx) = ...
                peakReductions{instance}(iMethod, 1);
            
            smallestExitFlagArray(iMethod, trial, nCustomerIdx) = ...
                smallestExitFlag{instance}(iMethod, 1);
            
            for iMetric = 1:nTrainMethods
                
                lossTestResultsArray(iMethod, trial, nCustomerIdx, ...
                    iMetric) = lossTestResults{instance}(iMethod, iMetric);
                
            end
        end
    end
end


%% Fromatting
% Collapse Trial Dimension
peakReductionsTrialFlattened = reshape(peakReductionsArray, ...
    [nMethods, length(Sim.nCustomers)*Sim.nAggregates]);

peakPowersTrialFlattened = reshape(peakPowersArray, ...
    [nMethods, length(Sim.nCustomers)*Sim.nAggregates]);

%% Put results together in structure for passing out
results.peakReductions = peakReductionsArray;
results.peakReductionsTrialFlattened = peakReductionsTrialFlattened;
results.peakPowers = peakPowersArray;
results.peakPowersTrialFlattened = peakPowersTrialFlattened;
results.smallestExitFlag = smallestExitFlagArray;
results.allKWhs = allKWhsArray;
results.lossTestResults = lossTestResultsArray;

end
