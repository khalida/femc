%% Load Running Configuration
tic;
timeStart = clock;
disp(timeStart);

Config;

%% Add path to the common functions (& any subfolders therein)
[parentFold, ~, ~] = fileparts(pwd);
commonFcnFold = [parentFold filesep 'functions'];
addpath(genpath(commonFcnFold), '-BEGIN');

%% Delete old and compile new mex files
% if updateMex, compileMexes; end;

%% Read in DATA
load(dataFileWithPath);

%% Extract useful demand data only
if makeForecast
    customerIdxs = cell(Sim.nInstances, 1);
    allDemandValues = cell(Sim.nInstances, 1);
    dataLengthRequired = (Sim.nDaysTrain + Sim.nDaysSelect +...
        Sim.nDaysTest)*Sim.stepsPerHour*Sim.hoursPerDay;
    
    instance = 0;
    for nCustomerIdx = 1:length(Sim.nCustomers)
        for trial = 1:Sim.nAggregates
            instance = instance + 1;
            customers = Sim.nCustomers(nCustomerIdx);
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
if makeForecast
    disp('======= FORECAST TRAINING =======');
    [ Pfem, Pemd, Sim, pars ] = ...
        trainAllForecasts( Pfem, Pemd, MPC, Sim, allDemandValues,...
        trainControl, k);
    
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
[ Sim, results ] = testAllForecasts( pars, allDemandValues, Sim, ...
    Pemd, Pfem, MPC, k);

%% Do Plotting
disp('======= PLOTTING =======');

[significance] = plotAllResultsEdward(Sim, results, Pemd, Pfem);


%% Save Results
disp('======= SAVING =======');
save(Sim.finalFileName, '-v7.3');

overAllTime = toc;
disp('Total Time Taken: ');
disp(overAllTime);
