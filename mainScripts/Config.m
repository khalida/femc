%% Global Configuration File

%% Instances
Sim.nCustomers = [5, 125];
Sim.nAggregates = 2;
Sim.nInstances = length(Sim.nCustomers) * Sim.nAggregates;
Sim.nProc = min(Sim.nInstances, 2);
Sim.nStochasticForecasts = 5;        % 100;
Sim.relativeSizeError = 1.0;

%% Battery Properties
Sim.batteryCapacityRatio = 0.05;    % as fraction of daily average demand
Sim.batteryChargingFactor = 1;      % ratio of charge rate to capacity

%% Simulation Duration and properties
Sim.nDaysTrain = 200;       %200;   % days of historic demand data
Sim.nDaysSelect = 56;       %56;    % to select forecast parameters
Sim.nDaysTest = 56;         %56;    % days to run simulation for
Sim.stepsPerHour = 2;       % Half-hourly data
Sim.hoursPerDay = 24;
k = 48;                 % horizon & seasonality (assumed same)

%% Forecast training options
trainControl.nHidden = 5; %50;
trainControl.suppressOutput = true;
trainControl.nStart = 1; %3;
trainControl.mseEpochs = 100; %1000; % No. of MSE epochs for pre-training
trainControl.minimiseOverFirst = 48;  % # of fcast steps to minimise over
trainControl.batchSize = 100; %1000;
trainControl.maxTime = 2; %15;       % maximum training time in mins
trainControl.maxEpochs = 100; %1000; % maximum No. of epochs
trainControl.trainRatio = 0.9;        % to train each net on
trainControl.nLags = k;
trainControl.horizon = k;
trainControl.performanceDifferenceThreshold = 0.02;
trainControl.nBestToCompare = 3;
trainControl.nDaysPreviousTrainSarma = 20;
trainControl.useHyndmanModel = false;
trainControl.seasonality = k;

% Forecast-free parameters
Sim.nTrainShuffles = 1; %5;     % # of shuffles to consider
Sim.nDaysSwap = 3; %25         % pairs of days to swap per shuffle
Sim.nHidden = 25; %250;        % For the fcast free controller FFNN

% PFEM Parameter Gridsearch points
Pfem.alphas = [1, 4];     % 2
Pfem.betas = [1, 4];      % 2
Pfem.gammas = [1, 4];       % 2
Pfem.deltas = [1];        % 1

% EMD Parameter Gridsearch points
Pemd.as = 10;% [10, 40, 160];       % 10
Pemd.bs = 0.5;% [0.5, 1, 2];         % 0.5
Pemd.cs = 0.5;% [0.5, 1, 2];         % 0.5
Pemd.ds = 4;% [1, 2, 4];           % 4

% Other loss functions to consider, and additional control methods:
otherLossHandles = {@lossMse, @lossMape};
Sim.additionalMethods = {'forecastFree', 'naivePeriodic', 'godCast',...
    'setPoint'};

%% MPC options
MPC.secondWeight = 0;% 1e-4;    % of degeneracy preventing Objective
MPC.knowCurrentDemandNow = false;  % Is current demand known to controller?
MPC.clipNegativeFcast = true;
MPC.iterationFactor = 1.0;		% To apply to default maximum iterations
MPC.rewardMargin = false;% true;		% Reward margin from creating a new peak?
MPC.SPrecourse = true;			% whether or not to allow setPoint recourse
MPC.billingPeriodDays = 7;
MPC.resetPeakToMean = false;
MPC.maxParForTypes = 4;
MPC.chargeWhenCan = false;
MPC.suppressOutput = trainControl.suppressOutput;

%% Data filename
dataFileWithPath = ...
    ['..' filesep 'data' filesep 'demand_3639.mat'];

Sim.visiblePlots = 'on';

%% Misc.
updateMex = true;
makeForecast = true;
rng(42)

