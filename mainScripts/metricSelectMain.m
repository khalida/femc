%% Tidy Up
clearvars; close all; clc;

%% Load Running Configuration
cfg = Config(pwd);

%% Load Functions
LoadFunctions;

%% Delete old and compile new mex files
if cfg.updateMex, compileMexes; end;
% cfg.makeForecast = false;

%% Extract useful demand data only
if cfg.makeForecast
    %% Read in DATA
    load(cfg.sim.dataFileWithPath); % demandData is [nTimestamp x nMeters]
    customerIdxs = cell(cfg.sim.nInstances, 1);
    allDemandValues = cell(cfg.sim.nInstances, 1);
    dataLengthRequired = (cfg.sim.nDaysTrain + cfg.sim.nDaysSelect +...
        cfg.sim.nDaysTest)*cfg.sim.stepsPerHour*cfg.sim.hoursPerDay;
    
    instance = 0;
    for nCustomerIdx = 1:length(cfg.sim.nCustomers)
        for trial = 1:cfg.sim.nAggregates
            instance = instance + 1;
            customers = cfg.sim.nCustomers(nCustomerIdx);
            customerIdxs{instance} = ...
                randsample(size(demandData, 2), customers);
            
            allDemandValues{instance} = ...
                sum(demandData(1:dataLengthRequired,...
                customerIdxs{instance}), 2);
        end
    end
    
    % Delete the original demand data (no longer needed)
    clearvars demandData;
end

%% Train All Forecasts (or load intermediate file)
if cfg.makeForecast
    disp('======= FORECAST TRAINING =======');
    [ cfg, pars ] = trainAllForecasts(cfg, allDemandValues);
    
    % Save intermediate file
    save(cfg.sav.intermediateFileName, '-v7.3');
else
    disp('======= LOADING FORECAST =======');
    load(cfg.sav.intermediateFileName);
    makeForecast = false;
    disp('======= done =======');
end

%% Test All Forecasts:
disp('======= FORECAST SELECTION / TESTING =======');
[ cfg, results ] = testAllForecasts( cfg, pars, allDemandValues);

%% Do Plotting
disp('======= PLOTTING =======');
plotAllResultsMetricSelect(cfg, results);

%% Save Results
disp('======= SAVING =======');
save(cfg.sav.finalFileName, '-v7.3');

overAllTime = toc;
disp('Total Time Taken: ');
disp(overAllTime);
