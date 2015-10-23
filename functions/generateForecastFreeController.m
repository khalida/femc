function bestNet = generateForecastFreeController(featureVector, ...
                        decisionVector, nHidden, nStart, trainControl)

% INPUTS:
%   featureVector:  Input data [nFeatures x nObservations]
%   decisionVector: Output data [nDecisions x nObservations]
%   nHidden:        No. of hidden layers in network
%   nStart:         No. of random starts to train

% OUTPUTS:
%   bestNet:        Trained Matlab neural network object

% TODO: this could probably be largely combined with
% trainFfnn(MultipleStarts).m

nObservations = size(featureVector, 2);
if size(decisionVector, 2) ~= nObservations;
    error('nObservations must be same in feature and decision vectors');
end;

% Training Function
trainingFunction = 'trainscg';  % Scaled Conjugate Gradient

nObservationsTrain = floor(nObservations*trainControl.trainRatio);
nObservationTest = nObservations - nObservationsTrain;
idxs = randperm(nObservations);
idxsTrain = idxs(1:nObservationsTrain);
idxsTest = idxs(nObservationsTrain+(1:nObservationTest));
featureVectorTrain = featureVector(:,idxsTrain);
decisionVectorTrain = decisionVector(:,idxsTrain);
featureVectorTest = featureVector(:,idxsTest);
decisionVectorTest = decisionVector(:,idxsTest);
    
performances = zeros(1, nStart);
allNets = cell(1, nStart);

for iStart = 1:nStart
    thisNet = fitnet(nHidden,trainingFunction);

    % Choose Input and Output Pre/Post-Processing Functions
    % For a list of all processing functions type: help nnprocess
    thisNet.input.processFcns = {'removeconstantrows','mapminmax'};
    thisNet.output.processFcns = {'removeconstantrows','mapminmax'};

    % Setup Division of Data for Training, Validation, Testing
    % For a list of all data division functions type: help nndivide
    thisNet.divideFcn = 'dividerand';  % Divide data randomly
    thisNet.divideMode = 'sample';  % Divide up every sample
    thisNet.divideParam.trainRatio = 70/100;
    thisNet.divideParam.valRatio = 15/100;
    thisNet.divideParam.testRatio = 15/100;

    % Choose a Performance Function
    % For a list of all performance functions type: help nnperformance
    thisNet.performFcn = 'mse';  % Mean squared error

    % Choose Plot Functions
    % For a list of all plot functions type: help nnplot
    thisNet.plotFcns = {'plotperform','plottrainstate','ploterrhist', ...
        'plotregression', 'plotfit'};

    % Suppress CMD line and GUI outputs
    thisNet.trainParam.showWindow = false;
    thisNet.trainParam.showCommandLine = false;

   % Train the Network
   [allNets{1, iStart}, tr] = train(thisNet,featureVectorTrain,...
       decisionVectorTrain);
   performances(1, iStart) = tr.best_tperf;
end

[~, idx_best] = min(performances);
bestNet = allNets{1, idx_best};

end
