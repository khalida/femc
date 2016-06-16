function [ AOK ] = metSelMainNcust( nCust )

%metSelMainNcust: Run the metricSelectMain script for number of customers
%                   specified in input argument

% INPUTS:
% nCust:    No. of customers, can be an array for multiple runs to be
            % included
            
% OUTPUTS:
% AOK:      Boolean set to true if everythin ran OK

%% Load Running Configuration, with nCust set
cfg = Config(pwd, nCust); %#ok<NASGU>

%% Run metricSelectMain:
metricSelectMain;

AOK = true;

end
