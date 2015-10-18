function [ Sim, results ] = testAllFcastsPar( pars, all_demand_vals, Sim, ...
    EMD, PFEM, MPC, k)

%TESTALLFCASTS Test the performance of all trained (and non-trained) fcasts
%   First the parameterised forecasts are run to select the best parameters
%   Then these best selected ones are compared to other methods

%% Pre-Allocation
bestParForecast = zeros(Sim.numInstances, 1);   % Index of the best forecast
bestEMDForecast = zeros(Sim.numInstances, 1);

Sim.sel_idxs = (1:(Sim.steps_per_hour*Sim.num_hours_sel)) + ...
    Sim.tr_idxs(end);
Sim.ts_idxs = (1:(Sim.steps_per_hour*Sim.num_hours_test)) + ...
    Sim.sel_idxs(end);

Sim.hour_numbers_sel = Sim.hour_numbers(Sim.sel_idxs, :);
Sim.hour_numbers_ts = Sim.hour_numbers(Sim.ts_idxs, :);

% Sim time (& range) for fcast selection and testing
simRange_sel = [0 Sim.num_hours_sel - 1/Sim.steps_per_hour];
simRange_test = [0 Sim.num_hours_test - 1/Sim.steps_per_hour];

peakReductions = cell(Sim.numInstances, 1);
peakPowers = cell(Sim.numInstances, 1);
smallestExitFlag = cell(Sim.numInstances, 1);
all_kWhs = zeros(Sim.numInstances, 1);
lossTestResults = cell(Sim.numInstances, 1);

%% Run Models for Fcast selection

% Extract data from Sim for efficiency:
battCapRatio = Sim.battCapRatio;
batt_charge_factor = Sim.batt_charge_factor;
tr_idxs = Sim.tr_idxs;
sel_idxs = Sim.sel_idxs;
ts_idxs = Sim.ts_idxs;
PFEMrange = PFEM.range; EMDrange = EMD.range;
lossTypesStrings = Sim.lossTypesStrings;
lossTypes = Sim.lossTypes;

hour_numbers_sel = Sim.hour_numbers_sel;
steps_per_hour = Sim.steps_per_hour;
steps_per_day = Sim.steps_per_day;
numInstances = Sim.numInstances;

if ~isfield(MPC, 'billingPeriodDays'); MPC.billingPeriodDays = 1;
    warning('Using default MPC.billingPeriodDays');  end;


Seltic = tic;

poolobj = gcp('nocreate');
delete(poolobj);

