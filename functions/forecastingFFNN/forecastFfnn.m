% file: forecastFfnn.m
% auth: Khalid Abdulla
% date: 21/10/2015
% brief: Given a neural network and some new inputs for a fcast origin,
%       create a new forecast.

function [ forecast ] = forecastFfnn( cfg, net, demand)

% INPUT:
% net: MATLAB trained neural network object
% demand: input data [nInputs x nObservations]
% trainControl: structure of train controllering parameters

% OUPUT:
% forecast: output forecast [nResponses x nObservations]

trainControl = cfg.fc;

suppressOutput = trainControl.suppressOutput;

nLags = net.inputs{1}.size;
x = demand((end - nLags + 1):end, :);
if ~strcmp(net.performFcn, 'mse')
    if(~suppressOutput)
        forecast = net(x, nn7);
    else
        % Supress command line output
        evalc('forecast = net(x, nn7);');
    end
else
    if(~suppressOutput)
        forecast = net(x);
    else
        % Supress command line output
        evalc('forecast = net(x);');
    end
end
