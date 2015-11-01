# Read in historic data:
historicData <- read.table('historicData.csv', header=FALSE, sep=',')
horizon <- read.table('intervalsToForecast.csv', header=FALSE, sep=',')
# k <- read.table('seasonality.csv', header=FALSE, sep=',')

# Load the forecast package:
library(forecast)

# Cast historicData as time-series
# historicDataTimeSeries <- ts(historicData$V1, frequency=k$V1);
historicDataTimeSeries <- ts(historicData$V1);

# Carry out automated forecast
thisForecast <- forecast(historicDataTimeSeries, h=horizon$V1, find.frequency=TRUE)

# Save the mean forecast as CSV file
write.table(thisForecast$mean, file='meanForecast.csv', sep=',',
                col.names=FALSE, row.names=FALSE, qmethod='double')
