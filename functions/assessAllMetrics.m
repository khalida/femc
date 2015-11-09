function [bestPfemIdx, bestPemdIdx, Pfem, Pemd, Sim] = assessAllMetrics(...
    Pfem, Pemd, Sim, allDemandValues, k, MPC)

tic;
% assessAllMetrics: Stochastically assess the performance of various
%                   forecast error metrics

Sim.stepsPerDay = Sim.stepsPerHour*Sim.hoursPerDay;
Sim.nHoursTrain = Sim.hoursPerDay*Sim.nDaysTrain;
Sim.nHoursTest = Sim.hoursPerDay*Sim.nDaysTest;
Sim.nHoursSelect = Sim.hoursPerDay*Sim.nDaysSelect;

% Generate sets of indexes for parameter selection, training, and testing
Sim.forecastSelectionIdxs = 1:(Sim.stepsPerHour*Sim.nHoursSelect);
Sim.trainIdxs = (1:(Sim.stepsPerHour*Sim.nHoursTrain)) + ...
    Sim.forecastSelectionIdxs(end);
Sim.testIdxs = (1:(Sim.stepsPerHour*Sim.nHoursTest)) + Sim.trainIdxs(end);

hourNumbers = mod((1:size(allDemandValues{1}, 1))', k);
hourNumbersSelect = hourNumbers(Sim.forecastSelectionIdxs, :);

%% Extract local variables to save parfor comms overhead
nInstances = Sim.nInstances;
nTrainMethods = Sim.nTrainMethods;
lossTypes = Sim.lossTypes;
stepsPerHour = Sim.stepsPerHour;
stepsPerDay = Sim.stepsPerDay;
batteryCapacityRatio = Sim.batteryCapacityRatio;
batteryChargingFactor = Sim.batteryChargingFactor;
forecastSelectionIdxs = Sim.forecastSelectionIdxs;
trainIdxs = Sim.trainIdxs;

%% Evaluate peformance of forecast with random perturbations
disp(' ==== Running Stochastic Forecasts ==== ');

nStochasticForecasts = Sim.nStochasticForecasts;
relativeSizeError = Sim.relativeSizeError;

stochasticForecastPerformance = zeros(nInstances, nStochasticForecasts);
stochasticForecastMetrics = zeros(nInstances, nStochasticForecasts,...
    nTrainMethods);

MPC = setDefaultValues(MPC, {'billingPeriodDays', 1});

parfor instance = 1:nInstances
    
    %% Extract aggregated demand
    demandValues = allDemandValues{instance};
    meanDemand = mean(demandValues);
    
    %% Battery properties
    batteryCapacity = meanDemand*batteryCapacityRatio*stepsPerDay;
    maximumChargeRate = batteryChargingFactor*batteryCapacity;
    
    %% Separate Data into training and testing
    demandValuesSelection = demandValues(forecastSelectionIdxs, :);
    demandValuesTrain = demandValues(trainIdxs, :);
    
    %% Create 'typical load pattern' for initialisation etc.
    loadPattern = mean(reshape(demandValuesTrain, ...
        [k, length(demandValuesTrain)/k]), 2);
    
    godCastOriginal = zeros(length(forecastSelectionIdxs), k);
    for jj = 1:k
        godCastOriginal(:, jj) = circshift(demandValuesSelection,...
            -[jj-1, 0]);
    end
    
    %% For each of the stochastic 'forecast' generate a random pertubation
    % to the godCast
    thisStochMetrics = zeros(1, nStochasticForecasts, nTrainMethods);
    
    for eachForecast = 1:nStochasticForecasts
        godCast = godCastOriginal + (rand(size(godCastOriginal))-0.5).*...
            (relativeSizeError*meanDemand);
        
        % Set forecast type to godCast (and not Naive or Set-Point)
        runControl = [];
        runControl.naiveP = false;
        runControl.godCast = true;
        runControl.MPC = MPC;
        runControl.MPC.setPoint = false;
        runControl.skipRun = false;
        
        [ runningPeak, ~, forecastUsed ] = mpcController( [], godCast,...
            demandValuesSelection, batteryCapacity, maximumChargeRate, ...
            loadPattern, hourNumbersSelect, stepsPerHour, k, runControl);
        
        % Extract simulation results
        stochasticForecastPerformance(instance, eachForecast) = ...
            extractSimulationResults(runningPeak', ...
            demandValuesSelection, k*MPC.billingPeriodDays);
        
        % Compute the performance of the 'forecast' by all train metrics
        for eachError = 1:nTrainMethods
            thisStochMetrics(1, eachForecast, eachError) = ...
                mean(lossTypes{eachError}(...
                godCastOriginal', forecastUsed)); %#ok<PFBNS>
        end
        
        disp(' === Stoch Forecast done: ===');
        disp(eachForecast);
        
    end
    
    stochasticForecastMetrics(instance, :, :) = thisStochMetrics;
    
    disp(' === Fraction of Instances Done: ===');
    disp(instance/nInstances);
    
end

disp('Time to end Metric Paraemeter Selection:');
toc;

disp('==== Selecting Best PFEM, PEMD, Parameter Values ====');
% Seek that with most negative correlation with performance

metricCorrelations = ones(nInstances, nTrainMethods).*Inf;
bestPemdIdx = zeros(nInstances, 1);
bestPfemIdx = zeros(nInstances, 1);

for instance = 1:nInstances
    
    %% Create normalised version of metrics in range [0, 1]
    thisForecastMetrics = squeeze(stochasticForecastMetrics(instance, ...
        :, :)); % nStochasticForecasts x nTrainMethods
    
    maxValues = repmat(max(thisForecastMetrics, [], 1),...
        [size(thisForecastMetrics, 1), 1]);
    
    minValues = repmat(min(thisForecastMetrics, [], 1),...
        [size(thisForecastMetrics, 1), 1]);
    
    thisForecastMetricsNormalised = (thisForecastMetrics - minValues)./ ...
        (maxValues - minValues);
    
    %% Find best PEMD parameters:
    if Pemd.num > 0
        for eachError = Pemd.range
            metricCorrelations(instance, eachError) = corr(...
                thisForecastMetricsNormalised(:, eachError), ...
                stochasticForecastPerformance(instance, :)');
        end
        [~, bestPemdIdx(instance)] = min(metricCorrelations(instance, :));
        
        % Reset PEMD values before repeating for PFEM parameters:
        metricCorrelations(instance, Pemd.range) = Inf;
    else
        bestPemdIdx = [];
    end
    
    %% Find best PFEM parameters:
    if Pfem.num > 0
        for eachError = Pfem.range
            metricCorrelations(instance, eachError) = corr(...
                thisForecastMetricsNormalised(:, eachError),...
                stochasticForecastPerformance(instance, :)');
        end
        [~, bestPfemIdx(instance)] = min(metricCorrelations(instance, :));
    else
        bestPfemIdx = [];
    end
    
    figure();
    plot(thisForecastMetricsNormalised, ...
        stochasticForecastPerformance(instance, :), '.');
    legend(Sim.lossTypesStrings);
end

end
