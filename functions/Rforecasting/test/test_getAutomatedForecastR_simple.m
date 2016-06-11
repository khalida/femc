%% Train and test 'R forecast' and plot performance VS NP forecast
% for a simple periodic profile (not exhaustive/thorough).

clearvars;

thisTic = tic;

% === RUNNING OPTIONS ===
period = 48;
dataLengthTrain = period*20;
dataLengthTest = period*2;
dataLenthTotal = dataLengthTrain + dataLengthTest;

% === Train Control Structure: ===
trainControl.minimiseOverFirst = period;
trainControl.season = period;

% === Seed for repeatability ===
rng(42);
demandData = sin(2.*pi.*(1:dataLenthTotal)./period) + ...
    rand(1, dataLenthTotal);

% === Train & Test Indexes ===
trainInd = 1:dataLengthTrain;
testInd = dataLengthTrain + (1:dataLengthTest);

% Produce forecasts, one horizon at a time
% add new data to historic time-series
nFcasts = dataLengthTest - period + 1;
MSEs_NP = zeros(nFcasts, 1);
MSEs_Rets = zeros(nFcasts, 1);

MAPEs_NP = zeros(nFcasts, 1);
MAPEs_Rets = zeros(nFcasts, 1);

origin = max(trainInd);
dataSoFarTS = demandData(trainInd);

hWait = waitbar(0, 'Running');

for eachHorizon = 1:nFcasts
    waitbar(eachHorizon/nFcasts, hWait);
    fcastRets = getAutomatedForecastR(dataSoFarTS, trainControl);
    actual = demandData(origin + (1:period));
    NP = dataSoFarTS((end-period+1):end);
    
    MSEs_NP(eachHorizon) = mean((actual - NP).^2);
    MSEs_Rets(eachHorizon) = mean((actual - fcastRets').^2);
    
    MAPEs_NP(eachHorizon) = mean(abs((actual-NP)./actual).*100);
    MAPEs_Rets(eachHorizon) = mean(abs((actual-fcastRets')...
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
        plot(1:period, NP, 'k');
        hold on;
        plot((1:period)+period, actual, 'k');
        plot((1:period)+period, NP, 'r');
        plot((1:period)+period, fcastRets, 'y');
        legend({'Historic', 'Actual', 'NP', 'Rets'});
    end
    
    dataSoFarTS = [dataSoFarTS, demandData(origin+1)]; %#ok<AGROW>
    origin = origin + 1;
end
close(hWait);

disp('mean(MSEs_NP)'); disp(mean(MSEs_NP));
disp('mean(MSEs_Rets)'); disp(mean(MSEs_Rets));

disp('mean(MAPEs_NP)'); disp(mean(MAPEs_NP));
disp('mean(MAPEs_Rets)'); disp(mean(MAPEs_Rets));

disp('Time taken: '); disp(toc);

disp('time for test_getAutomatedForecastR_simple: '); disp(toc(thisTic));

%% Determine pass/fail of test:
if mean(MSEs_Rets) < mean(MSEs_NP)
    disp('test_getAutomatedForecastR_simple PASSED!');
else
    error('test_getAutomatedForecastR_simple FAILED');
end

close all;