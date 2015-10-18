function [ runningPeak, exitFlag, fcUsed ] = ...
    onlineMPC_controller( simRange, net, godCast, demand, ...
    batt_cap, max_charge_rate, load_pattern, hourNum, steps_per_hour, ...
    k, runControl)

%ONLINEMPC_CONTROLLER Simulate t-series behaviour of MPC controller with
%given forecast
%   Replaces the original 'MG_MPC_fc' simulink model

% Default MPC values if not given:
if ~isfield(runControl, 'MPC'); runControl.MPC.values = 'default';
warning('Using default MPC values');  end;
if ~isfield(runControl.MPC, 'SPrecourse'); runControl.MPC.SPrecourse = false;
warning('Using default MPC.SPrecourse');  end;
if ~isfield(runControl.MPC, 'resetPeakToMean'); runControl.MPC.resetPeakToMean = false;
warning('Using default MPC.resetPeakToMean');  end;
if ~isfield(runControl.MPC, 'billingPeriodDays'); runControl.MPC.billingPeriodDays = 1;
warning('Using default MPC.billingPeriodDays');  end;

%% Initialisations
demand_delays = load_pattern;
SoC = 0.5*batt_cap;

if runControl.MPC.resetPeakToMean
    peak_so_far = mean(load_pattern);
else
    peak_so_far = 0;
end
daysPassed = 0;

ts = simRange(1):(1/steps_per_hour):simRange(2); % time in hours

%% Pre-Allocations
runningPeak = zeros(1, length(ts));
exitFlag = zeros(1, length(ts));
fcUsed = zeros(k, length(ts));

%% Run through time series
idx = 1;
for t = ts
    demand_now = demand(idx);
    hour_now = hourNum(idx);
    
    if runControl.godCast
        fcast = godCast(idx, :)';
    elseif runControl.naiveP
        fcast = demand_delays;
    elseif runControl.MPC.setPoint
        fcast = ones(size(demand_delays)).*demand_now;
    else
        % Produce forecast from input net
        fcast = fc_FFNN( net, demand_delays, true );
    end
    
    fcUsed(:, idx) = fcast;
    
    [pwr2batt, exitFlag(idx)] = controller_optimiser_Matlab(fcast, SoC, ...
        demand_now, batt_cap, max_charge_rate, steps_per_hour, peak_so_far, ...
        runControl.MPC);
    
    if runControl.MPC.SPrecourse
        % Peak power drawn over horizon (and existing peak)
        
        % peakForecastPower = max(pwr2batt(:) + fcast(:));
        peakForecastPower = max([pwr2batt(:) + fcast(:); peak_so_far]);
        
        % Check if optimal control action combined with actual current demand
        % will exceed this peak - and if so rectify charging action
        if (demand_now + pwr2batt(1)) > peakForecastPower
            pwr2batt_now = peakForecastPower - demand_now;
        else
            pwr2batt_now = pwr2batt(1);
        end
        
    else
        pwr2batt_now = pwr2batt(1);
    end
    
    % Apply control action to plant
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
