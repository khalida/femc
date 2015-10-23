%% Load Running Configuration
tic;
timeStart = clock;
disp(timeStart);

Config;

%% Source files for Common Functions
[parentFold, ~, ~] = fileparts(pwd);
commonFcnFold = [parentFold filesep 'functions'];
addpath(commonFcnFold, '-BEGIN');

%% Update compiled MEX Files (generally not required)
if updateMex
    mexFileNames = dir([commonFcnFold filesep '*.mex*']);
    for item = 1:length(mexFileNames);
        delete([commonFcnFold filesep mexFileNames(item).name]);
    end
    % Re-compile EMD mex files
    compile_FastEMD;
end

%% Read in DATA
load(dataFileWithPath);
rng('default');             % seed for repeatability

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
end

%% Train All Forecasts (or load intermediate file)
if makeForecast
    disp('======= FORECAST TRAINING =======');
    [ PFEM, EMD, Sim, pars ] = ...
        trainAllFcasts( PFEM, EMD, MPC, Sim, all_demand_vals,...
        trControl, k);
    
    % Save intermediate file
    save(Sim.intermediateFileName, '-v7.3');
else
    disp('======= LOADING FORECAST =======');
    load(Sim.intermediateFileName);
    makeForecast = false;
    disp('======= done =======');
end

%% Test All Forecasts:
disp('======= FORECAST SELECTION / TESTING =======');
[ Sim, results ] = testAllFcasts( pars, all_demand_vals, Sim, ...
    EMD, PFEM, MPC, k);

%% Do Plotting
disp('======= PLOTTING =======');
% [significance] = plotAllResults(Sim, results, EMD, PFEM);
[significance] = plotAllResultsEdward(Sim, results, EMD, PFEM);


%% Save Results
disp('======= SAVING =======');
save(Sim.finalFileName, '-v7.3');

overAllTime = toc;
disp('Total Time Taken: ');
disp(overAllTime);
