% file: compareFreocasts.m
% auth: Khalid Abdulla
% date: 20/10/2015
% brief: Evaluate various forecast models trained on various
%           error metrics (over a number of aggregation levels)

%% Load Config (includes seeding rng)
Config
if updateMex, compileMexes; end;
saveFileName = 'compareFcast_results_2015_10_20.mat';

%% Set-up // workers
poolObj = parpool('local', Sim.nProc);

%% Read in DATA
load(dataFileWithPath); % demandData is [nTimestamp x nMeters] array

%% Forecast parameters
trainLength = Sim.num_days_train*Sim.steps_per_hour*Sim.hours_per_day;
testLength = k;
nTests = (Sim.num_days_test-1)*testLength + 1;

%% Forecast Models & Error Metrics
loss_pars_unit = @(t, y) loss_par(t, y, [2, 2, 2, 1]);
loss_emd_pars_unit = @(t, y) loss_emd_par(t, y, [10, 0.5, 0.5, 4]);

lossTypes = {@loss_mse, @loss_mape, loss_pars_unit, ...
    loss_emd_pars_unit, @loss_mse, @loss_mape, loss_pars_unit, ...
    loss_emd_pars_unit};

fcTypeStrings = {'MSE SARMA', 'MAPE SARMA', 'PFEM SARMA', 'PEMD SARMA', ...
    'MSE FFNN', 'MAPE FFNN', 'PFEM FFNN', 'PEMD FFNN', 'NP'};
fcMetrics = {'MSE', 'MAPE', 'PFEM', 'PEMD'};

if length(lossTypes) ~= 2*length(fcMetrics)
    warning('No. of metrics seems wrong');
end

trHandles = [repmat({@train_SARMA}, [1, length(fcMetrics)]), ...
    repmat({@train_FFNN_multStart}, [1, length(fcMetrics)])];

fcHandles = [repmat({@fc_SARMA}, [1, length(fcMetrics)]), ...
    repmat({@fc_FFNN}, [1, length(fcMetrics)])];

%% Pre-Allocation
nMethods = length(fcTypeStrings);

% Set up 'instances matrix'
all_demand_vals = zeros(Sim.numInstances, size(demandData, 1));
all_kWhs = zeros(Sim.numInstances, 1);
pars = cell(Sim.numInstances, length(trHandles));       % Fcast parameters
fcVals = zeros(Sim.numInstances, nMethods, nTests,...
    testLength);                                        % Fcasts from tests
allMetrics = zeros(Sim.numInstances, nMethods, length(fcMetrics));

% Allocate half-hour-of-day indexes
hour_numbers = mod((1:size(demandData, 1))', k);
hour_numbers_tr = hour_numbers(1:trainLength);
trControl.hour_numbers_tr = hour_numbers_tr;
hour_numbers_ts = zeros(testLength, nTests);

% Test Data
y_test_all = zeros(Sim.numInstances, testLength, nTests);

% Prepare data for all instances
instance = 0;
for nCustIndex = 1:length(Sim.numCustomers)
    for trial = 1:Sim.numAggregates
        instance = instance + 1;
        customers = Sim.numCustomers(nCustIndex);
        customer_indices = ...
            randsample(size(demandData, 2), customers);
        all_demand_vals(instance, :) = ...
            sum(demandData(:, customer_indices), 2);
        all_kWhs(instance) = mean(all_demand_vals(instance, :));
        for ii = 1:nTests
            ts_idx = (trainLength+ii):(trainLength+ii+testLength-1);
            y_test_all(instance, :, ii) = all_demand_vals(instance, ts_idx)';
            hour_numbers_ts(:, ii) = hour_numbers(ts_idx);
        end
    end
end

% Produce the forecasts
tic;
for instance = 1:Sim.numInstances
    
    y = all_demand_vals(instance, :)';
    
    % Training Data
    y_train = y(1:trainLength);
    
    %% Train fcast parameters
    for ii = 1:length(lossTypes)
        disp(fcTypeStrings{ii});
        pars{instance, ii} = trHandles{ii}(y_train, k, ...
            lossTypes{ii}, trControl);
    end
    
    %% Make forecasts, for the nTests (and every fcast type)
    histData = y_train; % To accumulate historic data
    temp_metrics = zeros(nMethods, nTests, length(fcMetrics));
    
    for ii = 1:nTests
        actual = y_test_all(instance, :, ii)';
        for jj = 1:length(lossTypes)
            temp_fc = fcHandles{jj}(pars{instance, jj}, histData, true);
            fcVals(instance, jj, ii, :) = temp_fc(1:testLength);
            
            for eachError = 1:(length(lossTypes)/2)
                temp_metrics(jj, ii, eachError) = ...
                    lossTypes{eachError}(actual,...
                    squeeze(fcVals(instance, jj, ii, :)));
            end
        end
        % Naive periodic forecast
        temp_fc = histData((end-k+1):end);
        fcVals(instance, nMethods, ii, :) = temp_fc(1:testLength); 
        
        for eachError = 1:(length(lossTypes)/2)
            temp_metrics(nMethods, ii, eachError) = ...
                lossTypes{eachError}(actual,...
                squeeze(fcVals{instance}(nMethods, ii, :)));
        end
        histData = [histData; actual(1)]; %#ok<AGROW>
    end
    
    % Calculate overall summary values
    for jj = 1:(length(lossTypes)+1)
        for kk = 1:length(fcMetrics)
            allMetrics(instance, jj, kk) = mean(temp_metrics(jj, :, kk), 2);
        end
    end
    disp('==========');
    disp('Instance Done:');
    disp(instance);
    disp('==========');
end

toc;

% allMetrics = zeros(Sim.numInstances, nMethods, length(fcMetrics));
% all_kWhs = zeros(Sim.numInstances, 1);

%% Reshape data to be divided by  nCusteromers
allMetrics = reshape(allMetrics, ...
    [Sim.numAggregates, length(Sim.numCustomers), nMethods, length(fcMetrics)]);
all_kWhs = reshape(all_kWhs, [Sim.numAggregates, length(Sim.numCustomers)]);

clearvars poolObj;
save(saveFileName);

%% Produce Plots
compareForecastsPlotting(allMetrics, all_kWhs, fcTypeStrings,...
    fcMetrics, Sim.numCustomers, false, {});