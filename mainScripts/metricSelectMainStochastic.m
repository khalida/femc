%% Load Running Configuration (includes rng seed)
overAllTic = tic;
timeStart = clock;
disp(timeStart);
Config;

%% Add path to the common functions (& any subfolders therein)
[parentFold, ~, ~] = fileparts(pwd);
commonFunctionFolder = [parentFold filesep 'functions'];
addpath(genpath(commonFunctionFolder), '-BEGIN');

%% Update compiled MEX Files (generally not required)
if updateMex, compileMexes; end;

%% Read in DATA
load(dataFileWithPath);

if makeForecast
    
    %% Extract useful demand data only
    customerIdxs = cell(Sim.nInstances, 1);
    allDemandValues = cell(Sim.nInstances, 1);
    dataLengthRequired = (Sim.nDaysTrain + Sim.nDaysSelect +...
        Sim.nDaysTest)*Sim.stepsPerHour*Sim.hoursPerDay;
    
    instance = 0;
    for nCustIdx = 1:length(Sim.nCustomers)
        for trial = 1:Sim.nAggregates
            instance = instance + 1;
            customers = Sim.nCustomers(nCustIdx);
            customerIdxs{instance} = ...
                randsample(size(demandData, 2), customers);
            allDemandValues{instance} = ...
                sum(demandData(1:dataLengthRequired, customerIdxs{instance}), 2);
        end
    end
    
    % Delete the original demand data (no longer needed)
    clearvars demandData;
    
    %% Simulate on-line control over the selection data-set
    % and based on performance of various error metrics choose the
    % best parameters of PFEM and PEMD forecast.
    
    [bestPfemIdx, bestPemdIdx, Pfem, Pemd, Sim] = assessAllMetrics(...
        Pfem, Pemd, Sim, allDemandValues, k, MPC);
    
    % Add bestPfem and bestPemd forecast types - only the parameter values
    % selected for each instance will be trained
    
    Sim.lossTypesStrings = Sim.lossTypesStrings(...
        setdiff((1:Sim.nTrainMethods), [Pfem.range Pemd.range]));
    
    % Also remove these from the 'allMethodStrings' array:
    Sim.allMethodStrings = [Sim.lossTypesStrings, Sim.additionalMethods];
    
    % Add bestPFEM, bestEMD
    if Pfem.num > 0
        Sim.lossTypesStrings = [Sim.lossTypesStrings {'bestPfemSelected'}];
        Sim.allMethodStrings = [Sim.allMethodStrings {'bestPfemSelected'}];
    else
        bestPfemIdx = zeros(Sim.nInstances, 1);
    end
    
    if Pemd.num > 0
        Sim.lossTypesStrings = [Sim.lossTypesStrings {'bestPemdSelected'}];
        Sim.allMethodStrings = [Sim.allMethodStrings {'bestPemdSelected'}];
    else
        bestPemdIdx = zeros(Sim.nInstances, 1);
    end
    
    Sim.nMethods = length(Sim.allMethodStrings);
    Sim.nTrainMethods = length(Sim.lossTypesStrings);
    
    %% Train Selected Forecasts (or load intermediate file)
    disp('======= FORECAST TRAINING =======');
    [ Pfem, Pemd, Sim, pars ] = ...
        trainBestForecasts( Pfem, Pemd, MPC, Sim, allDemandValues,...
        trainControl, k, bestPfemIdx, bestPemdIdx);
    
    % Save intermediate file
    save([Sim.intermediateFileName(1:(end-4)) 'Stochastic.mat'], '-v7.3');
else
    disp('======= LOADING FORECAST =======');
    load([Sim.intermediateFileName(1:(end-4)) 'Stochastic.mat']);
    makeForecast = false;
    disp('======= done =======');
end

%%
disp('======= FORECAST SELECTION / TESTING =======');
[ Sim, results ] = testBestForecasts( pars, allDemandValues, Sim, MPC, k);

%%
disp('======= PLOTTING =======');
plotResultsStochasticSelection(Sim, results);

%%
disp('======= SAVING =======');
save([Sim.finalFileName(1:(end-4)) 'Stochastic.mat'], '-v7.3');

overAllTime = toc(overAllTic);
disp('Total Time Taken: ');
disp(overAllTime);
