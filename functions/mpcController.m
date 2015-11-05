function [ runningPeak, exitFlag, forecastUsed ] = mpcController( net, ...
    godCast, demand, batteryCapacity, maximumChargeRate, loadPattern, ...
    hourNum, stepsPerHour, k, runControl)

% mpcController: Simulate time series behaviour of MPC controller with
        % given forecast

% Set default MPC values if not given:
runControl = setDefaultValues(runControl, {'MPC', 'default',...
    'skipRun', false});
runControl.MPC = setDefaultValues(runControl.MPC,...
    {'SPrecourse', false, 'resetPeakToMean', false,...
    'billingPeriodDays', 1});

%% Initializations
demandDelays = loadPattern;
stateOfCharge = 0.5*batteryCapacity;

if runControl.MPC.resetPeakToMean
    peakSoFar = mean(loadPattern);
else
    peakSoFar = 0;
end
daysPassed = 0;

nIdxs = length(demand);

%% Pre-Allocations
runningPeak = zeros(1, nIdxs);
exitFlag = zeros(1, nIdxs);
forecastUsed = zeros(k, nIdxs);

%% Run through time series
for idx = 1:nIdxs;
    demandNow = demand(idx);
    hourNow = hourNum(idx);
    
    if runControl.godCast
        forecast = godCast(idx, :)';
    elseif runControl.naivePeriodic
        forecast = demandDelays;
    elseif runControl.MPC.setPoint
        forecast = ones(size(demandDelays)).*demandNow;
    else
        % Produce forecast from input net
        trainControl.suppressOutput = runControl.MPC.suppressOutput;
        forecast = forecastFfnn( net, demandDelays, ...
            trainControl);
    end
    
    forecastUsed(:, idx) = forecast;
    
    if runControl.skipRun
        continue;
    end
    
    [powerToBattery, exitFlag(idx)] = controllerOptimiser(forecast, ...
        stateOfCharge, demandNow, batteryCapacity, maximumChargeRate, ...
        stepsPerHour, peakSoFar, runControl.MPC);
    
    % ===== DEBUGGING ===== :
%     figure(1);
%     plot([forecast./stepsPerHour, godCast(idx, :)'./stepsPerHour, ...
%         powerToBattery./stepsPerHour, ...
%         cumsum(powerToBattery./stepsPerHour) + stateOfCharge, ...
%         (forecast + powerToBattery)./stepsPerHour]);
%     hline = refline(0, peakSoFar./stepsPerHour); hline.LineWidth = 2;
%     hline.Color = 'k';
%     grid on;
%     legend('Forecast [kWh/interval]', 'GodCast [kWh/interval]', ...
%         'Power to Batt [kWh/interval]', 'SoC [kWh]', ...
%         'Demand from Grid [kWh/interval]');
    % ===== ======

    % Implement set point recourse, if selected
    if runControl.MPC.SPrecourse
        
        % Peak power based on current forecast and decisions
        peakForecastPower = max([powerToBattery(:) + forecast(:); peakSoFar]);
        
        % Check if optimal control action combined with actual demand
        % will exceed this peak; rectify charging action if so:
        if (demandNow + powerToBattery(1)) > peakForecastPower
            powerToBatteryNow = peakForecastPower - demandNow;
        else
            powerToBatteryNow = powerToBattery(1);
        end
        
    else
        powerToBatteryNow = powerToBattery(1);
    end
    
    % Apply control action to plant (subject to rate and state of charnge
    % constraints)
    powerToBatteryNow = max([powerToBatteryNow, ...
        -stateOfCharge*stepsPerHour, -demandNow, -maximumChargeRate]);
    powerToBatteryNow = min([powerToBatteryNow, ...
        (batteryCapacity-stateOfCharge)*stepsPerHour, maximumChargeRate]);
    stateOfCharge = stateOfCharge + powerToBatteryNow*(1/stepsPerHour);
    
    % Update current peak power
    % Reset if we are at start of day(and NOT first time-step!)
    if hourNow == 1 &&  idx ~= 1
        daysPassed = daysPassed + 1;
    end
    
    if daysPassed == runControl.MPC.billingPeriodDays
        daysPassed = 0;
        
        if runControl.MPC.resetPeakToMean
            peakSoFar = mean(loadPattern);
        else
            peakSoFar = 0;
        end
    else
        peakSoFar = max(peakSoFar, demandNow + powerToBatteryNow);
    end
    
    % Compute outputs for saving
    runningPeak(idx) = peakSoFar;
    
    % Shift demandDelays (and add current demand)
    demandDelays = [demandDelays(2:end); demand(idx)];
end

end
