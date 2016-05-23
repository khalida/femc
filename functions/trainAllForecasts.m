function [ cfg, pars ] = ...
    trainAllForecasts( cfg, allDemandValues)

% trainAllForecasts: Train parameters for all trained forecasts. Run
%   through each instance and each error metric and output parameters
%   of trained forecasts.

tic;

%% Pre-Allocation
timeTaken = cell(cfg.sim.nInstances, 1);

% Parameters for the trained forecasts, and the forecast-free controller
pars = cell(cfg.sim.nInstances, cfg.fc.nMethods);

for instance = 1:cfg.sim.nInstances
    timeTaken{instance} = zeros(cfg.fc.nMethods,1);
end

cfg.sim.trainIdxs = 1:(cfg.sim.stepsPerHour*cfg.sim.nHoursTrain);
cfg.sim.hourNumber = mod((1:size(allDemandValues{1}, 1))', cfg.sim.k);
cfg.sim.hourNumberTrain = cfg.sim.hourNumber(cfg.sim.trainIdxs, :);

% Set default model type if not set already:
cfg.fc = setDefaultValues(cfg.fc, {'forecastModels', 'FFNN'});

if strcmp(cfg.fc.forecastModels, 'FFNN')
    trainHandle = @trainFfnnMultipleStarts;
    disp('== USING FFNN MODELS ===');
elseif strcmp(cfg.fc.forecastModels, 'SARMA')
    trainHandle = @trainSarma;
    disp('== USING SARMA MODELS ===');
else
    error('Selected cfg.fc.forecastModels not implemented');
end
                
% Extract local data from structures for efficiency in parFor loop
% communication
nInstances = cfg.sim.nInstances;
nMethods = cfg.fc.nMethods;
lossTypes = cfg.fc.lossTypes;
trainIdxs = cfg.sim.trainIdxs;
allMethodStrings  = cfg.fc.allMethodStrings;

%% Train Models
poolobj = gcp('nocreate');
delete(poolobj);

parfor instance = 1:nInstances
    
    % Extract aggregated demand
    demandValuesTrain = allDemandValues{instance}(trainIdxs);
    
    for methodTypeIdx = 1:nMethods
        switch allMethodStrings{methodTypeIdx} %#ok<PFBNS>
            
            % Skip if method doesn't need training
            case 'naivePeriodic'
                continue;
                
            case 'godCast'
                continue;
                
            case 'setPoint'
                continue;
                
            % Otherwise we have a forecast to train
            otherwise
                tempTic = tic;
                
                pars{instance, methodTypeIdx} = trainHandle(cfg, ...
                    demandValuesTrain, lossTypes{methodTypeIdx}); %#ok<PFBNS>
                
                timeTaken{instance}(methodTypeIdx) = toc(tempTic);
        end
        disp([allMethodStrings{methodTypeIdx} ' training done!']);
    end
end

poolobj = gcp('nocreate');
delete(poolobj);

cfg.sim.timeTaken = timeTaken;
cfg.sim.timeForecastTrain = toc;

disp('Time to end forecast training:'); disp(cfg.sim.timeForecastTrain);

end
