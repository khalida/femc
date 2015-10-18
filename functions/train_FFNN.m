% file: train_FFNN.m
% auth: Khalid Abdulla
% date: 10/04/2015
% brief: Train a single FFNN forecast model.

function this_net = train_FFNN( x_tr, t_tr, lossType, trControl)

% INPUTS:
% x_tr: matrix of training inputs [nFeat x nObs]
% t_tr: matrix of targets [nResp x nObs]
% lossType: handle to the loss function
% trControl: structure of training control parameters

% Parse the trControl structure
supp = trControl.supp;
hiddenLayerSize = trControl.numHidden;

trainFcn = 'trainscg';
% trainFcn = 'traingd';
this_net = fitnet(hiddenLayerSize,trainFcn);

% Choose Input and Output Pre/Post-Processing Functions
this_net.input.processFcns = {'removeconstantrows','mapminmax'};
this_net.output.processFcns = {'removeconstantrows','mapminmax'};

% Setup Division of Data for Training, Validation, Testing
% this_net.divideFcn = 'dividerand';  % Divide data randomly
% this_net.divideFcn = 'divideblock';  % Divide data in sequential blocks
% this_net.divideMode = 'sample';  % Divide up every sample
% this_net.divideMode = 'time';  % Divide up every sample
this_net.divideParam.trainRatio = 80/100;
this_net.divideParam.valRatio = 10/100;
this_net.divideParam.testRatio = 10/100;

% Silence the usual training guis/output
this_net.trainParam.showWindow = false;
this_net.trainParam.showCommandLine = false;

% Set the optionally specified training pars
if isfield(trControl, 'validFail')
    this_net.trainParam.max_fail = trControl.validFail; end

if isfield(trControl, 'sigmaValue')
    this_net.trainParam.sigma = trControl.sigmaValue; end

if isfield(trControl, 'lambdaValue')
    this_net.trainParam.lambda = trControl.lambdaValue; end

% MSE pre-training (done even if loss type is MSE)
origEpochs = this_net.trainParam.epochs;
this_net.trainParam.epochs = trControl.mseEpochs;
this_net.performFcn = 'mse';
if ~supp
    this_net = train(this_net,x_tr,t_tr);
else
    evalc('this_net = train(this_net,x_tr,t_tr);');
end
this_net.trainParam.epochs = origEpochs;

% Actual model training
if ~strcmp(func2str(lossType), 'loss_mse')
    % Set the (non-mse) loss function
    this_net.performFcn = 'gen_loss';
    if ~supp
        this_net.performParam.gen_loss = ...
            @(t, x)lossType(t(1:trControl.minimiseOverFirst, :), ...
            x(1:trControl.minimiseOverFirst, :));
    else
        evalc(['this_net.performParam.gen_loss = '...
            '@(t, x)lossType(t(1:trControl.minimiseOverFirst, :),' ...
            'x(1:trControl.minimiseOverFirst, :));']);
    end
else
    this_net.performFcn = 'mse';
end

this_net.userdata.lossType = func2str(lossType);
this_net.userdata.minimiseOverFirst = trControl.minimiseOverFirst;

% Train the Network

nObs = size(x_tr, 2);

if isfield(trControl, 'batchSize')
    nBatches = ceil(nObs/trControl.batchSize);
    batchIdxs = cell(nBatches, 1);
    for eachBatch = 1:nBatches
        batchIdxs{eachBatch} = (((eachBatch-1)*trControl.batchSize)+1):...
                min(((eachBatch*trControl.batchSize)), nObs);
    end
else
    nBatches = 1;
    batchIdxs = cell(1, 1);
    batchIdxs{1} = 1:nObs;
end

% TODO: Limit train time to 30min overall (NB: will get sub-optimal networks)
this_net.trainParam.time = (60*60)/nBatches;
% this_net.trainParam.epochs = 200;

for eachBatch = 1:nBatches
    x_batch = x_tr(:, batchIdxs{eachBatch});
    t_batch = t_tr(:, batchIdxs{eachBatch});
    
    if ~strcmp(func2str(lossType), 'loss_mse')
        if(~supp)
            [this_net,tr] = train(this_net,x_batch,t_batch, nn7);
        else
            evalc('[this_net,tr] = train(this_net,x_batch,t_batch, nn7);');
        end
    else
        if(~supp)
            [this_net,tr] = train(this_net,x_batch,t_batch);
        else
            evalc('[this_net,tr] = train(this_net,x_batch,t_batch);');
        end
    end
end

% Store various parameters along with the NN
this_net.userdata.numObs = size(x_tr,2);
this_net.userdata.finalPerf_ts = tr.best_tperf;
this_net.userdata.trainIndL = length(tr.trainInd(:));
this_net.userdata.trainStop = tr.stop;

if strcmp(tr.stop, 'Maximum time elapsed.')
    disp(['Warning: FFNN Training halted due to maximum time. Loss type: ' func2str(lossType)]);
end

end
