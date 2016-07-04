tic;

%% Load Functions
LoadFunctions;

disp('======= LOADING FORECAST =======');
load('..\results\2016_06_29_collect_FFNN_24ea_results\nCust_1000__batt_5pc__nAgg_6_noDN_intermediate.mat');
cfg.sav.resultsDir = '..\results\2016_06_29_collect_FFNN_24ea_results';
cfg.sav.finalFileName = [cfg.sav.resultsDir filesep 'nCust_1000__batt_5pc__nAgg_6_noDN'];
cfg.sim.eps = 1e-3;

%% Test All Forecasts:
disp('======= FORECAST SELECTION / TESTING =======');
[ cfg, results ] = testAllForecasts( cfg, pars, allDemandValues);

%% Save Results
disp('======= SAVING =======');
save(cfg.sav.finalFileName, '-v7.3');

%% Do Plotting
disp('======= PLOTTING =======');
plotAllResultsMetricSelect(cfg, results);

testTime = toc;
disp('Test Time Taken: ');
disp(testTime);
