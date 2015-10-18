% file: train_FFNN_multStart.m
% auth: Khalid Abdulla
% date: 22/01/2015
% brief: run train_FFFN multiple times

%% Train FFNN forecast model
function best_net = train_FFNN_multStart( demand, k,  lossType, trControl )

% demand:       is the time-history of demands on which to train the model
%                   divided into training and CV as required
% k:            is the forecast horizon
% lossType:     a handle to the loss function to train for
% trControl:    structure of train control parameters

% best_net:     best NN found

prevSteps = k;      % Number of previous time-steps as inputs to model
trainRatio = 0.9;   % To run single NN on - for multStart validation

% NN data from demand history
trainIdxs = (prevSteps+1):(size(demand, 1)-k);
numObs = length(trainIdxs);

% Set default values for optional train control pars
if ~isfield(trControl, 'includeTime'); trControl.includeTime = false;
    warning('Using default trControl.includeTime');  end;
if ~isfield(trControl, 'modelPerStep'); trControl.modelPerStep = false;
    warning('Using default trControl.modelPerStep');  end;
if ~isfield(trControl, 'numStarts'); trControl.numStarts = 3;
    warning('Using default trControl.numStarts');  end
if ~isfield(trControl, 'minimiseOverFirst');
    trControl.minimiseOverFirst = k;
    warning('Using default trControl.minimiseOverFirst');
end
if ~isfield(trControl, 'supp'); trControl.supp = true;
    warning('Using default trControl.supp');  end
if ~isfield(trControl, 'numHidden'); trControl.numHidden = 50;
    warning('Using default trControl.numHidden');  end
if ~isfield(trControl, 'mseEpochs'); trControl.mseEpochs = 1000;
    warning('Using default trControl.mseEpochs');  end

if trControl.includeTime
    inputs = zeros(numObs, prevSteps + 1);
else
    inputs = zeros(numObs, prevSteps);
end

outputs = zeros(numObs, k);

for idx = 1:numObs
    fcOrigin = trainIdxs(idx);
    inputs(idx, 1:prevSteps) = demand((fcOrigin-prevSteps):(fcOrigin-1));
    if trControl.includeTime
        inputs(idx, prevSteps+1) = trControl.hour_numbers_tr(fcOrigin);
    end
    outputs(idx, :) = demand(fcOrigin:(fcOrigin+k-1));
end

if trControl.modelPerStep
    perStepInputs = zeros(numObs/k, prevSteps, k);
    perStepOutputs = zeros(numObs/k, k, k);
    
    best_net = cell(k, 1);
    for ii = 1:k
        perStepInputs(:, :, ii) = inputs(inputs(:, prevSteps+1) == ii-1, 1:prevSteps);
        perStepOutputs(:, :, ii) = outputs(inputs(:, prevSteps+1) == ii-1, :);
    end
    
    for thisStep = 1:k
        % Format data for NN
        x = squeeze(perStepInputs(:, :, thisStep))';
        t = squeeze(perStepOutputs(:, :, thisStep))';
        
        numObs = size(x,2);
        numObs_tr = floor(numObs*trainRatio);
        numObs_ts = numObs - numObs_tr;
        ind = randperm(numObs);
        ind_tr = ind(1:numObs_tr);
        ind_ts = ind(numObs_tr+(1:numObs_ts));
        x_tr = x(:,ind_tr);
        t_tr = t(:,ind_tr);
        x_ts = x(:,ind_ts);
        t_ts = t(:,ind_ts);
        
        numStarts = trControl.numStarts;
        
        perfs = zeros(1, numStarts);
        all_nets = cell(1, numStarts);
        all_fcs = cell(1, numStarts);
        
        for ii = 1:numStarts
            all_nets{1, ii} = train_FFNN( x_tr, t_tr, lossType, trControl);
            all_fcs{1, ii} = fc_FFNN(all_nets{1, ii}, x_ts, true);
            perfs(1, ii) = mean(lossType(t_ts( ...
                1:trControl.minimiseOverFirst, :), ...
                all_fcs{1, ii}(1:trControl.minimiseOverFirst, :)), 2);
        end
        
        [~, idx_best] = min(perfs);
        best_net{thisStep, 1} = all_nets{1, idx_best};
        
        % Output performance of each start model for checking, if
        % difference is > 2 percent
        percDiff = (max(perfs) - min(perfs)) / min(perfs);
        if percDiff > 0.02
            disp(['Percent Diff: ' num2str(100*percDiff) ...
                '. Performances: ' num2str(perfs) ...
                '. Loss Fcn: ' func2str(lossType)]);
        end
    end
    
else
    
    % Format data for NN
    x = inputs';        %  x: [nFeat x nObs]
    t = outputs';       %  t: [nResp x nObs]
    
    numObs = size(x,2);
    numObs_tr = floor(numObs*trainRatio);
    numObs_ts = numObs - numObs_tr;
    ind = randperm(numObs);
    ind_tr = ind(1:numObs_tr);
    ind_ts = ind(numObs_tr+(1:numObs_ts));
    x_tr = x(:,ind_tr);
    t_tr = t(:,ind_tr);
    x_ts = x(:,ind_ts);
    t_ts = t(:,ind_ts);
    
    numStarts = trControl.numStarts;
    
    perfs = zeros(1, numStarts);
    all_nets = cell(1, numStarts);
    all_fcs = cell(1, numStarts);
    
    for ii = 1:numStarts
        all_nets{1, ii} = train_FFNN( x_tr, t_tr, lossType, trControl);
        all_fcs{1, ii} = fc_FFNN(all_nets{1, ii}, x_ts, true);
        perfs(1, ii) = mean(lossType(t_ts( ...
            1:trControl.minimiseOverFirst, :), ...
            all_fcs{1, ii}(1:trControl.minimiseOverFirst, :)), 2);
    end
    
    [~, idx_best] = min(perfs);
    
    % Output performance of each start model for checking, if
    % difference is > 2 percent
    percDiff = (max(perfs) - min(perfs)) / min(perfs);
    if percDiff > 0.02
        disp(['Percent Diff: ' num2str(100*percDiff)...
            '. Performances: ' num2str(perfs) ...
                '. Loss Fcn: ' func2str(lossType)]);
    end
    
    best_net = all_nets{1, idx_best};
end

end
