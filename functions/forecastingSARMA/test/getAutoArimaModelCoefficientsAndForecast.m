function [coefficients, meanForecast] = ...
    getAutoArimaModelCoefficientsAndForecast(dataValues, trainControl, ...
    order, seasonalOrder)

%% Create temprary directory for storing temporary files (and move into it)
originalDir = pwd;
tmpName = tempname;
mkdir(tmpName);
[locationOfRfile, ~, ~] = fileparts(which(...
    'getAutoArimaModelCoefficientsAndForecast.m'));
copyfile([locationOfRfile...
     filesep 'getAutoArimaModelCoefficientsAndForecast.R'],tmpName);
cd(tmpName);

%% Write historic (& other info) as columns
csvwrite('historicData.csv', dataValues(:));
csvwrite('seasonality.csv', trainControl.season);
csvwrite('intervalsToForecast.csv', trainControl.horizon);
csvwrite('order.csv', order(:));
csvwrite('seasonalOrder.csv', seasonalOrder(:));

%% Call the R forecasting script:
system('R CMD BATCH getAutoArimaModelCoefficientsAndForecast.R debug.txt');

%% Read in the mean forecast & coefficients (saved by the R script):
meanForecast = csvread('meanForecast.csv');
coefficients = csvread('coefficients.csv');

%% Return to rigina directlroy and destroy temporary directory
cd(originalDir);
rmdir(tmpName, 's');

end
