%% Test lossEmd by doing some simple numerical examples:
% Not an exhaustive unit test, but better than nothing
clearvars;

%% Allowable relative error:
relTol = 1e-5;

%% TEST 1
tTest1 = ones(7,1);
yTest1 = ones(7,1);
emd1 = lossEmd(tTest1, yTest1);
expectedResult1 = 0;
pass1 = closeEnough(expectedResult1, emd1, relTol*expectedResult1);


%% TEST 2
tTest2 = zeros(7,1) + 10;
yTest2 = (-3:3)' + 10;
emd2 = lossEmd(tTest2, yTest2);
expectedResult2 = 1*2 + 2*4 + 3*6;
pass2 = closeEnough(expectedResult2, emd2, relTol*expectedResult2);

%% SUMMARY:
if pass1 && pass2
    disp('test_lossEmd individual tests PASSED!');
else
    error('test_lossEmd individual tests FAILED');
end

% Check that can be used to get multiple instances at same time:
allTtest = [tTest1, tTest2];
allYtest = [yTest1, yTest2];
allEmds = lossEmd(allTtest, allYtest);

allExpectedValues = [expectedResult1, expectedResult2];

testsPassed = closeEnough(allExpectedValues, allEmds, ...
    relTol.*allExpectedValues);

if sum(testsPassed) == length(testsPassed)
    disp('test_lossEmd test PASSED!');
else
    error('test_lossEmd test FAILED');
end
