function cfg = Config(pwd)

%% Global Configuration File

%% Save all configuration options in 'cfg' structure, divided into
% cfg.fc:   for forecast settings
% cfg.opt:  for optimisation settings
% cfg.sim:  for simulation settings
% cfg.plt:  for plotting settings
% cfg.sav:  for saving settings

%% Input Data file
[parentFold, ~, ~] = fileparts(pwd);
cfg.sim.dataFileWithPath = ...
    [parentFold filesep 'data' filesep 'demand_3639.mat'];

%% Results directory
timeStart = clock;
disp('Time started: '); disp(timeStart);

% Create timeString for folder in which to save data:
timeString = [num2str(timeStart(1)), '_',...
    num2str(timeStart(2),'%0.2d'), '_', ...
    num2str(timeStart(3),'%0.2d'), '_', num2str(timeStart(4),'%0.2d'), ...
    num2str(timeStart(5),'%0.2d')];

cfg.sav.resultsDir = [parentFold filesep 'results' filesep timeString];
mkdir(cfg.sav.resultsDir);

%% Instances
cfg.sim.nCustomers = [1, 5, 25, 125]; % [1, 5, 25, 125];
cfg.sim.nAggregates = 2;
cfg.sim.nInstances = length(cfg.sim.nCustomers) * cfg.sim.nAggregates;
cfg.sim.nProc = min(cfg.sim.nInstances, 4);
cfg.sim.nStochasticForecasts = 50;        % 100;
cfg.sim.relativeSizeError = 0.5;
cfg.fc.forecastModels = 'FFNN';         % 'SARMA', 'FFNN'

%% Battery Properties
cfg.sim.batteryCapacityRatio = 0.05;    % fraction of daily avg demand
cfg.sim.batteryChargingFactor = 1;      % ratio of charge rate:capacity

%% Simulation Duration and properties
cfg.sim.nDaysTrain = 200;       %200;   % days of historic demand data
cfg.sim.nDaysSelect = 56;      %56;    % to select forecast parameters
cfg.sim.nDaysTest = 56;        %56;    % days to run simulation for
cfg.sim.stepsPerHour = 2;      % Half-hourly data
cfg.sim.hoursPerDay = 24;
cfg.sim.k = 48;                % horizon & seasonality (assumed same)
cfg.sim.horizon = cfg.sim.k;

%% Forecast training options
cfg.fc.nHidden = 50; %50;
cfg.fc.suppressOutput = true;
cfg.fc.nStart = 3; %3;
cfg.fc.mseEpochs = 1000; %1000; % No. of MSE epochs for pre-training
cfg.fc.minimiseOverFirst = 48;  % # of fcast steps to minimise over
cfg.fc.batchSize = 1000; %1000;
cfg.fc.maxTime = 15; %15;       % maximum training time in mins
cfg.fc.maxEpochs = 1000; %1000; % maximum No. of epochs
cfg.fc.trainRatio = 0.8;        % to train each net on
cfg.fc.nLags = cfg.sim.k;
cfg.fc.horizon = cfg.sim.k;
cfg.fc.performanceDifferenceThreshold = 0.1;
cfg.fc.nBestToCompare = 1;
cfg.fc.nDaysPreviousTrainSarma = 10;
cfg.fc.useHyndmanModel = false;
cfg.fc.seasonality = cfg.sim.k;

% PFEM Parameter Gridsearch points
cfg.fc.Pfem.alphas = [1, 2, 4];     % 2
cfg.fc.Pfem.betas = [1, 2];      % 2
cfg.fc.Pfem.gammas = [1, 4];       % 2
cfg.fc.Pfem.deltas = [1, 2];        % 1

% EMD Parameter Gridsearch points
cfg.fc.Pemd.as = [50, 100, 200];       % 10
cfg.fc.Pemd.bs = [0.5, 1];         % 0.5
cfg.fc.Pemd.cs = [0.5, 1];         % 0.5
cfg.fc.Pemd.ds = [5, 10];           % 4

% Other loss functions to consider, and additional control methods:
cfg.fc.otherLossHandles = {@lossMse, @lossMape};
cfg.fc.additionalMethods = {'naivePeriodic', 'godCast', 'setPoint'};

%% (MPC) Optimization options
cfg.opt.secondWeight = 0;% 1e-4;      % of degeneracy-preventing Objective
cfg.opt.knowCurrentDemandNow = false; % Current demand known to optimizer?
cfg.opt.clipNegativeFcast = true;
cfg.opt.iterationFactor = 1.0;        % To apply to default max iterations
cfg.opt.rewardMargin = true;          % Reward margin from new pk?
cfg.opt.SPrecourse = true;            % use setPoint recourse?
cfg.opt.billingPeriodDays = 7;
cfg.opt.resetPeakToMean = true;
cfg.opt.maxParForTypes = 4;
cfg.opt.chargeWhenCan = false;
cfg.opt.suppressOutput = cfg.fc.suppressOutput;

cfg.sim.visiblePlots = 'on';

%% Misc.
cfg.updateMex = true;
cfg.makeForecast = true;
rng(42);
cfg.plt.savePlots = true;
cfg.sim.eps = 1e-10;


