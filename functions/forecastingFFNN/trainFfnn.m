% file: trainFfnn.m
% auth: Khalid Abdulla
% date: 21/10/2015
% brief: Train a single FFNN forecast model.

function outputNet = trainFfnn( featureVectorTrain, responseVectorTrain,...
    lossType, trainControl)

% INPUTS:
% featureVectorTrain: matrix of training inputs [nFeatures x nObservations]
% responseVectorTrain: matrix of targets [nResponses x nObservations]
% lossType: handle to the loss function
% trainControl: structure of training control parameters

% OUTPUTS:
% outputNet: MATLAB trained neural network object

% Parse the trainControl structure
suppressOutput = trainControl.suppressOutput;
hiddenLayerSize = trainControl.nHidden;

trainFcn = 'trainscg';
% trainFcn = 'traingd';
outputNet = fitnet(hiddenLayerSize,trainFcn);

% Choose Input and Output Pre/Post-Processing Functions
outputNet.input.processFcns = {'removeconstantrows','mapminmax'};
outputNet.output.processFcns = {'removeconstantrows','mapminmax'};

% Setup Division of Data for Training, Validation, Testing
outputNet.divideParam.trainRatio = 80/100;
outputNet.divideParam.valRatio = 10/100;
outputNet.divideParam.testRatio = 10/100;

% Silence the usual training guis/output
outputNet.trainParam.showWindow = false;
outputNet.trainParam.showCommandLine = false;

% Set the optionally specified training parameters (otherwise use default)
if isfield(trainControl, 'validFail')
    outputNet.trainParam.max_fail = trainControl.validFail; end

if isfield(trainControl, 'sigmaValue')
    outputNet.trainParam.sigma = trainControl.sigmaValue; end

if isfield(trainControl, 'lambdaValue')
    outputNet.trainParam.lambda = trainControl.lambdaValue; end

%% MSE pre-training (done even if lossType is MSE)
originalEpochs = outputNet.trainParam.epochs;
outputNet.trainParam.epochs = trainControl.mseEpochs;
outputNet.performFcn = 'mse';
if ~suppressOutput
    outputNet = train(outputNet,featureVectorTrain,responseVectorTrain);
else
    evalc(['outputNet = ' ...
        'train(outputNet,featureVectorTrain,responseVectorTrain);']);
end
outputNet.trainParam.epochs = originalEpochs;

%% Model training according to chosen lossType
if ~strcmp(func2str(lossType), 'loss_mse')
    % Set the (non-mse) loss function
    outputNet.performFcn = 'gen_loss';
    if ~suppressOutput
        outputNet.performParam.gen_loss = ...
            @(t, x)lossType(t(1:trainControl.minimiseOverFirst, :), ...
            x(1:trainControl.minimiseOverFirst, :));
    else
        evalc(['outputNet.performParam.gen_loss = '...
            '@(t, x)lossType(t(1:trainControl.minimiseOverFirst, :),' ...
            'x(1:trainControl.minimiseOverFirst, :));']);
    end
else
    outputNet.performFcn = 'mse';
end

outputNet.userdata.lossType = func2str(lossType);
outputNet.userdata.minimiseOverFirst = trainControl.minimiseOverFirst;

%% Train the Network

nObservations = size(featureVectorTrain, 2);

if isfield(trainControl, 'batchSize')
    nBatch = ceil(nObservations/trainControl.batchSize);
    batchIdxs = cell(nBatch, 1);
    for iBatch = 1:nBatch
        batchIdxs{iBatch} = ...
            (((iBatch-1)*trainControl.batchSize)+1):...
            min(((iBatch*trainControl.batchSize)), nObservations);
    end
else
    nBatch = 1;
    batchIdxs = cell(1, 1);
    batchIdxs{1} = 1:nObservations;
end

% TODO: Limiting training time to 60min overall (NB: will get sub-optimal networks)
outputNet.trainParam.time = (trainControl.maxTime*60)/nBatch;
outputNet.trainParam.epochs = trainControl.maxEpochs;

for iBatch = 1:nBatch
    batchFeature = featureVectorTrain(:, batchIdxs{iBatch});
    batchResponse = responseVectorTrain(:, batchIdxs{iBatch});
    
    if ~strcmp(func2str(lossType), 'loss_mse')
        if(~suppressOutput)
            [outputNet,tr] = train(outputNet,batchFeature,...
                batchResponse, nn7);
        else
            evalc(['[outputNet,tr] = train(outputNet, batchFeature,' ...
                'batchResponse, nn7);']);
        end
    else
        if(~suppressOutput)
            [outputNet,tr] = train(outputNet, batchFeature, batchResponse);
        else
            evalc(['[outputNet,tr] = train(outputNet, batchFeature,' ...
                'batchResponse);']);
        end
    end
end

% Store various parameters along with the neural network
outputNet.userdata.numObs = size(featureVectorTrain,2);
outputNet.userdata.finalPerf_ts = tr.best_tperf;
outputNet.userdata.trainIndL = length(tr.trainInd(:));
outputNet.userdata.trainStop = tr.stop;

if strcmp(tr.stop, 'Maximum time elapsed.')
    disp(['Warning: FFNN Training halted due to maximum time. Loss type: ' func2str(lossType)]);
end

end
