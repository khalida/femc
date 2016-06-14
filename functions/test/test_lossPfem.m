%% Test lossPfem by doing some simple numerical examples:
% Not an exhaustive unit test, but better than nothing
clearvars;
tTest1 = ones(10,1);
yTest1 = ones(10,1);
parameters = [1, 1, 1, 0];

%% TEST 1
pfem1 = lossPfem(tTest1, yTest1, parameters);
expectedResult1 = 0;
pass1 = isequal(pfem1, expectedResult1);

%% TEST 2
tTest2 = ones(10,1);
yTest2 = (1:10)';
pfem2 = lossPfem(tTest2, yTest2, parameters);
expectedResult2 = mean(yTest2-tTest2);
pass2 = isequal(pfem2, expectedResult2);

%% TEST 3
tTest3 = ones(10,1);
yTest3 = (1:10)';
alphaValue = 2;
parameters(1) = alphaValue;      % Inrease the cost of under-forecasts
pfem3 = lossPfem(tTest3, yTest3, parameters);
expectedResult3 = (alphaValue*mean(yTest2-tTest1) + ...
    mean(tTest3-yTest3))/((1+alphaValue)/2);
pass3 = isequal(pfem3, expectedResult3);

%% TEST 4
tTest4 = ones(10,1);
yTest4 = (1:10)';
betaValue = 2;
parameters([1, 2]) = [1, betaValue];
pfem4 = lossPfem(tTest4, yTest4, parameters);
expectedResult4 = sqrt(lossMse(tTest4, yTest4));
pass4 = isequal(pfem4, expectedResult4);

%% TEST 5
tTest5 = ones(10,1);
yTest5 = (1:10)';
gammaValue = 2;
parameters([2, 3]) = [1, gammaValue];
pfem5 = lossPfem(tTest5, yTest5, parameters);
weights = linspace(gammaValue, 1, 10);
weights = weights./(mean(weights)); % so weigths average to 1.0
expectedResult5 = mean((yTest5-tTest5).*weights');
pass5 = isequal(pfem5, expectedResult5);

%% TEST 6
yTest6 = [ones(3,1); 10; ones(6,1)];
tTest6 = [ones(4,1); 10; ones(5,1)];
deltaValue = 1;
parameters([3, 4]) = [1, deltaValue];
pfem6 = lossPfem(tTest6, yTest6, parameters);
expectedResult6 = 0;
pass6 = isequal(pfem6, expectedResult6);

%% TEST 7; combination of first two tests
yTest = [yTest1, yTest2];
tTest = [tTest1, tTest2];
parameters = [1, 1, 1, 0];
pfemAll = lossPfem(tTest, yTest, parameters);
expectedAll = [expectedResult1, expectedResult2];
pass7 = isequal(expectedAll, pfemAll);

%% SUMMARY:
if pass1 && pass2 && pass3 && pass4 && pass5 && pass6 && pass7
    disp('test_lossPfem test PASSED!');
else
    error('lossPfem test FAILED');
end
