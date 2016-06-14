%% Test lossPemd by doing some simple numerical examples:
% Not an exhaustive unit test, but better than nothing
clearvars;

%% Allowable relative error:
relTol = 1e-5;

%% TEST 1
tTest1 = ones(7,1);
yTest1 = ones(7,1);
parameters = [100, 1, 1, 50];
pemd1 = lossPemd(tTest1, yTest1, parameters);
expectedResult1 = 0;
pass1 = closeEnough(expectedResult1, pemd1, relTol*expectedResult1);


%% TEST 2
tTest2 = zeros(7,1) + 10;
yTest2 = (-3:3)' + 10;
pemd2 = lossPemd(tTest2, yTest2, parameters);
expectedResult2 = 1*2 + 2*4 + 3*6;
pass2 = closeEnough(expectedResult2, pemd2, relTol*expectedResult2);


%% TEST 3; include a difference in the integrals
tTest3 = ones(7,1);
yTest3 = ones(7,1).*2;
pemd3 = lossPemd(tTest3, yTest3, parameters);
expectedResult3 = 7*parameters(1);
pass3 = closeEnough(expectedResult3, pemd3, relTol*expectedResult3);


%% TEST 4; combined difference in integrals and flows
tTest4 = zeros(7,1) + 10;
yTest4 = (-3:3)' + 11;
pemd4 = lossPemd(tTest4, yTest4, parameters);
expectedResult4 =  (1*2 + 2*4) + (sum(yTest4)-sum(tTest4))*parameters(1);
pass4 = closeEnough(expectedResult4, pemd4, relTol*expectedResult4);


%% TEST 5; check that we have symmetry with b==1
tTest5 = yTest4;
yTest5 = tTest4;
pemd5 = lossPemd(tTest5, yTest5, parameters);
expectedResult5 = expectedResult4;
pass5 = closeEnough(expectedResult5, pemd5, relTol*expectedResult5);


%% TEST 6; try reducing b to 0.5 so errors no long symmetric:
parameters(2) = 0.5;
yTest6 = yTest5;
tTest6 = tTest5;
pemd6 = lossPemd(tTest6, yTest6, parameters);
expectedResult6 = (1*2 + 2*4) + (sum(tTest6)-sum(yTest6))*parameters(1);
pass6 = closeEnough(expectedResult6, pemd6, relTol*expectedResult6);

%% TEST 7; test symmetric in other direction:
yTest7 = tTest5;
tTest7 = yTest5;
pemd7 = lossPemd(tTest7, yTest7, parameters);
expectedResult7 = (1*2 + 2*4) + (sum(yTest7)-sum(tTest7))*parameters(2)*parameters(1);
pass7 = closeEnough(expectedResult7, pemd7, relTol*expectedResult7);

%% TEST 8; Check interval assymetry with c=0.5
parameters(2) = 1;
parameters(3) = 0.5;
tTest8 = zeros(7,1) + 10;
yTest8 = (-3:3)' + 10;
pemd8_1 = lossPemd(tTest8, yTest8, parameters);
expectedResult8_1 = (1*2 + 2*4 + 3*6);
pass8_1 = closeEnough(expectedResult8_1, pemd8_1, ...
    relTol*expectedResult8_1);

% Check interval symmetry in other direction
pemd8_2 = lossPemd(yTest8,tTest8, parameters);
expectedResult8_2 = (1*2 + 2*4 + 3*6)*parameters(3);
pass8_2 = closeEnough(expectedResult8_2, pemd8_2, ...
    relTol*expectedResult8_2);

%% SUMMARY:
if pass1 && pass2 && pass3 && pass4 && pass5 && pass6 && pass7 && ...
        pass8_1 && pass8_2
    disp('test_lossPemd individual tests PASSED!');
else
    error('test_lossPemd individual tests FAILED');
end

% Check that can be used to get multiple instances at same time:
allTtest = [tTest1, tTest2, tTest3, tTest4, tTest5];

allYtest = [yTest1, yTest2, yTest3, yTest4, yTest5];

parameters = [100, 1, 1, 50];
allPemds = lossPemd(allTtest, allYtest, parameters);

allExpectedValues = [expectedResult1, expectedResult2, expectedResult3, ...
    expectedResult4, expectedResult5];

testsPassed = closeEnough(allExpectedValues, allPemds, ...
    relTol.*allExpectedValues);

if sum(testsPassed) == length(testsPassed)
    disp('test_lossPemd test PASSED!');
else
    error('test_lossPemd test FAILED');
end
