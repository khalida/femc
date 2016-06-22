function plotAllResultsMetricSelect(cfg, results, allDemandValues)

% plotAllResultsMetricSelect: Plot outputs from 'trainAllForecasts' and
% 'testAllFcasts' functions.

% INPUTS:
% cfg:              structure of running options
% results:          structure of results from simulations
% allDemandValues:  (optional) cellAray containing the original demand data

% OUTPUTS:
% none - plot to screen, and saving of plots only.

%% Etract results variables
meanKWhs = results.meanKWhs;
peakReductionsTrialFlattened = results.peakReductionsTrialFlattened;
smallestExitFlag = results.smallestExitFlag;
peakReductions = results.peakReductions;
lossTestResults = results.lossTestResults;

bestPfemForecast = results.bestPfemForecast;
bestPemdForecast = results.bestPemdForecast;


nDaysTrain = cfg.sim.nDaysTrain;
nDaysTest = cfg.sim.nDaysTest;
nDaysSelect = cfg.sim.nDaysSelect;

allMethodStrings = cfg.fc.allMethodStrings;
nMethods = cfg.fc.nMethods;
nInstances = cfg.sim.nInstances;
nAggregates = cfg.sim.nAggregates;
nCustomers = cfg.sim.nCustomers;
nTrainMethods = cfg.fc.nTrainMethods;


%% 1) Plot all individual peak reduction ratios VS Aggregation Size
% With subplots for absolute and relative performance

fig_1 = figure();

% Absolute Peak Reduction Ratios
subplot(1, 2, 1);
plot(meanKWhs(:), peakReductionsTrialFlattened', '.', 'markers', 20);
set(gca, 'xscale', 'log');
hold on;
% Plot warning circles about optimality
warnPeakReductions = peakReductionsTrialFlattened(smallestExitFlag < 1);
extendedKWhs = repmat(meanKWhs(:)', [nMethods, 1]);
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
    'Interpreter', 'none');
hold off;

% Relative peak reduction ratios
subplot(1, 2, 2);

% Reference method godCast
refMethodIdx = ismember(allMethodStrings,'godCast');
peakReductionsRelative = peakReductions./repmat(...
    peakReductions(refMethodIdx, :, :), [nMethods, 1, 1]);

peakReductionsRelativeTrialFlattened = reshape(peakReductionsRelative,...
    [nMethods, nInstances]);

plot(meanKWhs(:), peakReductionsRelativeTrialFlattened', '.', 'markers', 20)
set(gca, 'xscale', 'log');
hold on
% Plot warning circles about optimality
warnPeakReductions = peakReductionsRelativeTrialFlattened(...
    smallestExitFlag < 1);
if (isempty(warnPeakReductions))
    warnPeakReductions = -1;
end
plot(warnkWhs, warnPeakReductions, 'ro', 'markers', 20);
xlabel('Mean Load [kWh/interval]');
ylabel(['Mean PRR relative to Perfect Forecast, ' num2str(nDaysTrain)...
    '-day train, ' num2str(nDaysSelect) '-day parameter selection, '...
    num2str(nDaysTest) '-day test']);

legend([allMethodStrings, {'Some intervals not solved to optimality'}],...
    'Orientation', 'vertical', 'Interpreter', 'none');

hold off;
print(fig_1, '-dpdf', [cfg.sav.resultsDir filesep 'allPrrResults.pdf']);
plotAsTikz([cfg.sav.resultsDir filesep 'allPrrResults.tikz']);


selectedForecasts = setdiff(1:nMethods, [cfg.fc.Pfem.range, ...
    cfg.fc.Pemd.range]);

selectedForecastLabels = allMethodStrings(selectedForecasts);
meanPeakReductions = ...    % nCustomers X forecastTypes
    squeeze(mean(peakReductions(selectedForecasts, :, :), 2));

%% 2) Plot Absolute PRR against aggregation size (as means +/- error bars)
if length(cfg.sim.nCustomers) > 1
    fig_2 = figure();
    
    stdPeakReductions = ...
        squeeze(std(peakReductions(selectedForecasts, :, :),[], 2));
    
    meanKWhs = mean(meanKWhs, 1); % nCustomers X 1
    errorbar(repmat(meanKWhs, [length(selectedForecasts), 1])', ...
        meanPeakReductions',stdPeakReductions','.-', 'markers', 20);
    
    set(gca, 'xscale', 'log');
    
    xlabel('Mean Load [kWh/interval]');
    ylabel('Mean PRR, with +/- 1.0 std. dev.');
    legend(selectedForecastLabels, 'Interpreter', 'none',...
        'Orientation', 'vertical');
    grid on;
    hold off;
    
    print(fig_2, '-dpdf', [cfg.sav.resultsDir filesep ...
        'absolutePrrVsAggregationSize.pdf']);
    
    plotAsTikz([cfg.sav.resultsDir filesep ...
        'absolutePrrVsAggregationSize.tikz']);
    
    
    
    %% 3) Plot Relative PRR against aggregation size (as means +/- error bars)
    fig_3 = figure();
    
    meanPeakReductionsRelative = ...    % nCustomers X forecastTypes
        squeeze(mean(peakReductionsRelative(selectedForecasts, :, :), 2));
    
    stdPeakReductionsRelative = ...
        squeeze(std(peakReductionsRelative(selectedForecasts, :, :),[], 2));
    
    errorbar(repmat(meanKWhs, [length(selectedForecasts), 1])', ...
        meanPeakReductionsRelative',stdPeakReductionsRelative','.-',...
        'markers', 20);
    
    set(gca, 'xscale', 'log');
    
    xlabel('Mean Load [kWh/interval]');
    ylabel('Mean relative PRR, with +/- 1.0 std. dev.');
    legend(selectedForecastLabels, 'Interpreter', 'none',...
        'Orientation', 'vertical');
    
    grid on;
    hold off;
    
    print(fig_3, '-dpdf', [cfg.sav.resultsDir filesep ...
        'relativePrrVsAggregationSize.pdf']);
    
    plotAsTikz([cfg.sav.resultsDir filesep ...
        'relativePrrVsAggregationSize.tikz']);
    
