[parentFold, ~, ~] = fileparts(pwd);
commonFcnFold = [parentFold filesep 'commonFunctions'];
sourceFileString = [commonFcnFold filesep 'emd_hat_gd_metric_mex.cxx'];
eval(['mex -outdir ' commonFcnFold ' -O -DNDEBUG ' sourceFileString]);

% mex -O -DNDEBUG emd_hat_gd_metric_mex.cxx 
% mex -O -DNDEBUG emd_hat_mex.cxx