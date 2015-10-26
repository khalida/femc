% file: forecastSarma.m
% auth: Khalid Abdulla
% date: 21/10/2015
% brief: Produce k-step forecast using pre-trained SARMA model

function [ forecast ] = forecastSarma(parameters, demand, ...
    trainControl)
%forecastSarma k-Step forecast using SARMA(3,0)x(1,0)

% INPUTS
% parameters:     Structure of parameters of SARMA model (including k and s)
% demand:         historic demand up to *but not including* forecast origin
% trainControl:   Stricture of settings

% OUTPUTS
% forecast:      [k x 1] array of point forecast values

suppressOutput = trainControl.suppressOutput;
useHyndmanModel = trainControl.useHyndmanModel;


k = parameters.k;               % number of steps into future to forecast
coefficients = parameters.coefficients; % model coefficients

% TODO: Assumes order (3,0)x(1,0) would be better to generalise

thetaValues = coefficients(1:3);
phiValues = coefficients(4);

% Produce each forecast step into future in turn (results rely on previous
% steps)

if ~useHyndmanModel
    % M-file version of code
    % forecast = forecastSarmaMex(demand((end-k+1):end), thetaValues,...
    %    phiValues, k);
    
    % Mex version of code (faster)
    forecast = forecastSarmaMex_mex(demand((end-k+1):end), thetaValues,...
        phiValues, k);
else
    % M-file version of code
    % forecast = forecastSarmaHyndmandMex(demand((end-k+1):end),...
        %    thetaValues, phiValues, k);
    
    % Mex version of code (faster)
    forecast = forecastSarmaHyndmanMex_mex(demand((end-k-3+1):end), ...
        thetaValues, phiValues, k);
end

if ~suppressOutput
    disp('forecast = '); disp(forecast);
end

end