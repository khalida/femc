%% Test lossPfem by doing some simple numerical examples:
% Not an exhaustive unit test, but better than nothing

tTest = ones(10,1);
yTest = ones(10,1);
parameters = [1, 1, 1, 0];

%% TEST 1
pfem1 = lossPfem(tTest, yTest, parameters);
expectedResult1 = 0;
pass1 = isequal(pfem1, expectedResult1);

yTest = (1:10)';

%% TEST 2
pfem2 = lossPfem(tTest, yTest, parameters);
expectedResult2 = mean(yTest-tTest);
pass2 = isequal(pfem2, expectedResult2);

%% TEST 3
alphaValue = 2;
parameters(1) = alphaValue;      % Inrease the cost of under-forecasts
pfem3 = lossPfem(tTest, yTest, parameters);
expectedResult3 = (alphaValue*mean(yTest-tTest) + ...
    mean(tTest-yTest))/((1+alphaValue)/2);
pass3 = isequal(pfem3, expectedResult3);

%% TEST 4
betaValue = 2;
parameters([1, 2]) = [1, betaValue];
pfem4 = lossPfem(tTest, yTest, parameters);
expectedResult4 = sqrt(lossMse(tTest, yTest));
pass4 = isequal(pfem4, expectedResult4);

%% TEST 5
gammaValue = 2;
parameters([2, 3]) = [1, gammaValue];
pfem5 = lossPfem(tTest, yTest, parameters);
weights = linspace(gammaValue, 1, 10);
weights = weights./(mean(weights)); % so weigths average to 1.0
expectedResult5 = mean((yTest-tTest).*weights');
pass5 = isequal(pfem5, expectedResult5);

%% TEST 6
yTest = [ones(3,1); 10; ones(6,1)];
tTest = [ones(4,1); 10; ones(5,1)];
deltaValue = 1;
parameters([3, 4]) = [1, deltaValue];
pfem6 = lossPfem(tTest, yTest, parameters);
expectedResult6 = 0;
pass6 = isequal(pfem6, expectedResult6);

%% SUMMARY:
if pass1 && pass2 && pass3 && pass4 && pass5 && pass6
    disp('lossPfem test PASSED');
else
    error('lossPfem test FAILED');
end

