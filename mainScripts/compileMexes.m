%% TODO: look at options of doing this with a function rather than script

%% Remove any compiled mex files
allFileNames = getAllFiles(commonFunctionFolder);
for idx = 1:length(allFileNames)
    thisFile = allFileNames{idx};
    strIdxs = strfind(thisFile, '.mex');
    if ~isempty(strIdxs)
        delete(thisFile);
        disp('Mex file deleted');
    end
end


%% Re-compile EMD mex files
emdFcnFold = [commonFunctionFolder filesep 'EMDutilities'];
sourceFileString = ['''' emdFcnFold filesep 'emd_hat_gd_metric_mex.cxx'''];
emdFcnFoldWithQuotes = ['''' emdFcnFold ''''];
eval(['mex -outdir ' emdFcnFoldWithQuotes ' -O -DNDEBUG ' sourceFileString]);
% mex -O -DNDEBUG emd_hat_gd_metric_mex.cxx 
% mex -O -DNDEBUG emd_hat_mex.cxx


%% Re-compile SARMA mex files
sarmaFcnFold = [commonFunctionFolder filesep 'forecastingSARMA'];
codegen('forecastSarmaMex.m', '-report', '-args',...
    {coder.typeof(double(0), [Inf Inf]),...
    coder.typeof(double(0), [1 3]), ...
    coder.typeof(double(0), [1 1]), ...
    coder.typeof(double(0), [1 1])}, '-d', ...
    [commonFunctionFolder filesep 'codegen'], '-o', ...
    [sarmaFcnFold filesep 'forecastSarmaMex_mex']);

codegen('forecastSarmaHyndmanMex.m', '-report', '-args',...
    {coder.typeof(double(0), [Inf Inf]),...
    coder.typeof(double(0), [1 3]), ...
    coder.typeof(double(0), [1 1]), ...
    coder.typeof(double(0), [1 1])}, '-d', ...
    [commonFunctionFolder filesep 'codegen'], '-o', ...
    [sarmaFcnFold filesep 'forecastSarmaHyndmanMex_mex']);
