function [ AOK ] = recombineResults( inFileNames, outFile )
%recombineResults: Function to read multiple saved files, combine & plot
%                   results, and save single output file

% INPUTS:
% inFileNames:  Cell of strings containing the input files
% outFile:      String where combined file should be saved

% OUTPUTS:
% AOK:          Boolean returns true if all goes well

%% LOAD in DATA; assume that each nCustomer will only appear in one file
% and that all files will have the same cfg.sim.nAggregates (check for
% this)
cfgAll = [];
resultsAll = [];
for fileIdx = 1:length(inFileNames)
    thisFile = inFileNames{fileIdx};
    load(thisFile);
    
    % Either read in cfg file, or increment nCustomers list
    if isempty(cfgAll)
        cfgAll = cfg; %#ok<*NODEF>
    else
        cfgAll.sim.nCustomers = [cfgAll.sim.nCustomers, ...
            cfg.sim.nCustomers];
        
        if rem(cfgAll.sim.nInstances, cfg.sim.nInstances)~=0
            error(['All files expected to have same No. instances, ' ...
                'cfgAll.sim.nInstances:' num2str(cfgAll.sim.nInstances)...
                ', cfg.sim.nInstances:' num2str(cfg.sim.nInstances)]);
        end
        cfgAll.sim.nInstances = cfgAll.sim.nInstances + ...
            cfg.sim.nInstances;
    end
    
    % Either read in results list, or add in appropriate results
    if isempty(resultsAll)
        resultsAll = results;
    else
        % Need to add in all results in appropriate dimension
        % peakReductions: [method, trial, nCustomerIdx]
        resultsAll.peakReductions = cat(3, resultsAll.peakReductions, ...
            results.peakReductions);
        
        % peakReductionsTrialFlattened: [nMethods, nInstances]
        resultsAll.peakReductionsTrialFlattened = cat(2, ...
            resultsAll.peakReductionsTrialFlattened, ...
            results.peakReductionsTrialFlattened);
        
        % peakPowers: [method, trial, nCustomerIdx]
        resultsAll.peakPowers = cat(3, resultsAll.peakPowers, ...
            results.peakPowers);
        
        % peakPowersTrialFlattened: [nMethods, nInstances]
        resultsAll.peakPowersTrialFlattened = cat(2, ...
            resultsAll.peakPowersTrialFlattened, ...
            results.peakPowersTrialFlattened);
        
        % smallestExitFlag: [method, trial, nCustomerIdx]
        resultsAll.smallestExitFlag = cat(3, ...
            resultsAll.smallestExitFlag, results.smallestExitFlag);
        
        % meanKWhs: [trial, nCustomerIdx]
        resultsAll.meanKWhs = cat(2, resultsAll.meanKWhs, ...
            results.meanKWhs);
        
        % lossTestResults: [method, trial, nCustomerIdx, metric]
        resultsAll.lossTestResults = cat(3, ...
            resultsAll.lossTestResults, results.lossTestResults);
        
        % bestPfemForecast: [instances, 1]
        resultsAll.bestPfemForecast = cat(1, ...
            resultsAll.bestPfemForecast, results.bestPfemForecast);
        
        % bestPemdForecast: [instances, 1]
        resultsAll.bestPemdForecast = cat(1, ...
            resultsAll.bestPemdForecast, results.bestPemdForecast);
        
        % bestPfemForecastArray: [trail, nCustomerIdx]
        resultsAll.bestPfemForecastArray = cat(2, ...
            resultsAll.bestPfemForecastArray, ...
            results.bestPfemForecastArray);
        
        % bestPemdForecastArray: [trail, nCustomerIdx]
        resultsAll.bestPemdForecastArray = cat(2, ...
            resultsAll.bestPemdForecastArray, ...
            results.bestPemdForecastArray);
        
    end
end

%% Check that nInstances matches expected value
if cfgAll.sim.nInstances ~= (length(cfgAll.sim.nCustomers)*...
        cfgAll.sim.nAggregates)
    
    error(['No. of instances doesnt add up. cfgAll.sim.nInstances:' ...
        num2str(cfgAll.sim.nInstances) ', (length(cfgAll.sim.nCustomers)*'...
        'cfgAll.sim.nAggregates):' num2str((length(cfgAll.sim.nCustomers)*...
        cfgAll.sim.nAggregates))]);
end

%% Rename to expected variable names, and clear unused ones, then save
cfg = cfgAll; results = resultsAll;
clearvars cfgAll resultsAll;
disp('======= SAVING =======');
save(outFile, '-v7.3');

%% Finally plot the combined results:
disp('======= PLOTTING =======');
plotAllResultsMetricSelect(cfg, results);

AOK = true;

end
