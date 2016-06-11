%% Check that it works for a simple forecasting problem

% Running options:
periodLength = 48;
samplingInterval = (2*pi)/periodLength;
nPeriods = 200;
trainRatio = 0.75;
noiseMultiplier = 0.5;

% Prepare data:
timeSamples = (0:samplingInterval:(2*pi*nPeriods))';
nSamples = length(timeSamples);
nTrainIdxs = floor(trainRatio*nSamples);
trainIdxs = 1:nTrainIdxs;
testIdxs = (nTrainIdxs+1):nSamples;

dataValues = sin(timeSamples) + 1.5 + ...
    randn(size(timeSamples)).*noiseMultiplier;

trainValues = dataValues(trainIdxs);
testValues = dataValues(testIdxs);

[trainFeatureVectors, trainResponseVectors] = ...
    computeFeatureResponseVectors(trainValues,periodLength,periodLength);

cfg.fc.suppressOutput = false;
cfg.fc.nHidden = 20;
cfg.fc.mseEpochs = 1000;
cfg.fc.minimiseOverFirst = periodLength;
cfg.fc.maxTime = 5;
cfg.fc.maxEpochs = 1000;

%% Test 1: mse-minimising forecast:
net = trainFfnn( trainFeatureVectors, trainResponseVectors, @lossMse, ...
    cfg.fc);
disp('MSE net train stop: ');disp(net.userdata.trainStop);
testResponses = forecastFfnn(cfg, net, trainValues);

mse_mse = lossMse(testValues(1:periodLength, :), testResponses);
mse_mape = lossMape(testValues(1:periodLength, :), testResponses);
mse_meanMseError = mean(mse_mse);
mse_meanMapeError = mean(mse_mape);
figure();
plot([testValues(1:periodLength,:), testResponses, ...
    sin(timeSamples(testIdxs(1:periodLength))) + 1.5]);
legend('test values', 'test prediction (mse-min)', 'test without noise');

testPassed = mse_meanMseError < noiseMultiplier;

if testPassed
    disp('test_forecastFfnn test 1 PASSED!');
else
    error('test_forecastFfnn test 1 FAILED!');
end

%% Test 2: Check that forecasts do well on metric they minimize
cfg.fc.mseEpochs = 1000;
cfg.fc.maxEpochs = 1000;
net = trainFfnn( trainFeatureVectors, trainResponseVectors, @lossMape, ...
    cfg.fc);

disp('MAPE net train stop: ');disp(net.userdata.trainStop);
testResponses = forecastFfnn(cfg, net, trainValues);

mape_mse = lossMse(testValues(1:periodLength, :), testResponses);
mape_mape = lossMape(testValues(1:periodLength, :), testResponses);
mape_meanMseError = mean(mape_mse);
mape_meanMapeError = mean(mape_mape);
figure();
plot([testValues(1:periodLength,:), testResponses, ...
    sin(timeSamples(testIdxs(1:periodLength))) + 1.5]);

legend('test values', 'test prediction (mape-min)', 'test without noise');

testPassedMse = mse_mse < mape_mse;
testPassedMape = mape_mape < mse_mape;

if testPassedMse && testPassedMape
    disp('test_forecastFfnn test 2 PASSED!');
else
    error('test_forecastFfnn test 2 FAILED!');
end

close all;