%% Produce Derived values (no new settings below this line)
cfg.sim.stepsPerDay = cfg.sim.stepsPerHour*cfg.sim.hoursPerDay;
cfg.sim.nHoursTrain = cfg.sim.hoursPerDay*cfg.sim.nDaysTrain;
cfg.sim.nHoursTest = cfg.sim.hoursPerDay*cfg.sim.nDaysTest;
cfg.sim.nHoursSelect = cfg.sim.hoursPerDay*cfg.sim.nDaysSelect;

nCustString = '';
for ii = 1:length(cfg.sim.nCustomers);
    nCustString = [nCustString num2str(cfg.sim.nCustomers(ii)) '_'];
    %#ok<*AGROW>
end

if cfg.opt.knowCurrentDemandNow
    CDstring = '_withCD';
else
    CDstring = '_noCD';
end

cfg.sav.intermediateFileName = [cfg.sav.resultsDir filesep 'nCust_' ...
    nCustString '_batt_' num2str(100*cfg.sim.batteryCapacityRatio) ...
    'pc__nAgg_' num2str(cfg.sim.nAggregates) CDstring '_intermediate.mat'];

cfg.sav.finalFileName = [cfg.sav.resultsDir filesep 'nCust_' nCustString...
    '_batt_' num2str(100*cfg.sim.batteryCapacityRatio) 'pc__nAgg_' ...
    num2str(cfg.sim.nAggregates) CDstring '.mat'];

%% Generate PFEM grid-serach rows
cfg.fc.Pfem.num = length(cfg.fc.Pfem.alphas)*length(cfg.fc.Pfem.betas)*...
    length(cfg.fc.Pfem.gammas)*length(cfg.fc.Pfem.deltas);
cfg.fc.Pfem.loss = cell(cfg.fc.Pfem.num, 1);
cfg.fc.Pfem.allValues = zeros(cfg.fc.Pfem.num, 4);
thisParameterization = 1;
for alpha = cfg.fc.Pfem.alphas
    for beta = cfg.fc.Pfem.betas
        for gamma = cfg.fc.Pfem.gammas
            for delta = cfg.fc.Pfem.deltas
                cfg.fc.Pfem.loss{thisParameterization} = ...
                    @(t, y) lossPfem(t, y, [alpha, beta, gamma, delta]);
                
                cfg.fc.Pfem.allValues(thisParameterization, :) = ...
                    [alpha, beta, gamma, delta];
                
                thisParameterization = thisParameterization + 1;
            end
        end
    end
end

%% Generate PEMD grid-serach rows
cfg.fc.Pemd.num = length(cfg.fc.Pemd.as)*length(cfg.fc.Pemd.bs)*...
    length(cfg.fc.Pemd.cs)*length(cfg.fc.Pemd.ds);

cfg.fc.Pemd.loss = cell(cfg.fc.Pemd.num, 1);
cfg.fc.Pemd.allValues = zeros(cfg.fc.Pemd.num, 4);
thisParameterization = 1;
for a = cfg.fc.Pemd.as
    for b = cfg.fc.Pemd.bs
        for c = cfg.fc.Pemd.cs
            for d = cfg.fc.Pemd.ds
                cfg.fc.Pemd.loss{thisParameterization} = ...
                    @(t, y) lossPemd(t, y, [a, b, c, d]);
                
                cfg.fc.Pemd.allValues(thisParameterization, :) = ...
                    [a, b, c, d];
                
                thisParameterization = thisParameterization + 1;
            end
        end
    end
end

%% Generate list of loss function handles and labels
cfg.fc.lossTypes = [cfg.fc.otherLossHandles, cfg.fc.Pfem.loss', ...
    cfg.fc.Pemd.loss'];

cfg.fc.lossTypesStrings = cell(1, length(cfg.fc.lossTypes));
cfg.fc.Pfem.range = (1:cfg.fc.Pfem.num) + ...
    (length(cfg.fc.lossTypes)-cfg.fc.Pemd.num-cfg.fc.Pfem.num);

cfg.fc.Pemd.range = (1:cfg.fc.Pemd.num) + ...
    (length(cfg.fc.lossTypes)-cfg.fc.Pemd.num);

cfg.fc.lossTypesStrings(1, 1:length(cfg.fc.lossTypes)) = ...
    cellfun(@func2str, cfg.fc.lossTypes, 'UniformOutput', false);

% Add index values to the Pfem, Pemd labels (to stop them being the same)
counter1 = 1;
counter2 = 1;
for ii = 1:length(cfg.fc.lossTypes)
    if ii > (length(cfg.fc.lossTypes) - cfg.fc.Pfem.num - cfg.fc.Pemd.num)
        if ii <= (length(cfg.fc.lossTypes) - cfg.fc.Pemd.num)
            cfg.fc.lossTypesStrings{ii} = ...
                [cfg.fc.lossTypesStrings{ii} num2str(counter1)];
            
            counter1 = counter1 + 1;
        else
            cfg.fc.lossTypesStrings{ii} = ...
                [cfg.fc.lossTypesStrings{ii} num2str(counter2)];
            
            counter2 = counter2 + 1;
        end
    end
end

cfg.fc.allMethodStrings = [cfg.fc.lossTypesStrings, ...
    cfg.fc.additionalMethods];

cfg.fc.nTrainMethods = length(cfg.fc.lossTypes);
cfg.fc.nMethods = length(cfg.fc.allMethodStrings);

% Save a copy of this Config file to results directory
copyfile([pwd filesep 'Config.m'], [cfg.sav.resultsDir filesep ...
    'thisConfig.m']);
end
