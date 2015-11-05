# Load packages & seed analysis
library(tictoc)
library(forecast)
set.seed(42)

# Running settings
periodLength <- 48                         #intervals
historicDataLength <- 200*periodLength
forecastHorizon <- periodLength
noiseLevel <- 1.5
tSample <- (2*pi)/periodLength
tic()

# Produce example historic data:
sampleTimes <- seq(from=0, by=tSample, length.out=historicDataLength)
historicData <- sin(sampleTimes) + rnorm(length(sampleTimes))*noiseLevel

historicDataTS <- ts(historicData)

# Generate ETS forecast:
etsForecast <- forecast(historicDataTS, h=forecastHorizon, find.frequency=TRUE,
                        level=FALSE, robust=TRUE)

# Generate ARIMA forecast:
# arimaFit <- auto.arima(ts(historicData)) #, frequency=periodLength))
arimaFit <- auto.arima(historicDataTS)
arimaForecast <- forecast(arimaFit, h=forecastHorizon, level=FALSE, robust=TRUE)

# Plot the forecasts:
# ETS Forecast:
plot(c(historicDataTS[(historicDataLength-periodLength+1):historicDataLength], 
     etsForecast$mean), type='l', main='ETS Forecast')

points(x=(periodLength+1):(periodLength+length(etsForecast$mean)),
       y=etsForecast$mean, col='red')
grid()

# ARIMA Forecast:
plot(c(historicDataTS[(historicDataLength-periodLength+1):historicDataLength], 
       arimaForecast$mean), type='l', main='ARIMA Forecast')

points(x=(periodLength+1):(periodLength+length(arimaForecast$mean)),
       y=arimaForecast$mean, col='red')
grid()

toc()
