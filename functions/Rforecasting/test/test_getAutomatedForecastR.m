%% Test basic functionality of using the Automated R forecasts from MATLAB

interval = pi/20;
period = (2*pi)/interval;
nPeriodsTrain = 200;
noiseMultiplier = 2;

trainTimes = 0:interval:(nPeriodsTrain*2*pi);
trainIdxs = 1:(length(trainTimes));
plotTrainIdxs = trainIdxs((end-3*period):end);

testTimes = (nPeriodsTrain*2*pi) + ...
    (interval:interval:(2*pi));
testIdxs = max(trainIdxs) + (1:length(testTimes));
plotTestIdxs = max(plotTrainIdxs)+(1:length(testIdxs));

historicData = sin(trainTimes);
historicData = historicData + ...
    (rand(size(historicData))-0.5)*noiseMultiplier;

trainControl.seasonality = (2*pi)/interval;
trainControl.horizon = trainControl.seasonality;
trainControl.minimiseOverFirst = trainControl.seasonality;

[forecastEts] = getAutomatedForecastR(...
    historicData, trainControl);

fig_1 = figure(1);
plot(plotTrainIdxs, historicData(plotTrainIdxs), 'k', ...
    plotTestIdxs, forecastEts, 'g', ...
    plotTestIdxs, sin(testTimes), 'b');

legend('train data', 'R ETS', 'actual test');

print(fig_1, '-dpdf', 'test_singleForecast.pdf');

%% Check that function works in parrallel (i.e. no file collisions)
nParrallel = 4;
historicData = repmat(sin(trainTimes), [nParrallel, 1]);
historicData = historicData + ...
    (rand(size(historicData))-0.5)*noiseMultiplier;

allForecastsEts = zeros(nParrallel, length(testIdxs));
parfor iParrallel = 1:nParrallel
    [allForecastsEts(iParrallel, :)] = getAutomatedForecastR(...
        historicData(iParrallel, :), trainControl);
end

fig_2 = figure(2);
for iParrallel = 1:nParrallel
    
    subplot(2,2,iParrallel);
    
    plot(plotTrainIdxs, historicData(iParrallel, plotTrainIdxs), 'k', ...
        plotTestIdxs, allForecastsEts(iParrallel, :), 'g', ...
        plotTestIdxs, sin(testTimes), 'b');
    
    legend('train data', 'R ETS', 'actual test');
    
end

print(fig_2, '-dpdf', 'test_multipleForecast.pdf');
