function [ forecast ] = getAutomatedForecastR( historicData, trainControl )

% getAutomatedForecastR: Produce point forecast using R forecasting pkg
                % NB: this relies on reading/writing files so need to avoid
                % trying to run in parrallel!

% Create temprary directory for storing temporary files (and move into it)
originalDir = pwd;
tmpName = tempname;
mkdir(tmpName);
[locationOfRfile, ~, ~] = fileparts(which('getAutomatedForecastR.m'));
copyfile([locationOfRfile '\forecast.R'],tmpName);
cd(tmpName);

%Write historic (& other info) as columns
csvwrite('historicData.csv', historicData(:));
csvwrite('intervalsToForecast.csv', trainControl.minimiseOverFirst);
csvwrite('seasonality.csv', trainControl.seasonality);

%Call the R forecasting script:
system('R CMD BATCH forecast.R outputForDebugging.txt');

%Read in the mean forecast (saved by the R script):
forecast = csvread('meanForecast.csv');

% Destroy temporary directory and return to original directory
cd(originalDir);
% rmdir(tmpName, 's');

end
