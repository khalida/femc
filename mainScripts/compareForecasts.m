% file: compareForecasts.m
% auth: Khalid Abdulla
% date: 20/05/2016
% brief: Evaluate various forecast models trained on various
%           error metrics (over a number of aggregation levels)
clearvars; close all; clc;

%% Load Config (includes seeding rng)
cfg = Config(pwd);

%% Add path to the common functions (& any subfolders therein)
LoadFunctions;

if cfg.updateMex, compileMexes; end;
saveFileName = [cfg.sav.resultsDir filesep 'compareForecast_compareR.mat'];

%% Set-up // workers
poolobj = gcp('nocreate');
delete(poolobj);
poolObj = parpool('local', cfg.sim.nProc);

%% Read in DATA
load(cfg.sim.dataFileWithPath); % demandData is [nTimestamp x nMeters]

%% Forecast parameters
trainLength = cfg.sim.nDaysTrain*cfg.sim.stepsPerDay;
testLength = cfg.sim.horizon;
nTests = (cfg.sim.nDaysTest-1)*testLength + 1;

%% Forecast Models & Error Metrics
unitLossPfem = @(t, y) lossPfem(t, y, [2, 2, 2, 1]);
unitLossPemd = @(t, y) lossPemd(t, y, [10, 0.5, 0.5, 4]);

lossTypes = {@lossMse, @lossMape, unitLossPfem, ...
    unitLossPemd, @lossMse, @lossMape, unitLossPfem, ...
    unitLossPemd};

forecastTypeStrings = {'MSE SARMA', 'MAPE SARMA', 'PFEM SARMA',...
    'PEMD SARMA', 'MSE FFNN', 'MAPE FFNN', 'PFEM FFNN', 'PEMD FFNN',...
    'NP', 'R ETS'};

forecastMetrics = {'MSE', 'MAPE', 'PFEM', 'PEMD'};

if length(lossTypes) ~= 2*length(forecastMetrics)
    warning('No. of metrics seems wrong');
end

trainingHandles = [repmat({@trainSarma}, [1, length(forecastMetrics)]), ...
    repmat({@trainFfnnMultipleStarts}, [1, length(forecastMetrics)])];

forecastHandles = [repmat({@forecastSarma}, ...
    [1, length(forecastMetrics)]), repmat({@forecastFfnn}, ...
    [1, length(forecastMetrics)])];


%% Pre-Allocation
nMethods = length(forecastTypeStrings);
nMetrics = length(forecastMetrics);
nTrainedMethods = length(lossTypes);

% Set up 'instances matrix'
allDemandValues = zeros(cfg.sim.nInstances, size(demandData, 1));
allKWhs = zeros(cfg.sim.nInstances, 1);

% Cell array of forecast parameters
% Done as cellArrays of arrays to prevent issues with //-isation
pars = cell(1, cfg.sim.nInstances);
forecastValues = cell(cfg.sim.nInstances, 1);
allMetrics = cell(cfg.sim.nInstances, 1);
for instance = 1:cfg.sim.nInstances
    pars{instance} = cell(length(trainingHandles));
    forecastValues{instance} = zeros(nMethods, nTests, testLength);
    allMetrics{instance} = zeros(nMethods, length(forecastMetrics));
end

% Test Data
actualValuesAll = zeros(cfg.sim.nInstances, testLength, nTests);

% Prepare data for all instances
instance = 0;
for nCustIdx = 1:length(cfg.sim.nCustomers)
    for trial = 1:cfg.sim.nAggregates
        instance = instance + 1;
        customers = cfg.sim.nCustomers(nCustIdx);
        customerIdxs = ...
            randsample(size(demandData, 2), customers);
        
        allDemandValues(instance, :) = ...
            sum(demandData(:, customerIdxs), 2);
        
        allKWhs(instance) = mean(allDemandValues(instance, :));
        
        for ii = 1:nTests
            testIdx = (trainLength+ii):(trainLength+ii+testLength-1);
            actualValuesAll(instance, :, ii) = ...
                allDemandValues(instance, testIdx)';
        end
    end
