% file: compareFreocasts.m
% auth: Khalid Abdulla
% date: 19/06/2015
% brief: Evaluate various forecast models trained on various
%           error metrics (over a number of aggregation levels)

%% Add path to the common functions (& any subfolders therein)
[parentFold, ~, ~] = fileparts(pwd);
commonFcnFold = [parentFold filesep 'commonFunctions'];
addpath(commonFcnFold, '-BEGIN');
doCompile = false;

if doCompile
    
    % Remove any compiled versions of EMD in this directory:
    mexFileNames = dir([commonFcnFold filesep '*.mex*']);
    for item = 1:length(mexFileNames);
        delete([commonFcnFold filesep mexFileNames(item).name]);
    end
    % Re-compile EMD mex files
    compile_FastEMD;
    
    codegen('fc_SARMA_mex.m', '-report', '-args',...
        {coder.typeof(double(0), [Inf Inf]),...
        coder.typeof(double(0), [1 3]), ...
        coder.typeof(double(0), [1 1]), ...
        coder.typeof(double(0), [1 1])}, '-d', ...
        [commonFcnFold filesep 'codegen'], '-o', [commonFcnFold filesep 'fc_SARMA_mex_mex']);
end

%% Tidy Up
clear variables; close all; clc;

%% Set-up // workers
% myCluster = parcluster('local');
% delete(myCluster.Jobs);
% poolObj = parpool('local', 12);

%% Read in DATA
load(['..' filesep 'data' filesep 'demand_3639.mat']);       % demandData is [nTimestamp x nMeters] array

%% Forecast parameters
trainLength = 200*48;   % number of t-steps over which to train
k = 48;                 % fcast horizon & seasonality
testLength = 48;        % number of t-steps for test forecasts
n_tests = 25;           % number of test forecasts to make

%% Aggregation parameters
% numCustomers = [1 5 10 35 50 100 200 size(demandData, 2)];
numCustomers = [1 10 100 1000]; %min(3.^(0:6), size(demandData, 2));

numAggregates = 3;

%% Forecast Training Settings
trControl.supp = true;
trControl.numHidden = 50;
trControl.numStarts = 3;
trControl.includeTime = false;
trControl.mseEpochs = 1000;                 % No. of MSE epochs for pre-training
trControl.modelPerStep = false;             % If true train 1 model for each t-step of the seasonal period
trControl.minimiseOverFirst = testLength;   % No. of steps of fcast to minimise penalty over
if trControl.modelPerStep > trControl.includeTime
    error('To use forecast per step need to include time as an input');
end
trControl.batchSize = 1000;

% Optimal parameters found from 20-customer analysis:
% trControl.validFail = 9;
% trControl.sigmaValue = 5e-5;    % Even larger may be better
% trControl.lambdaValue = 5e-8;   % Appeared to be a sweet spot

loss_pars_unit = @(t, y) loss_par(t, y, [2, 2, 2, 1]);
loss_emd_pars_unit = @(t, y) loss_emd_par(t, y, [10, 0.5, 0.5, 4]);

lossTypes = {@loss_mse, @loss_mape, loss_pars_unit, ...
    loss_emd_pars_unit, @loss_mse, @loss_mape, loss_pars_unit, ...
    loss_emd_pars_unit};

% lossTypes = {@loss_mse, loss_emd_pars_unit, @loss_mse, loss_emd_pars_unit};

%% Forecast methods and error metrics
fcTypeStrings = {'MSE_SARMA', 'MAPE_SARMA', 'PFEM_SARMA', 'PEMD_SARMA', ...
    'MSE_FFNN', 'MAPE_FFNN', 'PFEM_FFNN', 'PEMD_FFNN', 'naivePeriodic'};
fcMetrics = {'MSE', 'MAPE', 'PFEM', 'PEMD'};

% fcTypeStrings = {'MSE_SARMA', 'PEMD_SARMA', 'MSE_FFNN', 'PEMD_FFNN', 'naivePeriodic'};
% fcMetrics = {'MSE', 'PEMD'};

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
numInstances = length(numCustomers)*numAggregates;
all_demand_vals = zeros(numInstances, size(demandData, 1));
all_kWhs = zeros(numInstances, 1);
pars = cell(numInstances, 1);
fcVals = cell(numInstances, 1);         % To store the fcasts for tests
allMetrics = cell(numInstances, 1);

for ii = 1:numInstances
    pars{ii} = cell(length(trHandles), 1);
    fcVals{ii} = zeros(nMethods, n_tests, testLength);
    allMetrics{ii} = zeros(nMethods, length(fcMetrics));
end

hour_numbers = mod((1:size(demandData, 1))', k);
hour_numbers_tr = hour_numbers(1:trainLength);
trControl.hour_numbers_tr = hour_numbers_tr;
hour_numbers_ts = zeros(testLength, n_tests);

% Test Data
y_test_all = zeros(numInstances, testLength, n_tests);

instance = 0;
for nCustIndex = 1:length(numCustomers)
    for trial = 1:numAggregates
        instance = instance + 1;
        customers = numCustomers(nCustIndex);
        customer_indices = ...
            randsample(size(demandData, 2), customers);
        all_demand_vals(instance, :) = ...
            sum(demandData(:, customer_indices), 2);
        all_kWhs(instance) = mean(all_demand_vals(instance, :));
        for ii = 1:n_tests
            ts_idx = (trainLength+1+(ii-1)*testLength):...
                (trainLength+ii*testLength);
            y_test_all(instance, :, ii) = all_demand_vals(instance, ts_idx)';
            hour_numbers_ts(:, ii) = hour_numbers(ts_idx);
        end
    end
end

tic;
parfor instance = 1:numInstances
    
    y = all_demand_vals(instance, :)';
    
    % Training Data
    y_train = y(1:trainLength);
    
    % TODO: I'm sure there is a better vectorised way to do this!
    
    %% Train fcast parameters
    for ii = 1:length(lossTypes)
        disp(fcTypeStrings{ii});
        pars{instance}{ii} = trHandles{ii}(y_train, k, lossTypes{ii}, trControl);
    end
    
    %% Make forecasts, for the n tests (and every fcast type)
    histData = y_train; % To accumulate historic data
    temp_metrics = zeros(nMethods, n_tests, length(fcMetrics));
    
    for ii = 1:n_tests
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
    [nMethods, numAggregates, length(numCustomers), length(fcMetrics)]);
all_kWhs = reshape(all_kWhs, [numAggregates, length(numCustomers)]);

save('compareForecast_results_2015_06_26_FULL.mat');

% delete(poolObj);
