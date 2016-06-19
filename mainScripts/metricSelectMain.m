%% Load Functions
LoadFunctions;

%% Load Config if not already done:
if ~exist('cfg', 'var')
    cfg = Config(pwd);
    doPlot = true;
else
    doPlot = false;
end

%% Delete old and compile new mex files
if cfg.updateMex, compileMexes; end;
% cfg.makeForecast = false;

%% Load Data, and extract that data which is to be used
if cfg.makeForecast
    %% Read in DATA
    load(cfg.sim.dataFileWithPath);
    % Loads 'demandData' into workspace, a [nTimestamp x nMeters] matrix
    customerIdxs = cell(cfg.sim.nInstances, 1);
    allDemandValues = cell(cfg.sim.nInstances, 1);
    dataLengthRequired = (cfg.sim.nDaysTrain + cfg.sim.nDaysSelect +...
        cfg.sim.nDaysTest)*cfg.sim.stepsPerDay;
    
    instance = 0;
    for nCustomerIdx = 1:length(cfg.sim.nCustomers)
        for trial = 1:cfg.sim.nAggregates
            instance = instance + 1;
            customers = cfg.sim.nCustomers(nCustomerIdx);
            
            % Select random aggregation of customers
            customerIdxs{instance} = ...
                randsample(size(demandData, 2), customers);
            
            % And sum their demands for each interval
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

%% Save Results
disp('======= SAVING =======');
save(cfg.sav.finalFileName, '-v7.3');

%% Do Plotting
if doPlot
    disp('======= PLOTTING =======');
    plotAllResultsMetricSelect(cfg, results);
end

overAllTime = toc;
disp('Total Time Taken: ');
disp(overAllTime);
