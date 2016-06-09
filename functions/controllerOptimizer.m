function [energyToBattery, exitFlag] = controllerOptimizer(cfg, ...
    forecast, demandNow, battery, peakSoFar)

% controllerOptimizer: Optimize the control given a forecast of demand
%                       using linear program (or SP heuristic).

%% INPUTS:
% cfg:              Structure of running options
% forecast:         Demand forecast for next k intervals [kWh]
% demandNow:        Actual demand for current interval [kWh]
% battery:          Object containing information about the batt
% peakSoFar:        Running peak demand in billing period [kWh]

%% OUTPUTS:
% energyToBattery:  [kWh] batt charge energy during horizon [horizon x 1]
% exitFlag:         Status flag of the linear program solver (1 is good!)

if cfg.opt.clipNegativeFcast
    forecast = max(forecast, 0);
end

horizon = length(forecast);

if horizon ~= cfg.sim.horizon
    error('Forecast not of correct horizon length');
end

if cfg.opt.knowDemandNow
    forecast(1) = demandNow;
end

%% Make setPoint decision; otherwise solve linear program
if cfg.opt.setPoint
    
    %% SET-POINT CONTROL
    energyToBattery = zeros(1,horizon);
    if forecast(1) > peakSoFar
        % Discharge sufficiently to prevent new peak
        energyToBattery(1) = max(-(forecast(1) - peakSoFar),...
            -battery.maxChargeEnergy);
    else
        % Charge without creating new peak
        energyToBattery(1) = min(peakSoFar - forecast(1),...
            battery.maxChargeEnergy);
    end
    % Finally constrain this decision to be feasible:
    energyToBattery(1) = battery.limitCharge(energyToBattery(1));
    exitFlag = 1;
    
else
    %% LINEAR PROGRAM CONTROL
    % Let variables x_i for i = {1:k} be the battery charge energy over
    % next k intervals. Total energy stored in battery will be (in kWh)
    % sum(i in 1:k) x_i + stateOfCharge
    
    % Let the x_(k+1) variable represent the amount by which the
    % maximum forecast power drawn from the grid exceeds the running peak
    % (this number is always non-negative)
    
    % Let variable x_(k+2) be the peak forecast power from the grid, minus
    % the running peak (this number can be negative, and equals x_(k+1) if
    % x_(k+1) is positive)
    
    % Objective is  1) Minimise (positive) exceedance of running peak
    %               2) (Secondary) encourage charging behavior
    
    f = [zeros(horizon, 1); 1; 0];
    
    if cfg.opt.chargeWhenCan
        % Encourage charging as secondary objective
        f(1:horizon) =  -cfg.opt.secondWeight;   
    end
    
    if cfg.opt.rewardMargin
        f(end-1) = 0;
        f(end) = 1;
    end
    
    
    %% CONSTRAINTS:
    
    % 1. Cumulative net energy into the battery cannot exceed
    % batteryCapacity - stateOfCharge:
    % i.e.: energyToBattery(1) <= batteryCapacity - stateOfCharge
    %       energyToBattery(1) + energyToBattery(2) <= batteryCapacity - stateOfCharge
    %       energyToBattery(1) + ... energyToBattery(k) <= batteryCapacity - stateOfCharge
    
    % Express these as inequality A*x <= b
    % NB: we have zeros for our k+1, k+2 variables:
    A = [tril(ones(horizon, horizon)), zeros(horizon, 2)];
    b = repmat(battery.capacity - battery.SoC, [horizon, 1]);
    
    % 2. Similar constraints ensure stateOfCharge doesn't fall below zero
    % Add these to contraints above:
    A = [A; [tril(-1*ones(horizon,horizon)), zeros(horizon, 2)]];
    b = [b; repmat(battery.SoC, [horizon, 1])];
    
    % 3. Constrain k+1 variable to be >= forecast power drawn from grid
    % exceedance determined by the 1..k variables:
    % Require: x_(k+1) >= x_i + forecast_i - peakSoFar
    %          x_i - x_(k+1) <= peakSoFar - forecast_i (for all i in 1:k)
    A = [A; [eye(horizon, horizon), ones(horizon, 1).*-1, zeros(horizon, 1)]];
    b = [b; peakSoFar - forecast];
    
    % 4. Constrain k+2 variable to be >= forecast power drawn from grid
    % exceedance determined by the 1..k variables:
    % Require: x_(k+2) >= x_i + forecsat_i - peakSoFar
    %          x_i - x_(k+2) <= peakSoFar - forecast_i (for all i in 1:k)
    A = [A; eye(horizon, horizon), zeros(horizon, 1), ones(horizon, 1).*-1];
    b = [b; peakSoFar - forecast];
    
    % 5. Constrain 1..k variables to be >= -forecast
    % (don't allow expected export)
    % Require: x_(i) >= -forecast (for all i in 1:k)
    %          -x_(i)<= forecast (for all i in 1:k)
    A = [A; -eye(horizon, horizon), zeros(horizon, 2)];
    b = [b; forecast];

    
    %% BOUNDS:
    
    % 1. Each of x_i (powerToBattery) must be <= maximumChargeEnergy
    %       leave x_(k+1, k+2) unbounded above
    ub = [ones([horizon 1]).*battery.maxChargeEnergy; Inf; Inf];
    
    % 2. Power withdrawn from battery is bounded by
    %       -maximumChargeEnergy and forecast demand (no export allowed)
    %       bound x_(k+1) below at 0; primary obj. is to not exceed peak
    %       Leave x_(k_2) unbounded below if we want to reward margin
    if cfg.opt.rewardMargin
        lb = [max(ones([horizon 1]).*-battery.maxChargeEnergy, -forecast);...
            0; -Inf];
    else
        lb = [max(ones([horizon 1]).*-battery.maxChargeEnergy, -forecast);...
            0; 0];
    end
    
    % Optimization running options
    options = optimoptions(@linprog,'Display', 'off'); %, ...
        % 'Algorithm', 'dual-simplex');
    
    % options.MaxIter = ceil(cfg.opt.iterationFactor*options.MaxIter);
    
    [xSoln, ~, exitFlag] = linprog(f,A,b,[],[],lb,ub,[],options);
    % x = linprog(f,A,b,Aeq,beq,lb,ub,x0,options)
    
    if exitFlag == -4
        disp('Trying the simplex algorithm');
        options = optimoptions(@linprog,'Display', 'off', 'Algorithm', ...
            'simplex'); %#ok<LINPROG>
        [xSoln, ~, exitFlag] = linprog(f,A,b,[],[],lb,ub,[],options);
    end
    
    % Check if output vector & exitFlag are of correct size
    if sum(size(xSoln) == [(horizon+2) 1]) ~= 2 || ...
            sum(size(exitFlag) == [1 1]) ~= 2
        disp('x_soln= '); disp(xSoln);
        disp('exitFlag= ');disp(exitFlag);
        disp('f= '); disp(f);
        disp('lb= '); disp(lb);
        disp('ub= '); disp(ub);
        disp('forecast= '); disp(forecast);
        disp('peakSoFar= '); disp(peakSoFar);
        error('Output vector or exit flag not of correct size');
    end
    
    energyToBattery = xSoln(1:horizon);
    
    if exitFlag ~= 1
        disp('Controller optimsation did not fully converge');
    end
end

end
