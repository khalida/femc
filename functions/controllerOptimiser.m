function [powerToBattery, exitFlag] = controllerOptimiser(forecast, ...
    stateOfCharge, demandNow, batteryCapacity, maximumChargeRate, ...
    stepsPerHour, peakSoFar, MPC)

% controllerOptimiser: Optimise the control given a forecast of demand
%                       using linear programming

% INPUTS:
% forecast:          demandNow forecast for next k steps [kW]
% stateOfCharge:     kWh currently in the battery
% demandNow:         actual demandNow for current time-step [kW]
% batteryCapacity:   kWh capacity of the battery
% maximumChargeRate: maximum kW in/out of battery
% stepsPerHour:      No. of intervals per hour
% peakSoFar:         running peak demandNow in billing period [kW]
% MPC:               structure containing details of MPC set-up

% OUTPUTS:
% powerToBattery:    kWh to send to battery during intervals 1:k
% exitFlag:          status flag of the linear program solver

% Set Defaults for MPC if not specified in MPC structure
MPC = setDefaultValues(MPC, {'secondWeight', 1e-4, ...
    'knowCurrentDemandNow', false, 'clipNegativeFcast', true, ...
    'iterationFactor', 1.0, 'rewardMargin', true, 'setPoint', false, ...
    'chargeWhenCan', false, 'suppressOutput', true});

if MPC.clipNegativeFcast
    forecast = max(forecast, 0);
end

k = length(forecast);

if MPC.knowCurrentDemandNow
    forecast(1) = demandNow;
end

%% Make simple setPoint decision; otherwise solve linear program
% NB: respecting SoC limits is handled within mpcController()
if MPC.setPoint
    
    %% SET-POINT CONTROL
    powerToBattery = zeros(1,k);
    if forecast(1) > peakSoFar
        % Discharge sufficiently to prevent new peak
        powerToBattery(1) = max(-(forecast(1) - peakSoFar),...
            -maximumChargeRate);
    else
        % Charge without creating new peak
        powerToBattery(1) = min(peakSoFar - forecast(1),...
            maximumChargeRate);
    end
    exitFlag = 1;
else
    
    %% LINEAR PROGRAM CONTROL
    % Let variables x_i for i = {1:k} be the power to send to battery over
    % next k intervals. Total energy stored in battery will be (in kWh)
    % sum(i in 1:k) (x_i/steps_per_hour) + stateOfCharge
    
    % Let the x_(k+1) variable represent the amount by which the
    % maximum forecast power drawn from the grid exceeds the running peak
    % (this number is always non-negative)
    
    % Let variable x_(k+2) be the peak forecast power from the grid, minus
    % the running peak (this number can be negative, and equales x_(k+1) if
    % x_(k+1) is positive
    
    % Objective is  1) Minimise positive exceedance of running peak
    %               2) (Secondary) maximise negative exceedance of running
                            % peak (margin from positive exceedance)
    
    if ~MPC.chargeWhenCan
        f = [zeros(k, 1); 1; MPC.secondWeight];
    else
        f = [-MPC.secondWeight; zeros(k-1, 1); 1; 0];
    end
    
    %% CONSTRAINTS:
    
    % 1. Cumulative net energy into the battery cannot exceed
    % batteryCapacity - stateOfCharge:
    % i.e.: powerToBattery(1) <=
    %(batteryCapacity - stateOfCharge)*stepsPerHour
    %       powerToBattery(1) + powerToBattery(2) <=
    %(batteryCapacity - stateOfCharge)*stepsPerHour
    %       ...
    %       powerToBattery(1) + ... powerToBattery(k) <=
    %(batteryCapacity - stateOfCharge)*stepsPerHour
    
    % Express these as inequality A*x <= b
    % NB: we have zeros for our k+1, k+2 variables:
    A = [tril(ones(k, k)), zeros(k, 2)];
    b = repmat((batteryCapacity - stateOfCharge)*stepsPerHour, [k, 1]);
    
    % 2. Similar constraints ensure stateOfCharge doesn't fall below zero
    % Add these to contraints above:
    A = [A; [tril(-1*ones(k,k)), zeros(k, 2)]];
    b = [b; repmat(stateOfCharge*stepsPerHour, [k, 1])];
    
    % 3. Constrain k+1 variable to be >= forecast power drawn from grid
    % exceedance determined by the 1..k variables:
    % Require: x_(k+1) >= x_i + forecast_i - peakSoFar
    %          x_i - x_(k+1) <= peakSoFar - forecast_i (for all i in 1:k)
    A = [A; [eye(k, k), ones(k, 1).*-1, zeros(k, 1)]];
    b = [b; peakSoFar - forecast];
    
    % 4. Constrain k+2 variable to be >= forecast power drawn from grid
    % exceedance determined by the 1..k variables:
    A = [A; eye(k, k), zeros(k, 1), ones(k, 1)];
    b = [b; peakSoFar - forecast];
    
    
    %% BOUNDS:
    
    % 1. Each of x_i (powerToBattery) must be <= maximumChargeRate
    %       leave x_(k+1, k+2) unbounded above
    ub = [ones([k 1]).*maximumChargeRate; Inf; Inf];
    
    % 2. Power withdrawn from battery is bounded below by
    %       -maximumChargeRate and forecast demandNow (no export allowed)
    %       bound x_(k+1) below at 0; primary object is to not exceed peak
    %       Leave x_(k_2) unbounded below if we want to reward margin as
                % secondary objective.
    if MPC.rewardMargin
        lb = [max(ones([k 1]).*-maximumChargeRate, -forecast); 0; -Inf];
    else
        lb = [max(ones([k 1]).*-maximumChargeRate, -forecast); 0; 0];
    end
    
    % Optimisation running options
    options = optimoptions(@linprog,'Display', 'off');
    options.MaxIter = ceil(MPC.iterationFactor*options.MaxIter);
    
    [xSoln, ~, exitFlag] = linprog(f,A,b,[],[],lb,ub,[],options);
    % x = linprog(f,A,b,Aeq,beq,lb,ub,x0,options)
    if exitFlag == -4
        options = optimoptions(@linprog,'Display', 'off', 'Algorithm', ...
            'simplex');
        [xSoln, ~, exitFlag] = linprog(f,A,b,[],[],lb,ub,[],options);
    end
    
    % Check if output vector & exitFlag are of correct size
    if sum(size(xSoln) == [(k+2) 1]) ~= 2 || ...
            sum(size(exitFlag) == [1 1]) ~= 2
        disp('x_soln= '); disp(xSoln);
        disp('exitFlag= ');disp(exitFlag);
        disp('lb= '); disp(lb);
        disp('ub= '); disp(ub);
        disp('forecast= '); disp(forecast);
        warning('Output vector or exit flag not of correct size');
    end
    
    powerToBattery = xSoln(1:k);
    
    if ~MPC.suppressOutput
        if exitFlag ~= 1
            disp('Controller optimsation did not fully converge');
        end
    end
end

end
