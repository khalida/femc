function [ PFEM, EMD, Sim, pars ] = ...
    trainAllFcasts( PFEM, EMD, MPC, Sim, all_demand_vals, trControl, k)

tic;

%TRAINALLFCASTS Train parameters for all trained fcasts

%   Run through each instance and each error metric and output
%   parameters of trained NN forecasts

Sim.steps_per_day = Sim.steps_per_hour*Sim.hours_per_day;
Sim.num_hours_train = Sim.hours_per_day*Sim.num_days_train;
Sim.num_hours_test = Sim.hours_per_day*Sim.num_days_test;
Sim.num_hours_sel = Sim.hours_per_day*Sim.num_days_sel;

%% Generate PFEM grid-serach rows
PFEM.num = length(PFEM.alphas)*length(PFEM.betas)*...
    length(PFEM.gammas)*length(PFEM.deltas);
PFEM.loss = cell(PFEM.num, 1);
PFEM.allVals = zeros(PFEM.num, 4);
thisPar = 1;
for alpha = PFEM.alphas
    for beta = PFEM.betas
        for gamma = PFEM.gammas
            for delta = PFEM.deltas
                PFEM.loss{thisPar} = @(t, y) loss_par(t, y, ...
                    [alpha, beta, gamma, delta]);
                PFEM.allVals(thisPar, :) = [alpha, beta, gamma, delta];
                thisPar = thisPar + 1;
            end
        end
    end
end

%% Generate EMD grid-serach rows
EMD.num = length(EMD.as)*length(EMD.bs)*length(EMD.cs)*length(EMD.ds);
EMD.loss = cell(EMD.num, 1);
EMD.allVals = zeros(EMD.num, 4);
thisPar = 1;
for a = EMD.as
    for b = EMD.bs
        for c = EMD.cs
            for d = EMD.ds
                EMD.loss{thisPar} = @(t, y) loss_emd_par(t, y, ...
                    [a, b, c, d]);
                EMD.allVals(thisPar, :) = [a, b, c, d];
                thisPar = thisPar + 1;
            end
        end
    end
end

%% Generate list of loss fcn handles and labels
Sim.lossTypes = [{@loss_mse, @loss_mape}, PFEM.loss', EMD.loss'];
Sim.lossTypesStrings = cell(1, length(Sim.lossTypes)+4);
PFEM.range = (1:PFEM.num) + (length(Sim.lossTypes)-EMD.num-PFEM.num);
EMD.range = (1:EMD.num) + (length(Sim.lossTypes)-EMD.num);

Sim.lossTypesStrings(1, 1:length(Sim.lossTypes)) = ...
    cellfun(@func2str, Sim.lossTypes, 'UniformOutput', false);

counter1 = 1;
counter2 = 1;
for ii = 1:length(Sim.lossTypes)
    if ii > (length(Sim.lossTypes) - PFEM.num - EMD.num)
        if ii <= (length(Sim.lossTypes) - EMD.num)
            Sim.lossTypesStrings{ii} = [Sim.lossTypesStrings{ii} num2str(counter1)];
            counter1 = counter1 + 1;
        else
            Sim.lossTypesStrings{ii} = [Sim.lossTypesStrings{ii} num2str(counter2)];
            counter2 = counter2 + 1;
        end
    end
end

Sim.lossTypesStrings(1, length(Sim.lossTypes)+(1:4)) = ...
    {'fcastFree', 'naivePeriodic', 'godCast', 'setPoint'};

Sim.nTrainMethods = length(Sim.lossTypes);
Sim.nMethods = length(Sim.lossTypesStrings);

%% Pre-Allocation
timeTaken = cell(Sim.numInstances, 1);
pars = cell(Sim.numInstances, Sim.nTrainMethods+1);

for instance = 1:Sim.numInstances
    timeTaken{instance} = zeros(Sim.nTrainMethods+1,1);
end

