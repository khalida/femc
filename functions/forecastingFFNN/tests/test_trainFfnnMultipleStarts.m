% Test using a simple sinusoidal prediction problem, and confirm
% performance is improved by running multiple models

trainControl.suppressOutput = false;
trainControl.nHidden = 10;
trainControl.mseEpochs = 1000;
trainControl.minimiseOverFirst = 1;
trainControl.maxTime = 1;
trainControl.maxEpochs = 1;

trainControl.horizon = 10;
trainControl.nLags = 10;
trainControl.trainRatio = 0.9;
trainControl.performanceDifferenceThreshold = 0.001;

testMultiplier = 5;

% Produce sinusoidal series to learn from:
timeIndexesTrain = linspace(0, 2*pi*testMultiplier,...
    trainControl.horizon*testMultiplier);
exampleTimeSeries = sin(timeIndexesTrain);

lossType = @lossMse;

trainControl.nStart = 1;
outputNetSingle = trainFfnnMultipleStarts( exampleTimeSeries, lossType,...
    trainControl);

trainControl.nStart = 100;
outputNetMultiple = trainFfnnMultipleStarts( exampleTimeSeries, lossType,...
    trainControl );

testInput = exampleTimeSeries((end-trainControl.nLags+1):end)';
testOutput = testInput;

netSingleResponse = outputNetSingle(testInput);
netMultipleResponse = outputNetMultiple(testInput);

testPassed = max(abs(netMultipleResponse-testOutput)) < ...
    max(abs(netSingleResponse-testOutput));

if testPassed
    disp('trainFfnnMultipleStarts test PASSED!');
else
    error('trainFfnnMultipleStarts test FAILED!');
end
