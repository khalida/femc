# Read in historic data (and other info)
historicData <- read.table('historicData.csv', header=FALSE, sep=',')
horizon <- read.table('intervalsToForecast.csv', header=FALSE, sep=',')
seasonality <- read.table('seasonality.csv', header=FALSE, sep=',')
order <- read.table('order.csv', header=FALSE, sep=',')
seasonalOrder <- read.table('seasonalOrder.csv', header=FALSE, sep=',')

# Load the forecast package:
library(forecast)

# Cast historicData as time-series
historicDataTimeSeries <- ts(historicData$V1, frequency=seasonality$V1);

# Carry out automated forecast
arimaFit <- Arima(historicDataTimeSeries, order=order$V1, seasonal=seasonalOrder$V1, 
                       include.mean=FALSE);

arimaForecast <- forecast(arimaFit, h=horizon$V1);

# Save the mean forecast as CSV file
write.table(arimaForecast$mean, file='meanForecast.csv', sep=',',
                col.names=FALSE, row.names=FALSE, qmethod='double')

# Save the model coefficients as CSV file
write.table(as.numeric(arimaFit$coef), file='coefficients.csv', sep=',',
            col.names=FALSE, row.names=FALSE, qmethod='double')
