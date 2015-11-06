function [ forecastEts ] = getAutomatedForecastR( ...
    historicData, trainControl )

% getAutomatedForecastR: Produce point forecast using R forecasting pkg
% NB: this relies on reading/writing files so care required
% in handling temporary files when running in parrallel.

%% Create temprary directory for storing temporary files (and move into it)
originalDir = pwd;
tmpName = tempname([pwd filesep 'tmp']);
mkdir(tmpName);
[locationOfRfile, ~, ~] = fileparts(which('getAutomatedForecastR.m'));
copyfile([locationOfRfile filesep 'forecast.R'],tmpName);
cd(tmpName);

%% Write historic (& other info) as columns
csvwrite('historicData.csv', historicData(:));
csvwrite('intervalsToForecast.csv', trainControl.minimiseOverFirst);
csvwrite('seasonality.csv', trainControl.seasonality);

%% Call the R forecasting script:
system('R CMD BATCH forecast.R outputForDebugging.txt');

%% Read mean forecast (saved by the R script):
% Allow for file not being found:
if exist('meanForecastEts.csv', 'file') == 2
    forecastEts = csvread('meanForecastEts.csv');
else
    forecastEts = zeros(trainControl.minimiseOverFirst, 1);
    warning(['meanForecastEts.csv not found, folder: ' pwd]);
end

%% Return to original directory & attempt to destroy temporary directory
cd(originalDir);
[status, message, id] = rmdir(tmpName, 's');
if status ~= 1
    warning(['Temp directory not destroyed: ' tmpName ...
        ', message: ' message ', id: ' id]);
end

end