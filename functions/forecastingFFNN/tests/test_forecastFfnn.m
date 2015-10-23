%% Check that it works for an existing net:

load('test_data.mat');
testDemandSeries = (1:100)';
outputs = forecastFfnn( net, testDemandSeries, false );

fcBasic = net(((100-47):100)');

testPassed = isequal(fcBasic, outputs);

if testPassed
    disp('forecastFfnn test PASSED!');
else
    error('forecastFfnn test FAILED!');
end
