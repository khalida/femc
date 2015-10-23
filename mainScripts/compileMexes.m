%% TODO: look at options of doing this with a function rather than script

%% Add path to the common functions (& any subfolders therein)
[parentFold, ~, ~] = fileparts(pwd);
commonFcnFold = [parentFold filesep 'functions'];
addpath(genpath(commonFcnFold), '-BEGIN');


%% Remove any compiled mex files
mexFileNames = dir([commonFcnFold filesep '*.mex*']);
for item = 1:length(mexFileNames);
    delete([commonFcnFold filesep mexFileNames(item).name]);
end


%% Re-compile EMD mex files
emdFcnFold = [commonFcnFold filesep 'EMDutilities'];
sourceFileString = ['''' emdFcnFold filesep 'emd_hat_gd_metric_mex.cxx'''];
emdFcnFoldWithQuotes = ['''' emdFcnFold ''''];
eval(['mex -outdir ' emdFcnFoldWithQuotes ' -O -DNDEBUG ' sourceFileString]);
% mex -O -DNDEBUG emd_hat_gd_metric_mex.cxx 
% mex -O -DNDEBUG emd_hat_mex.cxx


%% Re-compile SARMA mex files
sarmaFcnFold = [commonFcnFold filesep 'forecastingSARMA'];
codegen('forecastSarmaMex.m', '-report', '-args',...
    {coder.typeof(double(0), [Inf Inf]),...
    coder.typeof(double(0), [1 3]), ...
    coder.typeof(double(0), [1 1]), ...
    coder.typeof(double(0), [1 1])}, '-d', ...
    [commonFcnFold filesep 'codegen'], '-o', ...
    [sarmaFcnFold filesep 'forecastSarmaMex_mex']);

codegen('forecastSarmaHyndmanMex.m', '-report', '-args',...
    {coder.typeof(double(0), [Inf Inf]),...
    coder.typeof(double(0), [1 3]), ...
    coder.typeof(double(0), [1 1]), ...
    coder.typeof(double(0), [1 1])}, '-d', ...
    [commonFcnFold filesep 'codegen'], '-o', ...
    [sarmaFcnFold filesep 'forecastSarmaHyndmanMex_mex']);
