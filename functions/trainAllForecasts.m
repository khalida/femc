function [ Pfem, Pemd, Sim, pars ] = trainAllForecasts( Pfem, Pemd, MPC,...
    Sim, allDemandValues, trainControl, k)

% trainAllForecasts: Train parameters for all trained forecasts. Run
%   through each instance and each error metric and output parameters
%   of trained forecasts.

tic;

%% Pre-Allocation
timeTaken = cell(Sim.nInstances, 1);

% Parameters for the trained forecasts, and the forecast-free controller
pars = cell(Sim.nInstances, Sim.nMethods);

for instance = 1:Sim.nInstances
    timeTaken{instance} = zeros(Sim.nMethods,1);
end

Sim.trainIdxs = 1:(Sim.stepsPerHour*Sim.nHoursTrain);
Sim.hourNumber = mod((1:size(allDemandValues{1}, 1))', k);
Sim.hourNumberTrain = Sim.hourNumber(Sim.trainIdxs, :);

% Set default model type if not set already:
Sim = setDefaultValues(Sim, {'forecastModels', 'FFNN'});

if strcmp(Sim.forecastModels, 'FFNN')
    trainHandle = @trainFfnnMultipleStarts;
    disp('== USING FFNN MODELS ===');
elseif strcmp(Sim.forecastModels, 'SARMA')
    trainHandle = @trainSarma;
    disp('== USING SARMA MODELS ===');
else
    error('Selected Sim.forecastModels not implemented');
end
                

trainControl.hourNumberTrain = Sim.hourNumberTrain;

% Extract local data from structures for efficiency in parFor loop
% communication
nInstances = Sim.nInstances;
nMethods = Sim.nMethods;
lossTypes = Sim.lossTypes;
trainIdxs = Sim.trainIdxs;
allMethodStrings  = Sim.allMethodStrings;

%% Train Models
poolobj = gcp('nocreate');
delete(poolobj);

parfor instance = 1:nInstances
    
    % Extract aggregated demand
    demandValuesTrain = allDemandValues{instance}(trainIdxs);
    
    for methodTypeIdx = 1:nMethods
        switch allMethodStrings{methodTypeIdx} %#ok<PFBNS>
            
            case 'forecastFree'
                tempTic = tic;
                pars{instance, methodTypeIdx} = ...
                    trainForecastFreeController( demandValuesTrain, Sim,...
                    trainControl, MPC);
                timeTaken{instance}(methodTypeIdx) = toc(tempTic);
                
                % Skip if method doesn't need training
            case 'naivePeriodic'
                continue;
                
            case 'godCast'
                continue;
                
            case 'setPoint'
                continue;
                
                % Otherwise assume we have a forecast to train
            otherwise
                tempTic = tic;
                pars{instance, methodTypeIdx} = trainHandle(...
                    demandValuesTrain, lossTypes{methodTypeIdx}, ...
                    trainControl); %#ok<PFBNS>
                
                timeTaken{instance}(methodTypeIdx) = toc(tempTic);
        end
        disp([allMethodStrings{methodTypeIdx} ' training done!']);
    end
end

poolobj = gcp('nocreate');
delete(poolobj);

Sim.timeTaken = timeTaken;
Sim.timeForecastTrain = toc;

disp('Time to end forecast training:'); disp(Sim.timeForecastTrain);

end
