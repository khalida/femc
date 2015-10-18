function [ PFEM, EMD, Sim, pars ] = ...
    trainBestFcasts( PFEM, EMD, MPC, Sim, all_demand_vals, trControl,...
    k, bestPFEMidx, bestEMDidx)

tic;

%TRAINBESTFCASTS Train fcasts to mimise stoch selected parameters

%% Pre-Allocation
pars = cell(Sim.numInstances, Sim.nMethods);
timeTaken = zeros(Sim.numInstances, Sim.nMethods);

Sim.hour_numbers = mod((1:size(all_demand_vals{1}, 1))', k);
Sim.hour_numbers_tr = Sim.hour_numbers(Sim.tr_idxs, :);
trControl.hour_numbers_tr = Sim.hour_numbers_tr;

%% Extract local variables for efficiency (parfor comms overhead)
numInstances = Sim.numInstances;
nMethods = Sim.nMethods;

lossTypes = Sim.lossTypes;
tr_idxs = Sim.tr_idxs;
hours_per_day = Sim.hours_per_day;
steps_per_hour = Sim.steps_per_hour;
battCapRatio = Sim.battCapRatio;
num_hours_train = Sim.num_hours_train;
batt_charge_factor = Sim.batt_charge_factor;
hour_numbers = Sim.hour_numbers;
num_train_shuffles = Sim.num_train_shuffles;
num_days_swap = Sim.num_days_swap;
nHidden = Sim.nHidden;
lossTypesStrings = Sim.lossTypesStrings;
steps_per_day = Sim.steps_per_day;
days_init = 1;
in_idxs = (0:(days_init*steps_per_day-1)) + min(tr_idxs);
tr_FF_idxs = setdiff(tr_idxs, in_idxs);

hour_numbers_tr_FF = hour_numbers(tr_FF_idxs);
simRange_tr_FF = [0 num_hours_train - hours_per_day*days_init ...
    - 1/steps_per_hour];

%% Train Models
parfor instance = 1:numInstances
% for instance = 1:numInstances
    
    % Extract aggregated demand
    demand_vals_tr = all_demand_vals{instance}(tr_idxs);

    % Fore fcastfree controller seperate train data into init and training
    demand_vals_tr_FF = all_demand_vals{instance}(tr_FF_idxs);
    demand_vals_in_FF = all_demand_vals{instance}(in_idxs, :);
    
    thisTimeTaken = zeros(1, nMethods);

    for fcType = 1:nMethods
        
        thisFcTypeString = lossTypesStrings{fcType}; %#ok<PFBNS>
        
        % No need to produce fcasts for non-trained types:
        if strcmp(thisFcTypeString, 'naivePeriodic'); continue; end;
        if strcmp(thisFcTypeString, 'godCast'); continue; end;
        if strcmp(thisFcTypeString, 'setPoint'); continue; end;
        
        tempTic = tic;
        
        if ~strcmp(thisFcTypeString, 'fcastFree')
            if strcmp(thisFcTypeString, 'bestPFEM')
                thisLossType = lossTypes{bestPFEMidx(instance)};                %#ok<PFBNS>
            elseif strcmp(thisFcTypeString, 'bestEMD')
                thisLossType = lossTypes{bestEMDidx(instance)};               
            else
                thisLossType = lossTypes{fcType};
            end
            
            pars{instance, fcType} = ...
                train_FFNN_multStart( demand_vals_tr, k,  ...
                thisLossType, trControl);
            
            thisTimeTaken(1, fcType) = toc(tempTic);

        else
            
            % Train fcastFree model
            meankWh = mean(demand_vals_tr);
            
            % Create 'historical load pattern' for initialisation etc.
            load_pattern_in = mean(reshape(demand_vals_in_FF, ...
                [k, length(demand_vals_in_FF)/k]), 2);
            
            % Create the 'god forecast' for training data
            godCast = zeros(size(demand_vals_tr_FF, 1), k);
            for ii = 1:k
                godCast(:, ii) = circshift(demand_vals_tr_FF, -[ii-1, 0]);
            end
            
            % Set-up parameters for on-line simulation
            batt_cap = meankWh*battCapRatio*steps_per_day;
            max_charge_rate = batt_charge_factor*batt_cap;
            
            runControl = [];
            runControl.MPC = MPC;
            
            % Run On-line Model to create training examples
            [ featVec, decVec] = ...
                onlineMPC_genFcastFreeExamples( simRange_tr_FF, godCast, ...
                demand_vals_tr_FF, batt_cap, max_charge_rate, load_pattern_in, ...
                hour_numbers_tr_FF, steps_per_hour, k, runControl);
            
            allFeatVec = zeros(size(featVec, 1), length(...
                demand_vals_tr_FF)*(num_train_shuffles + 1));
            
            allDecVec = zeros(size(decVec, 1), length(...
                demand_vals_tr_FF)*(num_train_shuffles + 1));
            
            allFeatVec(:, 1:length(demand_vals_tr_FF)) = featVec;
            allDecVec(:, 1:length(demand_vals_tr_FF)) = decVec;
            offset = length(demand_vals_tr_FF);
            
            % Continue generating examples with suffled versions of
            % training data:
            for eachShuffle = 1:num_train_shuffles
                new_demand_vals_tr = demand_vals_tr_FF;
                for eachSwap = 1:num_days_swap
                    thisSwapStart = randi(length(demand_vals_tr_FF) - 2*k);
                    tmp = new_demand_vals_tr(thisSwapStart + (1:k));
                    new_demand_vals_tr(thisSwapStart + (1:k)) = ...
                        new_demand_vals_tr(thisSwapStart + (1:k) + k);
                    new_demand_vals_tr(thisSwapStart + (1:k) + k) = tmp;
                end
                [ featVec, decVec] = ...
                    onlineMPC_genFcastFreeExamples( simRange_tr_FF, godCast,...
                    new_demand_vals_tr, batt_cap, max_charge_rate, ...
                    load_pattern_in, hour_numbers_tr_FF, steps_per_hour, k, runControl);
                
                allFeatVec(:, offset + (1:length(demand_vals_tr_FF))) = ...
                    featVec;
                allDecVec(:, offset + (1:length(demand_vals_tr_FF))) = ...
                    decVec;
                offset = offset + length(demand_vals_tr_FF);
            end
            
            % Train fcast-free NN model based on these examples
            pars{instance, fcType} = genFcastFreeController(allFeatVec,...
                allDecVec, nHidden, trControl.numStarts);
            
            thisTimeTaken(1, fcType) = toc(tempTic);
            
        end
        disp('fcType complete: ');
        disp(lossTypesStrings{fcType});
    end
    timeTaken(instance, :) = thisTimeTaken;
end

Sim.timeTaken = timeTaken;
Sim.timeFcastTrain = toc;

disp('Time to end fcast train:'); disp(Sim.timeFcastTrain);

end