%% Produce 'derived' values:
Sim.stepsPerDay = Sim.stepsPerHour*Sim.hoursPerDay;
Sim.nHoursTrain = Sim.hoursPerDay*Sim.nDaysTrain;
Sim.nHoursTest = Sim.hoursPerDay*Sim.nDaysTest;
Sim.nHoursSelect = Sim.hoursPerDay*Sim.nDaysSelect;

nCustString = '';
for ii = 1:length(Sim.nCustomers);
    nCustString = [nCustString num2str(Sim.nCustomers(ii)) '_'];
    %#ok<*AGROW>
end

if MPC.knowCurrentDemandNow
    CDstring = '_withCD';
else
    CDstring = '_noCD';
end

Sim.intermediateFileName = ['..' filesep 'results' filesep 'nCust_' ...
    nCustString '_batt_' num2str(100*Sim.batteryCapacityRatio) ...
    'pc__nAgg_' num2str(Sim.nAggregates) CDstring '_intermediate.mat'];

Sim.finalFileName = ['..' filesep 'results' filesep 'nCust_' nCustString...
    '_batt_' num2str(100*Sim.batteryCapacityRatio) 'pc__nAgg_' ...
    num2str(Sim.nAggregates) CDstring '.mat'];

%% Generate PFEM grid-serach rows
Pfem.num = length(Pfem.alphas)*length(Pfem.betas)*...
    length(Pfem.gammas)*length(Pfem.deltas);
Pfem.loss = cell(Pfem.num, 1);
Pfem.allValues = zeros(Pfem.num, 4);
thisParameterization = 1;
for alpha = Pfem.alphas
    for beta = Pfem.betas
        for gamma = Pfem.gammas
            for delta = Pfem.deltas
                Pfem.loss{thisParameterization} = @(t, y) lossPfem(t, y, ...
                    [alpha, beta, gamma, delta]);
                Pfem.allValues(thisParameterization, :) = ...
                    [alpha, beta, gamma, delta];
                thisParameterization = thisParameterization + 1;
            end
        end
    end
end

%% Generate PEMD grid-serach rows
Pemd.num = length(Pemd.as)*length(Pemd.bs)*length(Pemd.cs)*length(Pemd.ds);
Pemd.loss = cell(Pemd.num, 1);
Pemd.allValues = zeros(Pemd.num, 4);
thisParameterization = 1;
for a = Pemd.as
    for b = Pemd.bs
        for c = Pemd.cs
            for d = Pemd.ds
                Pemd.loss{thisParameterization} = ...
                    @(t, y) lossPemd(t, y, [a, b, c, d]);
                Pemd.allValues(thisParameterization, :) = [a, b, c, d];
                thisParameterization = thisParameterization + 1;
            end
        end
    end
end

%% Generate list of loss function handles and labels
Sim.lossTypes = [otherLossHandles, Pfem.loss', Pemd.loss'];
Sim.lossTypesStrings = cell(1, length(Sim.lossTypes));
Pfem.range = (1:Pfem.num) + (length(Sim.lossTypes)-Pemd.num-Pfem.num);
Pemd.range = (1:Pemd.num) + (length(Sim.lossTypes)-Pemd.num);

Sim.lossTypesStrings(1, 1:length(Sim.lossTypes)) = ...
    cellfun(@func2str, Sim.lossTypes, 'UniformOutput', false);

% Add index values to the Pfem, Pemd labels (to stop them being same)
counter1 = 1;
counter2 = 1;
for ii = 1:length(Sim.lossTypes)
    if ii > (length(Sim.lossTypes) - Pfem.num - Pemd.num)
        if ii <= (length(Sim.lossTypes) - Pemd.num)
            Sim.lossTypesStrings{ii} = [Sim.lossTypesStrings{ii} num2str(counter1)];
            counter1 = counter1 + 1;
        else
            Sim.lossTypesStrings{ii} = [Sim.lossTypesStrings{ii} num2str(counter2)];
            counter2 = counter2 + 1;
        end
    end
end

Sim.allMethodStrings = [Sim.lossTypesStrings, Sim.additionalMethods];
Sim.nTrainMethods = length(Sim.lossTypes);
Sim.nMethods = length(Sim.allMethodStrings);
