%% Check that it works for an existing net:

load('test_data.mat');
testDemandSeries = (1:100)';
trainControl.suppressOutput = false;

outputs = forecastFfnn( net, testDemandSeries, trainControl );

fcBasic = net(((100-47):100)');

testPassed = isequal(fcBasic, outputs);

if testPassed
    disp('forecastFfnn test PASSED!');
else
    error('forecastFfnn test FAILED!');
end
