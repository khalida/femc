% file: compareFreocasts.m
% auth: Khalid Abdulla
% date: 20/10/2015
% brief: Evaluate various forecast models trained on various
%           error metrics (over a number of aggregation levels)

%% Load Config
Config

%% Add path to the common functions (& any subfolders therein)
[parentFold, ~, ~] = fileparts(pwd);
commonFcnFold = [parentFold filesep 'functions'];
addpath(commonFcnFold, '-BEGIN');

if updateMex
    % Remove any compiled mex files
    mexFileNames = dir([commonFcnFold filesep '*.mex*']);
    for item = 1:length(mexFileNames);
        delete([commonFcnFold filesep mexFileNames(item).name]);
    end
    % Re-compile EMD mex files
    compile_FastEMD;
    
    % Re-compile SARMA mex files
    codegen('fc_SARMA_mex.m', '-report', '-args',...
        {coder.typeof(double(0), [Inf Inf]),...
        coder.typeof(double(0), [1 3]), ...
        coder.typeof(double(0), [1 1]), ...
        coder.typeof(double(0), [1 1])}, '-d', ...
        [commonFcnFold filesep 'codegen'], '-o', [commonFcnFold filesep 'fc_SARMA_mex_mex']);
end

%% Tidy Up
clear variables; close all; clc;

%% Load Config (Again)
Config

%% Set-up // workers
myCluster = parcluster('local');
delete(myCluster.Jobs);
poolObj = parpool('local', Sim.nProc);

%% Read in DATA
load(dataFileWithPath); % demandData is [nTimestamp x nMeters] array

%% Forecast parameters
trainLength = Sim.num_days_train*Sim.steps_per_hour*...
    Sim.hours_per_day;                  % number of t-steps over which to train
testLength = k;                         % number of t-steps for test forecasts

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
Sim.numInstances = length(Sim.numCustomers)*Sim.numAggregates;
all_demand_vals = zeros(Sim.numInstances, size(demandData, 1));
all_kWhs = zeros(Sim.numInstances, 1);
pars = cell(Sim.numInstances, 1);
fcVals = cell(Sim.numInstances, 1);         % To store the fcasts for tests
allMetrics = cell(Sim.numInstances, 1);

for ii = 1:Sim.numInstances
    pars{ii} = cell(length(trHandles), 1);
    fcVals{ii} = zeros(nMethods, Sim.num_days_test, testLength);
    allMetrics{ii} = zeros(nMethods, length(fcMetrics));
end

hour_numbers = mod((1:size(demandData, 1))', k);
hour_numbers_tr = hour_numbers(1:trainLength);
trControl.hour_numbers_tr = hour_numbers_tr;
hour_numbers_ts = zeros(testLength, Sim.num_days_test);

% Test Data
y_test_all = zeros(Sim.numInstances, testLength, Sim.num_days_test);

% Prepare data for all of the instance runs
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
        for ii = 1:Sim.num_days_test
            ts_idx = (trainLength+1+(ii-1)*testLength):...
                (trainLength+ii*testLength);
            y_test_all(instance, :, ii) = all_demand_vals(instance, ts_idx)';
            hour_numbers_ts(:, ii) = hour_numbers(ts_idx);
        end
    end
end

% Produce the forecasts
tic;
parfor instance = 1:Sim.numInstances
    
    y = all_demand_vals(instance, :)';
    
    % Training Data
    y_train = y(1:trainLength);
    
    %% Train fcast parameters
    for ii = 1:length(lossTypes)
        disp(fcTypeStrings{ii});
        pars{instance}{ii} = trHandles{ii}(y_train, k, lossTypes{ii}, trControl);
    end
    
    %% Make forecasts, for the n tests (and every fcast type)
    histData = y_train; % To accumulate historic data
    temp_metrics = zeros(nMethods, Sim.num_days_test, length(fcMetrics));
    
    for ii = 1:Sim.num_days_test
        actual = y_test_all(instance, :, ii)';
        for jj = 1:length(lossTypes)
            temp_fc = fcHandles{jj}( pars{instance}{jj}, histData, true); %#ok<*PFBNS>
            fcVals{instance}(jj, ii, :) = temp_fc(1:testLength);
            
            for eachError = 1:(length(lossTypes)/2)
                temp_metrics(jj, ii, eachError) = ...
                    lossTypes{eachError}(actual,...
                    squeeze(fcVals{instance}(jj, ii, :)));
            end
        end
        % Naive periodic forecast
        temp_fc = histData((end-k+1):end);
        fcVals{instance}(nMethods, ii, :) = temp_fc(1:testLength);
        
        for eachError = 1:(length(lossTypes)/2)
            temp_metrics(nMethods, ii, eachError) = ...
                lossTypes{eachError}(actual,...
                squeeze(fcVals{instance}(nMethods, ii, :)));
        end
        histData = [histData; actual];
    end
    
    % Calculate overall summary values
    for jj = 1:(length(lossTypes)+1)
        for kk = 1:length(fcMetrics)
            allMetrics{instance}(jj, kk) = mean(temp_metrics(jj, :, kk), 2);
        end
    end
    disp('==========');
    disp('Instance Done:');
    disp(instance);
    disp('==========');
end

toc;

%% Convert back from instances to old-style of labels
allMetrics = reshape(cell2mat(allMetrics), ...
    [nMethods, Sim.numAggregates, length(Sim.numCustomers), length(fcMetrics)]);
all_kWhs = reshape(all_kWhs, [Sim.numAggregates, length(Sim.numCustomers)]);

save('compareFcast_results_2015_10_20.mat');
delete(poolObj);

%% Produce Plots
compareForecastsPlotting(allMetrics, all_kWhs, fcTypeStrings,...
    fcMetrics, false, {});