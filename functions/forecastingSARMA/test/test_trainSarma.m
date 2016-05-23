%% Test by checking the performance against a given time-series for which
% SARMA(3,0)x(1,0) performs well.

% NB: this effectively also tests the 'lossSarma' function

%% Running options
doPlots = true;
suppressOutput = true;
percentThreshold = 0.2;

% Demand Data
[demand, periodLength] = getNoisySinusoid();
demand = demand + 10;

cfg.fc.suppressOutput = suppressOutput;
cfg.fc.useHyndmanModel = true;
cfg.fc.minimiseOverFirst = periodLength;
cfg.fc.nDaysPreviousTrainSarma = 20;
cfg.fc.performanceDifferenceThreshold = 0.02;
cfg.fc.nBestToCompare = 3;
cfg.fc.nLags = periodLength;

demandTrain = demand(1:(end-periodLength));
demandTest = demand((end-periodLength+1):end);


%% Test Hyndman model:
tic;
[ parametersHyndman ] = trainSarma( cfg, demandTrain, @lossMse);
hyndmanTrainTime = toc;
forecastHyndman = forecastSarma(cfg, parametersHyndman, demandTrain);

%% Numerical pass-fail:
absolutePercentageErrorsHyndman = abs(forecastHyndman(:) - ...
    demandTest) ./ abs(demandTest);

if max(absolutePercentageErrorsHyndman) < percentThreshold
    disp('trainSarma hyndman-type test PASSED!');
else
    error('trainSarma hyndman-type test FAILED!');
end
disp(['hyndman training time [s] = ' num2str(hyndmanTrainTime)]);

%% Test Sevlian et. al model:
trainControl.useHyndmanModel = false;
tic;
[ parametersSevlian ] = trainSarma(cfg, demandTrain, @lossMse);
sevlianTrainTime = toc;
forecastSevlian = forecastSarma(cfg, parametersSevlian, demandTrain);
absolutePercentageErrorsSevlian = abs(forecastSevlian(:) - ...
    demandTest) ./ abs(demandTest);

% Numerical pass-fail:
if (max(absolutePercentageErrorsSevlian) < percentThreshold)
    disp('forecastSarma sevlian-type test PASSED!');
else
    error('forecastSarma sevlian-type test FAILED!');
end
disp(['sevlian training time [s] = ' num2str(sevlianTrainTime)]);

%% Do some plotting:
if doPlots
    figure();
    plot(1:length(demand), demand, length(demand) + (1:periodLength), ...
        forecastHyndman);
    xlabel('Index');
    ylabel('Forecast from hyndman-type model (coefficents from Matlab)');
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
