fileNames = {...
    '..\results\2016_06_29_collect_SARMA_36ea_results\nCust_1__batt_5pc__nAgg_12_noDN.mat' ...
    '..\results\2016_06_29_collect_SARMA_36ea_results\nCust_10__batt_5pc__nAgg_12_noDN.mat' ...
    '..\results\2016_06_29_collect_SARMA_36ea_results\nCust_100__batt_5pc__nAgg_12_noDN.mat' ...
    '..\results\2016_06_29_collect_SARMA_36ea_results\nCust_1000__batt_5pc__nAgg_12_noDN.mat'};

outFile = ...
    '..\results\2016_06_29_collect_SARMA_36ea_results\nCust_1_10_100_1000__batt_5pc__nAgg_12_noDN.mat';

recombineResults(fileNames, outFile);
