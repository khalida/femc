function [ runningPeak, exitFlag, forecastUsed] = mpcController(cfg,...
    trainedModel, godCast, demand,demandDelays, battery, runControl)

% mpcController: Simulate time series behaviour of MPC controller with a
% given forecast model.

%% INPUTS:
% cfg:          Structure with all the running parameters
% trainedModel: Trained forecast model
% godCast:      Matrix of perfect foresight forecasts [nIdxs x horizon]
% demand:       Vector of demand values [nIdxs x 1]
% demandDelays: Vector of previous demand  values [nLags x 1]
% battery:      Battery object
% runControl:   Structure with speicific running options

%% OUTPUTS:
% runningPeak:  Vector of peakSoFar values [nIdxs x 1]
% exitFlag:     Vector of status flags (from linear program) [nIdxs x 1]
% forecastUsed: Matrix of forecasts used [horizon x nIdxs]


%% Initializations
battery.reset();

% Create zero-size battery for case of simulation with no battery
% if isfield(runControl, 'NB') && runControl.NB
%     battery = Battery(cfg, 0.0);
% end

nIdxs = size(godCast, 1);
daysPassed = 0;

if cfg.opt.resetPeakToMean
    peakSoFar = mean(demandDelays);
else
    peakSoFar = 0;
end

%% Pre-Allocations
runningPeak = zeros(nIdxs, 1);
exitFlag = ones(nIdxs, 1);
forecastUsed = zeros(cfg.sim.horizon, nIdxs);
chargeEnergy = zeros(1, nIdxs);


%% Run through time series
% h = waitbar(0, 'Running mpcController');

for idx = 1:nIdxs;
    % waitbar(idx/nIdxs, h);
    demandNow = demand(idx);
    
    if runControl.godCast
        forecast = godCast(idx, :)';
        titleString = 'godCast';
        
    elseif runControl.naivePeriodic
        forecast = demandDelays((end-cfg.fc.season+1):...
            (end-cfg.fc.season+cfg.sim.horizon));
        
        titleString = 'NP';
        
    elseif runControl.setPoint
        forecast = ones(cfg.sim.horizon, 1).*demandNow;
        titleString = 'SP';
        
    else
        % Produce forecast from input model
        titleString = 'MFFC';
        
        % Select forecast function handle
        switch cfg.fc.forecastModels
            case 'FFNN'
                forecastHandle = @forecastFfnn;
                
            case 'SARMA'
                forecastHandle = @forecastSarma;
                
            otherwise
                error('Selected cfg.fc.forecastModels not implemented');
        end
        
        forecast = forecastHandle(cfg, trainedModel, demandDelays);
    end
    
    % Error-checking:
    if ~isequal(forecast, demand(idx:(idx + cfg.sim.horizon - 1))) && ...
            runControl.godCast
        
        error('godCast Forecast doesnt match?');
    end
    
    forecastUsed(:, idx) = forecast;
    cfg.opt.setPoint = runControl.setPoint;
    
    if runControl.skipRun
        continue;
    end
    
    %% STD. FORECAST-BASED OR SP-based CONTROLLER:
    [energyToBattery, exitFlag(idx)] = controllerOptimizer(cfg, ...
        forecast, demandNow, battery, peakSoFar);
    
    peakForecastEnergy = max([energyToBattery(:) + forecast(:); ...
        peakSoFar]);
    
    energyToBatteryNow = energyToBattery(1);
    
    % Implement set point recourse, if selected
    if cfg.opt.setPointRecourse
        
        % Check if opt action combined with actual demand exceeds expected
        % peak, & rectify if so:
        if (demandNow + energyToBatteryNow) > peakForecastEnergy
            energyToBatteryNow = peakForecastEnergy - demandNow;
            
            % SP recourse has been applied; need to re-apply battery
            % constraints
            energyToBatteryNow = battery.limitCharge(energyToBatteryNow);
        end
    end
    
    %% Plot first horizon to assist with debugging
    if ~cfg.opt.suppressOutput && idx == 1
        figure();
        plot([forecast, godCast(idx, :)', ...
            cumsum(energyToBattery(:)) + battery.SoC, ...
            energyToBattery(:), forecast + energyToBattery(:)]);
        
        hline = refline(0, peakSoFar); hline.LineWidth = 2;
        hline.Color = 'k';
        
        hline = refline(0, battery.capacity); hline.LineWidth = 2;
        hline.Color = 'c';
        
        grid on;
        legend('Forecast [kWh/interval]', 'GodCast [kWh/interval]', ...
            'SoC [kWh]', 'Energy to Batt [kWh/interval]', ...
            'Expected Demand from Grid [kWh/interval]',...
            'Peak so Far [kWh/interval', 'Battery Capacity [kWh]');
        
        title(['1st horizon, ' titleString]);
    end
    
    
    %% Apply control action to plant
    % (subject to rate and state of charnge constraints)
    battery.chargeBy(energyToBatteryNow);
    chargeEnergy(1, idx) = energyToBatteryNow;
    
    % Compute running peak for saving:
    peakSoFar = max(peakSoFar, demandNow + energyToBatteryNow);
    runningPeak(idx) = peakSoFar;
    
    % Increment No. of days passed, if required
    if mod(idx, cfg.sim.stepsPerDay) == 0
        daysPassed = daysPassed + 1;
    end
    
    % If we've reached end of billing period, reset the peak tracker
    if daysPassed == cfg.opt.billingPeriodDays
        daysPassed = 0;
        
        if cfg.opt.resetPeakToMean
            peakSoFar = mean(demandDelays);
        else
            peakSoFar = 0;
        end
    end
    
    % Shift demandDelays (and add current demand)
    demandDelays = [demandDelays(2:end); demandNow];
end

%% Plot time-series behavior for debugging
if ~cfg.opt.suppressOutput
    figure();
    plot([godCast(:, 1), cumsum(chargeEnergy(1,:)') + battery.capacity/2, ...
        chargeEnergy(1,:)', godCast(:, 1) + chargeEnergy(1,:)', runningPeak]);
    
    hline = refline(0, battery.capacity); hline.LineWidth = 2;
    hline.Color = 'c';
    
    grid on;
    legend('Local Demand [kWh/interval]', 'SoC [kWh]',...
        'Energy to Batt [kWh/interval]', 'Grid Demand [kWh/interval]',...
        'Running Peak [kWh/interval', 'Battery Capacity [kWh]');
    
    title(['All horizons, ' titleString]);
end

% delete(h);

end