end


%% 4) BoxPlots of Rel/Abs PRR for each Method (across all instances)
if cfg.sim.nInstances > 1
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
    
    print(fig_4, '-dpdf', [cfg.sav.resultsDir filesep ...
        'allPrrResultsBoxPlot.pdf']);
    
    plotAsTikz([cfg.sav.resultsDir filesep ...
        'allPrrResultsBoxPlot.tikz']);
    
end

if length(cfg.sim.nCustomers) > 1
    %% 5) Plots showing performace of each Forecast Against the different
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
            
            if cfg.fc.Pfem.num > 0
                for eachMethod = 1:nMethods
                    lossTestResults(eachMethod, eachAgg, eachNcust, ...
                        nTrainMethods+1) = lossTestResults(eachMethod, eachAgg, ...
                        eachNcust, bestPfemForecast(instance));
                end
            end
            if cfg.fc.Pemd.num > 0
                for eachMethod = 1:nMethods
                    lossTestResults(eachMethod, eachAgg, eachNcust, ...
                        nTrainMethods+2) = lossTestResults(eachMethod, eachAgg, ...
                        eachNcust, bestPemdForecast(instance));
                end
            end
        end
    end
    
    lossTestResultsMeanOverTrials = squeeze(mean(lossTestResults, 2));
    lossTestResultsStdOverTrials = squeeze(std(lossTestResults, [], 2));
    
    % Find indexes of metrics to plot
    % TODO: Sort this out: currently a bit of hack!)
    metricsToPlotStrings = {'lossMse', 'lossMape'};
    if cfg.fc.Pfem.num > 0
        metricsToPlotStrings = [metricsToPlotStrings, {'bestPfemSelected'}];
    end
    if cfg.fc.Pemd.num > 0
        metricsToPlotStrings = [metricsToPlotStrings, {'bestPemdSelected'}];
    end
    
    metricsToPlotIdx = zeros(length(metricsToPlotStrings), 1);
    for ii = 1:length(metricsToPlotStrings);
        if strcmp(metricsToPlotStrings{ii}, 'bestPfemSelected')
            metricsToPlotIdx(ii) = nTrainMethods+1;
        elseif strcmp(metricsToPlotStrings{ii}, 'bestPemdSelected')
            metricsToPlotIdx(ii) = nTrainMethods+2;
        else
            metricsToPlotIdx(ii) = find(ismember(allMethodStrings,...
                metricsToPlotStrings{ii}));
        end
    end
    
    % Find indexes of forecasts to plot
    methodsNotToPlotStrings = {'setPoint'};
    methodsNotToPlotIdx = [];
    for ii = 1:length(methodsNotToPlotStrings);
        methodsNotToPlotIdx = [methodsNotToPlotIdx, ...
            find(ismember(allMethodStrings, ...
            methodsNotToPlotStrings{ii}))]; %#ok<AGROW>
    end
    
    selectedForecasts = setdiff(1:nMethods, methodsNotToPlotIdx);
    
    for eachMetricIdxIdx = 1:length(metricsToPlotIdx)
        eachMetricIdx = metricsToPlotIdx(eachMetricIdxIdx);
        subplot(1, length(metricsToPlotIdx), eachMetricIdxIdx);
        
        errorbar(repmat(meanKWhs, [length(selectedForecasts), 1])', ...
            squeeze(lossTestResultsMeanOverTrials(selectedForecasts, :, ...
            eachMetricIdx))', squeeze(lossTestResultsStdOverTrials(...
            selectedForecasts, :, eachMetricIdx))','.-', 'markers', 20);
        
        set(gca, 'xscale', 'log');
        
        
        grid on;
        legend(allMethodStrings(selectedForecasts), 'Interpreter', 'none',...
            'Orientation', 'vertical');
        
        xlabel('Mean Load [kWh/interval]');
        ylabel('Forecast Error Metric +/- 1.0 std. dev.');
        title(metricsToPlotStrings{eachMetricIdxIdx}, 'Interpreter', 'none');
    end
    
    print(fig_5, '-dpdf', [cfg.sav.resultsDir filesep...
        'allForecastPerformances.pdf']);
    
    plotAsTikz([cfg.sav.resultsDir filesep...
        'allForecastPerformances.tikz']);
