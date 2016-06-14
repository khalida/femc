%% Simple one-case unit test (not exhaustive)
clearvars;

%% Test 1a
gridPower = ones(100, 1);
demandValues = ones(100, 1);
billingIntervals = 10;
expectedPrr1a = 0;
tol = 1e-6;

[ prr1a ] = extractSimulationResults(gridPower,...
    demandValues, billingIntervals);

pass1a = closeEnough(expectedPrr1a, prr1a, tol);

%% Test 1b
gridPower = zeros(100, 1);
billingIntervals = 10;
expectedPrr1b = 1;

[ prr1b ] = extractSimulationResults(gridPower,...
    demandValues, billingIntervals);

pass1b = closeEnough(expectedPrr1b, prr1b, tol);


%% Test 2
demandValues = sin((1:100)');
gridPower = demandValues.*0.5;
expectedPrr2 = 0.5;

[ prr2 ] = extractSimulationResults(gridPower,...
    demandValues, billingIntervals);

pass2 = closeEnough(expectedPrr2, prr2, tol);


%% Test 3
periodLength = 10;
gridPower = sin(2*pi*(1/periodLength)*(1:100)');
demandValues = gridPower.*2;
expectedPrr3 = 0.5;

[ prr3 ] = extractSimulationResults(gridPower,...
    demandValues, billingIntervals);

pass3 = closeEnough(expectedPrr3, prr3, tol);

if pass1a && pass1b && pass2 && pass3
    disp('test_extractSimulationResults PASSED!');
else
    error('test_extractSimulationResuts FAILED');
end
