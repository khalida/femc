# Read in historic data:
historicData <- read.table('historicData.csv', header=FALSE, sep=',')
horizon <- read.table('intervalsToForecast.csv', header=FALSE, sep=',')
# k <- read.table('seasonality.csv', header=FALSE, sep=',')

# Load the forecast package:
library(forecast)

# Cast historicData as time-series (optionally force frequency)
# historicDataTimeSeries <- ts(historicData$V1, frequency=k$V1);
historicDataTimeSeries <- ts(historicData$V1);

# Carry out automated ETS forecast
forecastEts <- forecast(historicDataTimeSeries, h=horizon$V1,
                                find.frequency=TRUE, level=FALSE, 
                                robust=TRUE)

# Save the mean forecast as CSV files
write.table(forecastEts$mean, file='meanForecastEts.csv', sep=',',
            col.names=FALSE, row.names=FALSE, qmethod='double')

# Carry out automated ARIMA forecast
fitArima <- auto.arima(historicDataTimeSeries)
forecastArima <- forecast(fitArima, h=horizon, level=FALSE, robust=TRUE)

# Save the mean forecast as CSV files
write.table(forecastArima$mean, file='meanForecastArima.csv', sep=',',
                col.names=FALSE, row.names=FALSE, qmethod='double')
