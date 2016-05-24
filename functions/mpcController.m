function [ runningPeak, exitFlag, forecastUsed, respVecs, featVecs, ...
    b0_raw ] = mpcController(cfg, trainedModel, godCast, demand, ...
    demandDelays, battery, runControl)

% mpcController: Simulate time series behaviour of MPC controller with a
% given forecast model (or FF controller).

%% INPUTS:
% cfg:          Structure with all the running parameters
% trainedModel: Trained forecast (or FF controller) model
% godCast:      Matrix of perfect foresight forecasts [nIdxs x horizon]
% demand:       Vector of demand values [nIdxs x 1]
% demandDelays: Vector of previous demand  values [nLags x 1]
% battery:      Battery object
% runControl:   Structure with speicific running options

%% OUTPUTS:
% runningPeak:  Vector of peakSoFar values [nIdxs x 1]
% exitFlag:     Vector of status flags (from linear program) [nIdxs x 1]
% forecastUsed: Matrix of forecasts used [horizon x nIdxs]
% respVecs:     Matrix of possible response vectors [nResp x nIdxs]
% featVecs:     Matrix of possible feature vectors [nFeat x nIdxs]
% b0_raw:       Unconstrained charge decisions from model [nIdxs x 1]


%% Initializations
battery.reset();

% Create zero-size battery for case of sim with no battery
if isfield(runControl, 'NB') && runControl.NB
    battery = Battery(cfg, 0.0);
end

nIdxs = size(godCast, 1);
daysPassed = 0;

if cfg.opt.resetPeakToMean
    peakSoFar = mean(demandDelays);
else
    peakSoFar = 0;
end

%% Pre-Allocations
runningPeak = zeros(nIdxs, 1);
exitFlag = zeros(nIdxs, 1);
forecastUsed = zeros(cfg.sim.horizon, nIdxs);
if cfg.opt.SPrecourse
    respVecs = zeros(2, nIdxs);         % [b0; peakPower]
else
    respVecs = zeros(1, nIdxs);         % [b0]
end

% featVec = [demandDelay; stateOfCharge; (demandNow); peakSoFar];
if cfg.opt.knowCurrentDemandNow
    nFeatures = cfg.fc.nLags + 3;
else
    nFeatures = cfg.fc.nLags + 2;
end
featVecs = zeros(nFeatures, nIdxs);


%% Run through time series
h = waitbar(0, 'Running mpcController');

for idx = 1:nIdxs;
    waitbar(idx/nIdxs, h);
    demandNow = demand(idx);
    
    if isfield(runControl, 'randomizeInterval')
        if mod(idx, runControl.randomizeInterval) == 0
            battery.randomReset();
        end
    end
    
    if runControl.godCast
        forecast = godCast(idx, :)';
        titleString = 'godCast';
        
    elseif isfield(runControl, 'NB') && runControl.NB
        forecast = zeros(size(godCast(idx, :)'));
        titleString = 'NB';
        
    elseif isfield(runControl, 'modelCast') && runControl.modelCast
        forecast = godCast(idx, :)';
        titleString = 'modelCast';
        
    elseif runControl.naivePeriodic
        forecast = demandDelays(1:cfg.sim.horizon);
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
    
    %% STD. FORECAST-BASED OR SP CONTROLLER:
    [energyToBattery, exitFlag(idx)] = controllerOptimizer(cfg, ...
        forecast, demandNow, battery, peakSoFar);
    
    peakForecastEnergy = max([energyToBattery(:) + forecast(:); ...
        peakSoFar]);
    
    energyToBatteryNow = energyToBattery(1);
    b0_raw = energyToBatteryNow;
    
    
    % Implement set point recourse, if selected
    if cfg.opt.SPrecourse
        
        % Check if opt action combined with actual demand exceeds expected
        % peak, & rectify if so:
        if (demandNow + energyToBatteryNow) > peakForecastEnergy
            energyToBatteryNow = peakForecastEnergy - demandNow;
        end
        
        % SP recourse has been applied; need to re-apply battery
        % constraints
        energyToBatteryNow = battery.limitCharge(energyToBatteryNow);
    end
    
    %% Plot first horizon to assis with debugging
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
    respVecs(1, idx) = energyToBatteryNow;
    
    if cfg.opt.SPrecourse
        respVecs(2, idx) = peakForecastEnergy;
    end
    
    % Compute running peak for saving:
    peakSoFar = max(peakSoFar, demandNow + energyToBatteryNow);
    runningPeak(idx) = peakSoFar;
    
    % Increment No. of days passed, if required
    if mod(idx, cfg.sim.stepsPerDay) == 0
        daysPassed = daysPassed + 1;
    end
    
    % If we've reached end of billing period, resent the peak tracker
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
    plot([godCast(:, 1), cumsum(respVecs(1,:)') + battery.capacity/2, ...
        respVecs(1,:)', godCast(:, 1) + respVecs(1,:)', runningPeak]);
    
    hline = refline(0, battery.capacity); hline.LineWidth = 2;
    hline.Color = 'c';
    
    grid on;
    legend('Local Demand [kWh/interval]', 'SoC [kWh]',...
        'Energy to Batt [kWh/interval]', 'Grid Demand [kWh/interval]',...
        'Running Peak [kWh/interval', 'Battery Capacity [kWh]');
    
    title(['All horizons, ' titleString]);
end

delete(h);

end