end


%% Produce the forecasts
tic;
parfor instance = 1:cfg.sim.nInstances
% for instance = 1:cfg.sim.nInstances
  
    y = allDemandValues(instance, :)';
    
    % Training Data
    yTrain = y(1:trainLength);
    
    %% Train forecast parameters
    for ii = 1:nTrainedMethods
        disp(forecastTypeStrings{ii}); %#ok<PFBNS>
        pars{instance}{ii} = trainingHandles{ii}(cfg, yTrain,...
            lossTypes{ii}); %#ok<PFBNS>
    end
    
    %% Make forecasts, for the nTests (and every forecast type)
    % Array in which to accumulate historic data
    historicData = yTrain;
    tempMetrics = zeros(nMethods, nTests, length(forecastMetrics));
    
    for ii = 1:nTests
        actual = actualValuesAll(instance, ...
            1:cfg.fc.minimiseOverFirst, ii)'; %#ok<PFBNS>
        
        for eachMethod = 1:nTrainedMethods
            tempForecast = ...
                forecastHandles{eachMethod}(cfg, ...
                pars{instance}{eachMethod}, historicData); %#ok<PFBNS>
            
            forecastValues{instance}(eachMethod, ii, :) = ...
                tempForecast(1:testLength);
        end
        
        % Naive periodic forecast
        NPidx = find(ismember(forecastTypeStrings, 'NP'));
        tempForecast = historicData((end-cfg.fc.season+1):...
            (end-cfg.fc.season+cfg.sim.horizon));
        forecastValues{instance}(NPidx, ii, :) = ...
            tempForecast(1:testLength);
        
        % 'R forecast':
        ETSidx = find(ismember(forecastTypeStrings, 'R ETS'));
        
        [tmpEts] = getAutomatedForecastR(historicData, cfg.fc);
        
        forecastValues{instance}(ETSidx, ii, ...
            1:cfg.fc.minimiseOverFirst) = tmpEts';
        
        % Compute error metrics (for each test, and method):
        for eachMethod = 1:nMethods
            for eachError = 1:nMetrics
                tempMetrics(eachMethod, ii, eachError) = ...
                    lossTypes{eachError}(actual, ...
                    squeeze(forecastValues{instance}(eachMethod, ii, ...
                    1:cfg.fc.minimiseOverFirst)));
            end
        end
        
        historicData = [historicData; actual(1)];
    end
    
    % Calculate overall summary values
    for eachMethod = 1:nMethods
        for eachMetric = 1:nMetrics
            allMetrics{instance}(eachMethod, eachMetric) = ...
                mean(tempMetrics(eachMethod, :, eachMetric), 2);
        end
    end
    disp('==========');
    disp('Instance Done:');
    disp(instance);
    disp('==========');
    
    % DEBUG
    %disp('==========');
    %disp('tempMetrics:');
    %disp(tempMetrics);
    %disp('==========');
end

toc;


%% Reshape data to be grouped by nCustomers
% Done using loop to avoid transposition confusion
allMetricsArray = zeros(cfg.sim.nAggregates, length(cfg.sim.nCustomers),...
    nMethods, length(forecastMetrics));

instance = 0;
for nCustIdx = 1:length(cfg.sim.nCustomers)
    for trial = 1:cfg.sim.nAggregates
        instance = instance + 1;
        for iMethod = 1:nMethods
            for metric = 1:nMetrics
                allMetricsArray(trial, nCustIdx, iMethod, metric) =...
                    allMetrics{instance}(iMethod, metric);
            end
        end
    end
end

allKWhs = reshape(allKWhs, [cfg.sim.nAggregates,...
    length(cfg.sim.nCustomers)]);

clearvars poolObj;
save(saveFileName);

%% Produce Plots
plotCompareForecasts(allMetricsArray, allKWhs, forecastTypeStrings,...
    forecastMetrics, cfg);
