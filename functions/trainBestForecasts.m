function [ Pfem, Pemd, Sim, pars ] = trainBestForecasts( Pfem, Pemd, ...
    MPC, Sim, allDemandValues, trainControl, k, bestPfemIdx, bestPemdIdx)

% trainBestForecasts: Train forecasts to minimise error metrics with
% stochastically selected parameter values

tic;

%% Pre-Allocation
pars = cell(Sim.nInstances, Sim.nMethods);
timeTaken = zeros(Sim.nInstances, Sim.nMethods);

Sim.hourNumber = mod((1:size(allDemandValues{1}, 1))', k);
Sim.hourNumberTrain = Sim.hourNumber(Sim.trainIdxs, :);
trainControl.hourNumberTrain = Sim.hourNumberTrain;

%% Extract local variables to reduce parfor comms overhead
nInstances = Sim.nInstances;
nMethods = Sim.nMethods;

lossTypes = Sim.lossTypes;
trainIdxs = Sim.trainIdxs;
allMethodStrings = Sim.allMethodStrings;


%% Train Models
parfor instance = 1:nInstances
    
    %% Extract aggregate demand
    demandValuesTrain = allDemandValues{instance}(trainIdxs);
    
    %% Train models
    for methodTypeIdx = 1:nMethods
        
        thisForecastTypeString = ...
            allMethodStrings{methodTypeIdx};%#ok<PFBNS>
        
        switch thisForecastTypeString
            
            case 'forecastFree'
                tempTic = tic;
                pars{instance, methodTypeIdx} = ...
                    trainForecastFreeController( demandValuesTrain, Sim,...
                    trainControl, MPC);
                timeTaken(instance, methodTypeIdx) = toc(tempTic);
                
                % Skip if method doesn't need training
            case 'naivePeriodic'
                continue;
                
            case 'godCast'
                continue;
                
            case 'setPoint'
                continue;
                
                % Otherwise assume we have a forecast to train
            otherwise
                
                % Extract selected loss type as required
                if strcmp(thisForecastTypeString, 'bestPfemSelected')
                    thisLossType = ...
                        lossTypes{bestPfemIdx(instance)}; %#ok<PFBNS>
                    
                elseif strcmp(thisForecastTypeString, 'bestPemdSelected')
                    thisLossType = lossTypes{bestPemdIdx(instance)};
                    
                else
                    thisLossType = lossTypes{methodTypeIdx};
                end
                
                tempTic = tic;
                pars{instance, methodTypeIdx} = ...
                    trainFfnnMultipleStarts( demandValuesTrain, ...
                    thisLossType, trainControl);
                timeTaken(instance, methodTypeIdx) = toc(tempTic);
        end
        disp(' === Forecast Type complete: ==== ');
        disp(thisForecastTypeString);
    end
    
    disp(' ====== Instance Completed ===== ');
    disp(instance);
end

Sim.timeTaken = timeTaken;
Sim.timeForecastTrain = toc;

disp('Time to end Forecast Training:'); disp(Sim.timeFcastTrain);

end
