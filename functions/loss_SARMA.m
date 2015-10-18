%% Loss function for selected loss type, given current parameter settings

function [loss] = loss_SARMA (pars, demand, lossType, k, trControl)

% pars:     current values of fcast parameters
% demand:   t-series on which to base loss (historic)
% lossType: handle to loss functions
% k:        horizon of forecast to evaluate

% For all time-steps in demand for which forecast can be evaluated, make a
% forecast over k-steps, and compute loss

actuals = zeros(length(demand)-k, trControl.minimiseOverFirst);
fcasts = zeros(length(demand)-k, trControl.minimiseOverFirst);

parsIn.pars = pars;
parsIn.k = k;

for t = k:(length(demand)-k)
    fc = fc_SARMA(parsIn, demand((t-k+1):t), true);
    fcasts(t,:) = fc(1:trControl.minimiseOverFirst);
    
    temp_actuals = demand(t+1:t+k);
    actuals(t, :) = temp_actuals(1:trControl.minimiseOverFirst);
end

% Remove the zero fcasts
fcasts = fcasts(k:end, :);              % [nObs x k]
actuals = actuals(k:end, :);            % [nObs x k]

loss = lossType(actuals', fcasts');     % loss functions require [k x nObs]

end