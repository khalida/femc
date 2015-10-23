%% Load Data
load('..\..\models\runOnEdward\MPC_results_loss_and_EMD_par_2015_10_16_withCD_10pc_batt_withSP');
nTrainMethods = length(lossTypes);

%% Plotting
% Plot all peak reduction ratios VS aggregation size
figure(1);
subplot(1, 2, 1);
plot(all_kWhs(:), allPeakReductions_', '.', 'markers', 20)
hold on
% Plot warning circles about optimality
warnPeakReductions = allPeakReductions(smallestExitFlag < 1);
nMethods = size(allPeakReductions, 1);
extended_kWhs = repmat(all_kWhs, [1, 1, nMethods]);
warn_kWhs = extended_kWhs(smallestExitFlag < 1);
if (isempty(warn_kWhs))
    warn_kWhs = -1;
    warnPeakReductions = -1;
end
plot(warn_kWhs, warnPeakReductions, 'ro', 'markers', 20);
xlabel('Mean Load [kWh/time-step]');
ylabel(['Mean PRR, ' num2str(num_days_train) '-day train, '...
    num2str(num_days_test) '-day test']);
legend(lossTypesStrings{:}, 'Some time-steps not solved to optimality');
hold off;

% Plot of all relative peak reduction ratios VS aggregation size
subplot(1, 2, 2);
% NB: reference method is still godCast - but no longer at end of matrix

refMethod = find(ismember(lossTypesStrings,'godCast'));
allPeakReductions_rel = allPeakReductions./repmat(...
    allPeakReductions(refMethod, :, :), [nMethods, 1, 1]);

allPeakReductions_rel_ = reshape(allPeakReductions_rel,...
    [nMethods, length(numCustomers)*numAggregates]);

plot(all_kWhs(:), allPeakReductions_rel_', '.', 'markers', 20)
hold on
% Plot warning circles about optimality
warnPeakReductions = allPeakReductions_rel_(smallestExitFlag < 1);
extended_kWhs = repmat(all_kWhs, [1, 1, nMethods]);
warn_kWhs = extended_kWhs(smallestExitFlag < 1);
if (isempty(warn_kWhs))
    warn_kWhs = 0;
    warnPeakReductions = 0;
end
plot(warn_kWhs, warnPeakReductions, 'ro', 'markers', 20);
xlabel('Mean Load [kWh/time-step]');
ylabel(['Mean PRR relative to perfect forecast, ' num2str(num_days_train)...
    '-day train, ' num2str(num_days_test) '-day test']);
legend(lossTypesStrings{:}, 'Some time-steps not solved to optimality');
hold off;

% Plot mean peak reduction ratio for given number of customers
figure(201);
%subplot(1, 2, 1);
selectedFcs = setdiff(1:nMethods, [parRange, EMDRange]);
selectedFcLabels = lossTypesStrings(selectedFcs);
meanPeakReductions = ...    % nCustomers X fcTypes
    squeeze(mean(allPeakReductions(selectedFcs, :, :), 2));
stdPeakReductions = ...
    squeeze(std(allPeakReductions(selectedFcs, :, :),[], 2));
mean_kWhs = mean(all_kWhs, 1); % nCustomers X 1
errorbar(repmat(mean_kWhs, [length(selectedFcs), 1])', ...
    meanPeakReductions',stdPeakReductions'./2,'.-', 'markers', 20);
xlabel('Mean Load [kWh/time-step]');
ylabel('Mean PRR, with +/- 0.5 std. dev.');
legend(selectedFcLabels, 'interpreter', 'none');
grid on;
hold off;

% Plot mean rel. peak reduction ratio for given number of customers
figure(202);
% subplot(1, 2, 2);
meanPeakReductions_rel = ...    % nCustomers X fcTypes
    squeeze(mean(allPeakReductions_rel(selectedFcs, :, :), 2));
stdPeakReductions_rel = ...
    squeeze(std(allPeakReductions_rel(selectedFcs, :, :),[], 2));
errorbar(repmat(mean_kWhs, [length(selectedFcs), 1])', ...
    meanPeakReductions_rel',stdPeakReductions_rel'./2,'.-', 'markers', 20);
xlabel('Mean Load [kWh/time-step]');
ylabel('Mean relative PRR, with +/- 0.5 std. dev.');
legend(selectedFcLabels, 'interpreter', 'none');
grid on;
hold off;

% Plot the distribution of abs peak reduction ratios for each fcast
figure(401);
subplot(1, 2, 1);
allPeakReductions_flat = squeeze(allPeakReductions_(selectedFcs, :));
boxplot(allPeakReductions_flat', 'labels', selectedFcLabels);
ylabel('Mean PRR []');
grid on;

% Plot the distribution of rel peak reduction ratios for each fcast
subplot(1, 2, 2);
allPeakReductions_rel_flat = ...
    squeeze(allPeakReductions_rel_(selectedFcs, :));
boxplot(allPeakReductions_rel_flat', 'labels', selectedFcLabels);
ylabel('Mean PRR relative to perfect forecast');
grid on;

% Plot performance of the fcasts for each error metric
figure(901);
allLossTestResults_meanOverTrials = squeeze(mean(allLossTestResults, 2));
allLossTestResults_stdOverTrials = squeeze(std(allLossTestResults, [], 2));
for eachErrorIdx = 1:nTrainMethods
    thisSelectedFcs = unique([selectedFcs, eachErrorIdx]);
    thisSelectedFcsString = lossTypesStrings(thisSelectedFcs);
    subplot(2, ceil(nTrainMethods/2), eachErrorIdx);
    errorbar(repmat(mean_kWhs, [length(thisSelectedFcs), 1])', ...
        squeeze(allLossTestResults_meanOverTrials(thisSelectedFcs, :, ...
        eachErrorIdx))', squeeze(allLossTestResults_stdOverTrials(...
        thisSelectedFcs, :, eachErrorIdx))','.-', 'markers', 20);
    
    grid on;
    legend(thisSelectedFcsString, 'interpreter', 'none');
    xlabel('Mean Load [kWh/time-step]');
    ylabel('Forecast Error Metric +/- 1 std. dev.');
    title(lossTypesStrings{eachErrorIdx}, 'interpreter', 'none');
end


%% Compute tests for Statistical Significance between Results
% Overall statistical significance
nSelMethods = length(selectedFcs);
overallSignificance = ones(nSelMethods-1, nSelMethods-1).*NaN;
for firstMethod = 1:(nSelMethods-1)
    for secondMethod = (firstMethod+1):nSelMethods
        firstMethod_results = squeeze(allPeakReductions_rel(...
            selectedFcs(firstMethod), :, :));
        firstMethod_results = firstMethod_results(:);
        
        secondMethod_results = squeeze(allPeakReductions_rel(...
            selectedFcs(secondMethod), :, :));
        secondMethod_results = secondMethod_results(:);
        
        [overallSignificance(firstMethod, secondMethod), ~] = ...
            ttest2(firstMethod_results, secondMethod_results);
    end
end
overallSig_ds = dataset({overallSignificance selectedFcLabels{1:end}}, ...
    'obsnames', selectedFcLabels(1:(end-1)));
disp(overallSig_ds);

% For a particular level of agregation
eachLevelSignificance = cell(length(numCustomers), 1);
eachLevelSig_ds = cell(length(numCustomers), 1);
for aggLevel = 1:length(numCustomers)
    eachLevelSignificance{aggLevel} = ...
        ones(nSelMethods-1, nSelMethods-1).*NaN;
    for firstMethod = 1:(nSelMethods-1)
        for secondMethod = (firstMethod+1):nSelMethods
            firstMethod_results = squeeze(allPeakReductions_rel(...
                selectedFcs(firstMethod), :, aggLevel));
            secondMethod_results = squeeze(allPeakReductions_rel(...
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