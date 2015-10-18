%% Load Running Configuration
overAllTic = tic;
timeStart = clock;
disp(timeStart);

Config;

%% Source files for Common Functions
[parentFold, ~, ~] = fileparts(pwd);
commonFcnFold = [parentFold filesep 'commonFunctions'];
addpath(commonFcnFold, '-BEGIN');

%% Update comiled MEX Files (generally not required)
if updateMex
    mexFileNames = dir([commonFcnFold filesep '*.mex*']);
    for item = 1:length(mexFileNames);
        delete([commonFcnFold filesep mexFileNames(item).name]);
    end
    % Re-compile EMD mex files
    % TODO: need to include compilation of any other mex files
    compile_FastEMD;
end

%% Read in DATA
load(dataFileWithPath);
rng('default');                         % seed for repeatability

%% Extract useful demand data only
if makeForecast
    customer_indices = cell(Sim.numInstances, 1);
    all_demand_vals = cell(Sim.numInstances, 1);
    dataLengthReq = (Sim.num_days_train + Sim.num_days_sel +...
        Sim.num_days_test)*Sim.steps_per_hour*Sim.hours_per_day;
    
    instance = 0;
    for nCustIndex = 1:length(Sim.numCustomers)
        for trial = 1:Sim.numAggregates
            instance = instance + 1;
            customers = Sim.numCustomers(nCustIndex);
            customer_indices{instance} = ...
                randsample(size(demandData, 2), customers);
            all_demand_vals{instance} = ...
                sum(demandData(1:dataLengthReq, customer_indices{instance}), 2);
        end
    end
    
    % Delete the original demand data (no longer needed)
    clearvars demandData;
    
    %% Based on full set of available parameters, simulate on-line control
    % over the selection data-set and based on performance of various error
    % metrics choose the best parameters of PFEM and EMD forecast.
    
    [bestPFEMidx, bestEMDidx, PFEM, EMD, Sim] = assessAllMetrics( PFEM, EMD, ...
        Sim, all_demand_vals, k, MPC);
    
    % Add bestPFEM and bestEMD forecast types - NB: only the forecast types
    % selected for each instance will actually be trained
    
    % Remove all of the parameterised loss-types
    Sim.lossTypesStrings = Sim.lossTypesStrings(setdiff(1:length(...
        Sim.lossTypesStrings), [PFEM.range EMD.range]));
    
    % Add bestPFEM, bestEMD
    if PFEM.num > 0
        Sim.lossTypesStrings = [Sim.lossTypesStrings {'bestPFEM'}];
    else
        bestPFEMidx = zeros(Sim.numInstances, 1);
    end
    
    if EMD.num > 0
        Sim.lossTypesStrings = [Sim.lossTypesStrings {'bestEMD'}];
    else
        bestEMDidx = zeros(Sim.numInstances, 1);
    end
    
    Sim.nMethods = length(Sim.lossTypesStrings);
    
    %% Train All Forecasts (or load intermediate file)
    disp('======= FORECAST TRAINING =======');
    [ PFEM, EMD, Sim, pars ] = ...
        trainBestFcasts( PFEM, EMD, MPC, Sim, all_demand_vals,...
        trControl, k, bestPFEMidx, bestEMDidx);
    
    % Save intermediate file
    save(Sim.intermediateFileName, '-v7.3');
else
    disp('======= LOADING FORECAST =======');
    load(Sim.intermediateFileName);
    makeForecast = false;
    disp('======= done =======');
end

%%
disp('======= FORECAST SELECTION / TESTING =======');
[ Sim, results ] = testBestFcasts( pars, all_demand_vals, Sim, ...
    MPC, k);

%%
disp('======= PLOTTING =======');
[significance] = plotResultsStoch(Sim, results);

%%
disp('======= SAVING =======');
save(Sim.finalFileName, '-v7.3');

overAllTime = toc(overAllTic);
disp('Total Time Taken: ');
disp(overAllTime);
