# Read in historic data:
historicData <- read.table('historicData.csv', header=FALSE, sep=',')
horizon <- read.table('intervalsToForecast.csv', header=FALSE, sep=',')

# Load the forecast package:
library(forecast)

# Cast historicData as time-series (optionally force frequency)
historicDataTimeSeries <- ts(historicData$V1);
# historicDataTimeSeries <- ts(historicData$V1, frequency=k$V1);

# Check if historic data is of zero-variance and return constant fcast if so:
if(var(historicDataTimeSeries) == 0) {

  forecastEts <- NULL;
  forecastEts$mean <- rep(mean(historicDataTimeSeries),times=horizon$V1)
} else {

  # Carry out automated ETS forecast
  forecastEts <- forecast(historicDataTimeSeries, h=horizon$V1,
                                find.frequency=TRUE, level=FALSE, 
                                robust=TRUE)
}

# Check if forecast is of correct length
if (length(forecastEts$mean) != horizon$V1) {
  warning("Wrong length forecast returned by forecast() function.")
}

# Save the mean forecast as CSV files
write.table(forecastEts$mean, file='meanForecastEts.csv', sep=',',
            col.names=FALSE, row.names=FALSE, qmethod='double')
