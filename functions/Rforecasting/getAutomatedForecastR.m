function [ forecastArima, forecastEts ] = getAutomatedForecastR( ...
    historicData, trainControl )

% getAutomatedForecastR: Produce point forecast using R forecasting pkg
                % NB: this relies on reading/writing files so care required
                % in handling temporary files when running in parrallel.

%% Create temprary directory for storing temporary files (and move into it)
originalDir = pwd;
tmpName = tempname;
mkdir(tmpName);
[locationOfRfile, ~, ~] = fileparts(which('getAutomatedForecastR.m'));
copyfile([locationOfRfile '\forecast.R'],tmpName);
cd(tmpName);

%% Write historic (& other info) as columns
csvwrite('historicData.csv', historicData(:));
csvwrite('intervalsToForecast.csv', trainControl.minimiseOverFirst);
csvwrite('seasonality.csv', trainControl.seasonality);

%% Call the R forecasting script:
system('R CMD BATCH forecast.R outputForDebugging.txt');

%Read in the mean forecast (saved by the R script):
forecastArima = csvread('meanForecastArima.csv');
forecastEts = csvread('meanForecastEts.csv');

%% Return to original directory & destroy temporary directory
cd(originalDir);
% rmdir(tmpName, 's');

end