Sim.tr_idxs = 1:(Sim.steps_per_hour*Sim.num_hours_train);
Sim.hour_numbers = mod((1:size(all_demand_vals{1}, 1))', k);
Sim.hour_numbers_tr = Sim.hour_numbers(Sim.tr_idxs, :);

trControl.hour_numbers_tr = Sim.hour_numbers_tr;

% Extract local variables for efficiency:
numInstances = Sim.numInstances;
nTrainMethods = Sim.nTrainMethods;
lossTypes = Sim.lossTypes;
tr_idxs = Sim.tr_idxs;
hours_per_day = Sim.hours_per_day;
steps_per_hour = Sim.steps_per_hour;
battCapRatio = Sim.battCapRatio;
num_hours_train = Sim.num_hours_train;
batt_charge_factor = Sim.batt_charge_factor;  % ratio of charge rate to batt_cap
hour_numbers_tr = Sim.hour_numbers_tr;
num_train_shuffles = Sim.num_train_shuffles;
num_days_swap = Sim.num_days_swap;
nHidden = Sim.nHidden;
lossTypesStrings = Sim.lossTypesStrings;
steps_per_day = Sim.steps_per_day;

%% Train Models
poolobj = gcp('nocreate');
delete(poolobj);

parfor instance = 1:numInstances
    % Avoid parfor errors
    tempTic = [];
    % Extract aggregated demand
    demand_vals_tr = all_demand_vals{instance}(tr_idxs);
    for fcType = 1:(nTrainMethods+1)
        if ~strcmp(lossTypesStrings{fcType}, 'fcastFree') %#ok<PFBNS>
            tempTic = tic;
            pars{instance, fcType} = ...
                train_FFNN_multStart( demand_vals_tr, k,  ...
                lossTypes{fcType}, trControl); %#ok<PFBNS>
            timeTaken{instance}(fcType) = toc(tempTic);
        else
            
            % Train fcastFree model
            meankWh = mean(demand_vals_tr);
            
            % Seperate training data into initialisation (1-day) and training
            % (rest)
            days_init = 1;
            in_idxs = 1:(days_init*steps_per_day);
            demand_vals_in = demand_vals_tr(in_idxs, :);
            demand_vals_tr = demand_vals_tr(setdiff(tr_idxs, in_idxs), :);
            
            % Create 'historical load pattern' used for initialisation etc.
            load_pattern_in = mean(reshape(demand_vals_in, ...
                [k, length(demand_vals_in)/k]), 2);
            
            % Create the 'god forecast' for training data
            godCast = zeros(size(demand_vals_tr, 1), k);
            for ii = 1:k
                godCast(:, ii) = circshift(demand_vals_tr, -[ii-1, 0]);
            end
            
            % Set-up parameters for on-line simulation
            batt_cap = meankWh*battCapRatio*steps_per_day;
            max_charge_rate = batt_charge_factor*batt_cap;
            simRange_tr = [0 num_hours_train - hours_per_day*days_init ...
                - 1/steps_per_hour];
            
            hour_numbers_tr_ = hour_numbers_tr(setdiff(tr_idxs,...
                in_idxs)); %#ok<PFBNS>
            
            runControl = [];
            runControl.MPC = MPC;
            
            % Run On-line Model to create training examples
            [ featVec, decVec] = ...
                onlineMPC_genFcastFreeExamples( simRange_tr, godCast, ...
                demand_vals_tr, batt_cap, max_charge_rate, load_pattern_in, ...
                hour_numbers_tr_, steps_per_hour, k, runControl);
            
            allFeatVec = zeros(size(featVec, 1), length(...
                demand_vals_tr)*(num_train_shuffles + 1));
            
            allDecVec = zeros(size(decVec, 1), length(...
                demand_vals_tr)*(num_train_shuffles + 1));
            
            allFeatVec(:, 1:length(demand_vals_tr)) = featVec;
            allDecVec(:, 1:length(demand_vals_tr)) = decVec;
            offset = length(demand_vals_tr);
            
            % Continue generating examples with suffled versions of
            % training data:
            for eachShuffle = 1:num_train_shuffles
                new_demand_vals_tr = demand_vals_tr;
                for eachSwap = 1:num_days_swap
                    thisSwapStart = randi(length(demand_vals_tr) - 2*k);
                    tmp = new_demand_vals_tr(thisSwapStart + (1:k));
                    new_demand_vals_tr(thisSwapStart + (1:k)) = ...
                        new_demand_vals_tr(thisSwapStart + (1:k) + k);
                    new_demand_vals_tr(thisSwapStart + (1:k) + k) = tmp;
                end
                [ featVec, decVec] = ...
                    onlineMPC_genFcastFreeExamples( simRange_tr, godCast,...
                    new_demand_vals_tr, batt_cap, max_charge_rate, ...
                    load_pattern_in, hour_numbers_tr_, steps_per_hour, k, runControl);
                
                allFeatVec(:, offset + (1:length(demand_vals_tr))) = ...
                    featVec;
                allDecVec(:, offset + (1:length(demand_vals_tr))) = ...
                    decVec;
                offset = offset + length(demand_vals_tr);
            end
            
            % Train fcast-free NN model based on these examples
            pars{instance, fcType} = genFcastFreeController(allFeatVec,...
                allDecVec, nHidden, trControl.nStart);
            
            timeTaken{instance}(fcType) = toc(tempTic);
        end
    end
end

poolobj = gcp('nocreate');
delete(poolobj);

Sim.timeTaken = timeTaken;
Sim.timeFcastTrain = toc;

disp('Time to end fcast train:'); disp(Sim.timeFcastTrain);

end
