[parentFold, ~, ~] = fileparts(pwd);
commonFunctionFolder = [parentFold filesep 'functions'];
addpath(genpath(commonFunctionFolder), '-BEGIN');
