%% Test basic functionality of using the Automated R forecasts from MATLAB

interval = pi/20;
nPeriodsTrain = 3;
noiseMultiplier = 2;

trainTimes = 0:interval:(nPeriodsTrain*2*pi);
trainIdxs = 1:length(trainTimes);

testTimes = (nPeriodsTrain*2*pi) + ...
    (interval:interval:(2*pi));
testIdxs = max(trainIdxs) + (1:length(testTimes));

historicData = sin(trainTimes);
historicData = historicData + ...
    (rand(size(historicData))-0.5)*noiseMultiplier;

trainControl.k = (2*pi)/interval;
trainControl.horizon = trainControl.k;
forecast = getAutomatedForecastR(historicData, trainControl);

figure(1);
plot(trainIdxs, historicData, 'k', ...
    testIdxs, forecast, 'r', ...
    testIdxs, sin(testTimes));


%% Check that function works in parrallel (i.e. no file collisions)
nParrallel = 4;
historicData = repmat(sin(trainTimes), [nParrallel, 1]);
historicData = historicData + ...
    (rand(size(historicData))-0.5)*noiseMultiplier;
allForecasts = zeros(nParrallel, length(testIdxs));
parfor iParrallel = 1:nParrallel
    allForecasts(iParrallel, :) = ...
        getAutomatedForecastR(historicData(iParrallel, :), trainControl);
end

figure(2);
for iParrallel = 1:nParrallel
   subplot(2,2,iParrallel);
   plot(trainIdxs, historicData(iParrallel, :), 'k', ...
    testIdxs, allForecasts(iParrallel, :), 'r', ...
    testIdxs, sin(testTimes));
end
