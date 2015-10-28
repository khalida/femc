function [ runningPeak ] = mpcControllerForecastFree( net, demand, ...
    batteryCapacity, maximumChargeRate, loadPattern, hourNum,...
    stepsPerHour, MPC)

% mpcControllerForecastFree: Time series simulation of a forecast free
                                % controller

%% Initialisations
demandDelays = loadPattern;
stateOfCharge = 0.5*batteryCapacity;
nIdxs = length(demand);

%% Pre-Allocations
runningPeak = zeros(1, nIdxs);

%% Set Default Values:
MPC = setDefaultValues(MPC, {'knowCurrentDemandNow', false, ...
    'SPrecourse', false, 'resetPeakToMean', false, ...
    'billingPeriodDays', 1});

if MPC.resetPeakToMean
    peakSoFar = mean(loadPattern);
else
    peakSoFar = 0;
end
daysPassed = 0;

%% Run through time series
for idx = 1:nIdxs
    demandNow = demand(idx);
    hourNow = hourNum(idx);
    
    if MPC.knowCurrentDemandNow
        featureVector = [demandDelays; demandNow; stateOfCharge;...
            peakSoFar; hourNow];
    else
        featureVector = [demandDelays; stateOfCharge; peakSoFar; hourNow];
    end
    
    forecastFreeControllerOutput = net( featureVector );
    
    % Apply set point recourse if selected
    if MPC.SPrecourse
        powerToBatteryNow = forecastFreeControllerOutput(1);
        peakForecastPower = max([forecastFreeControllerOutput(2); peakSoFar]);
        
        if (demandNow + powerToBatteryNow) > peakForecastPower
            powerToBatteryNow = peakForecastPower - demandNow;
        end
    else
        powerToBatteryNow = forecastFreeControllerOutput;
    end
    
    % Apply control decision, subject to rate and state of charge
    % constriants
    powerToBatteryNow = max([powerToBatteryNow, ...
        -stateOfCharge*stepsPerHour, -demandNow, -maximumChargeRate]);
    powerToBatteryNow = min([powerToBatteryNow, (batteryCapacity-stateOfCharge)*stepsPerHour, ...
        maximumChargeRate]);
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
    
    % Compute outputs for saving
    runningPeak(idx) = peakSoFar;
    
    % Shift demand delays (and add current demand)
    demandDelays = [demandDelays(2:end); demand(idx)];
end

end
