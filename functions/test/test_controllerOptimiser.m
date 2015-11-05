%% Test by producing a simple case with a perfect forecast, and confirm
% Optimal solution is found:


%% YOU ARE HERE!

[powerToBattery, exitFlag] = controllerOptimiser(forecast, ...
    stateOfCharge, demandNow, batteryCapacity, maximumChargeRate, ...
    stepsPerHour, peakSoFar, MPC);

