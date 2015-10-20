%% Running Parameters for Error Metric Selection

%% Instances
Sim.numCustomers = [1, 5, 25, 125];
Sim.numAggregates = 2;
Sim.numInstances = length(Sim.numCustomers) * Sim.numAggregates;
Sim.nProc = min(Sim.numInstances, 4);
Sim.numStochFcasts = 10;% 100;
Sim.relSizeError = 0.5;

%% Battery Properties
Sim.battCapRatio = 0.05;       % batt_cap as fraction of daily avg demand
Sim.batt_charge_factor = 1;     % ratio of charge rate to batt_cap

%% Simulation Duration and properties
Sim.num_days_train = 200; %200;       % days of historic demand data
Sim.num_days_sel = 56; %56;          % days over which to test forecast parameters
Sim.num_days_test = 56; %56;         % days to run simulation for
Sim.steps_per_hour = 2;         % Half-hourly data
Sim.hours_per_day = 24;
k = 48;                     % horizon & seasonality (assumed same)

%% Forecast training options
trControl.numHidden = 50; %50;
trControl.supp = true;
trControl.numStarts = 3;% 3;
trControl.mseEpochs = 1000;         % No. of MSE epochs for pre-training
trControl.includeTime = false;
trControl.modelPerStep = false;     % Train 1 model for each t-step?
trControl.minimiseOverFirst = 48;   % # of fcast steps to minimise over
if trControl.modelPerStep > trControl.includeTime
    error('To use forecast per step need to include time as an input');
end
trControl.batchSize = 1000;

% Forecast-free parameters
Sim.num_train_shuffles = 5; %5;         % # of shuffles to consider
Sim.num_days_swap = 25;             % pairs of days to swap per shuffle
Sim.nHidden = 250; %250;                  % For the fcast free controller FFNN

% PFEM Parameter Gridsearch points
PFEM.alphas = [2];% 2, 4
PFEM.betas = [2];%, 2, 4
PFEM.gammas = [2];%, 4, 10
PFEM.deltas = [1];%, 2, 3

% EMD Parameter Gridsearch points
EMD.as = [10];%#ok<*NBRAK> %, 200
EMD.bs = [0.5];%, 0.75, 1
EMD.cs = [0.5];%, 0.75, 1
EMD.ds = [4];%, 10, 20 a*b must be >= d

%% MPC options
MPC.secondWeight = 1e-4; 		% Weight of degeneracy preventing Objective
MPC.knowCurrentDemand = false;  % Is current demand known to controller?
MPC.clipNegativeFcast = true;
MPC.iterFactor = 1.0;			% Factor to apply to default max # of iter
MPC.rewardMargin = false;		% Reward margin from creating a new peak?
MPC.SPrecourse = true;			% whether or not to allow setPoint recourse
MPC.billingPeriodDays = 1;
MPC.resetPeakToMean = false;
MPC.maxParForTypes = 4;
MPC.chargeWhenCan = false;

%% Data filenames
dataFileWithPath = ...
    ['..' filesep 'data' filesep 'demand_3639.mat'];

numCustString = '';
for ii = 1:length(Sim.numCustomers);
    numCustString = [numCustString num2str(Sim.numCustomers(ii)) '_']; 
    %#ok<*AGROW>
end

if MPC.knowCurrentDemand
    CDstring = '_withCD';
else
    CDstring = '_noCD';
end

Sim.intermediateFileName = ['nCust_' numCustString '_batt_'...
    num2str(100*Sim.battCapRatio) 'pc__nAgg_' num2str(Sim.numAggregates) CDstring '_intermediate.mat'];

Sim.finalFileName = ['nCust_' numCustString '_batt_'...
    num2str(100*Sim.battCapRatio) 'pc__nAgg_' num2str(Sim.numAggregates) CDstring '.mat'];

Sim.visiblePlots = 'on';

%% Misc.
updateMex = false;
makeForecast = true;
