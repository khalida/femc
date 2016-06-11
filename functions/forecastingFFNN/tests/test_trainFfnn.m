% Test using a simple (XOR) logical function, and confirm adequate
% performance:
clearvars;

trainControl.suppressOutput = false;
trainControl.nHidden = 10;
trainControl.mseEpochs = 1000;
trainControl.minimiseOverFirst = 1;
trainControl.maxTime = 5;
trainControl.maxEpochs = 200;

% Produce example feature vector and response vectors:
featureVectorTrain = randi([0,1], [100, 2])';
responseVectorTrain = xor(featureVectorTrain(1, :), ...
    featureVectorTrain(2, :));

lossType = @lossMse;

outputNet = trainFfnn( featureVectorTrain, responseVectorTrain,...
    lossType, trainControl);

testInput = [0 0 1 1;
             0 1 0 1];
         
testOutput = [0 1 1 0];

testOutput_response = outputNet(testInput);

testPassed = max(abs(testOutput_response-testOutput)) < 1e-4;

if testPassed
    disp('test_trainFfnn test PASSED!');
else
    error('test_trainFfnn test FAILED!');
end
