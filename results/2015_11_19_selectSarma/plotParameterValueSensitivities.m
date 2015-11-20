%% Tidy Up
clearvars; close all; clc;

load('2015_11_19_nCust_1_5_25_125__batt_5pc__nAgg_3_noCD_selectSarma.mat');
metricNames = {'\alpha', '\beta', '\gamma', '\delta'};
metricValues = zeros(4, 12);

figure();
for plotIdx = 1:length(metricNames)

    subplot(2,2,plotIdx);
    
    metricValues(plotIdx, :) =  Pfem.allValues(results.bestPfemForecast - ...
        min(Pfem.range) + 1, plotIdx);
    
    plot(results.allKWhs(:), metricValues(plotIdx, :)', '.', 'MarkerSize', 25);
    hold on;
    
    meanValues = zeros(length(Sim.nCustomers), 1);
    
    for sizeIdx = 1:length(Sim.nCustomers)
        meanValues(sizeIdx) = mean(metricValues(plotIdx,...
            (1+(sizeIdx-1)*Sim.nAggregates):(sizeIdx*Sim.nAggregates)));
    end
    
    meanKWhs = mean(results.allKWhs, 1);
    plot(meanKWhs, meanValues);
    grid on;
    xlabel('Aggregate Size [kWh]'); 
    ylabel(['Pfem ' metricNames{plotIdx} ' Value']);
end
hold off;

% clearvars;
