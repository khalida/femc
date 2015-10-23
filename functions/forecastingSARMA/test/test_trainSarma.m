%% Test by checking the performance against a given time-series for which
% SARMA(3,0)x(1,0) performs well.

% NB: this effectively also tests the 'lossSarma' function

doPlots = false;
suppressOutput = true;
percentThreshold = 0.05;

load('test_demand_data.mat');
% INCLUDES: demand, coefficients, meanRforecast, zeroARmeanRforecast
% zeroSARmeanRforecast

k = 48;
trainControl.suppressOutput = suppressOutput;
trainControl.useHyndmanModel = true;
trainControl.minimiseOverFirst = k;
trainControl.nDaysPreviousTrainSarma = 20;
trainControl.performanceDifferenceThreshold = 0.02;
trainControl.nBestToCompare = 3;

% Divide data into training and testing:
demand = demand*2 + 50;
demandTrain = demand(1:(end-k));
demandTest = demand((end-k+1):end);

%% Test Hyndman model:
tic;
[ parametersHyndman ] = trainSarma( demandTrain, k,  @loss_mse,...
    trainControl);
hyndmanTrainTime = toc;
forecastHyndman = forecastSarma(parametersHyndman, demandTrain, ...
    trainControl.suppressOutput, true);

%% Numerical pass-fail:
absolutePercentageErrorsHyndman = abs(forecastHyndman(:) - ...
    demandTest) ./ abs(demandTest);

if max(absolutePercentageErrorsHyndman) < percentThreshold
    disp('trainSarma hyndman-type test PASSED!');
else
    error('trainSarma hyndmand-type test FAILED!');
end
disp(['hyndman training time [s] = ' num2str(hyndmanTrainTime)]);

%% Test Sevlian et. al model:
trainControl.useHyndmanModel = false;
tic;
[ parametersSevlian ] = trainSarma( demandTrain, k,  @loss_mse,...
    trainControl);
sevlianTrainTime = toc;
forecastSevlian = forecastSarma(parametersSevlian, demandTrain, ...
    trainControl.suppressOutput, false);
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
    figure(1);
    plot(1:length(demand), demand, length(demand) + (1:k), ...
        forecastHyndman);
    xlabel('Index');
    ylabel('Forecast from hyndman-type model (coefficents from Matlab)');
    grid on;
    
    figure(2);
    plot(1:length(demand), demand, length(demand) + (1:k), ...
        forecastSevlian);
    xlabel('Index');
    ylabel('Forecast from Sevlian-type model (coefficents from Matlab)');
    grid on;
    
    figure(3);
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
