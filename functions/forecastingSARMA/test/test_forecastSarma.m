%% Test by checking the results produced VS those found from R forecasting
% package for a particular trained SARMA model and previous values

doPlots = false;
if doPlots, suppressOutput = false; else suppressOutput = true; end %#ok<*UNRCH>
percentThreshold = 0.05;

parameters.k = 48;
load('test_demand_data.mat');
% INCLUDES: demand, coefficients, meanRforecast, zeroARmeanRforecast
% zeroSARmeanRforecast
parameters.coefficients = coefficients(1:4)';

%% Test Hyndman model:
[ forecastHyndman ] = forecastSarma(parameters, demand, suppressOutput, ...
    true);

%% Numerical pass-fail:
absolutePercentageErrors = abs(forecastHyndman(:) - meanRforecast) ./ ...
    abs(meanRforecast);

if max(absolutePercentageErrors) < percentThreshold
    disp('forecastSarma hyndman-type test PASSED!');
else
    error('forecastSarma hyndmand-type test FAILED!');
end

%% Test Sevlian et. al model:
% Zero AR components:
parameters.coefficients = [0, 0, 0, coefficients(4)'];
[ forecastSevlian ] = forecastSarma(parameters, demand, suppressOutput, ...
    false);
absolutePercentageErrorsZeroAR = abs(forecastSevlian(:) - ...
    zeroARmeanRforecast) ./ abs(zeroARmeanRforecast);

% Zero SAR components:
parameters.coefficients = [coefficients(1:3)', 0];
[ forecastSevlian ] = forecastSarma(parameters, demand, suppressOutput, ...
    false);
absolutePercentageErrorsZeroSAR = abs(forecastSevlian(:) - ...
    zeroSARmeanRforecast) ./ abs(zeroSARmeanRforecast);

% Numerical pass-fail:
if (max(absolutePercentageErrorsZeroAR) < percentThreshold) && ...
        (max(absolutePercentageErrorsZeroSAR) < percentThreshold)
    disp('forecastSarma sevlian-type test PASSED!');
else
    error('forecastSarma sevlian-type test FAILED!');
end

%% Do some plotting:
if doPlots
    figure(1);
    plot(1:length(demand), demand, length(demand) + (1:parameters.k), ...
        forecastSevlian);
    xlabel('Index');
    ylabel('Forecast from sevlian-type model (coefficents from R ARIMA())');
    grid on;
    
    figure(2);
    plot(1:length(demand), demand, length(demand) + (1:parameters.k), ...
        forecastHyndman);
    xlabel('Index');
    ylabel('Forecast from hyndman-type model (coefficents from R ARIMA())');
    grid on;
    
    figure(3);
    plot(meanRforecast, forecastHyndman, '.');
    xlabel('Mean of R forecast');
    ylabel('Point forecast from Matlab using Hyndmand-type model');
    grid on;
    hold on;
    refline(1, 0);
end
