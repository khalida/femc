function [pwr2batt, exitFlag] = controller_optimiser_Matlab(fcast, SoC, ...
    demand, batt_cap, max_charge_rate, steps_per_hour, peak_so_far, MPC)

%CONTROLLER_OPTIMISER Optimise the control outputs given a forecast

% Set Defaults for MPC if not specified in MPC structure
if ~isfield(MPC, 'secondWeight'); MPC.secondWeight = 1e-4;
warning('Using default MPC.secondWeight');  end;
if ~isfield(MPC, 'knowCurrentDemand'); MPC.knowCurrentDemand = true;
warning('Using default MPC.knowCurrentDemand');  end;
if ~isfield(MPC, 'clipNegativeFcast'); MPC.clipNegativeFcast = true;
warning('Using default MPC.clipNegativeFcast');  end;
if ~isfield(MPC, 'iterFactor'); MPC.iterFactor = 1.0;
warning('Using default MPC.iterFactor');  end;
if ~isfield(MPC, 'rewardMargin'); MPC.rewardMargin = false;
warning('Using default MPC.rewardMargin');  end;
if ~isfield(MPC, 'setPoint'); MPC.setPoint = false;
warning('Using default MPC.setPoint');  end;
if ~isfield(MPC, 'chargeWhenCan'); MPC.chargeWhenCan = false;
warning('Using default MPC.chargeWhenCan'); end;


if MPC.clipNegativeFcast
    fcast = max(fcast, 0);
end
k = length(fcast);

if MPC.knowCurrentDemand
    fcast(1) = demand;
end

%% Make simple setPoint decision; otherwise run linprog
% NB: respecting SoC limits is handled within onlineMPC_controller
if MPC.setPoint
    pwr2batt = zeros(1,k);
    if fcast(1) > peak_so_far
        % Discharge sufficiently to prevent new peak
        pwr2batt(1) = max(-(fcast(1) - peak_so_far), -max_charge_rate);
    else                        
        % Charge without creating new peak
        pwr2batt(1) = min(peak_so_far - fcast(1), max_charge_rate);
    end
    exitFlag = 1;
else
    
    %% OBJECTIVE FUNCTION
    
    % let variables 1 to k be the power to send to battery over next k
    % time-steps: NB: total energy stored in batt will be sum(i in 1:k)
    % x_i/steps_per_hour
    
    % let the k+1 variable represent the amount by which the
    % maximum fcast power drawn from the grid **exceeds the running peak**
    
    % let variables k+2... 2k+1 be the absolute values of variables 1 to k
    
    % Objective is  1) minimise exceedance of peak
    %               2) (Secondary) don't (dis)charge unecessarily
    
    % Only apply second weight to the implemented step
    secondWeights = [1; zeros(k-1, 1)].*MPC.secondWeight;
    
    if ~MPC.chargeWhenCan
        f = [zeros(k, 1); 1; ones(k, 1).*secondWeights];
    else
        f = [-MPC.secondWeight; zeros(k-1, 1); 1; zeros(k, 1)];
    end
    
    %% CONSTRAINTS:
    
    % 1. Cumulative net energy into the battery cannot exceed batt_cap - soc:
    % i.e.: pwr2batt(1) <= (Batt_cap - SoC)*steps_per_day
    %       pwr2batt(1) + pwr2batt(2) <= (Batt_cap - SoC)*steps_per_hour
    %       ...
    %       pwr2batt(1) + ... pwr2batt(k) <= (Batt_cap - SoC)*steps_per_hour
    
    % Express these as inequality A*x <= b
    % NB: we need zeros for our k+1:2k+1 variables:
    A = [tril(ones(k, k)), zeros(k, k+1)];
    b = repmat((batt_cap - SoC)*steps_per_hour, [k, 1]);
    
    % 2. Similar constraints ensure SoC doesn't fall below
    % zero. Add these to contraints above:
    A = [A; [tril(-1*ones(k,k)), zeros(k, k+1)]];
    b = [b; repmat(SoC*steps_per_hour, [k, 1])];
    
    % 3. Constrain k+1 variable to be >= est. power drawn from grid exceedance
    % determined by the 1..k variables:
    % Require: x_(k+1) >= x_i + fcast_i - peak_so_far
    %          x_i - x_(k+1) <= peak_so_far - fcast_i (for all i in [1, k])
    A = [A; [eye(k, k), ones(k, 1).*-1, zeros(k, k)]];
    b = [b; peak_so_far - fcast];
    
    % 4. Contraint k+2:2k+1 variables to be >= to 1:k variables
    % i.e. x_(i+k+1) >= x_i     for all i in [1, k]
    % so: x_i - x_(i+k+1) <= 0  for all i in [1, k]
    A = [A; eye(k, k), zeros(k, 1), -1.*eye(k, k)];
    b = [b; zeros(k, 1)];
    
    % 5. Contraint k+2:2k+1 variables to be >= to -1 x 1:k variables
    % i.e. x_(i+k+1) >= -x_i     for all i in [1, k]
    % so: -x_i - x_(i+k+1) <= 0  for all i in [1, k]
    A = [A; -1*eye(k, k), zeros(k, 1), -1.*eye(k, k)];
    b = [b; zeros(k, 1)];
    
    %% BOUNDS:
    
    % 1. Each of x_i (pwr2batt) must be <= max_charge_rate
    %       leave x_((k+1):(2k+1)) unbounded above
    ub = [ones(size(fcast)).*max_charge_rate; Inf; Inf.*ones(size(fcast))];
    
    % 2. power withdrawn from battery is bounded below by max_charge_rate and
    %       fcast demand (no export allowed)
    %       leave x_(k+1) unbounded below as we want to reward margin; i.e.
    %       keep solutions as far from establishing a new peak as possible.
    %       this would seem a prudent approach
    
    if MPC.rewardMargin
        lb = [max(ones(size(fcast)).*-max_charge_rate, -fcast); -Inf; ...
            -Inf.*ones(size(fcast))];
    else
        lb = [max(ones(size(fcast)).*-max_charge_rate, -fcast); 0; ...
            -Inf.*ones(size(fcast))];
    end
    
    % Optimisation running options
    options = optimoptions(@linprog,'Display', 'off');
    options.MaxIter = ceil(MPC.iterFactor*options.MaxIter);
    
    [x_soln, ~, exitFlag] = linprog(f,A,b,[],[],lb,ub,[],options);
    if exitFlag == -4
        options = optimoptions(@linprog,'Display', 'off', 'Algorithm', ...
            'simplex');
        [x_soln, ~, exitFlag] = linprog(f,A,b,[],[],lb,ub,[],options);
    end

    % x = linprog(f,A,b,Aeq,beq,lb,ub,x0,options)
    
    % Check if output vector & exitFlag are of correct size
    if sum(size(x_soln) == [97 1]) ~= 2 || sum(size(exitFlag) == [1 1]) ~= 2
        disp('x_soln= '); disp(x_soln);
        disp('exitFlag= ');disp(exitFlag);
        disp('lb= '); disp(lb);
        disp('ub= '); disp(ub);
        disp('fcast= '); disp(fcast);
        warning('Output vector or exit flag not of correct size');
    end
    
    pwr2batt = x_soln(1:k);
    
%     if exitFlag ~= 1
%         disp('Controller optimsation did not fully converge');
%     end
    
end

end
