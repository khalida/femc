%% Check that it works for a simple forecasting problem

% Running options:
samplingInterval = (2*pi)/20;
nPeriods = 100;
trainRatio = 0.75;
noiseMultiplier = 0.25;

% Prepare data:
timeSamples = (0:samplingInterval:(2*pi*nPeriods))';
periodLength = (2*pi)/samplingInterval;
nSamples = length(timeSamples);
nTrainIdxs = floor(trainRatio*nSamples);
trainIdxs = 1:nTrainIdxs;
testIdxs = (nTrainIdxs+1):nSamples;

dataValues = sin(timeSamples) + randn(size(timeSamples)).*noiseMultiplier;
trainValues = dataValues(trainIdxs);
testValues = dataValues(testIdxs);

[trainFeatureVectors, trainResponseVectors] = ...
    computeFeatureResponseVectors(trainValues,periodLength,periodLength);

cfg.fc.suppressOutput = false;
cfg.fc.nHidden = 10;
cfg.fc.mseEpochs = 1000;
cfg.fc.minimiseOverFirst = 1;
cfg.fc.maxTime = 5;
cfg.fc.maxEpochs = 200;

net = trainFfnn( trainFeatureVectors, trainResponseVectors, @lossMse, ...
    cfg.fc);

testResponses = forecastFfnn(cfg, net, trainValues);

mseError = lossMse(testValues(1:periodLength, :), testResponses);
meanMseError = mean(mseError);
figure();
plot([testValues(1:periodLength,:), testResponses, ...
    sin(timeSamples(testIdxs(1:periodLength)))]);
legend('test values', 'test prediction', 'test without noise');

testPassed = meanMseError < noiseMultiplier;

if testPassed
    disp('forecastFfnn test PASSED!');
else
    error('forecastFfnn test FAILED!');
end
