%% Test by producing a simple case with a perfect forecast, and confirm
% Optimal solution is found:

%% Set-up a simple problem:
cfg.opt.clipNegativeFcast = false;
cfg.sim.horizon = 48;
cfg.opt.knowDemandNow = false;
cfg.opt.setPoint = false;
cfg.opt.chargeWhenCan = false;
cfg.opt.secondWeight = 0;
cfg.opt.rewardMargin = true;
cfg.opt.iterationFactor = 1.0;
cfg.sim.eps = 1e-8;                % Small No. to avoid rounding issues

% Battery properties:
cfg.sim.batteryChargingFactor = 1.0;
cfg.sim.stepsPerHour = 2;

forecast = ones(cfg.sim.horizon, 1).*2;     % Constant 2kWh/interval fcast
demandNow = 2;                              % 2kWh/interval demand now
peakSoFar = 1;                              % 1kWh/interval peak demand

%% Test 1a. Case with a very large battery:
% With large battery and problem above, expect charge of -2kWh/interval
% as we're rewarding margin
battery = Battery(cfg, 1000);               % 1000kWh bat charged to 500kWh
[energyToBattery, exitFlag] = controllerOptimizer(cfg, forecast,...
    demandNow, battery, peakSoFar);

% Check for obvious solution, and success exitFlag from optimiser
if ~closeEnough(energyToBattery(1), -2.0, cfg.sim.eps)
    disp('energyToBattery:'); disp(energyToBattery);
    disp('exitFlag:'); disp(exitFlag);
    error('battery test 1a failed, wrong answer');
elseif exitFlag ~= 1.0
    disp('energyToBattery:'); disp(energyToBattery);
    disp('exitFlag:'); disp(exitFlag);
    error('battery test 1a failed, wrong exitFlag');
else
    disp('test_controllerOptimizer TEST 1a PASSED!');
end

%% Test 1b. Case with a very large battery:
% With large battery and problem above, expect charge of -1kWh/interval
% as we're not rewarding margin (NB: degenerate; we can only check bound)
cfg.opt.rewardMargin = false;
battery = Battery(cfg, 1000);               % 1000kWh bat charged to 500kWh
[energyToBattery, exitFlag] = controllerOptimizer(cfg, forecast,...
    demandNow, battery, peakSoFar);

% Check for obvious solution, and success exitFlag from optimiser
if ~(energyToBattery(1) <= -1.0)
    disp('energyToBattery:'); disp(energyToBattery);
    disp('exitFlag:'); disp(exitFlag);
    error('battery test 1b failed, wrong answer');
elseif exitFlag ~= 1.0
    disp('energyToBattery:'); disp(energyToBattery);
    disp('exitFlag:'); disp(exitFlag);
    error('battery test 1b failed, wrong exitFlag');
else
    disp('test_controllerOptimizer TEST 1b PASSED!');
end
cfg.opt.rewardMargin = true;

%% Test 2. Case with a limited battery:
% With limited battery

battery = Battery(cfg, 2);                  % 2kWh bat charged to 1kWh
[energyToBattery, exitFlag] = controllerOptimizer(cfg, forecast,...
    demandNow, battery, peakSoFar);

% Check for obvious solution, and success exitFlag from optimiser
if ~closeEnough(energyToBattery(1), -1.0/cfg.sim.horizon, cfg.sim.eps)
    disp('energyToBattery:'); disp(energyToBattery);
    disp('exitFlag:'); disp(exitFlag);
    error('battery test 2 failed, wrong answer');
elseif exitFlag ~= 1.0
    disp('energyToBattery:'); disp(energyToBattery);
    disp('exitFlag:'); disp(exitFlag);
    error('battery test 2 failed, wrong exitFlag');
else
    disp('test_controllerOptimizer TEST 2 PASSED!');
end

%% Test 3. Check set-point controller:
% Expect setPoint controller to charge battery by -1.0kWh/interval, even
% with a limited capacity (no look-ahead)
cfg.opt.setPoint = true;
battery = Battery(cfg, 2);                  % 2kWh bat charged to 1kWh
[energyToBattery, exitFlag] = controllerOptimizer(cfg, forecast,...
    demandNow, battery, peakSoFar);

% Check for obvious solution, and success exitFlag from optimiser
if ~closeEnough(energyToBattery(1), -1.0, cfg.sim.eps)
    disp('energyToBattery:'); disp(energyToBattery);
    disp('exitFlag:'); disp(exitFlag);
    error('battery test 3 failed, wrong answer');
elseif exitFlag ~= 1.0
    disp('energyToBattery:'); disp(energyToBattery);
    disp('exitFlag:'); disp(exitFlag);
    error('battery test 3 failed, wrong exitFlag');
else
    disp('test_controllerOptimizer TEST 3 PASSED!');
end

%% TODO: this is a very limited test suite, but a useful sanity check!