%% Plot mean peak reductions for various numbers of customers

figure(201);
meanPeakReductions = ...    % nMethods X numCustomers
    squeeze(mean(allPeakReductions, 2));
stdPeakReductions = ...
    squeeze(std(allPeakReductions,[],2));
mean_kWhs = mean(all_kWhs, 1); % 1 x nCustomers
errorbar(repmat(mean_kWhs, [nMethods, 1])', meanPeakReductions', ...
    stdPeakReductions'./2, '.-', 'markers', 20);
xlabel('Mean Load [kWh/time-step]');
ylabel('Mean PRR, with +/- 0.5 std. dev.');
legend(methodStrings, 'interpreter', 'None');
grid on;
hold off;

% Compute allPeakReductions relative to godCast:
refIndex =find(ismember(methodStrings,'godCast'));
allPeakReductions_rel = allPeakReductions./...
    repmat(allPeakReductions(refIndex, :, :), [nMethods 1 1]);

figure(202);
meanPeakReductions_rel = ...    % nMethods X numCustomers
    squeeze(mean(allPeakReductions_rel, 2));
stdPeakReductions_rel = ...
    squeeze(std(allPeakReductions_rel,[],2));
mean_kWhs = mean(all_kWhs, 1); % 1 x nCustomers
errorbar(repmat(mean_kWhs, [nMethods, 1])', meanPeakReductions_rel', ...
    stdPeakReductions_rel'./2, '.-', 'markers', 20);
xlabel('Mean Load [kWh/time-step]');
ylabel('Relative Mean PRR, with +/- 0.5 std. dev.');
legend(methodStrings, 'interpreter', 'None');
grid on;
hold off;

% Plot performance of the fcasts for each error metric
figure(901);
allLossTestResults_meanOverTrials = squeeze(mean(allLossTestResults, 2));
allLossTestResults_stdOverTrials = squeeze(std(allLossTestResults, [], 2));

for eachError = 1:length(lossTypes)
    subplot(2, ceil(length(lossTypes)/2), eachError);
    errorbar(repmat(mean_kWhs, [nMethods, 1])', ...
        squeeze(allLossTestResults_meanOverTrials(:, :, ...
        eachError))', squeeze(allLossTestResults_stdOverTrials(...
        :, :, eachError))','.-', 'markers', 20);
    
    grid on;
    legend(methodStrings, 'interpreter', 'none');
    xlabel('Mean Load [kWh/time-step]');
    ylabel('Forecast Error Metric +/- 1 std. dev.');
    title(methodStrings{eachError}, 'interpreter', 'none');
end
