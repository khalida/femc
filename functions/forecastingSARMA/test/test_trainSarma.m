%% Test by checking the performance against a given time-series for which
% SARMA(3,0)x(1,0) performs well.

% NB: this effectively also tests the 'lossSarma' function, and associated
% MEX functions.
clearvars;

%% Running options
doPlots = true;
suppressOutput = true;
percentThreshold = 0.2;

% Demand Data
[demand, periodLength] = getNoisySinusoid();
demand = demand + 10;

cfg.fc.suppressOutput = suppressOutput;
cfg.fc.useHyndmanModel = true;
cfg.fc.season = periodLength;
cfg.sim.horizon = periodLength;
cfg.fc.minimiseOverFirst = periodLength;
cfg.fc.nDaysPreviousTrainSarma = 20;
cfg.fc.perfDiffThresh = 0.02;
cfg.fc.nStart = 3;
cfg.fc.nMaxSarmaStarts = 20;
cfg.fc.nLags = periodLength;

cfg.sim.stepsPerDay = periodLength;

demandTrain = demand(1:(end-periodLength));
demandTest = demand((end-periodLength+1):end);


%% Test Hyndman model:
thisTic = tic;
[ parametersHyndman ] = trainSarma( cfg, demandTrain, @lossMse);
hyndmanTrainTime = toc(thisTic);
forecastHyndman = forecastSarma(cfg, parametersHyndman, demandTrain);

%% Numerical pass-fail:
absolutePercentageErrorsHyndman = abs((forecastHyndman(:) - ...
    demandTest) ./ demandTest);

if max(absolutePercentageErrorsHyndman) < percentThreshold
    disp('test_trainSarma Hyndman-type test PASSED!');
else
    error('test_trainSarma Hyndman-type test FAILED!');
end
disp(['Hyndman-type training time [s] = ' num2str(hyndmanTrainTime)]);

%% Test Sevlian et. al type model:
trainControl.useHyndmanModel = false;
thisTic = tic;
[ parametersSevlian ] = trainSarma(cfg, demandTrain, @lossMse);
sevlianTrainTime = toc(thisTic);
forecastSevlian = forecastSarma(cfg, parametersSevlian, demandTrain);

absolutePercentageErrorsSevlian = abs((forecastSevlian(:) - ...
    demandTest) ./ demandTest);

% Numerical pass-fail:
if (max(absolutePercentageErrorsSevlian) < percentThreshold)
    disp('test_trainSarma Sevlian-type test PASSED!');
else
    error('test_trainSarma sevlian-type test FAILED!');
end
disp(['Sevlian training time [s] = ' num2str(sevlianTrainTime)]);

%% Do some plotting:
if doPlots
    figure();
    plot(1:length(demand), demand, length(demand) + (1:periodLength), ...
        forecastHyndman);
    xlabel('Index');
    ylabel('Forecast from Hyndman-type model (coefficents from Matlab)');
    grid on;
    
    figure();
    plot(1:length(demand), demand, length(demand) + (1:periodLength), ...
        forecastSevlian);
    xlabel('Index');
    ylabel('Forecast from Sevlian-type model (coefficents from Matlab)');
    grid on;
    
    figure();
    subplot(1,2,1);
    plot(demandTest, forecastHyndman, '.');
    xlabel('Actual');
    ylabel('Hyndman Point forecast from Matlab');
    grid on;
    hold on;
    refline(1, 0);
    subplot(1,2,2);
    plot(demandTest, forecastSevlian, '.');
    xlabel('Actual');
    ylabel('Sevlian Point forecast from Matlab');
    grid on;
    hold on;
    refline(1, 0);
end

close all;