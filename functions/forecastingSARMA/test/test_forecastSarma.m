%% Test by checking the results produced VS those found from R forecasting
% package for a particular trained SARMA model (ltd to (3,0)x(1,0)[nPeriod]
clearvars;

doPlots = true;
if doPlots, suppressOutput = false; else
    suppressOutput = true; end %#ok<*UNRCH>
percentThreshold = 1e-3;

%% Generate some historicData
[dataValues, periodLength] = getNoisySinusoid();

cfg.sim.horizon = periodLength;
cfg.fc.season = periodLength;
cfg.fc.suppressOutput = suppressOutput;
cfg.fc.useHyndmanModel = true;
cfg.fc.nLags = periodLength;

[coefficients, meanForecast] = getAutoArimaModelCoefficientsAndForecast(...
    cfg, dataValues, [3, 0, 0], [1, 0, 0]);

parameters.k = periodLength;
parameters.coefficients = coefficients(1:4)';

%% Test Hyndman model (one implemented in R forecast package)
[ forecastHyndman ] = forecastSarma(cfg, parameters, dataValues);

%% Numerical pass-fail:
absolutePercentageErrors = abs((forecastHyndman(:) - meanForecast) ./ ...
    meanForecast);

if max(absolutePercentageErrors) < percentThreshold
    disp('test_forecastSarma Hyndman-type test PASSED!');
else
    error('test_forecastSarma Hyndmand-type test FAILED!');
end

%% Test Sevlian et. al model (need to have zero AR or SAR components)
cfg.fc.useHyndmanModel = false;
% Zero AR components:
[coefficients, meanSevlianForecast] = ...
    getAutoArimaModelCoefficientsAndForecast(cfg, dataValues, ...
    [0, 0, 0], [1, 0, 0]);

parameters.coefficients = [0, 0, 0, coefficients];

[ forecastSevlian ] = forecastSarma(cfg, parameters, dataValues);

absolutePercentageErrorsZeroAR = abs((forecastSevlian(:) - ...
    meanSevlianForecast) ./ meanSevlianForecast);

% Zero SAR components:
[coefficients, meanSevlianForecast] = ...
    getAutoArimaModelCoefficientsAndForecast(cfg, dataValues, ...
    [3; 0; 0], [0; 0; 0]);

parameters.coefficients = [coefficients', 0];
[ forecastSevlian ] = forecastSarma(cfg, parameters, dataValues);
absolutePercentageErrorsZeroSAR = abs((forecastSevlian(:) - ...
    meanSevlianForecast) ./ meanSevlianForecast);

% Numerical pass-fail:
if (max(absolutePercentageErrorsZeroAR) < percentThreshold) && ...
        (max(absolutePercentageErrorsZeroSAR) < percentThreshold)
    disp('test_forecastSarma Sevlian-type test PASSED!');
else
    error('test_forecastSarma Sevlian-type test FAILED!');
end

%% Do some plotting:
if doPlots
    figure();
    plot(1:length(dataValues), dataValues, length(dataValues) +...
        (1:parameters.k), forecastSevlian);
    
    xlabel('Index');
    ylabel(['Forecast from Sevlian-type model '...
        '(coefficents from R ARIMA())']);
    
    grid on;
    
    figure();
    plot(1:length(dataValues), dataValues, length(dataValues) +...
        (1:parameters.k), forecastHyndman);
    
    xlabel('Index');
    ylabel(['Forecast from Hyndman-type model '...
        '(coefficents from R ARIMA())']);
    
    grid on;
    
    figure();
    plot(meanForecast, forecastHyndman, '.');
    xlabel('Mean of R forecast');
    ylabel('Point forecast from Matlab using Hyndman-type model');
    grid on;
    hold on;
    refline(1, 0);
end

close all;