function [significance] = plotResultsStoch( Sim, results)

%PLOTRESULTSSTOCK Plot outputs from 'trainBestFcasts' and 'testBestFcasts'
%   functions.

%% Expand fields (of data structures)
resultsFields = fieldnames(results);
for ii = 1:length(resultsFields)
    eval([resultsFields{ii} ' = results.' resultsFields{ii} ';']);
end

simFields = fieldnames(Sim);
for ii = 1:length(simFields)
    eval([simFields{ii} ' = Sim.' simFields{ii} ';']);
end

% Reference method is still godCast - but no longer at end of matrix
refMethod = find(ismember(lossTypesStrings,'godCast'));
peakReductions_rel = peakReductions./repmat(...
    peakReductions(refMethod, :, :), [nMethods, 1, 1]);

peakReductions_rel_ = reshape(peakReductions_rel,...
    [nMethods, length(numCustomers)*numAggregates]);

%% Plotting

% Plot mean peak reduction ratio for given number of customers
fig_201 = figure(201);
selectedFcs = 1:nMethods;
selectedFcLabels = lossTypesStrings(selectedFcs);
meanPeakReductions = ...    % nCustomers X fcTypes
    squeeze(mean(peakReductions(selectedFcs, :, :), 2));

stdPeakReductions = ...
    squeeze(std(peakReductions(selectedFcs, :, :),[], 2));

mean_kWhs = mean(all_kWhs, 1); % nCustomers X 1

errorbar(repmat(mean_kWhs, [length(selectedFcs), 1])', ...
    meanPeakReductions',stdPeakReductions'./2,'.-', 'markers', 20);

xlabel('Mean Load [kWh/time-step]');
ylabel('Mean PRR, with +/- 0.5 std. dev.');
legend(selectedFcLabels, 'interpreter', 'none',...
 'Location', 'northoutside', 'Orientation', 'vertical');
grid on;
hold off;

print(fig_201, '-dpdf', 'abs_PRR_VS_aggregation_size.pdf');

% Plot mean rel. peak reduction ratio for given number of customers
fig_202 = figure(202);
meanPeakReductions_rel = ...    % nCustomers X fcTypes
    squeeze(mean(peakReductions_rel(selectedFcs, :, :), 2));

stdPeakReductions_rel = ...
    squeeze(std(peakReductions_rel(selectedFcs, :, :),[], 2));

errorbar(repmat(mean_kWhs, [length(selectedFcs), 1])', ...
    meanPeakReductions_rel',stdPeakReductions_rel'./2,'.-', 'markers', 20);

xlabel('Mean Load [kWh/time-step]');
ylabel('Mean relative PRR, with +/- 0.5 std. dev.');
legend(selectedFcLabels, 'interpreter', 'none',...
 'Location', 'northoutside', 'Orientation', 'vertical');
grid on;
hold off;
print(fig_202, '-dpdf', 'rel_PRR_VS_aggregation_size.pdf');


% Plot the distribution of abs peak reduction ratios for each fcast
fig_401 = figure(401);
subplot(1, 2, 1);
peakReductions_flat = squeeze(peakReductions_(selectedFcs, :));
boxplot(peakReductions_flat', 'labels', selectedFcLabels, 'plotstyle',...
    'compact');
ylabel('Mean PRR []');
grid on;

% Plot the distribution of rel peak reduction ratios for each fcast
subplot(1, 2, 2);
peakReductions_rel_flat = squeeze(peakReductions_rel_(selectedFcs, :));
boxplot(peakReductions_rel_flat', 'labels', selectedFcLabels,...
    'plotstyle', 'compact');
ylabel('Mean PRR relative to perfect forecast');
grid on;
print(fig_401, '-dpdf', 'all_PRR_results_box_plot.pdf');

% Plot performance of the fcasts for each error metric
fig_901 = figure(901);
lossTestResults_meanOverTrials = squeeze(mean(lossTestResults, 2));
lossTestResults_stdOverTrials = squeeze(std(lossTestResults, [], 2));

for eachErrorIdx = 1:length(lossTypes)

    subplot(2, ceil(length(lossTypes)/2), eachErrorIdx);
    subplot(2, ceil(length(lossTypes)/2), eachErrorIdx);
    
    errorbar(repmat(mean_kWhs, [length(selectedFcs), 1])', ...
        squeeze(lossTestResults_meanOverTrials(selectedFcs, :, ...
        eachErrorIdx))', squeeze(lossTestResults_stdOverTrials(...
        selectedFcs, :, eachErrorIdx))','.-', 'markers', 20);
    
    grid on;
    legend(selectedFcLabels, 'interpreter', 'none',...
     'Location', 'northoutside', 'Orientation', 'vertical');
    xlabel('Mean Load [kWh/time-step]');
    ylabel('Forecast Error Metric +/- 1 std. dev.');
    
    tmp_lossTypesString = func2str(lossTypes{eachErrorIdx});
    title(tmp_lossTypesString, 'interpreter', 'none');
end

print(fig_901, '-dpdf', 'all_forecast_performances.pdf');

%% Compute tests for Statistical Significance between Results
% Overall statistical significance
nSelMethods = length(selectedFcs);
overallSignificance = ones(nSelMethods-1, nSelMethods-1).*NaN;
for firstMethod = 1:(nSelMethods-1)
    for secondMethod = (firstMethod+1):nSelMethods
        firstMethod_results = squeeze(peakReductions_rel(...
            selectedFcs(firstMethod), :, :));
        firstMethod_results = firstMethod_results(:);
        
        secondMethod_results = squeeze(peakReductions_rel(...
            selectedFcs(secondMethod), :, :));
        secondMethod_results = secondMethod_results(:);
        
        [overallSignificance(firstMethod, secondMethod), ~] = ...
            ttest2(firstMethod_results, secondMethod_results);
    end
end
overallSig_ds = dataset({overallSignificance selectedFcLabels{1:end}}, ...
    'obsnames', selectedFcLabels(1:(end-1)));
disp(overallSig_ds);
significance.overall = overallSig_ds;

% For a particular level of agregation
eachLevelSignificance = cell(length(numCustomers), 1);
eachLevelSig_ds = cell(length(numCustomers), 1);
for aggLevel = 1:length(numCustomers)
    eachLevelSignificance{aggLevel} = ...
        ones(nSelMethods-1, nSelMethods-1).*NaN;
    for firstMethod = 1:(nSelMethods-1)
        for secondMethod = (firstMethod+1):nSelMethods
            firstMethod_results = squeeze(peakReductions_rel(...
                selectedFcs(firstMethod), :, aggLevel));
            secondMethod_results = squeeze(peakReductions_rel(...
                selectedFcs(secondMethod), :, aggLevel));
            
            [eachLevelSignificance{aggLevel}(firstMethod, secondMethod),...
                ~] = ttest2(firstMethod_results, secondMethod_results);
        end
    end
    eachLevelSig_ds{aggLevel} = ...
        dataset({eachLevelSignificance{aggLevel}...
        selectedFcLabels{1:end}}, 'obsnames', selectedFcLabels(1:(end-1)));
    disp([num2str(numCustomers(aggLevel)) ' Customers:']);
    disp(eachLevelSig_ds{aggLevel});
end
significance.eachLevel = eachLevelSig_ds;

end
