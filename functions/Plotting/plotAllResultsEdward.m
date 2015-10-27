function plotAllResultsEdward( Sim, results, Pemd, Pfem)

% plotAllResultsEdward: Plot outputs from 'trainAllForecasts' and
% 'testAllFcasts' functions.

% Expand fields (of data structures)
allKWhs = results.allKWhs;
peakReductionsTrialFlattened = results.peakReductionsTrialFlattened;
smallestExitFlag = results.smallestExitFlag;
peakReductions = results.peakReductions;
lossTestResults = results.lossTestResults;

bestPfemForecast = results.bestPfemForecast;
bestPemdForecast = results.bestPemdForecast;

nDaysTrain = Sim.nDaysTrain;
nDaysTest = Sim.nDaysTest;
nDaysSelect = Sim.nDaysSelect;

lossTypesStrings = Sim.lossTypesStrings;
nMethods = length(lossTypesStrings);
nInstances = Sim.nInstances;
nAggregates = Sim.nAggregates;
nCustomers = Sim.nCustomers;
nTrainMethods = Sim.nTrainMethods;

resultsFields = fieldnames(results);
for ii = 1:length(resultsFields)
    eval([resultsFields{ii} ' = results.' resultsFields{ii} ';']);
end

simFields = fieldnames(Sim);
for ii = 1:length(simFields)
    eval([simFields{ii} ' = Sim.' simFields{ii} ';']);
end

%% 1) Plot all individual peak reduction ratios VS Aggregation Size
% With subplots for absolute and relative performance

fig_1 = figure();

% Absolite Peak Reduction Ratios
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

legend([lossTypesStrings, {'Some intervals not solved to optimality'}],...
    'Location', 'best','Interpreter', 'none');
hold off;

% Relative peak reduction ratios
subplot(1, 2, 2);

% Reference method godCast
refMethod = ismember(lossTypesStrings,'godCast');
peakReductionsRelative = peakReductions./repmat(...
    peakReductions(refMethod, :, :), [nMethods, 1, 1]);

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

legend([lossTypesStrings, {'Some intervals not solved to optimality'}],...
    'Location', 'best', 'Orientation', 'vertical', 'Interpreter', 'none');

hold off;
print(fig_1, '-dpdf', 'allPrrResults.pdf');

%% 2) Plot Absolute PRR against aggregation size (as means +/- error bars)

fig_2 = figure();

selectedForecasts = setdiff(1:nMethods, [Pfem.range, Pemd.range]);
selectedForecastLabels = lossTypesStrings(selectedForecasts);
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

print(fig_2, '-dpdf', 'absolutePrrVsAggregationSize.pdf');

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

print(fig_3, '-dpdf', 'relativePrrVsAggregationSize.pdf');

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

print(fig_4, '-dpdf', 'allPrrResultsBoxPlot.pdf');

%% 5) Plots showing performace of Each Forecast Against the different
% Error metrics (look at only BestPfem and BestPemd metrics to keep
% the number of plots manageable (but plot all relevant forecasts).
fig_5 = figure();

% Extend 'lossTestResults' with loss according to the 'bestPfem',
% 'bestPemd' metric for each instance. lossTestResults is:
% [nMethods x nAggregates x length(nCustomers) x nTrainMethods]);

instance = 0;
for eachNcust = 1:length(nCustomers)
    for eachAgg = 1:nAggregates;
        instance = instance + 1;
        for eachMethod = 1:nMethods
            lossTestResults(eachMethod, eachAgg, eachNcust, ...
                nTrainMethods+1) = lossTestResults(eachMethod, eachAgg, ...
                eachNcust, bestPfemForecast(instance));
            
            lossTestResults(eachMethod, eachAgg, eachNcust, ...
                nTrainMethods+2) = lossTestResults(eachMethod, eachAgg, ...
                eachNcust, bestPemdForecast(instance));
        end
    end
end

lossTestResultsMeanOverTrials = squeeze(mean(lossTestResults, 2));
lossTestResultsStdOverTrials = squeeze(std(lossTestResults, [], 2));

% Find indexes of metrics to plot (TODO: this is a bit of hack!)

metricsToPlotStrings = {'lossMse', 'lossMape', 'bestPfemSelected', ...
    'bestPemdSelected'};
metricsToPlotIdx = zeros(length(metricsToPlotStrings), 1);
for ii = 1:length(metricsToPlotStrings);
    if strcmp(metricsToPlotStrings{ii}, 'bestPfemSelected')
        metricsToPlotIdx(ii) = nTrainMethods+1;
    elseif strcmp(metricsToPlotStrings{ii}, 'bestPemdSelected')
        metricsToPlotIdx(ii) = nTrainMethods+2;
    else
        metricsToPlotIdx(ii) = find(ismember(lossTypesStrings,...
            metricsToPlotStrings{ii}));
    end
end

% Find indexes of forecasts to plot

methodsNotToPlotStrings = {'forecastFree', 'setPoint'};
methodsNotToPlotIdx = zeros(length(methodsNotToPlotStrings), 1);
for ii = 1:length(methodsNotToPlotStrings);
    methodsNotToPlotIdx(ii) = find(ismember(lossTypesStrings,...
        methodsNotToPlotStrings{ii}));
end

selectedForecasts = setdiff(1:nMethods, methodsNotToPlotIdx);

for eachMetricIdxIdx = 1:length(metricsToPlotIdx)
    eachMetricIdx = metricsToPlotIdx(eachMetricIdxIdx);
    subplot(2, ceil(nTrainMethods/2), eachMetricIdxIdx);
    errorbar(repmat(meanKWhs, [length(selectedForecasts), 1])', ...
        squeeze(lossTestResultsMeanOverTrials(selectedForecasts, :, ...
        eachMetricIdx))', squeeze(lossTestResultsStdOverTrials(...
        selectedForecasts, :, eachMetricIdx))','.-', 'markers', 20);
    
    grid on;
    legend(lossTypesStrings(selectedForecasts), 'Interpreter', 'none',...
        'Location', 'best', 'Orientation', 'vertical');
    xlabel('Mean Load [kWh/interval]');
    ylabel('Forecast Error Metric +/- 1.0 std. dev.');
    title(metricsToPlotStrings{eachMetricIdxIdx}, 'Interpreter', 'none');
end

print(fig_5, '-dpdf', 'allForecastPerformances.pdf');

end
