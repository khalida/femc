% file: compareForecasts.m
% auth: Khalid Abdulla
% date: 20/10/2015
% brief: Evaluate various forecast models trained on various
%           error metrics (over a number of aggregation levels)

%% Load Config (includes seeding rng)
Config

%% Add path to the common functions (& any subfolders therein)
[parentFold, ~, ~] = fileparts(pwd);
commonFcnFold = [parentFold filesep 'functions'];
addpath(genpath(commonFcnFold), '-BEGIN');

% if updateMex, compileMexes; end;
saveFileName = '..\results\2015_10_27_compareForecast_minimiseOver_1.mat';

%% Set-up // workers
poolObj = parpool('local', Sim.nProc);

%% Read in DATA
load(dataFileWithPath); % demandData is [nTimestamp x nMeters] array

%% Forecast parameters
trainLength = Sim.nDaysTrain*Sim.stepsPerHour*Sim.hoursPerDay;
testLength = k;
nTests = (Sim.nDaysTest-1)*testLength + 1;

%% Forecast Models & Error Metrics
unitLossPfem = @(t, y) lossPfem(t, y, [2, 2, 2, 1]);
unitLossPemd = @(t, y) lossPemd(t, y, [10, 0.5, 0.5, 4]);

lossTypes = {@lossMse, @lossMape, unitLossPfem, ...
    unitLossPemd, @lossMse, @lossMape, unitLossPfem, ...
    unitLossPemd};

forecastTypeStrings = {'MSE SARMA', 'MAPE SARMA', 'PFEM SARMA', 'PEMD SARMA', ...
    'MSE FFNN', 'MAPE FFNN', 'PFEM FFNN', 'PEMD FFNN', 'NP'};
forecastMetrics = {'MSE', 'MAPE', 'PFEM', 'PEMD'};

if length(lossTypes) ~= 2*length(forecastMetrics)
    warning('No. of metrics seems wrong');
end

trainingHandles = [repmat({@trainSarma}, [1, length(forecastMetrics)]), ...
    repmat({@trainFfnnMultipleStarts}, [1, length(forecastMetrics)])];

forecastHandles = [repmat({@forecastSarma}, [1, length(forecastMetrics)]), ...
    repmat({@forecastFfnn}, [1, length(forecastMetrics)])];

%% Pre-Allocation
nMethods = length(forecastTypeStrings);

% Set up 'instances matrix'
allDemandValues = zeros(Sim.nInstances, size(demandData, 1));
allKWhs = zeros(Sim.nInstances, 1);

% Cell array of forecast parameters
% Done as cellArrays of arrays to prevent issues with //-isation
pars = cell(1, Sim.nInstances);
forecastValues = cell(Sim.nInstances, 1);
allMetrics = cell(Sim.nInstances, 1);
for instance = 1:Sim.nInstances
    pars{instance} = cell(length(trainingHandles));
    forecastValues{instance} = zeros(nMethods, nTests, testLength);
    allMetrics{instance} = zeros(nMethods, length(forecastMetrics));
end

% Allocate half-hour-of-day indexes
hourNumbers = mod((1:size(demandData, 1))', k);
hourNumbersTrain = hourNumbers(1:trainLength);
trainControl.hourNumbersTrain = hourNumbersTrain;
hourNumbersTest = zeros(testLength, nTests);

% Test Data
actualValuesAll = zeros(Sim.nInstances, testLength, nTests);

% Prepare data for all instances
instance = 0;
for nCustIdx = 1:length(Sim.nCustomers)
    for trial = 1:Sim.nAggregates
        instance = instance + 1;
        customers = Sim.nCustomers(nCustIdx);
        customerIdxs = ...
            randsample(size(demandData, 2), customers);
        allDemandValues(instance, :) = ...
            sum(demandData(:, customerIdxs), 2);
        allKWhs(instance) = mean(allDemandValues(instance, :));
        for ii = 1:nTests
            testIdx = (trainLength+ii):(trainLength+ii+testLength-1);
            actualValuesAll(instance, :, ii) = allDemandValues(instance, testIdx)';
            hourNumbersTest(:, ii) = hourNumbers(testIdx);
        end
    end
end

% Produce the forecasts
tic;
parfor instance = 1:Sim.nInstances
    
    y = allDemandValues(instance, :)';
    
    % Training Data
    yTrain = y(1:trainLength);
    
    %% Train forecast parameters
    for ii = 1:length(lossTypes)
        disp(forecastTypeStrings{ii}); %#ok<PFBNS>
        pars{instance}{ii} = trainingHandles{ii}(yTrain, lossTypes{ii},...
            trainControl); %#ok<PFBNS>
    end
    
    %% Make forecasts, for the nTests (and every forecast type)
    % Array in which to accumulate historic data
    historicData = yTrain;
    tempMetrics = zeros(nMethods, nTests, length(forecastMetrics));
    
    for ii = 1:nTests
        actual = actualValuesAll(instance, ...
            1:trainControl.minimiseOverFirst, ii)'; %#ok<PFBNS>
        for jj = 1:length(lossTypes)
            tempForecast = forecastHandles{jj}(pars{instance}{jj},...
                historicData, trainControl); %#ok<PFBNS>
            forecastValues{instance}(jj, ii, :) = ...
                tempForecast(1:testLength);
            
            for eachError = 1:(length(lossTypes)/2)
                tempMetrics(jj, ii, eachError) = ...
                    lossTypes{eachError}(actual, ...
                    squeeze(forecastValues{instance}(jj, ii, ...
                    1:trainControl.minimiseOverFirst)));
            end
        end
        
        % Naive periodic forecast
        tempForecast = historicData((end-k+1):end);
        forecastValues{instance}(nMethods, ii, :) = tempForecast(1:testLength);
        
        for eachError = 1:(length(lossTypes)/2)
            tempMetrics(nMethods, ii, eachError) = ...
                lossTypes{eachError}(actual,...
                squeeze(forecastValues{instance}(nMethods, ii, ...
                1:trainControl.minimiseOverFirst)));
        end
        historicData = [historicData; actual(1)];
    end
    
    % Calculate overall summary values
    for jj = 1:(length(lossTypes)+1)
        for kk = 1:length(forecastMetrics)
            allMetrics{instance}(jj, kk) = mean(tempMetrics(jj, :, kk), 2);
        end
    end
    disp('==========');
    disp('Instance Done:');
    disp(instance);
    disp('==========');
end

toc;


%% Reshape data to be grouped by  nCusteromers
% Done using loop to avoid transposition confusion
allMetricsArray = zeros(Sim.nAggregates, length(Sim.nCustomers), ...
    nMethods, length(forecastMetrics));

instance = 0;
for nCustIdx = 1:length(Sim.nCustomers)
    for trial = 1:Sim.nAggregates
        instance = instance + 1;
        for forecastType = 1:(length(lossTypes)+1)
            for metric = 1:length(forecastMetrics)
                allMetricsArray(trial, nCustIdx, forecastType, metric) =...
                    allMetrics{instance}(forecastType, metric);
            end
        end
    end
end

allKWhs = reshape(allKWhs, [Sim.nAggregates, length(Sim.nCustomers)]);

clearvars poolObj;
save(saveFileName);

%% Produce Plots
plotCompareForecasts(allMetricsArray, allKWhs, forecastTypeStrings,...
    forecastMetrics, Sim.nCustomers, true);