function [ featureVectors, decisionVectors ] = ...
    mpcGenerateForecastFreeExamples(godCast, demand, ...
    batteryCapacity, maximumChargeRate, loadPattern, hourNum,...
    stepsPerHour, k, MPC)

% mpcGenerateForecastFreeExamples: Simulate ttime series behaviour of MPC
        % controller with godCast input to generate fcast free training
        % examples.

%% Initializations
demandDelays = loadPattern;
stateOfCharge = 0.5*batteryCapacity;
nIdxs = length(demand);

% Set default values of MPC structure
MPC = setDefaultValues(MPC, {'SPrecourse', false, ...
    'resetPeakToMean', false, 'knowCurrentDemandNow', false, ...
    'billingPeriodDays', 1});

if MPC.resetPeakToMean
    peakSoFar = mean(loadPattern);
else
    peakSoFar = 0;
end

daysPassed = 0;

%% Pre-Allocations
% Features <k previous demands, (demandNow), SoC, peakSoFar, hourNum>
if MPC.knowCurrentDemandNow
    featureVectors = zeros(k + 4, nIdxs);
else
    featureVectors = zeros(k + 3, nIdxs);
end

% Response <next step charging power, (peakForecastPower)>
if MPC.SPrecourse
    decisionVectors = zeros(2, nIdxs);
else
    decisionVectors = zeros(1, nIdxs);
end


%% Run through time series
for idx = 1:nIdxs
    demandNow = demand(idx);
    hourNow = hourNum(idx);
    
    % Use godCast as we want on-line controller to be as effective
    % as possible
    forecast = godCast(idx, :)';
    
    % And we're not using setPoint:
    MPC.setPoint = false;
    
    % Find optimal battery charging actions
    [powerToBattery, ~] = controllerOptimiser(forecast, stateOfCharge, ...
        demandNow, batteryCapacity, maximumChargeRate, stepsPerHour, ...
        peakSoFar, MPC);
    
    % Save feature and response vectors:
    if MPC.knowCurrentDemandNow
        featureVectors(:, idx) = [demandDelays; demandNow; ...
            stateOfCharge; peakSoFar; hourNow];
    else
        featureVectors(:, idx) = [demandDelays; stateOfCharge;...
            peakSoFar; hourNow];
    end

    % Save data for set-point recourse if required
    if MPC.SPrecourse
        % Peak power over horizon if forecasts correct and actions taken
        peakForecastPower = max([powerToBattery(:) + forecast(:); peakSoFar]);
        decisionVectors(:, idx) =  [powerToBattery(1); peakForecastPower];
        
        % Check if optimal action combined with actual current demand
        % will exceed this peak - and if so rectify charging action
        if (demandNow + powerToBattery(1)) > peakForecastPower
            powerToBatteryNow = peakForecastPower - demandNow;
        else
            powerToBatteryNow = powerToBattery(1);
        end

    else
        decisionVectors(:, idx) =  powerToBattery(1);
        powerToBatteryNow = powerToBattery(1);
    end
    
    % Apply control action to plant, subject to rate and state of charge
    % constraints
    powerToBatteryNow = max([powerToBatteryNow, ...
        -stateOfCharge*stepsPerHour, -demandNow, -maximumChargeRate]);
    powerToBatteryNow = min([powerToBatteryNow, ...
        (batteryCapacity-stateOfCharge)*stepsPerHour, maximumChargeRate]);
    stateOfCharge = stateOfCharge + powerToBatteryNow*(1/stepsPerHour);
    
    % Update current peak power
    % Reset if we are at start of day (and NOT first interval)
    if hourNow == 1 &&  idx ~= 1
        daysPassed = daysPassed + 1;
    end
    
    if daysPassed == MPC.billingPeriodDays
        daysPassed = 0;
        
        if MPC.resetPeakToMean
            peakSoFar = mean(loadPattern);
        else
            peakSoFar = 0;
        end
    else
        peakSoFar = max(peakSoFar, demandNow + powerToBatteryNow);
    end
    
    % Shift demand delays and add current demand
    demandDelays = [demandDelays(2:end); demand(idx)];
end

end