end


%% Wilcoxon signed rank test for mediam PFEM, PEMD being larger than MSE:
% (with paired observations):
lossMseIdx = strcmp(allMethodStrings, 'lossMse');
lossPfemIdx = strcmp(allMethodStrings, 'bestPfemSelected');
lossPemdIdx = strcmp(allMethodStrings, 'bestPemdSelected');

% Each row for different nCustomer, 1st column Pfem, 2nd columnd Pemd:
pValuesBetterThanMse = zeros(length(nCustomers), 2);
prrRelativeToMse = zeros(length(nCustomers), nAggregates, 2);

for nCustIdx = 1:length(nCustomers)
    thesePeakReductions = squeeze(peakReductions(:, :, nCustIdx));
    % Fill out p-value for null hypothesis that Pfem not greater than mse:
    [pValuesBetterThanMse(nCustIdx, 1), ~, ~] = ...
        signrank(thesePeakReductions(lossMseIdx, :), ...
        thesePeakReductions(lossPfemIdx, :), 'tail', 'left', 'method', ...
        'exact');
    
    prrRelativeToMse(nCustIdx, :, 1) = ...
        thesePeakReductions(lossPfemIdx, :)./...
        thesePeakReductions(lossMseIdx, :);
    
    
    % Fill out p-value for null hypothesis that Pemd not greater than mse:
    [pValuesBetterThanMse(nCustIdx, 2), ~, ~] = ...
        signrank(thesePeakReductions(lossMseIdx, :), ...
        thesePeakReductions(lossPemdIdx, :), 'tail', 'left');
    
    prrRelativeToMse(nCustIdx, :, 2) = ...
        thesePeakReductions(lossPemdIdx, :)./...
        thesePeakReductions(lossMseIdx, :);
end
disp('pValuesBetterThanMse');
disp(pValuesBetterThanMse);

disp('prrRelativeToMse');
disp(prrRelativeToMse);


