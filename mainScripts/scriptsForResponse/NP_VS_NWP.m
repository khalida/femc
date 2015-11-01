% Script to show NP (Naive Periodic) and NWP (Naive Weekly Periodic)
% forecasts over various levels of aggregation

%% Tidying up
clear all; close all; clc; %#ok<CLSCR>

%% Running Parameters
nCustomers = [1 5 25 125];
nAggregates = 100;
nInstances = length(nCustomers)*nAggregates;
k = 48;
horizon = 48;
dataFileWithPath = ...
    ['..' filesep '..' filesep 'data' filesep 'demand_3639.mat'];

rng(42);
nTests = 200;
fileName = ['..' filesep '..' filesep 'results' filesep 'NP_VS_NWP.pdf'];
myPaperPosition = [-0.75 -0.25 19 15];
myPaperSize = [17 14];

%% Extract Data for the aggregates
load(dataFileWithPath);             % demandData [nMeters x nReads]
customerIdxs = cell(nInstances, 1);
allDemandValues = cell(nInstances, 1);
dataLengthRequired = nTests + (k*8) - 1;

instance = 0;
for nCustomerIdx = 1:length(nCustomers)
    for trial = 1:nAggregates
        instance = instance + 1;
        customers = nCustomers(nCustomerIdx);
        customerIdxs{instance} = ...
            randsample(size(demandData, 2), customers);
        allDemandValues{instance} = ...
            sum(demandData(1:dataLengthRequired,...
            customerIdxs{instance}), 2);
    end
end

% Delete the original demand data (no longer needed)
clearvars demandData;

%% Produce and evaluate the forecasts
testIdxs = (k*7) + (1:nTests);
if ((max(testIdxs) + (k-1)) ~= dataLengthRequired || ...
        length(testIdxs) ~= nTests)
    error('Test indexes dont line up');
end

NPforecast = zeros(nInstances, nTests, horizon);
NWPforecast = zeros(nInstances, nTests, horizon);
godCastForecast = zeros(nInstances, nTests, horizon);
allMSEerror = zeros(nInstances, nTests, 2);

for instance = 1:nInstances
    for iTest = 1:nTests
        idx = testIdxs(iTest);
        godCastForecast(instance, iTest, :) = ...
            allDemandValues{instance}(idx:(idx+horizon-1));
        
        NPforecast(instance, iTest, :) = ...
            allDemandValues{instance}((idx-48):(idx-1));
        
        NWPforecast(instance, iTest, :) = ...
            allDemandValues{instance}((idx-(48*7)):(idx-(48*7)+47));
        
        % Compute the MSE errors for the 3 forecast types for this horizon
        allMSEerror(instance, iTest, 1) = ...
            lossMse(squeeze(godCastForecast(instance, iTest, :)), ...
            squeeze(NPforecast(instance, iTest, :)));
        
        allMSEerror(instance, iTest, 2) = ...
            lossMse(squeeze(godCastForecast(instance, iTest, :)), ...
            squeeze(NWPforecast(instance, iTest, :)));
    end
end

summaryMSEerror = zeros(nInstances, 2);
for instance = 1:nInstances
    summaryMSEerror(instance, 1) = ...
        mean(squeeze(allMSEerror(instance, :, 1)));
    
    summaryMSEerror(instance, 2) = ...
        mean(squeeze(allMSEerror(instance, :, 2)));
end

%% Divide data back-up into nCustomer table:
finalMSEerrors = zeros(length(nCustomers), nAggregates, 2);
instance = 0;
for nCustomerIdx = 1:length(nCustomers)
    for trial = 1:nAggregates
        instance = instance + 1;
        finalMSEerrors(nCustomerIdx, trial, :) = ...
            summaryMSEerror(instance, :);
    end
end

%% Plot the results, box-plots over the aggregation levels considered:
% Absolute results
figure(1);
aboxplot(permute(finalMSEerrors, [3 2 1]), 'labels', nCustomers, 'fclabels', ...
    {'NP', 'NWP'});

set(gca, 'YScale', 'log');
grid on;
legend({'NP', 'NWP'}, 'Interpreter', 'none', 'Location', 'best');
xlabel('No. of Househoulds');
ylabel('48 Interval Mean Squared Error [(kWh)^2]');
set(gca, 'XGrid', 'off');
origYlims = get(gca, 'ylim');
for xpos = [1.5 2.5 3.5 4.5]
    line([xpos xpos], origYlims, 'color', 'k');
end
ylim(origYlims);
set(gca,'TickLength',[0 0])

%% Save plot:
set(gcf, 'PaperPosition', myPaperPosition); %Position the plot further to the left and down. Extend the plot to fill entire paper.
set(gcf, 'PaperSize', myPaperSize); %Keep the same paper size
saveas(gcf, fileName, 'pdf');