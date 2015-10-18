function best_net = genFcastFreeController(featureVec, decVec, nHidden, numStarts)

% INPUTS:
%   featureVec - input data.
%   decVec - target data.
%   nHidden - No. of Hidden Layers to train.
%   numStarts - No. of random starts to consider

x = featureVec;
t = decVec;

trainRatio = 0.9;   % To run single NN on - for multStart validation
trainIdxs = 1:size(x, 2);
numObs = length(trainIdxs);
if size(t, 2) ~= numObs; error('Number of observations must be same in feature and decision vectors'); end;

% Choose a Training Function
trainFcn = 'trainscg';  % Scaled Conjugate Gradient

% Create a Fitting Network
hiddenLayerSize = nHidden;

numObs_tr = floor(numObs*trainRatio);
numObs_ts = numObs - numObs_tr;
ind = randperm(numObs);
ind_tr = ind(1:numObs_tr);
ind_ts = ind(numObs_tr+(1:numObs_ts));
x_tr = x(:,ind_tr);
t_tr = t(:,ind_tr);
x_ts = x(:,ind_ts);
t_ts = t(:,ind_ts);
    
perfs = zeros(1, numStarts);
all_nets = cell(1, numStarts);

for ii = 1:numStarts

    net = fitnet(hiddenLayerSize,trainFcn);

    % Choose Input and Output Pre/Post-Processing Functions
    % For a list of all processing functions type: help nnprocess
    net.input.processFcns = {'removeconstantrows','mapminmax'};
    net.output.processFcns = {'removeconstantrows','mapminmax'};

    % Setup Division of Data for Training, Validation, Testing
    % For a list of all data division functions type: help nndivide
    net.divideFcn = 'dividerand';  % Divide data randomly
    net.divideMode = 'sample';  % Divide up every sample
    net.divideParam.trainRatio = 70/100;
    net.divideParam.valRatio = 15/100;
    net.divideParam.testRatio = 15/100;

    % Choose a Performance Function
    % For a list of all performance functions type: help nnperformance
    net.performFcn = 'mse';  % Mean squared error

    % Choose Plot Functions
    % For a list of all plot functions type: help nnplot
    net.plotFcns = {'plotperform','plottrainstate','ploterrhist', ...
        'plotregression', 'plotfit'};

    % Suppress CMD line and GUI outputs
    net.trainParam.showWindow = false;
    net.trainParam.showCommandLine = false;

   % Train the Network
   [all_nets{1, ii}, tr] = train(net,x,t);
   perfs(1, ii) = tr.best_tperf;

end

[~, idx_best] = min(perfs);

% Debugging output performance of model
disp(perfs);
best_net = all_nets{1, idx_best};

end
