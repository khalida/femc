% file: forecastPerformanceOverHorizon.m
% auth: Khalid Abdulla
% date: 30/10/2015
% brief: Evaluate the MSE-minimising SARMA and FFNN forecasts over the
% horizon

%% Running Options
nCustomers = [1, 10, 100 1000];
nAggregates = 4;
nInstances = length(nCustomers)*nAggregates;
nDaysTrain = 200;
nDaysTest = 50;
hoursPerDay = 24;
stepsPerHour = 2;
k = 48;
dataFileWithPath = ...
    ['..' filesep '..' filesep 'data' filesep 'demand_3639.mat'];

fileName = ['..' filesep '..' filesep 'results' filesep ...
    'performanceOverHorizon.pdf'];
myPaperPosition = [-0.75 0.0 19 14];
myPaperSize = [17 14];

%% Add path to the common functions (& any subfolders therein)
[parentFold, ~, ~] = fileparts(pwd);
commonFcnFold = [parentFold filesep 'functions'];
addpath(genpath(commonFcnFold), '-BEGIN');

%% Read in DATA
load(dataFileWithPath); % demandData is [nTimestamp x nMeters] array

%% Forecast parameters
trainLength = nDaysTrain*stepsPerHour*hoursPerDay;
testLength = k;
nTests = (nDaysTest-1)*testLength + 1;

forecastTypeStrings = {'MSE SARMA', 'MSE FFNN', 'NP'};
forecastMetrics = {'MSE'};

%% Pre-Allocation
nMethods = length(forecastTypeStrings);
allDemandValues = zeros(nInstances, size(demandData, 1));
allKWhs = zeros(nInstances, 1);

forecastValues = cell(nInstances, 1);
mseValues = cell(nInstances, 1);
meanMseValues = cell(nInstances, 1);
for instance = 1:nInstances
    forecastValues{instance} = zeros(nMethods, nTests, testLength);
    mseValues{instance} = zeros(nMethods, nTests, testLength);
    meanMseValues{instance} = zeros(nMethods, testLength);
end

% Allocate half-hour-of-day indexes
hourNumber = mod((1:size(demandData, 1))', k);
hourNumberTrain = hourNumber(1:trainLength);
trainControl.hourNumberTrain = hourNumberTrain;
hourNumberTest = zeros(testLength, nTests);

% Test Data
actualValuesAll = zeros(nInstances, testLength, nTests);

%% Prepare data for all instances
instance = 0;
for nCustIdx = 1:length(nCustomers)
    for trial = 1:nAggregates
        instance = instance + 1;
        customers = nCustomers(nCustIdx);
        customerIdxs = randsample(size(demandData, 2), customers);
        allDemandValues(instance, :) = sum(demandData(:, customerIdxs), 2);
        allKWhs(instance) = mean(allDemandValues(instance, :));
        for iTest = 1:nTests
            testIdx = (trainLength+iTest):(trainLength+iTest+testLength-1);
            actualValuesAll(instance, :, iTest) = ...
                allDemandValues(instance, testIdx)';
            hourNumberTest(:, iTest) = hourNumber(testIdx);
        end
    end
end

%% Set-up trainControl parameters
trainControl.nHidden = 50;
trainControl.suppressOutput = true;
trainControl.nStart = 3;
trainControl.mseEpochs = 1000;
trainControl.minimiseOverFirst = 48;
trainControl.batchSize = 1000;
trainControl.maxTime = 15;
trainControl.maxEpochs = 1000;
trainControl.trainRatio = 0.9;
trainControl.nLags = k;
trainControl.horizon = k;
trainControl.performanceDifferenceThreshold = 0.02;
trainControl.nBestToCompare = 3;
trainControl.nDaysPreviousTrainSarma = 20;
trainControl.useHyndmanModel = false;

%% Produce & evaluate the forecasts
tic;
poolobj = gcp('nocreate');
delete(poolobj);

parfor instance = 1:nInstances
    
    y = allDemandValues(instance, :)';
    
    % Training Data
    yTrain = y(1:trainLength);
    
    %% Train forecast parameters
    sarmaPars = trainSarma(yTrain, @lossMse, trainControl);
    ffnnPars = trainFfnnMultipleStarts(yTrain, @lossMse, trainControl);
    
    %% Make forecasts, for the nTests
    % Array in which to accumulate historic data
    historicData = yTrain;
    
    for iTest = 1:nTests
        actual = actualValuesAll(instance, ...
            1:trainControl.minimiseOverFirst, iTest); %#ok<PFBNS>
        
        forecastValues{instance}(1, iTest, :) = ...
            forecastSarma(sarmaPars, historicData, trainControl);
        
        forecastValues{instance}(2, iTest, :) = ...
            forecastFfnn(ffnnPars, historicData, trainControl);
        
        forecastValues{instance}(3, iTest, :) = ...
            historicData((end-k+1):end);
        
        % Evaluate the forecasts, on a per-interval basis, for each of the
        % 3 forecasts:
        for eachMethod = 1:nMethods
            mseValues{instance}(eachMethod, iTest, :) = lossMse(actual,...
                squeeze(forecastValues{instance}(eachMethod, iTest, :))');
        end
        
        historicData = [historicData; actual(1)];
    end
    
    % Calculate values summarised over nTests
    for eachMethod = 1:nMethods
        for eachInterval = 1:testLength
            meanMseValues{instance}(eachMethod, eachInterval) =...
                mean(mseValues{instance}(eachMethod, :, eachInterval));
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
meanMseValuesArray = zeros(nAggregates, length(nCustomers), nMethods, ...
    testLength);

instance = 0;
for nCustIdx = 1:length(nCustomers)
    for trial = 1:nAggregates
        instance = instance + 1;
        for forecastType = 1:nMethods
            meanMseValuesArray(trial, nCustIdx, forecastType,:) =...
                meanMseValues{instance}(forecastType, :);
        end
    end
end

% Finally take mean over trials:
meanMseValuesMeanOverTrials = squeeze(mean(meanMseValuesArray, 1));
% should have dimensions [length(nCustomers, nMethods, testLength]

%% Plotting
for nCustIdx = 1:length(nCustomers)
    subplot(2, 2, nCustIdx);
    plot(squeeze(meanMseValuesMeanOverTrials(nCustIdx, :, :))', ...
        'LineWidth', 2);
    grid on;
    title(['Aggregates of ' num2str(nCustomers(nCustIdx)) ' customers']);
    if nCustIdx == 1
        legend(forecastTypeStrings, 'Location', 'best');
    end
    if nCustIdx == 3
        xlabel(['                                                     ' ... 
            '                    ' 'Interval into Forecast Horizon [No.]'])
        ylabel(['                                                      '...
            'MSE Averaged over ' num2str(nDaysTest) ' Days and ' ...
            num2str(nAggregates) ' Aggregates [(kWh)^2]']);
    end
end

%% Save plot:
set(gcf, 'PaperPosition', myPaperPosition); %Position the plot further to the left and down. Extend the plot to fill entire paper.
set(gcf, 'PaperSize', myPaperSize); %Keep the same paper size
saveas(gcf, fileName, 'pdf');