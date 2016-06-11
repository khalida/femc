%% Test lossMape by doing some simple numerical examples:
clearvars;

%% Allowable relative error:
relTol = 1e-6;

%% TEST 1 - single dimensional case
tTest1 = rand(7,1);
yTest1 = rand(7,1);
mape1 = lossMape(tTest1, yTest1);
expectedResult1 = mean(abs((tTest1-yTest1)./tTest1));
pass1 = closeEnough(expectedResult1, mape1, relTol*expectedResult1);


%% TEST 2 - multiple horizon case
nHorizons = 2;
tTest2 = rand(7,nHorizons);
yTest2 = rand(7,nHorizons);
mape2 = lossMape(tTest2, yTest2);
expectedResult2 = zeros(1, nHorizons);
for idx = 1:nHorizons
    expectedResult2(idx) = mean(abs((tTest2(:,idx)-yTest2(:,idx))./...
        tTest2(:,idx)));
end
pass2 = closeEnough(expectedResult2, mape2, relTol.*expectedResult2);

%% TEST 3 - multiple horizon with zeros for actuals
tTest3 = zeros(7,nHorizons);
yTest3 = rand(7,nHorizons);
mape3 = lossMape(tTest3, yTest3);
expectedResult3 = zeros(1, nHorizons);
for idx = 1:nHorizons
    expectedResult3(idx) = mean(abs((tTest3(:,idx)-yTest3(:,idx))./...
        tTest3(:,idx)));
end
pass3 = closeEnough(expectedResult3, mape3, relTol.*expectedResult3);


%% TEST 4 - multiple horizon with zeros for actuals & fcasts
tTest4 = zeros(7,nHorizons);
yTest4 = zeros(7,nHorizons);
mape4 = lossMape(tTest4, yTest4);
expectedResult4 = zeros(1, nHorizons);
for idx = 1:nHorizons
    thisError = tTest4(:,idx)-yTest4(:,idx);
    percError = thisError./tTest4(:,idx);
    for intIdx = 1:length(thisError)
        if thisError(intIdx) == 0
            percError(intIdx) = 0;
        end
    end
    expectedResult4(idx) = mean(abs(percError));
end
pass4 = closeEnough(expectedResult4, mape4, relTol.*expectedResult4);


%% SUMMARY:
if pass1 && pass2 && pass3 && pass4
    disp('test_lossMape tests PASSED!');
else
    error('test_lossMape FAILED');
end