for instance = 1:numInstances
    
    all_kWhs(instance) = mean(all_demand_vals{instance});
    
    % Battery properties
    batt_cap = all_kWhs(instance)*battCapRatio*steps_per_day;
    max_charge_rate = batt_charge_factor*batt_cap;
    
    % Separate Data into training and testing
    demand_vals_tr = all_demand_vals{instance}(tr_idxs, :);
    demand_vals_sel = all_demand_vals{instance}(sel_idxs, :);
    peakLocalPower = max(demand_vals_sel);
    
    % Create 'historical load pattern' used for initialisation etc.
    load_pattern = mean(reshape(demand_vals_tr, ...
        [k, length(demand_vals_tr)/k]), 2);
    
    godCast_val = zeros(length(ts_idxs), k);
    for jj = 1:k
        godCast_val(:, jj) = circshift(demand_vals_sel, -[jj-1, 0]);
    end
    
    thisInstancePeakReductions = zeros(Sim.nMethods,1);
    thisInstancePeakPower = zeros(Sim.nMethods,1);
    thisInstanceSmallestExitFlag = zeros(Sim.nMethods,1);
    thisInstanceLossTestResults = ...
        zeros(Sim.nMethods, length(Sim.lossTypes));
    
    %% For each parameterised method run simulation
    parfor fcType = [PFEMrange, EMDrange]
        % Check if we are on godCast or naivePeriodic
        runControl = [];
        runControl.MPC = MPC;
        
        runControl.MPC.setPoint = ...
            strcmp(lossTypesStrings{fcType}, 'setPoint');
        
	% If method is set-point then show it current demand
        if(runControl.MPC.setPoint)
	    runControl.MPC.knowCurrentDemand = true
	end
        
        runControl.naiveP = false;
        runControl.godCast = false;
        
        [runningPeak, exitFlag, fcUsed] = onlineMPC_controller( ...
            simRange_sel, pars{instance, fcType}, godCast_val, ...
            demand_vals_sel, batt_cap, max_charge_rate, load_pattern, ...
            hour_numbers_sel, steps_per_hour, k, runControl);
        
        % Extract simulation results
        grid_power_ts = runningPeak';
        grid_daily_cols = reshape(grid_power_ts, [k*MPC.billingPeriodDays,...
            length(grid_power_ts)/(k*MPC.billingPeriodDays)]);
        
        grid_daily_peaks = max(grid_daily_cols);
        
        demand_daily_cols = reshape(demand_vals_sel, [k*MPC.billingPeriodDays, ...
            length(demand_vals_sel)/(k*MPC.billingPeriodDays)]);
        
        demand_daily_peaks = max(demand_daily_cols);
        
        daily_ratios = grid_daily_peaks./demand_daily_peaks;
        
        thisInstancePeakReductions(fcType) = 1 - mean(daily_ratios);
        thisInstancePeakPower(fcType) = peakLocalPower;
        thisInstanceSmallestExitFlag(fcType) = min(exitFlag);
        
        % Compute the performance of the fcast by all train metrics
        tempLossResults = zeros(1, length(lossTypes));
        for eachError = 1:length(lossTypes)
            tempLossResults(eachError) = ...
                mean(lossTypes{eachError}(godCast_val', fcUsed));
        end
        thisInstanceLossTestResults(fcType, :) = tempLossResults;
    end
    
    peakReductions{instance} = thisInstancePeakReductions;
    peakPowers{instance} = thisInstancePeakPower;
    smallestExitFlag{instance} = thisInstanceSmallestExitFlag;
    lossTestResults{instance} = thisInstanceLossTestResults;
    
    disp('Instance Completed: ');
    disp(instance);
end

poolobj = gcp('nocreate');
delete(poolobj);

timeSel = toc(Seltic);
disp('Time to Select Fcast:'); disp(timeSel);

% Find the best forecast from the parameter grid-searches
for instance = 1:numInstances
    [~, indx] = max(peakReductions{instance}(PFEMrange));
    bestParForecast(instance) = indx + min(PFEMrange) - 1;
    
    [~, indx] = max(peakReductions{instance}(EMDrange));
    bestEMDForecast(instance) = indx + min(EMDrange) - 1;
end

% Extend relevant variables to accomodate the 2 new forecasts
Sim.lossTypesStrings = [Sim.lossTypesStrings, {'bestParSelected',...
    'bestEMDSelected'}];
Sim.nMethods = length(Sim.lossTypesStrings);

for instance = 1:numInstances
    peakReductions{instance} = [peakReductions{instance}; ...
        zeros(2,1)];
    peakPowers{instance} = [peakPowers{instance};
        zeros(2,1)];
    smallestExitFlag{instance} = [smallestExitFlag{instance}; ...
        zeros(2,1)];
    lossTestResults{instance} = [lossTestResults{instance}; ...
        zeros(2, length(Sim.lossTypes))];
end

%% Run Models for performance evaluation
% Take methods out of Sim struct for efficiency
nMethods = Sim.nMethods;
nTrainMethods = Sim.nTrainMethods;
lossTypesStrings = Sim.lossTypesStrings;
hour_numbers_ts = Sim.hour_numbers_ts;
steps_per_hour = Sim.steps_per_hour;

Evaltic = tic;

poolobj = gcp('nocreate');
delete(poolobj);

disp('==== Fcast Evaluation ===')
for instance = 1:numInstances
    
    % Battery properties
    batt_cap = all_kWhs(instance)*battCapRatio*steps_per_day;
    max_charge_rate = batt_charge_factor*batt_cap;
    
    % Separate Data into training and testing
    demand_vals_sel = all_demand_vals{instance}(sel_idxs);
    demand_vals_ts = all_demand_vals{instance}(ts_idxs);
    peakLocalPower = max(demand_vals_ts);
    
    % Create 'historical load pattern' used for initialisation etc.
    load_pattern = mean(reshape(demand_vals_sel, ...
        [k, length(demand_vals_sel)/k]), 2);
    
    % Create test demand time-series object
    godCast_val = zeros(length(ts_idxs), k);
    for jj = 1:k
        godCast_val(:, jj) = circshift(demand_vals_ts, -[jj-1, 0]);
    end
    
    %% For each method (except non-opt parameterised ones)
    
    thisInstancePeakReductions = zeros(size(peakReductions{1}));
    thisInstancePeakPower = zeros(size(peakPowers{1}));
    thisInstanceSmallestExitFlag = zeros(size(smallestExitFlag{1}));
    thisInstanceLossTestResults = zeros(size(lossTestResults{1}));
    thisInstanceBestParForecast = bestParForecast(instance);
    thisInstanceBestEMDForecast = bestEMDForecast(instance);
    
    demand_vals_tr = all_demand_vals{instance}(tr_idxs, :);
    
    parfor fcTypeIn = 1:nMethods
        
        if any(fcTypeIn == [PFEMrange, EMDrange])
           continue; 
        end
        
        % Avoid parfor errors
        fcUsed = []; exitFlag = 1;
        runControl = [];
        runControl.MPC = MPC;
        
        if strcmp(lossTypesStrings{fcTypeIn}, 'fcastFree')
            % Implement fcastFree controller
            
            % Create 'historical load pattern' used for initialisation etc.
            load_pattern_tr = mean(reshape(demand_vals_tr, ...
                [k, length(demand_vals_tr)/k]), 2);
            
            % Evaluate performance of controller
            [ runningPeak ] = onlineMPC_controller_fcastFree(...
                simRange_test, pars{instance, fcTypeIn}, demand_vals_ts,...
                batt_cap, max_charge_rate, load_pattern_tr,...
                hour_numbers_ts, steps_per_hour, runControl);
        else
            % Implement a normal fcast-driven or set-point controller
            
            % If we are using 'bestSelected' forecast then set fcType:
            if strcmp(lossTypesStrings{fcTypeIn}, 'bestParSelected')
                fcType = thisInstanceBestParForecast;
            elseif strcmp(lossTypesStrings{fcTypeIn}, 'bestEMDSelected')
                fcType = thisInstanceBestEMDForecast;
            else
                fcType = fcTypeIn;
            end
            
            % Check if we are on godCast or naivePeriodic
            runControl.naiveP = ...
                strcmp(lossTypesStrings{fcTypeIn}, 'naivePeriodic');
            
            runControl.godCast = ...
                strcmp(lossTypesStrings{fcTypeIn}, 'godCast');
            
            runControl.MPC.setPoint = ...
                strcmp(lossTypesStrings{fcTypeIn}, 'setPoint');
            
	    % If method is set-point then show it current demand
            if(runControl.MPC.setPoint)
		runControl.MPC.knowCurrentDemand = true
	    end
            
            [runningPeak, exitFlag, fcUsed] = onlineMPC_controller( ...
                simRange_test, pars{instance, min(fcType, nTrainMethods)}, ...
                godCast_val, demand_vals_ts, batt_cap, max_charge_rate, ...
                load_pattern, hour_numbers_ts, steps_per_hour, k,...
                runControl); %#ok<PFBNS>
        end
        
        % Extract simulation results
        grid_power_ts = runningPeak';
        grid_daily_cols = reshape(grid_power_ts, [k*MPC.billingPeriodDays,...
            length(grid_power_ts)/(k*MPC.billingPeriodDays)]);
        
        grid_daily_peaks = max(grid_daily_cols);
        
        demand_daily_cols = reshape(demand_vals_ts, [k*MPC.billingPeriodDays,...
		length(demand_vals_ts)/(k*MPC.billingPeriodDays)]);
        demand_daily_peaks = max(demand_daily_cols);
        
        daily_ratios = grid_daily_peaks./demand_daily_peaks;
        
        thisInstancePeakReductions(fcTypeIn) = 1 - mean(daily_ratios);
        thisInstancePeakPower(fcTypeIn) = peakLocalPower;
        thisInstanceSmallestExitFlag(fcTypeIn) = min(exitFlag);
        
        % Compute the performance of the fcast by all train metrics
        if ~strcmp(lossTypesStrings{fcTypeIn}, 'fcastFree')
            tempLossResults = zeros(1, length(lossTypes));
            for eachError = 1:length(lossTypes)
                tempLossResults(eachError) = ...
                    mean(lossTypes{eachError}(godCast_val', fcUsed));
            end
            
            thisInstanceLossTestResults(fcTypeIn, :) = tempLossResults;
        end
    end
    
    peakReductions{instance} = thisInstancePeakReductions;
    peakPowers{instance} = thisInstancePeakPower;
    smallestExitFlag{instance} = thisInstanceSmallestExitFlag;
    lossTestResults{instance} = thisInstanceLossTestResults;
    
    disp('Instance Completed: ');
    disp(instance);
end

poolobj = gcp('nocreate');
delete(poolobj);

timeEval = toc(Evaltic);
disp('Time to Evaluate Fcasts:'); disp(timeEval);


%% Convert to array from cellArrays
peakReductions = reshape(cell2mat(peakReductions), ...
    [nMethods, Sim.numAggregates, length(Sim.numCustomers)]);

peakPowers = reshape(cell2mat(peakPowers), ...
    [nMethods, Sim.numAggregates, length(Sim.numCustomers)]);

smallestExitFlag = reshape(cell2mat(smallestExitFlag), ...
    [nMethods, Sim.numAggregates, length(Sim.numCustomers)]);

all_kWhs = reshape(all_kWhs, ...
    [Sim.numAggregates, length(Sim.numCustomers)]);

lossTestResults = reshape(cell2mat(lossTestResults), ...
    [nMethods, Sim.numAggregates, length(Sim.numCustomers), nTrainMethods]);


%% Fromatting
% Collapse Trial Dimension
peakReductions_ = reshape(peakReductions, ...
    [nMethods, length(Sim.numCustomers)*Sim.numAggregates]);

peakPowers_ = reshape(peakPowers, ...
    [nMethods, length(Sim.numCustomers)*Sim.numAggregates]);

%% Put results together in structure for passing out
results.peakReductions = peakReductions;
results.peakReductions_ = peakReductions_;
results.peakPowers = peakPowers;
results.peakPowers_ = peakPowers_;
results.smallestExitFlag = smallestExitFlag;
results.all_kWhs = all_kWhs;
results.lossTestResults = lossTestResults;
results.bestParForecast = bestParForecast;
results.bestEMDForecast = bestEMDForecast;

end
