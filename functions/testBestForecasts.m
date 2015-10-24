function [ Sim, results ] = testBestForecasts( pars, allDemandValues,...
    Sim, MPC, k)

% testBestForecasts: Test the performance of best parameterized forecasts
% selected using stochstic selection.

%% Pre-Allocation
Sim.hourNumbersTest = Sim.hourNumbers(Sim.testIdxs, :);

% Sim time (& range) for forecast testing
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
lossTypesStrings = Sim.lossTypesStrings;
hourNumbersTest = Sim.hourNumbersTest;
stepsPerHour = Sim.stepsPerHour;

testingTic = tic;

% Set any missing default values in MPC structure
MPC = setDefaultValues(MPC, 'billingPeriodDays', 1});


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
    
    %% For each method (except non-opt parameterised ones)
    for forecastType = 1:nMethods
        
        runControl = [];
        runControl.MPC = MPC;
        
        if strcmp(lossTypesStrings{forecastType}, 'fcastFree') %#ok<PFBNS>
            % Implement fcastFree controller
            
            % Evaluate performance of controller
            [ runningPeak ] = mpcControllerForecastFree( simRangeTest,...
                pars{instance, forecastType}, demandValuesTest,...
                batteryCapacity, maximumChargeRate, loadPattern,...
                hourNumbersTest, stepsPerHour, MPC);
            
            exitFlag = 1;
        else
            % Implement a normal forecast-driven or set-point controller
            
            % Check if we are on godCast or naivePeriodic
            runControl.naivePeriodic = ...
                strcmp(lossTypesStrings{forecastType}, 'naivePeriodic');
            
            runControl.godCast = ...
                strcmp(lossTypesStrings{forecastType}, 'godCast');
            
            runControl.MPC.setPoint = ...
                strcmp(lossTypesStrings{forecastType}, 'setPoint');
            
            % If method is set-point then show it current demand
            if(runControl.MPC.setPoint)
                runControl.MPC.knowCurrentDemand = true;
            end
            
            [runningPeak, exitFlag, fcUsed] = mpcController( ...
                simRangeTest, pars{instance, forecastType}, ...
                godCastValues, demandValuesTest, batteryCapacity, ...
                maximumChargeRate, loadPattern, hourNumbersTest, ...
                stepsPerHour, k, runControl);
            
            % Compute the performance of the forecast by all metrics
            if ~strcmp(lossTypesStrings{forecastType}, 'setPoint');
                for eachError = 1:length(lossTypes)
                    lossTestResults{instance}(forecastType, eachError)...
                        = mean(lossTypes{eachError}(godCastValues', fcUsed));
                end
            end
        end
        
        % Extract simulation results
        gridPowerTimsSeries = runningPeak';
        gridBillingPeriodColumns = reshape(gridPowerTimsSeries,...
            [k*MPC.billingPeriodDays,...
            length(gridPowerTimsSeries)/(k*MPC.billingPeriodDays)]);
        
        gridBillingPeriodPeaks = max(gridBillingPeriodColumns);
        
        demandBillingPeriodColumns = reshape(demandValuesTest,...
            [k*MPC.billingPeriodDays, ...
            length(demandValuesTest)/(k*MPC.billingPeriodDays)]);
        
        demandBillingPeriodPeaks = max(demandBillingPeriodColumns);
        
        billingPeriodRatios = ...
            gridBillingPeriodPeaks./demandBillingPeriodPeaks;
        
        peakReductions{instance}(forecastType) = ...
            1 - mean(billingPeriodRatios);
        peakPowers{instance}(forecastType) = peakLocalPower;
        smallestExitFlag{instance}(forecastType) = min(exitFlag);
        
    end
    disp('Instance Completed: ');
    disp(instance);
end

timeTesting = toc(testingTic);
disp('Time to Test Forecasts:'); disp(timeTesting);


%% Convert from cellArrays to arrays
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

end
