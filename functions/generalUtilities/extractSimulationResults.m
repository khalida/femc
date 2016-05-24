function [ peakReductionRatio ] = extractSimulationResults( ...
    gridPower, demandValues, billingIntervals)

% extractSimulationResults: Extract peak reduction from simulation data

if ~isequal(size(gridPower), size(demandValues))
    warning('gridPower and demandValues should have the same size');
end
nPeriods = floor(length(gridPower)/billingIntervals)*billingIntervals;
gridPower = gridPower(1:nPeriods);
demandValues = demandValues(1:nPeriods);

gridBillingPeriodColumns = reshape(gridPower, [billingIntervals, ...
    length(gridPower)/(billingIntervals)]);

gridBillingPeriodPeaks = max(gridBillingPeriodColumns, [], 1);

demandBillingPeriodColumns = reshape(demandValues, [billingIntervals,...
    length(demandValues)/(billingIntervals)]);

demandBillingPeriodPeaks = max(demandBillingPeriodColumns, [], 1);

if ~isequal(size(demandBillingPeriodColumns), ...
        size(gridBillingPeriodColumns))
    error(['demandBillingPeriodColumns and ' ...
        'gridBillingPeriodColumns should have the same size']);
end

billingPeriodRatios = gridBillingPeriodPeaks./demandBillingPeriodPeaks;

peakReductionRatio = 1 - mean(billingPeriodRatios);

end
