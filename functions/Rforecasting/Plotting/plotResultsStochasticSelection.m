function plotResultsStochasticSelection( Sim, results)

% plotResultsStochasticSelection: Plot outputs from 'trainBestForecasts'
                        % and 'testBestForecasts' functions.

%% Expand required fields of structures:

allKWhs = results.allKWhs;
peakReductionsTrialFlattened = results.peakReductionsTrialFlattened;
smallestExitFlag = results.smallestExitFlag;
peakReductions = results.peakReductions;

nDaysTrain = Sim.nDaysTrain;
nDaysTest = Sim.nDaysTest;
nDaysSelect = Sim.nDaysSelect;

allMethodStrings = Sim.allMethodStrings;
nMethods = Sim.nMethods;
nInstances = Sim.nInstances;

%% 1) Plot all individual peak reduction ratios VS Aggregation Size
% With subplots for absolute and relative performance

fig_1 = figure();

% Absolute Peak Reduction Ratios
subplot(1, 2, 1);
plot(allKWhs(:), peakReductionsTrialFlattened', '.', 'markers', 20);
hold on;
% Plot warning circles about optimality
warnPeakReductions = peakReductionsTrialFlattened(smallestExitFlag < 1);
extendedKWhs = repmat(allKWhs(:)', [nMethods, 1]);
warnkWhs = extendedKWhs(smallestExitFlag < 1);
if (isempty(warnkWhs))
    warnkWhs = -1;
    warnPeakReductions = -1;
end
plot(warnkWhs, warnPeakReductions, 'ro', 'markers', 20);
xlabel('Mean Load [kWh/interval]');
ylabel(['Mean PRR, ' num2str(nDaysTrain) '-day train, '...
    num2str(nDaysSelect) '-day parameter selection, ' ...
    num2str(nDaysTest) '-day test']);

legend([allMethodStrings, {'Some intervals not solved to optimality'}],...
    'Location', 'best','Interpreter', 'none');
hold off;

% Relative peak reduction ratios
subplot(1, 2, 2);

% Reference method godCast
refMethodIdx = ismember(allMethodStrings,'godCast');
peakReductionsRelative = peakReductions./repmat(...
    peakReductions(refMethodIdx, :, :), [nMethods, 1, 1]);

peakReductionsRelativeTrialFlattened = reshape(peakReductionsRelative,...
    [nMethods, nInstances]);

plot(allKWhs(:), peakReductionsRelativeTrialFlattened', '.', 'markers', 20)
hold on
% Plot warning circles about optimality
warnPeakReductions = peakReductionsRelativeTrialFlattened(...
    smallestExitFlag < 1);
plot(warnkWhs, warnPeakReductions, 'ro', 'markers', 20);
xlabel('Mean Load [kWh/interval]');
ylabel(['Mean PRR relative to Perfect Forecast, ' num2str(nDaysTrain)...
    '-day train, ' num2str(nDaysSelect) '-day parameter selection, '...
    num2str(nDaysTest) '-day test']);

legend([allMethodStrings, {'Some intervals not solved to optimality'}],...
    'Location', 'best', 'Orientation', 'vertical', 'Interpreter', 'none');

hold off;
print(fig_1, '-dpdf', ['..' filesep 'results' filesep ...
    'allPrrResultsStochasticSelection.pdf']);


%% 2) Plot Absolute PRR against aggregation size (as means +/- error bars)

fig_2 = figure();

selectedForecasts = 1:nMethods;
selectedForecastLabels = allMethodStrings(selectedForecasts);
meanPeakReductions = ...    % nCustomers X forecastTypes
    squeeze(mean(peakReductions(selectedForecasts, :, :), 2));
stdPeakReductions = ...
    squeeze(std(peakReductions(selectedForecasts, :, :),[], 2));
meanKWhs = mean(allKWhs, 1); % nCustomers X 1
errorbar(repmat(meanKWhs, [length(selectedForecasts), 1])', ...
    meanPeakReductions',stdPeakReductions','.-', 'markers', 20);
xlabel('Mean Load [kWh/interval]');
ylabel('Mean PRR, with +/- 1.0 std. dev.');
legend(selectedForecastLabels, 'Interpreter', 'none',...
    'Location', 'best', 'Orientation', 'vertical');
grid on;
hold off;

print(fig_2, '-dpdf', ['..' filesep 'results' filesep ...
    'absolutePrrVsAggregationSizeStochasticSelection.pdf']);


%% 3) Plot Relative PRR against aggregation size (as means +/- error bars)
fig_3 = figure();

meanPeakReductionsRelative = ...    % nCustomers X forecastTypes
    squeeze(mean(peakReductionsRelative(selectedForecasts, :, :), 2));
stdPeakReductionsRelative = ...
    squeeze(std(peakReductionsRelative(selectedForecasts, :, :),[], 2));
errorbar(repmat(meanKWhs, [length(selectedForecasts), 1])', ...
    meanPeakReductionsRelative',stdPeakReductionsRelative','.-',...
    'markers', 20);
xlabel('Mean Load [kWh/interval]');
ylabel('Mean relative PRR, with +/- 1.0 std. dev.');
legend(selectedForecastLabels, 'Interpreter', 'none',...
    'Location', 'best', 'Orientation', 'vertical');
grid on;
hold off;

print(fig_3, '-dpdf', ['..' filesep 'results' filesep ...
    'relativePrrVsAggregationSizeStochasticSelection.pdf']);

%% 4) BoxPlots of Rel/Abs PRR for each Method (across all instances)

fig_4 = figure();
% Absolute PRRs
subplot(1, 2, 1);
peakReductionsFlattened = ...
    squeeze(peakReductionsTrialFlattened(selectedForecasts, :));
boxplot(peakReductionsFlattened', 'labels', selectedForecastLabels,...
    'plotstyle', 'compact');
ylabel('Mean PRR []');
grid on;

% Relative PRRs
subplot(1, 2, 2);
peakReductionsRelativeFlattened = ...
    squeeze(peakReductionsRelativeTrialFlattened(selectedForecasts, :));
boxplot(peakReductionsRelativeFlattened', 'labels', ...
    selectedForecastLabels, 'plotstyle', 'compact');
ylabel('Mean PRR relative to perfect forecast');
grid on;

print(fig_4, '-dpdf', ['..' filesep 'results' filesep ...
    'allPrrResultsBoxPlotStochasticSelection.pdf']);

end
