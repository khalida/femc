%% Stand-along script which runs all of the units tests
% Note that the unit tests are not comprehensive, but should catch obvious
% bugs, or issues with installation / Matlab version compatibility

%% Prepare test environment (recompile mex functions)
clearvars; close all; clc;
tic;
LoadFunctions;
compileMexes;

%% Call all of the test scripts in turn (will output results to screen)
test_controllerOptimizer;
test_createGodCast;
test_lossPemd;
test_lossPfem;
test_lossEmd;
test_lossMape;
test_lossMse;
test_mpcController;
test_Battery;
test_forecastFfnn;
test_trainFfnn;
test_trainFfnnMultipleStarts;
toc;

%% Celebrate all of the tests passing:
hallelujah();
