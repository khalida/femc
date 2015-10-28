function [ forecast ] = getAutomatedForecastR( historicData,...
    trainControl )

% getAutomatedForecastR: Produce point forecast using R forecasting pkg

system('R CMD BATCH infile outfile');

end

