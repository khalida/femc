% Test using a simple sinusoidal prediction problem, and confirm
% performance is improved by running multiple models
clearvars;

rng(42);
noiseLvl = 0.5;
cfg.fc.suppressOutput = false;
cfg.fc.nHidden = 15;
cfg.fc.mseEpochs = 8;
cfg.fc.minimiseOverFirst = 1;
cfg.fc.maxTime = 20;
cfg.fc.maxEpochs = 3;

cfg.sim.horizon = 48;
cfg.fc.nLags = 48;
cfg.fc.trainRatio = 0.8;
cfg.fc.perfDiffThresh = 0.05;

testMultiplier = 300;

% Produce sinusoidal series to learn from:
timeIndexesTrain = linspace(0, 2*pi*testMultiplier,...
    cfg.sim.horizon*testMultiplier);

timeIndexesTest = max(timeIndexesTrain) + timeIndexesTrain;

trainTimeSeries = sin(timeIndexesTrain) + ...
    rand(size(timeIndexesTrain)).*noiseLvl;

testTimeSeries = sin(timeIndexesTest) + ...
    rand(size(timeIndexesTrain)).*noiseLvl;

lossType = @lossMse;

cfg.fc.nStart = 1;
outputNetSingle = trainFfnnMultipleStarts(cfg, trainTimeSeries, lossType);

cfg.fc.nStart = 40;
outputNetMultiple = trainFfnnMultipleStarts(cfg, trainTimeSeries, ...
    lossType);

historicData = trainTimeSeries((end-cfg.fc.nLags+1):end)';
netSingleResponse = zeros(cfg.sim.horizon, 1);
netMultipleResponse = zeros(cfg.sim.horizon, 1);
idealResponse = zeros(cfg.sim.horizon, 1);

% Go through test data and produce forecasts
for idx = 1:(length(testTimeSeries)-cfg.sim.horizon)
    netSingleResponse = [netSingleResponse, ...
        outputNetSingle(historicData)]; %#ok<*AGROW>
    
    netMultipleResponse = [netMultipleResponse, ...
        outputNetMultiple(historicData)];
    
    % Store the ideal response:
    idealResponse = [idealResponse, ...
        testTimeSeries(idx:(idx+cfg.sim.horizon-1))'];
    
    % Roll data forward:
    historicData = [historicData(2:end); testTimeSeries(idx)];
end

figure();
plot(idealResponse(:), netSingleResponse(:)', '.');
xlabel('Target Value'); ylabel('Net Response');
hold on; grid on;
plot(idealResponse(:), netMultipleResponse(:), '.');
legend('Single Net', 'Multi Net');
refline(1,0);

netMultRespMeanError = mean(mean(abs(netMultipleResponse-idealResponse)));
netSingleRespMeanError = mean(mean(abs(netSingleResponse-idealResponse)));

testPassed = netMultRespMeanError < netSingleRespMeanError;

if testPassed
    disp('trainFfnnMultipleStarts test PASSED!');
else
    error('trainFfnnMultipleStarts test FAILED!');
end

close all;