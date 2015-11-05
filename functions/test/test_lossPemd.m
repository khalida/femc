%% Test lossPfem by doing some simple numerical examples:
% Not an exhaustive unit test, but better than nothing

%% Allowable Percentage error:
tolerance = 1e-4;

%% TEST 1
tTest1 = ones(7,1);
yTest1 = ones(7,1);
parameters = [100, 1, 1, 50];
pemd1 = lossPemd(tTest1, yTest1, parameters);
expectedResult1 = 0;
pass1 = or(isequal(expectedResult1, pemd1), ...
    abs((expectedResult1 - pemd1)/pemd1) < tolerance);


%% TEST 2
tTest2 = zeros(7,1) + 10;
yTest2 = (-3:3)' + 10;
pemd2 = lossPemd(tTest2, yTest2, parameters);
expectedResult2 = 1*2 + 2*4 + 3*6;
pass2 = abs((expectedResult2 - pemd2)/pemd2) < tolerance;


%% TEST 3; include a difference in the integrals
tTest3 = ones(7,1);
yTest3 = ones(7,1).*2;
pemd3 = lossPemd(tTest3, yTest3, parameters);
expectedResult3 = 7*parameters(1);
pass3 = isequal(pemd3, expectedResult3);


%% TEST 4; combined difference in integrals and flows
tTest4 = zeros(7,1) + 10;
yTest4 = (-3:3)' + 11;
pemd4 = lossPemd(tTest4, yTest4, parameters);
expectedResult4 =  (1*2 + 2*4) + (sum(yTest4)-sum(tTest4))*parameters(1);
pass4 = or(isequal(expectedResult4, pemd4), ...
    abs((expectedResult4 - pemd4)/pemd4) < tolerance);

%% TEST 5; check that we have symmetry with b==1
tTest5 = yTest4;
yTest5 = tTest4;
pemd5 = lossPemd(tTest5, yTest5, parameters);
expectedResult5 = expectedResult4;
pass5 = or(isequal(expectedResult5, pemd5), ...
    abs((expectedResult5 - pemd5)/pemd5) < tolerance);

%% TEST 6; try reducing b to 0.5 so errors no long symmetric:
parameters(2) = 0.5;
yTest6 = yTest5;
tTest6 = tTest5;
pemd6 = lossPemd(tTest6, yTest6, parameters);
expectedResult6 = (1*2 + 2*4) + (sum(tTest6)-sum(yTest6))*parameters(1);
pass6 = or(isequal(expectedResult5, pemd5), ...
    abs((expectedResult5 - pemd5)/pemd5) < tolerance);

%% TEST 7; test symmetric in other direction:
yTest7 = tTest5;
tTest7 = yTest5;
pemd7 = lossPemd(tTest7, yTest7, parameters);
expectedResult7 = (1*2 + 2*4) + (sum(yTest7)-sum(tTest7))*parameters(2)*parameters(1);
pass7 = or(isequal(expectedResult7, pemd7), ...
    abs((expectedResult7 - pemd7)/pemd7) < tolerance);

%% TEST 8; Check interval assymetry with c=0.5
parameters(2) = 1;
parameters(3) = 0.5;
tTest8 = zeros(7,1) + 10;
yTest8 = (-3:3)' + 10;
pemd8_1 = lossPemd(tTest8, yTest8, parameters);
expectedResult8_1 = (1*2 + 2*4 + 3*6);
pass8_1 = or(isequal(expectedResult8_1, pemd8_1), ...
    abs((expectedResult8_1 - pemd8_1)/pemd8_1) < tolerance);

% Check interval symmetry in other direction
pemd8_2 = lossPemd(yTest8,tTest8, parameters);
expectedResult8_2 = (1*2 + 2*4 + 3*6)*parameters(3);
pass8_2 = or(isequal(expectedResult8_2, pemd8_2), ...
    abs((expectedResult8_2 - pemd8_2)/pemd8_2) < tolerance);

%% SUMMARY:
if pass1 && pass2 && pass3 && pass4 && pass5 && pass6 && pass7 && ...
        pass8_1 && pass8_2
    disp('lossPemd test PASSED');
else
    error('lossPemd test FAILED');
end

% Check that can be used to get multiple instances at same time:
allTtest = [tTest1, tTest2, tTest3, tTest4, tTest5];

allYtest = [yTest1, yTest2, yTest3, yTest4, yTest5];

parameters = [100, 1, 1, 50];
allPemds = lossPemd(allTtest, allYtest, parameters);

allExpectedValues = [expectedResult1, expectedResult2, expectedResult3, ...
    expectedResult4, expectedResult5];

testsPassed = or(allPemds==allExpectedValues, ...
    abs((allPemds - allExpectedValues)./allExpectedValues) < tolerance);

if sum(testsPassed) == length(testsPassed)
    disp('lossPemd test PASSED');
else
    error('lossPemd test FAILED');
end