%% Get average values of the forecast parameters over aggregation levels
pfemParsVsNcust = zeros(length(nCustomers), size(cfg.fc.Pfem.allValues, 2));
pfemParsVsNcustAll = zeros(nInstances, 1+size(cfg.fc.Pfem.allValues, 2));
pemdParsVsNcust = zeros(length(nCustomers), size(cfg.fc.Pemd.allValues, 2));
pemdParsVsNcustAll = zeros(nInstances, 1+size(cfg.fc.Pemd.allValues, 2));
for nCustIdx = 1:length(nCustomers)
    % PFEM Parameters
    pfemParsVsNcust(nCustIdx, :) = median(cfg.fc.Pfem.allValues(...
        results.bestPfemForecastArray(:, nCustIdx) + 1 - ...
        min(cfg.fc.Pfem.range), :), 1);
    
    pfemParsVsNcustAll(((nCustIdx-1)*nAggregates+1):(nCustIdx*nAggregates), ...
        1) = nCustomers(nCustIdx);
    
    pfemParsVsNcustAll(((nCustIdx-1)*nAggregates+1):(nCustIdx*nAggregates), ...
        2:end) = cfg.fc.Pfem.allValues( results.bestPfemForecastArray(:,...
        nCustIdx) + 1 - min(cfg.fc.Pfem.range), :);
    
    % PEMD Parameters
    pemdParsVsNcust(nCustIdx, :) = median(cfg.fc.Pemd.allValues(...
        results.bestPemdForecastArray(:, nCustIdx) + 1 - ...
        min(cfg.fc.Pemd.range), :), 1);
    
    pemdParsVsNcustAll(((nCustIdx-1)*nAggregates+1):(nCustIdx*nAggregates), ...
        1) = nCustomers(nCustIdx);
    
    pemdParsVsNcustAll(((nCustIdx-1)*nAggregates+1):(nCustIdx*nAggregates), ...
        2:end) = cfg.fc.Pemd.allValues( results.bestPemdForecastArray(:,...
        nCustIdx) + 1 - min(cfg.fc.Pemd.range), :);
end

% Perform bivariate plot of PEMD, PFEM parameters:
figure();
gplotmatrix(pfemParsVsNcustAll, [], pfemParsVsNcustAll(:, 1));
title('PFEM Parameter-selection scatter plot, colored by nCustomer');

figure();
title('PEMD Parameter-selection scatter plot, colored by nCustomer');
gplotmatrix(pemdParsVsNcustAll, [], pemdParsVsNcustAll(:, 1));

disp('pfemParsVsNcust');
disp(pfemParsVsNcust);

disp('pemdParsVsNcust');
disp(pemdParsVsNcust);

%% Plot raw data (primarily for debugging/reference):
if exist('allDemandValues', 'var')
    figure();
    hold on;
    index = 0;
    for eachNcust = 1:length(nCustomers)
        for eachAgg = 1:nAggregates
            index = index + 1;
            subplot(length(nCustomers), nAggregates, index);
            hold on;
            plot(cfg.sim.trainIdxs, ...
                allDemandValues{index}(cfg.sim.trainIdxs));
            
            plot(cfg.sim.forecastSelectionIdxs, ...
                allDemandValues{index}(cfg.sim.forecastSelectionIdxs));
            
            plot(cfg.sim.testIdxs, ...
                allDemandValues{index}(cfg.sim.testIdxs));
        end
    end
    legend('Train Data', 'Forecast Selection Data', 'Test Data');
end

%% Scatter plot of properties of demand signals VS parameter choices made
if exist('allDemandValues', 'var')
    % Feature vector: [mean demand, max demand, min demand, max/mean, std]
    demanSignalFeatures = zeros(nInstances, 5);
    index = 0;
    for eachNcust = 1:length(nCustomers)
        for eachAgg = 1:nAggregates
            index = index + 1;
            thisDemand = allDemandValues{index};
            demanSignalFeatures(index, 1) = mean(thisDemand);
            demanSignalFeatures(index, 2) = max(thisDemand);
            demanSignalFeatures(index, 3) = min(thisDemand);
            demanSignalFeatures(index, 4) = max(thisDemand)/...
                mean(thisDemand);
            
            demanSignalFeatures(index, 5) = std(thisDemand);
        end
    end
    
    % Plot pair-wise scatter of these dimensions, and colour by each
    % parameter (4 subplot per PFEM, PEMD):
    for eachPar = 1:4
        figure();
        gplotmatrix(demanSignalFeatures, [], ...
            pfemParsVsNcustAll(:, 1+eachPar));
        
        title(['PFEM Demand Sgl Propoerty scatter, colored by par '...
            'selection. ' num2str(eachPar)]);
    end
    
    for eachPar = 1:4
        figure();
        gplotmatrix(demanSignalFeatures, [], ...
            pemdParsVsNcustAll(:, 1+eachPar));
        
        title(['PEMD Demand Sgl Propoerty scatter, colored by par '...
            'selection. ' num2str(eachPar)]);
    end
end

end
