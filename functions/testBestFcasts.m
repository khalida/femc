function [ Sim, results ] = testBestFcasts( pars, all_demand_vals, Sim, ...
    MPC, k)

%TESTBESTFCASTS Test the performance of best forecasts selected via
%                   stochstic selection

%% Pre-Allocation
Sim.hour_numbers_ts = Sim.hour_numbers(Sim.ts_idxs, :);

% Sim time (& range) for fcast testing
simRange_test = [0 Sim.num_hours_test - 1/Sim.steps_per_hour];

peakReductions = cell(Sim.numInstances, 1);
peakPowers = cell(Sim.numInstances, 1);
smallestExitFlag = cell(Sim.numInstances, 1);
all_kWhs = zeros(Sim.numInstances, 1);
lossTestResults = cell(Sim.numInstances, 1);

for instance = 1:Sim.numInstances
    peakReductions{instance} = zeros(Sim.nMethods,1);
    peakPowers{instance} = zeros(Sim.nMethods,1);
    smallestExitFlag{instance} = zeros(Sim.nMethods,1);
    lossTestResults{instance} = ...
        zeros(Sim.nMethods, length(Sim.lossTypes));
end

% Extract data from Sim for efficiency (parfor comms overhead)
battCapRatio = Sim.battCapRatio;
batt_charge_factor = Sim.batt_charge_factor;
tr_idxs = Sim.tr_idxs;
ts_idxs = Sim.ts_idxs;
lossTypes = Sim.lossTypes;

steps_per_day = Sim.steps_per_day;
numInstances = Sim.numInstances;

nMethods = Sim.nMethods;
nTrainMethods = Sim.nTrainMethods;
lossTypesStrings = Sim.lossTypesStrings;
hour_numbers_ts = Sim.hour_numbers_ts;
steps_per_hour = Sim.steps_per_hour;

Evaltic = tic;

if ~isfield(MPC, 'billingPeriodDays'); MPC.billingPeriodDays = 1;
warning('Using default MPC.billingPeriodDays');  end;

%% Run Models for performance evaluation
disp('==== Fcast Evaluation ===')

parfor instance = 1:numInstances
% for instance = 1:numInstances

    all_kWhs(instance) = mean(all_demand_vals{instance});

    % Battery properties
    batt_cap = all_kWhs(instance)*battCapRatio*steps_per_day;
    max_charge_rate = batt_charge_factor*batt_cap;
    
    % Separate Data into training and testing
    demand_vals_tr = all_demand_vals{instance}(tr_idxs);
    demand_vals_ts = all_demand_vals{instance}(ts_idxs);
    peakLocalPower = max(demand_vals_ts);
    
    % Create 'historical load pattern' used for initialisation etc.
    load_pattern = mean(reshape(demand_vals_tr, ...
        [k, length(demand_vals_tr)/k]), 2);
    
    godCast_val = zeros(length(ts_idxs), k);
    for jj = 1:k
        godCast_val(:, jj) = circshift(demand_vals_ts, -[jj-1, 0]);
    end
    
    %% For each method (except non-opt parameterised ones)
    for fcType = 1:nMethods

        runControl = [];
        runControl.MPC = MPC;
        
        % DEBUG: print lossTypesString to scree:
        disp('lossTypesStrings{fcType}:');
        disp(lossTypesStrings{fcType});
        
        if strcmp(lossTypesStrings{fcType}, 'fcastFree')
            % Implement fcastFree controller

            % Evaluate performance of controller
            [ runningPeak ] = onlineMPC_controller_fcastFree(...
                simRange_test, pars{instance, fcType}, demand_vals_ts,...
                batt_cap, max_charge_rate, load_pattern,...
                hour_numbers_ts, steps_per_hour, runControl);
            
            exitFlag = 1;
        else
            % Implement a normal fcast-driven or set-point controller

            % Check if we are on godCast or naivePeriodic
            runControl.naiveP = ...
                strcmp(lossTypesStrings{fcType}, 'naivePeriodic');
            
            runControl.godCast = ...
                strcmp(lossTypesStrings{fcType}, 'godCast');
            
            runControl.MPC.setPoint = ...
                strcmp(lossTypesStrings{fcType}, 'setPoint');
            
            % If method is set-point then show it current demand
            if(runControl.MPC.setPoint)
                runControl.MPC.knowCurrentDemand = true;
            end
            
            [runningPeak, exitFlag, fcUsed] = onlineMPC_controller( ...
                simRange_test, pars{instance, fcType}, ...
                godCast_val, demand_vals_ts, batt_cap, max_charge_rate, ...
                load_pattern, hour_numbers_ts, steps_per_hour, k,...
                runControl);
            
            % Compute the performance of the fcast by all train metrics
            if ~strcmp(lossTypesStrings{fcType}, 'setPoint');
                for eachError = 1:length(lossTypes)
                    lossTestResults{instance}(fcType, eachError)...
                        = mean(lossTypes{eachError}(godCast_val', fcUsed));
                end
            end
        end
        
        % Extract simulation results
        grid_power_ts = runningPeak';
        grid_daily_cols = reshape(grid_power_ts, [k*MPC.billingPeriodDays,...
            length(grid_power_ts)/(k*MPC.billingPeriodDays)]);
        
        grid_daily_peaks = max(grid_daily_cols);
        
        demand_daily_cols = reshape(demand_vals_ts, [k*MPC.billingPeriodDays, ...
            length(demand_vals_ts)/(k*MPC.billingPeriodDays)]);
        
        demand_daily_peaks = max(demand_daily_cols);
        
        daily_ratios = grid_daily_peaks./demand_daily_peaks;
        
        peakReductions{instance}(fcType) = 1 - mean(daily_ratios);
        peakPowers{instance}(fcType) = peakLocalPower;
        smallestExitFlag{instance}(fcType) = min(exitFlag);
        
    end
    disp(instance/numInstances);
end

timeEval = toc(Evaltic);
disp('Time to Evaluate Fcasts:'); disp(timeEval);


%% Convert from cellArrays to arrays
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

end
