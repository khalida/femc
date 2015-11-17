%% Train and test 'R forecast' and plot performance VS NP forecast

clearvars; close all; clc;

% Start the clock!
tic;

% === RUNNING OPTIONS ===
nCustomers = [1, 10, 100, 1000];
nAggregates = 2;
dataFile = '../../../data/demand_3639.csv';
S = 48*1;
h = 48;
nIndTrain = 48*200;
nIndFcast = 48*7*4;
trainControl.minimiseOverFirst = h;
trainControl.seasonality = S;

% === Seed for repeatability ===
rng(42);

% === READ IN DATA ===
demandData = csvread(dataFile);
nReads = size(demandData, 1);
nMeters = size(demandData, 2);

% === Train & Test Indexes ===
firstTrainIndex = nReads - nIndFcast - nIndTrain + 1;
trainInd = firstTrainIndex + (0:(nIndTrain-1));
testInd = max(trainInd) + (1:nIndFcast);

if(max(testInd) > nReads)
    warning('Test index out of bounds');
end

% Pre-allocate matrices of results
MSE_NP = zeros(length(nCustomers), nAggregates);
MSE_Rets = zeros(length(nCustomers), nAggregates);

MAPE_NP = zeros(length(nCustomers), nAggregates);
MAPE_Rets = zeros(length(nCustomers), nAggregates);

% Loop through each aggregate, in each number of customers of interest:
for ii =  1:length(nCustomers)
    
    nCust = nCustomers(ii);
    
    for eachAgg = 1:nAggregates
        
        % === SELECT & SUM RANDOM SUBSET OF CUSTOMERS ===
        customerIndexes = randsample(nMeters, nCust, false);
        demandSignal_full = sum(demandData(:, customerIndexes), 2);
        demandSignalTrain = demandSignal_full(trainInd);
        
        % Produce forecasts, one horizon at a time, add new data to time-series
        nFcasts = nIndFcast - h + 1;
        MSEs_NP = zeros(nFcasts, 1);
        MSEs_Rets = zeros(nFcasts, 1);
        
        MAPEs_NP = zeros(nFcasts, 1);
        MAPEs_Rets = zeros(nFcasts, 1);
        
        origin = max(trainInd);
        dataSoFarTS = demandSignalTrain;
        
        for eachHorizon = 1:nFcasts
            
            fcastRets = getAutomatedForecastR(dataSoFarTS, trainControl);
            actual = demandSignal_full(origin + (1:h));
            NP = dataSoFarTS((end-h+1):end);
            
            MSEs_NP(eachHorizon) = mean((actual - NP).^2);
            MSEs_Rets(eachHorizon) = mean((actual - fcastRets).^2);
            
            MAPEs_NP(eachHorizon) = mean(((actual-NP)./actual).*100);
            MAPEs_Rets(eachHorizon) = mean(((actual-fcastRets)...
                ./actual).*100);
            
            if (eachHorizon==1)
                
                % === Plot forecast point VS actuals ===
                plot(actual, fcastRets, '.');
                hold on;
                refline(1, 0);
                xlabel('Actual');
                ylabel('Predicted');
                hold off;
                
                % === Plot the forecast to show how it looks compared to historic, actual, NP
                figure();
                plot(1:h, NP, 'k');
                hold on;
                plot((1:h)+h, actual, 'k');
                plot((1:h)+h, NP, 'r');
                plot((1:h)+h, fcastRets, 'y');
            end
            
            dataSoFarTS = [dataSoFarTS; demandSignal_full(origin+1)]; %#ok<AGROW>
            origin = origin + 1;
        end
        
        MSE_NP(ii, eachAgg) = mean(MSEs_NP);
        MSE_Rets(ii, eachAgg) = mean(MSEs_Rets);
        
        MAPE_NP(ii, eachAgg) = mean(MAPEs_NP);
        MAPE_Rets(ii, eachAgg) = mean(MAPEs_Rets);
        
        figure();
        plot(MSEs_NP, 'r');
        plot(MSEs_Rets, 'y');
        disp(['nCust: ', num2str(nCust), ', eachAgg: ',...
            num2str(eachAgg), ', DONE!']);
    end
end

disp('MSE_NP');
disp(MSE_NP);

disp('MSE_Rets');
disp(MSE_Rets);

disp('MAPE_NP');
disp(MAPE_NP);

disp('MAPE_Rets');
disp(MAPE_Rets);


% Print MAPE of automated forecast method and NP over aggregation level:
MAPE_NP_mean = mean(MAPE_NP, 2);
MAPE_NP_std = std(MAPE_NP, [], 2);

MAPE_Rets_mean = mean(MAPE_Rets, 2);
MAPE_Rets_std = std(MAPE_Rets, [], 2);
       
errorbar(nCustomers, MAPE_NP_mean, MAPE_NP_std);
hold on;
plot(nCustomers, MAPE_Rets_mean);
legend('NP', 'Rets');
ylabel('MAPE [%]');
hold off;

% Repeat for MSE: which is what auto-method most-likely seeks to minimise:
MSE_NP_mean = mean(MSE_NP, 2);
MSE_NP_std = std(MSE_NP, [], 2);

MSE_Rets_mean = mean(MSE_Rets, 2);
MSE_Rets_std = std(MSE_Rets, [], 2);

errorbar(nCustomers, MSE_NP_mean, MAPE_NP_std);
hold on;
plot(nCustomers, MAPE_Rets_mean);
legend('NP', 'Rets');
ylabel('MAPE [%]');
hold off;

toc;