function [ runningPeak ] = ...
    onlineMPC_controller_fcastFree( simRange, net, demand, batt_cap, ...
    max_charge_rate, load_pattern, hourNum, steps_per_hour, runControl)

%ONLINEMPC_CONTROLLER_FCASTFREE Time series simulation of a forecast free
%                           controller

%% Initialisations
demand_delays = load_pattern;
SoC = 0.5*batt_cap;
ts = simRange(1):(1/steps_per_hour):simRange(2); % time in hours

%% Pre-Allocations
runningPeak = zeros(1, length(ts));

if ~isfield(runControl.MPC, 'knowCurrentDemand'); runControl.MPC.knowCurrentDemand = true;
    warning('Using default MPC.knowCurrentDemand');  end;
if ~isfield(runControl.MPC, 'SPrecourse'); runControl.MPC.SPrecourse = false;
    warning('Using default MPC.SPrecourse');  end;
if ~isfield(runControl.MPC, 'resetPeakToMean'); runControl.MPC.resetPeakToMean = false;
    warning('Using default MPC.resetPeakToMean');  end;
if ~isfield(runControl.MPC, 'billingPeriodDays'); runControl.MPC.billingPeriodDays = 1;
    warning('Using default MPC.billingPeriodDays');  end;

if runControl.MPC.resetPeakToMean
    peak_so_far = mean(load_pattern);
else
    peak_so_far = 0;
end
daysPassed = 0;

%% Run through time series
idx = 1;
for t = ts
    demand_now = demand(idx);
    hour_now = hourNum(idx);
    
    if runControl.MPC.knowCurrentDemand
        featVec = [demand_delays; demand_now; SoC; peak_so_far; hour_now];
    else
        featVec = [demand_delays; SoC; peak_so_far; hour_now];
    end
    
    fcastControllerOutput = net( featVec );
    
    if runControl.MPC.SPrecourse
        pwr2batt_now = fcastControllerOutput(1);
        % peakForecastPower = fcastControllerOutput(2);
        peakForecastPower = max([fcastControllerOutput(2); peak_so_far]);
        
        if (demand_now + pwr2batt_now) > peakForecastPower
            pwr2batt_now = peakForecastPower - demand_now;
        end
    else
        pwr2batt_now = fcastControllerOutput;
    end
    
    % Apply control decision
    pwr2batt_now = max([pwr2batt_now, -SoC*steps_per_hour, -demand_now, ...
        -max_charge_rate]);
    pwr2batt_now = min([pwr2batt_now, (batt_cap-SoC)*steps_per_hour, ...
        max_charge_rate]);
    SoC = SoC + pwr2batt_now*(1/steps_per_hour);
    
    % Update current peak power
    if hour_now == 1 &&  idx ~= 1 % Reset if we are at start of day (and NOT first time-step!)
        daysPassed = daysPassed + 1;
    end
    
    if daysPassed == runControl.MPC.billingPeriodDays
        daysPassed = 0;
        
        if runControl.MPC.resetPeakToMean
            peak_so_far = mean(load_pattern);
        else
            peak_so_far = 0;
        end
    else
        peak_so_far = max(peak_so_far, demand_now + pwr2batt_now);
    end
    
    % Compute outputs for saving
    runningPeak(idx) = peak_so_far;
    
    % Shift demand delays one by one (and add current demand)
    demand_delays = [demand_delays(2:end); demand(idx)];
    idx = idx + 1;
end

end
