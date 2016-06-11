%% Test by producing a simple case with a perfect forecast, and confirm
% Optimal time-series solution is found:
clearvars;

%% Set-up a simple problem:
cfg.opt.clipNegativeFcast = false;
cfg.opt.resetPeakToMean = true;
cfg.sim.horizon = 48;
cfg.fc.season = cfg.sim.horizon;
cfg.opt.knowDemandNow = false;
cfg.opt.setPointRecourse = false;
cfg.opt.chargeWhenCan = false;
cfg.opt.secondWeight = 0;
cfg.opt.rewardMargin = true;
cfg.opt.iterationFactor = 1.0;
cfg.sim.eps = 1e-8;                % Small No. to avoid rounding issues
cfg.opt.suppressOutput = false;
cfg.opt.billingPeriodDays = 2;

% Battery properties:
cfg.sim.batteryChargingFactor = 100;
cfg.sim.stepsPerHour = 2;
cfg.sim.stepsPerDay = 48;

demand = ones(cfg.sim.horizon*4, 1).*2;     % Alternating 1,2kWh/interval
demand(1:2:end) = 1;

demandDelays = ones(cfg.sim.horizon, 1).*2;
demandDelays(1:2:end) = 1;
godCast = createGodCast(demand, cfg.sim.horizon);

% Set runControl options
runControl.godCast = true;
runControl.naivePeriodic = false;
runControl.setPoint = false;
runControl.skipRun = false;

%% Test 1a Case with a very large battery:
% With large battery and problem above, expect charge of -2kWh/interval
% as we're rewarding margin
battery = Battery(cfg, 1000);               % 1000kWh bat charged to 500kWh

[ runningPeak, exitFlag, ~] = mpcController(cfg,...
    [], godCast, demand, demandDelays, battery, runControl);

% Check for obvious solution, and success exitFlag from optimiser
if ~closeEnough(max(runningPeak), mean(demand), cfg.sim.eps)
    disp('runningPeak:'); disp(runningPeak);
    disp('exitFlag:'); disp(exitFlag);
    error('battery test 1a failed, wrong answer');
elseif min(exitFlag) ~= 1
    disp('runningPeak:'); disp(runningPeak);
    disp('exitFlag:'); disp(exitFlag);
    error('battery test 1a failed, wrong exitFlag');
else
    disp('test_mpcController TEST 1a PASSED!');
end

%% Test 1b Case with a very large battery:
% Reset running peak to zero:
cfg.opt.resetPeakToMean = false;
battery = Battery(cfg, 1000);               % 1000kWh bat charged to 500kWh

[ runningPeak, exitFlag, ~] = mpcController(cfg,...
    [], godCast, demand, demandDelays, battery, runControl);

% Check for obvious solution, and success exitFlag from optimiser
if ~closeEnough(max(runningPeak), 0.0, cfg.sim.eps)
    disp('runningPeak:'); disp(runningPeak);
    disp('exitFlag:'); disp(exitFlag);
    error('battery test 1b failed, wrong answer');
elseif min(exitFlag) ~= 1
    disp('runningPeak:'); disp(runningPeak);
    disp('exitFlag:'); disp(exitFlag);
    error('battery test 1b failed, wrong exitFlag');
else
    disp('test_mpcController TEST 1b PASSED!');
end
cfg.opt.resetPeakToMean = true;

%% Test 2a Case with ltd. size battery:
sizeForReductionToMean = 0.5;         % [kWh]
battery = Battery(cfg, 0.5*sizeForReductionToMean);
expectedPeak = mean([mean(demand), max(demand)]);

[ runningPeak, exitFlag, ~] = mpcController(cfg,...
    [], godCast, demand, demandDelays, battery, runControl);

% Check for obvious solution, and success exitFlag from optimiser
if ~closeEnough(max(runningPeak), expectedPeak, cfg.sim.eps)
    disp('runningPeak:'); disp(runningPeak);
    disp('exitFlag:'); disp(exitFlag);
    error('battery test 2a failed, wrong answer');
elseif min(exitFlag) ~= 1
    disp('runningPeak:'); disp(runningPeak);
    disp('exitFlag:'); disp(exitFlag);
    error('battery test 2a failed, wrong exitFlag');
else
    disp('test_mpcController TEST 2a PASSED!');
end

%% Test 2b Case with ltd. size battery, and charge-rate limit
cfg.sim.batteryChargingFactor = 2;
battery = Battery(cfg, 0.5*sizeForReductionToMean);
expectedPeak = max(expectedPeak, max(demand)-battery.maxChargeEnergy);

[ runningPeak, exitFlag, ~] = mpcController(cfg,...
    [], godCast, demand, demandDelays, battery, runControl);

% Check for obvious solution, and success exitFlag from optimiser
if ~closeEnough(max(runningPeak), expectedPeak, cfg.sim.eps)
    disp('runningPeak:'); disp(runningPeak);
    disp('exitFlag:'); disp(exitFlag);
    error('battery test 2b failed, wrong answer');
elseif min(exitFlag) ~= 1
    disp('runningPeak:'); disp(runningPeak);
    disp('exitFlag:'); disp(exitFlag);
    error('battery test 2b failed, wrong exitFlag');
else
    disp('test_mpcController TEST 2b PASSED!');
end

%% Test 3a Set-point Controller
runControl.godCast = false;
runControl.setPoint = true;
runControl.skipRun = false;
battery = Battery(cfg, sizeForReductionToMean);

[ runningPeak, exitFlag, ~] = mpcController(cfg,...
    [], godCast, demand, demandDelays, battery, runControl);

% Check for obvious solution, and success exitFlag from optimiser
if ~closeEnough(max(runningPeak), 1.5, cfg.sim.eps)
    disp('runningPeak:'); disp(runningPeak);
    disp('exitFlag:'); disp(exitFlag);
    error('battery test 3a failed, wrong answer');
elseif min(exitFlag) ~= 1
    disp('runningPeak:'); disp(runningPeak);
    disp('exitFlag:'); disp(exitFlag);
    error('battery test 3a failed, wrong exitFlag');
else
    disp('test_mpcController TEST 3a PASSED!');
end

%% Test 3b Set-point Controller, with battery capacity limit
cfg.sim.batteryChargingFactor = 100;
battery = Battery(cfg, 0.5*sizeForReductionToMean);
expectedPeak = mean([mean(demand), max(demand)]);

[ runningPeak, exitFlag, ~] = mpcController(cfg,...
    [], godCast, demand, demandDelays, battery, runControl);

% Check for obvious solution, and success exitFlag from optimiser
if ~closeEnough(max(runningPeak), expectedPeak, cfg.sim.eps)
    disp('runningPeak:'); disp(runningPeak);
    disp('exitFlag:'); disp(exitFlag);
    error('battery test 3b failed, wrong answer');
elseif min(exitFlag) ~= 1
    disp('runningPeak:'); disp(runningPeak);
    disp('exitFlag:'); disp(exitFlag);
    error('battery test 3b failed, wrong exitFlag');
else
    disp('test_mpcController TEST 3b PASSED!');
end

close all;

%% TODO: this is a very limited test suite, but a useful sanity check!