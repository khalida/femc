% file: train_SARMA.m
% auth: Khalid Abdulla
% date: 9/12/2014
% brief: given a demand t-series and lossType, train SARMA(3,0)x(1,0) to
%               minimise that loss function.

%% Train SARMA model
function parsOut = train_SARMA( demand, k,  lossType, trControl)

% demand is the time-history of demands on which to train the model
% k:        is number of steps for which fc is to be optimised (for 1:k)
% lossType: is a handle to the loss function
% trControl is a structure with various train control parameters

% pars:     are the optimal parameters found by the training

%% Select some initial parameters, and bounds
% Assume model (3,0)x(1,0)
% TODO: would be better to make this GENERIC

% Bounds
lb = -1 + eps;
ub = 1 - eps;

% Initialisation
numInit = 3;  % Number of random initialisations to try (initially 3) increased if results differ significantly
maxInit = 20;

% Limit training length to 20-days
% (based on testing with aggregations of 20 customers)
demand = demand((end-20*k + 1):end);

numPars = 4;    % TODO this is assumed to be theta_1, theta_2, theta_3, and phi_1
pars0_all = lb + (ub-lb)*rand(numInit, numPars);
pars_all = zeros(numInit, numPars);
loss_all = zeros(numInit, 1);

% Set bounds for each par
lb_all = lb.*ones(size(pars0_all(1,:)));
ub_all = ub.*ones(size(pars0_all(1,:)));

% Handle train control settings
% set to default values when not specified
if ~isfield(trControl, 'supp'); trControl.supp = false;
    warning('Using default trControl.supp');  end

for thisInit = 1:numInit;
    
    % DEBUGGING:
    % disp(['thisInit: ' num2str(thisInit)]);
    
    pars0 = pars0_all(thisInit, :);
    
    %% Minimise the selected loss function
    if(~trControl.supp)
        options = optimoptions(@fmincon,'Display', 'iter');
    else
        % options = optimset('Algorithm','interior-point', 'Display', 'off');
        options = optimoptions(@fmincon,'Display', 'off');
    end
    
    % Set any custom parameters which are selected
    if isfield(trControl, 'TolFun'); options.TolFun = trControl.TolFun; end
    if isfield(trControl, 'TolCon'); options.TolCon = trControl.TolCon; end
    if isfield(trControl, 'TolX'); options.TolX = trControl.TolX; end
    if isfield(trControl, 'TolProjCGAbs');
        options.TolProjCGAbs = trControl.TolProjCGAbs; end
    
    [pars_all(thisInit, :), loss_all(thisInit, :)] = fmincon(...
        @dePar_loss_SARMA, pars0, [], [], [], [], lb_all, ub_all, [], options);
    %[x,fval] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
    
end

resultsMat = [loss_all, pars_all];
resultsMat = sortrows(resultsMat, 1);
bestLoss = resultsMat(1:3, 1);
percDiff = (max(bestLoss) - min(bestLoss))./min(bestLoss);

while percDiff > 0.01 && size(resultsMat, 1) < maxInit
    numRows = size(resultsMat, 1);
    
    for thisInit = (numRows+1):(numRows+3);
        
        pars0 = lb + (ub-lb)*rand(1, numPars);
        
        %% Minimise the selected loss function
        if(~trControl.supp)
            options = optimoptions(@fmincon,'Display', 'iter');
        else
            options = optimoptions(@fmincon,'Display', 'off');
        end
        
        [resultsMat(thisInit, 2:end), resultsMat(thisInit, 1)] = ...
            fmincon(@dePar_loss_SARMA, pars0, [], [], [], [], lb_all, ...
            ub_all, [], options);
        %[x,fval] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
        
    end
    
    resultsMat = sortrows(resultsMat, 1);
    bestLoss = resultsMat(1:3, 1);
    percDiff = (max(bestLoss) - min(bestLoss))./min(bestLoss);
    
end

% Select best model (will be at top as it's been sorted)
best_loss = resultsMat(1, 1);
best_pars = resultsMat(1, 2:end);

if(~trControl.supp); disp(best_loss); end

% If we have run into maximum number if initialisation display the losses of all initialisations:
if size(resultsMat, 1) >= maxInit
    warning('Maximim No. of SARMA initalisations reached, allErrors:');
    disp(resultsMat(:, 1)');
end 

% Loss function for selected loss type, given current parameter settings
    function [loss] = dePar_loss_SARMA (pars)
        all_loss = loss_SARMA(pars, demand, lossType, k, trControl);
        loss = mean(all_loss);
    end

% Prepare parameter structure
parsOut.pars = best_pars;
parsOut.k = k;

end
