% file: trainSarma.m
% auth: Khalid Abdulla
% date: 22/10/2015
% brief: given a demand time series and lossType, train SARMA(3,0)x(1,0) to
%               minimise that loss function.

%% Train SARMA model
function parametersOut = trainSarma(cfg, demand, lossType)

% INPUTS
% cfg:          structure with running options
% demand:       time history of demands on which to train the model [T x 1]
% lossType:     is a handle to the loss function

% OUTPUTS
% parametersOut: are the optimal parameters found by the training


%% Select some initial parameters, and bounds
% Assume model (3,0)x(1,0)
% TODO: would be better to make this general

% Bounds
lowerBound = -1 + eps;
upperBound = 1 - eps;

% Initialisation
% No. of random initializations to try, increased if results differ
nInitializations = cfg.fc.nStart;
maxInitializations = cfg.fc.nMaxSarmaStarts;
k = cfg.fc.nLags;

% Limit training length to certain number of days
% (based on testing with aggregations of 20 customers)
if length(demand) > (cfg.fc.nDaysPreviousTrainSarma*cfg.sim.stepsPerDay)
    demand = demand((end-cfg.fc.nDaysPreviousTrainSarma*...
        cfg.sim.stepsPerDay + 1):end);
end

nParameters = 4;  % theta_1, theta_2, theta_3, phi_1
allParametersInitial = lowerBound + ...
    (upperBound-lowerBound)*rand(nInitializations, nParameters);

allParametersFinal = zeros(nInitializations, nParameters);
allLoss = zeros(nInitializations, 1);

% Set bounds for each par
allLowerBounds = lowerBound.*ones(size(allParametersInitial(1,:)));
allUpperBounds = upperBound.*ones(size(allParametersInitial(1,:)));

for iInit = 1:nInitializations;
    
    thisParametersInitial = allParametersInitial(iInit, :);
    
    %% Minimise the selected loss function
    if(~cfg.fc.suppressOutput)
        options = optimoptions(@fmincon,'Display', 'iter');
    else
        options = optimoptions(@fmincon,'Display', 'off');
    end
    
    % Set any custom parameters which are selected
    if isfield(cfg.fc, 'TolFun'),
        options.TolFun = cfg.fc.TolFun; end
    if isfield(cfg.fc, 'TolCon');
        options.TolCon = cfg.fc.TolCon; end
    if isfield(cfg.fc, 'TolX');
        options.TolX = cfg.fc.TolX; end
    if isfield(cfg.fc, 'TolProjCGAbs');
        options.TolProjCGAbs = cfg.fc.TolProjCGAbs; end
    
    [allParametersFinal(iInit, :), allLoss(iInit, :)] = fmincon(...
        @deParameterizedLossSarma, thisParametersInitial, ...
        [], [], [], [], allLowerBounds, allUpperBounds, [], options);
    %[x,fval] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
    
end

% Results matrix stores ascending loss in 1st column,
% and associated parameters in subsequent columns
resultsMatrix = [allLoss, allParametersFinal];
resultsMatrix = sortrows(resultsMatrix, 1);
bestLoss = resultsMatrix(1:cfg.fc.nStart, 1);
percentageDifference = (max(bestLoss) - min(bestLoss))./min(bestLoss);
outsideTolerance = percentageDifference > cfg.fc.perfDiffThresh;

while outsideTolerance && size(resultsMatrix, 1) < maxInitializations
    numRows = size(resultsMatrix, 1);
    
    for iInit = numRows+(1:nInitializations);
        
        thisParametersInitial = lowerBound + ...
            (upperBound-lowerBound)*rand(1, nParameters);
        
        %% Minimise the selected loss function
        if(~cfg.fc.suppressOutput)
            options = optimoptions(@fmincon,'Display', 'iter');
        else
            options = optimoptions(@fmincon,'Display', 'off');
        end
        
        [resultsMatrix(iInit, 2:end), resultsMatrix(iInit, 1)] = ...
            fmincon(@deParameterizedLossSarma, thisParametersInitial,...
            [], [], [], [], allLowerBounds, allUpperBounds, [], options);
        %[x,fval] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
    end
    
    resultsMatrix = sortrows(resultsMatrix, 1);
    bestLoss = resultsMatrix(1:cfg.fc.nStart, 1);
    percentageDifference = (max(bestLoss) - min(bestLoss))./min(bestLoss);
    outsideTolerance = percentageDifference > cfg.fc.perfDiffThresh;
end

% Select best model (will be at top as resultsMatrix has been sorted)
bestLoss = resultsMatrix(1, 1);
bestParameters = resultsMatrix(1, 2:end);

if(~cfg.fc.suppressOutput); disp('Best SARMA loss:'); disp(bestLoss); end

% If we have run into max No. of initializations,
% display the losses of all initializations:
if size(resultsMatrix, 1) >= maxInitializations
    warning('Maximim No. of SARMA initalisations reached, allLosses:');
    disp(resultsMatrix(:, 1)');
end

%% Loss function for selected loss type,
% as a function of only the current parameter settings
    function [loss] = deParameterizedLossSarma (parameters)
        allLosses = lossSarma(cfg, parameters, demand, lossType);
        loss = mean(allLosses);
    end

% Prepare parameter structure
parametersOut.coefficients = bestParameters;
parametersOut.k = k;

end
