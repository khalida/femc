%% Test lossMape by doing some simple numerical examples:

%% Allowable relative error:
relTol = 1e-6;

%% TEST 1 - single dimensional case
tTest1 = rand(7,1);
yTest1 = rand(7,1);
mse1 = lossMse(tTest1, yTest1);
expectedResult1 = mean((tTest1-yTest1).^2);
pass1 = closeEnough(expectedResult1, mse1, relTol*expectedResult1);


%% TEST 2 - multiple horizon case
nHorizons = 2;
tTest2 = rand(7,nHorizons);
yTest2 = rand(7,nHorizons);
mse2 = lossMse(tTest2, yTest2);
expectedResult2 = zeros(1, nHorizons);
for idx = 1:nHorizons
    expectedResult2(idx) = mean((tTest2(:,idx)-yTest2(:,idx)).^2);
end
pass2 = closeEnough(expectedResult2, mse2, relTol.*expectedResult2);


%% TEST 3 - multiple horizon with zeros for actuals
tTest3 = zeros(7,nHorizons);
yTest3 = rand(7,nHorizons);
mse3 = lossMse(tTest3, yTest3);
expectedResult3 = zeros(1, nHorizons);
for idx = 1:nHorizons
    expectedResult3(idx) = mean((tTest3(:,idx)-yTest3(:,idx)).^2);
end
pass3 = closeEnough(expectedResult3, mse3, relTol.*expectedResult3);


%% TEST 4 - multiple horizon with zeros for actuals & fcasts
tTest4 = zeros(7,nHorizons);
yTest4 = zeros(7,nHorizons);
mse4 = lossMse(tTest4, yTest4);
expectedResult4 = zeros(1, nHorizons);
pass4 = closeEnough(expectedResult4, mse4, relTol.*expectedResult4);


%% SUMMARY:
if pass1 && pass2 && pass3 && pass4
    disp('test_lossMse tests PASSED!');
else
    error('test_lossMse FAILED');
end