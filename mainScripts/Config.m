%% Global Configuration File

%% Instances
Sim.nCustomers = [1, 5, 25, 125];
Sim.nAggregates = 2;
Sim.nInstances = length(Sim.nCustomers) * Sim.nAggregates;
Sim.nProc = min(Sim.nInstances, 4);
Sim.numStochFcasts = 10;% 100;
Sim.relativeSizeError = 0.5;

%% Battery Properties
Sim.batteryCapacityRatio = 0.05; % as fraction of daily average demand
Sim.batteryChargingFactor = 1;   % ratio of charge rate to capacity

%% Simulation Duration and properties
Sim.nDaysTrain = 200;    %200;   % days of historic demand data
Sim.nDaysSelect = 56;    %56;    % to select forecast parameters
Sim.nDaysTest = 56;      %56;    % days to run simulation for
Sim.stepsPerHour = 2;   % Half-hourly data
Sim.hoursPerDay = 24;
k = 48;                 % horizon & seasonality (assumed same)

%% Forecast training options
trainControl.nHidden = 50; %50;
trainControl.suppressOutput = true;
trainControl.nStart = 3;% 3;
trainControl.mseEpochs = 1000;        % No. of MSE epochs for pre-training
trainControl.minimiseOverFirst = 48;  % # of fcast steps to minimise over
trainControl.batchSize = 1000;              
trainControl.maxTime = 5;                  % maximum training time in mins
trainControl.maxEpochs = 1000;              % maximum No. of epochs
trainControl.trainRatio = 0.9;              % to train each net on
trainControl.nLags = k;
trainControl.horizon = k;
trainControl.performanceDifferenceThreshold = 0.02;
trainControl.nBestToCompare = 3;
trainControl.nDaysPreviousTrainSarma = 20;
trainControl.useHyndmanModel = false;

% Forecast-free parameters
Sim.nTrainShuffles = 5; %5;     % # of shuffles to consider
Sim.nDaysSwap = 25;             % pairs of days to swap per shuffle
Sim.nHidden = 250; %250;        % For the fcast free controller FFNN

% PFEM Parameter Gridsearch points
Pfem.alphas = [2];% 2, 4
Pfem.betas = [2];%, 2, 4
Pfem.gammas = [2];%, 4, 10
Pfem.deltas = [1];%, 2, 3

% EMD Parameter Gridsearch points
Pemd.as = [10];%#ok<*NBRAK> %, 200
Pemd.bs = [0.5];%, 0.75, 1
Pemd.cs = [0.5];%, 0.75, 1
Pemd.ds = [4];%, 10, 20 a*b must be >= d

%% MPC options
MPC.secondWeight = 1e-4; 		% of degeneracy preventing Objective
MPC.knowCurrentDemandNow = true;  % Is current demand known to controller?
MPC.clipNegativeFcast = true;
MPC.iterationFactor = 1.0;		% To apply to default maximum iterations
MPC.rewardMargin = false;		% Reward margin from creating a new peak?
MPC.SPrecourse = true;			% whether or not to allow setPoint recourse
MPC.billingPeriodDays = 7;
MPC.resetPeakToMean = true;
MPC.maxParForTypes = 4;
MPC.chargeWhenCan = false;
MPC.suppressOutput = trainControl.suppressOutput;

%% Data filenames
dataFileWithPath = ...
    ['..' filesep 'data' filesep 'demand_3639.mat'];

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

Sim.intermediateFileName = ['nCust_' nCustString '_batt_'...
    num2str(100*Sim.batteryCapacityRatio) 'pc__nAgg_' ...
    num2str(Sim.nAggregates) CDstring '_intermediate.mat'];

Sim.finalFileName = ['nCust_' nCustString '_batt_'...
    num2str(100*Sim.batteryCapacityRatio) 'pc__nAgg_' ...
    num2str(Sim.nAggregates) CDstring '.mat'];

Sim.visiblePlots = 'on';

%% Misc.
updateMex = true;
makeForecast = true;
rng(42)