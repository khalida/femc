% Test using a simple (XOR) logical function, and confirm addequate
% performance:

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

lossType = @loss_mse;

outputNet = trainFfnn( featureVectorTrain, responseVectorTrain,...
    lossType, trainControl);

testInput = [0 0 1 1;
             0 1 0 1];
         
testOutput = [0 1 1 0];

testOutput_response = outputNet(testInput);

testPassed = max(abs(testOutput_response-testOutput)) < 1e-4;

if testPassed
    disp('trainFfnn test PASSED!');
else
    error('trainFfnn test FAILED!');
end
