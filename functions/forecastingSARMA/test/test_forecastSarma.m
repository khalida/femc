%% Test by checking the results produced VS those found from R forecasting
% package for a particular trained SARMA model (ltd to (3,0)x(1,0)[nPeriod]

doPlots = true;
if doPlots, suppressOutput = false; else
    suppressOutput = true; end %#ok<*UNRCH>
percentThreshold = 1e-3;

%% Generate some historicData
[dataValues, periodLength] = getNoisySinusoid();

trainControl.horizon = periodLength;
trainControl.season = periodLength;
trainControl.suppressOutput = suppressOutput;
trainControl.useHyndmanModel = true;
trainControl.nLags = periodLength;

[coefficients, meanForecast] = ...
    getAutoArimaModelCoefficientsAndForecast(dataValues, trainControl, ...
    [3, 0, 0], [1, 0, 0]);

parameters.k = periodLength;
parameters.coefficients = coefficients(1:4)';

%% Test Hyndman model (one implemented in R forecast package)
[ forecastHyndman ] = forecastSarma(parameters, dataValues, ...
    trainControl);

%% Numerical pass-fail:
absolutePercentageErrors = abs(forecastHyndman(:) - meanForecast) ./ ...
    abs(meanForecast);

if max(absolutePercentageErrors) < percentThreshold
    disp('forecastSarma hyndman-type test PASSED!');
else
    error('forecastSarma hyndmand-type test FAILED!');
end

%% Test Sevlian et. al model (need to have zero AR or SAR components)
trainControl.useHyndmanModel = false;
% Zero AR components:
[coefficients, meanSevlianForecast] = ...
    getAutoArimaModelCoefficientsAndForecast(dataValues, trainControl, ...
    [0, 0, 0], [1, 0, 0]);

parameters.coefficients = [0, 0, 0, coefficients];

[ forecastSevlian ] = forecastSarma(parameters, dataValues, trainControl);
absolutePercentageErrorsZeroAR = abs(forecastSevlian(:) - ...
    meanSevlianForecast) ./ abs(meanSevlianForecast);

% Zero SAR components:
[coefficients, meanSevlianForecast] = ...
    getAutoArimaModelCoefficientsAndForecast(dataValues, trainControl, ...
    [3; 0; 0], [0; 0; 0]);
parameters.coefficients = [coefficients', 0];
[ forecastSevlian ] = forecastSarma(parameters, dataValues, trainControl);
absolutePercentageErrorsZeroSAR = abs(forecastSevlian(:) - ...
    meanSevlianForecast) ./ abs(meanSevlianForecast);

% Numerical pass-fail:
if (max(absolutePercentageErrorsZeroAR) < percentThreshold) && ...
        (max(absolutePercentageErrorsZeroSAR) < percentThreshold)
    disp('forecastSarma sevlian-type test PASSED!');
else
    error('forecastSarma sevlian-type test FAILED!');
end

%% Do some plotting:
if doPlots
    figure();
    plot(1:length(dataValues), dataValues, length(dataValues) + (1:parameters.k), ...
        forecastSevlian);
    xlabel('Index');
    ylabel('Forecast from sevlian-type model (coefficents from R ARIMA())');
    grid on;
    
    figure();
    plot(1:length(dataValues), dataValues, length(dataValues) + (1:parameters.k), ...
        forecastHyndman);
    xlabel('Index');
    ylabel('Forecast from hyndman-type model (coefficents from R ARIMA())');
    grid on;
    
    figure();
    plot(meanForecast, forecastHyndman, '.');
    xlabel('Mean of R forecast');
    ylabel('Point forecast from Matlab using Hyndmand-type model');
    grid on;
    hold on;
    refline(1, 0);
end
