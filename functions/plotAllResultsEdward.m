function [significance] = plotAllResultsEdward( Sim, results, EMD, PFEM)

%PLOT ALL RESULTS Plot outputs from 'trainAllFcasts' and 'testAllFcasts'
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

%% Plotting
% Plot all peak reduction ratios VS aggregation size

myPaperPosition = [0 0 6 4];
myPaperSize = [6 4];
myGcaPosition = [0 0 0.8 0.8];
doSetGCA = false;
smallerFontSize = 8;
smallerMarkerSize = 10;
if isfield(Sim, 'visiblePlots')
    isVisible = Sim.visiblePlots;
else
    isVisible = 'off';
end

fig_001 = figure('Visible', isVisible, 'PaperPosition', myPaperPosition, 'PaperSize', myPaperSize);

subplot(1, 2, 1);
plot(all_kWhs(:), peakReductions_', '.', 'markers', 20)
hold on
% Plot warning circles about optimality
warnPeakReductions = peakReductions_(smallestExitFlag < 1);
extended_kWhs = repmat(all_kWhs(:)', [nMethods, 1]);
warn_kWhs = extended_kWhs(smallestExitFlag < 1);
if (isempty(warn_kWhs))
    warn_kWhs = -1;
    warnPeakReductions = -1;
end
plot(warn_kWhs, warnPeakReductions, 'ro', 'markers', 20);
xlabel('Mean Load [kWh/time-step]');
ylabel(['Mean PRR, ' num2str(num_days_train) '-day train, '...
    num2str(num_days_test) '-day test']);
legend(lossTypesStrings{:}, 'Some time-steps not solved to optimality',...
 'Location', 'northoutside', 'Orientation', 'vertical');
hold off;

% Plot of all relative peak reduction ratios VS aggregation size
subplot(1, 2, 2);

% Reference method is still godCast - but no longer at end of matrix
refMethod = find(ismember(lossTypesStrings,'godCast'));
peakReductions_rel = peakReductions./repmat(...
    peakReductions(refMethod, :, :), [nMethods, 1, 1]);

peakReductions_rel_ = reshape(peakReductions_rel,...
    [nMethods, length(numCustomers)*numAggregates]);

plot(all_kWhs(:), peakReductions_rel_', '.', 'markers', 20)
hold on
% Plot warning circles about optimality
warnPeakReductions = peakReductions_rel_(smallestExitFlag < 1);
extended_kWhs = repmat(all_kWhs(:)', [nMethods, 1]);
warn_kWhs = extended_kWhs(smallestExitFlag < 1);
if (isempty(warn_kWhs))
    warn_kWhs = -1;
    warnPeakReductions = -1;
end
plot(warn_kWhs, warnPeakReductions, 'ro', 'markers', 20);
xlabel('Mean Load [kWh/time-step]');
ylabel(['Mean PRR relative to perfect forecast, ' num2str(num_days_train)...
    '-day train, ' num2str(num_days_test) '-day test']);
legend(lossTypesStrings{:}, 'Some time-steps not solved to optimality',...
 'Location', 'northoutside', 'Orientation', 'vertical');
hold off;

if doSetGCA
	set(gca, 'Position', myGcaPosition);
end
set(findall(fig_001,'-property','FontSize'),'FontSize',smallerFontSize);
set(findall(fig_001,'-property','MarkerSize'),'MarkerSize',smallerMarkerSize);

print(fig_001, '-dpdf', 'all_PRR_results.pdf');
if ~strcmp(isVisible, 'on')
    close(fig_001);
end


fig_201 = figure('Visible', isVisible, 'PaperPosition', myPaperPosition, 'PaperSize', myPaperSize);

% Plot mean peak reduction ratio for given number of customers
selectedFcs = setdiff(1:nMethods, [PFEM.range, EMD.range]);
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
if doSetGCA
	set(gca, 'Position', myGcaPosition);
end
set(findall(fig_201,'-property','FontSize'),'FontSize',smallerFontSize);
set(findall(fig_201,'-property','MarkerSize'),'MarkerSize',smallerMarkerSize);

print(fig_201, '-dpdf', 'abs_PRR_VS_aggregation_size.pdf');

if ~strcmp(isVisible, 'on')
    close(fig_201);
end



fig_202 = figure('Visible', isVisible, 'PaperPosition', myPaperPosition, 'PaperSize', myPaperSize);

% Plot mean rel. peak reduction ratio for given number of customers
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

if doSetGCA
	set(gca, 'Position', myGcaPosition);
end
set(findall(fig_202,'-property','FontSize'),'FontSize',smallerFontSize);
set(findall(fig_202,'-property','MarkerSize'),'MarkerSize',smallerMarkerSize);

print(fig_202, '-dpdf', 'rel_PRR_VS_aggregation_size.pdf');

if ~strcmp(isVisible, 'on')
    close(fig_202);
end


fig_401 = figure('Visible', isVisible, 'PaperPosition', myPaperPosition, 'PaperSize', myPaperSize);

% Plot the distribution of abs peak reduction ratios for each fcast
subplot(1, 2, 1);
peakReductions_flat = squeeze(peakReductions_(selectedFcs, :));
boxplot(peakReductions_flat', 'labels', selectedFcLabels, 'plotstyle', 'compact');
ylabel('Mean PRR []');
grid on;

% Plot the distribution of rel peak reduction ratios for each fcast
subplot(1, 2, 2);
peakReductions_rel_flat = ...
    squeeze(peakReductions_rel_(selectedFcs, :));
boxplot(peakReductions_rel_flat', 'labels', selectedFcLabels, 'plotstyle', 'compact');
ylabel('Mean PRR relative to perfect forecast');
grid on;

if doSetGCA
	set(gca, 'Position', myGcaPosition);
end
% set(findall(fig_401,'-property','FontSize'),'FontSize',smallerFontSize);


print(fig_401, '-dpdf', 'all_PRR_results_box_plot.pdf');

if ~strcmp(isVisible, 'on')
    close(fig_401);
end


fig_901 = figure('Visible', isVisible, 'PaperPosition', myPaperPosition, 'PaperSize', myPaperSize);

% Plot performance of the fcasts for each error metric
lossTestResults_meanOverTrials = squeeze(mean(lossTestResults, 2));
lossTestResults_stdOverTrials = squeeze(std(lossTestResults, [], 2));
for eachErrorIdx = 1:nTrainMethods
    thisSelectedFcs = unique([selectedFcs, eachErrorIdx]);
    thisSelectedFcsString = lossTypesStrings(thisSelectedFcs);
    subplot(2, ceil(nTrainMethods/2), eachErrorIdx);
    errorbar(repmat(mean_kWhs, [length(thisSelectedFcs), 1])', ...
        squeeze(lossTestResults_meanOverTrials(thisSelectedFcs, :, ...
        eachErrorIdx))', squeeze(lossTestResults_stdOverTrials(...
        thisSelectedFcs, :, eachErrorIdx))','.-', 'markers', 20);
    
    grid on;
    legend(thisSelectedFcsString, 'interpreter', 'none',...
     'Location', 'northoutside', 'Orientation', 'vertical');
    xlabel('Mean Load [kWh/time-step]');
    ylabel('Forecast Error Metric +/- 1 std. dev.');
    title(lossTypesStrings{eachErrorIdx}, 'interpreter', 'none');
end

if doSetGCA
	set(gca, 'Position', myGcaPosition);
end
set(findall(fig_901,'-property','FontSize'),'FontSize',smallerFontSize);
set(findall(fig_901,'-property','MarkerSize'),'MarkerSize',smallerMarkerSize);


print(fig_901, '-dpdf', 'all_forecast_performances.pdf');

if ~strcmp(isVisible, 'on')
    close(fig_901);
end

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
