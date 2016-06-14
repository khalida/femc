%% Single Unit test using a simple example (not exhaustive)
clearvars;

timeSeries = 1:10;
nLags = 4;
horizon = 3;
[ featureVectors, responseVectors ] = ...
    computeFeatureResponseVectors( timeSeries, nLags, horizon);

isFeatureVectorCorrect = isequal(featureVectors,...
    [1, 2, 3, 4;
    2, 3, 4, 5;
    3, 4, 5, 6;
    4, 5, 6, 7]');

isResponseVectorCorrect = isequal(responseVectors,...
    [5, 6, 7;
    6, 7, 8;
    7, 8, 9;
    8, 9, 10]');

if isFeatureVectorCorrect && isResponseVectorCorrect
    disp('test_computeFetureResponseVectors PASSED!');
else
    error('test_computeFetureResponseVectors FAILED');
end
