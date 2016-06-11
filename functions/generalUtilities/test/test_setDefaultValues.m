%% Test with a few simple examples to confirm expected behaviour
clearvars;

TestControlIn.value1 = 1;
TestControlIn.value2 = 2;
TestControlIn.value3 = 3;
fieldValuePairs = {'value4', 4, 'value5', 5, 'value6', 6, ...
                    'value7', 'bob'};

[ TestControlOut ] = setDefaultValues( TestControlIn, ...
    fieldValuePairs);

% Test all new field value pairs (could automate this)
testPassed = TestControlOut.value4 == 4;
testPassed = testPassed && TestControlOut.value5 == 5;
testPassed = testPassed && TestControlOut.value6 == 6;
testPassed = testPassed && isequal(TestControlOut.value7, 'bob');

% Check original value pairs still set OK
testPassed = testPassed && TestControlOut.value1 == 1;
testPassed = testPassed && TestControlOut.value2 == 2;
testPassed = testPassed && TestControlOut.value3 == 3;

if testPassed
    disp('test_setDefualtValues PASSED!');
else
    error('test_setDefualtValues FAILED');
end
