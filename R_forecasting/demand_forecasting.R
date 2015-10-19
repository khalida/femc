# Train and test 'R forecast' and plot performance

# ==== RUNNING OPTIONS ==== #
nCustomers = 1
dataFile = "../data/demand_250.csv"
S = 48*1
subSeries = 1:(48*100)
lForecast = 48*2

# ==== Seed for repeatability ==== #
set.seed(42)

# ==== LOAD PACKAGES ==== #
library(forecast)
library(ggplot2)


# ==== LOAD FUNCTIONS ==== #
source("utilityFunctions.R")

# ==== READ IN DATA ==== #
demandData <- read.csv(dataFile, header=FALSE)
# produces data-frame with meters in columns, and time-steps in rows:
nReads = dim(demandData)[1]
nMeters = dim(demandData)[2]

# ==== SELECT & SUM RANDOM SUBSET OF CUSTOMERS ==== #
customerIndexes <- sample(1:nMeters, nCustomers, replace=F)
if (nCustomers > 1) {
  demandSignal_full <- rowSums(demandData[, customerIndexes])  
} else {
  demandSignal_full <- demandData[, customerIndexes] 
}
demandSignal <- demandSignal_full[subSeries]

# ==== ANALYSE SERIES ==== #
demandTS <- ts(demandSignal, frequency=S)
plot.ts(demandTS)
acf(demandTS, lag.max = S)
seasonplot(demandTS)

demandStar <- seasonalDiff(demandTS)
plot.ts(demandStar)
acf(demandStar, lag.max = S)

# Force a single seasonal then first differening:
demandStar2 <- diff(demandTS,lag=S)
demandStar2 <- diff(demandStar2, lag=1, differences=1)
acf(demandStar2, lag.max = S)

# ==== Produce AUTO ARIMA Forecast === #
fit <- auto.arima(demandTS)
print(fit)
fcast <- forecast(fit, h=lForecast)
fcastVals <- data.frame(mean = as.numeric(fcast$mean), upper = fcast$upper[, 2],
                        lower = fcast$lower[, 2], actual = 
                          demandSignal_full[max(subSeries) + 1:lForecast])

plot(fcast)

# ==== Plot forecast point and range VS actuals === #
print(ggplot(fcastVals, aes(x = actual, y = mean)) +
  geom_point(size = 2) +
  geom_errorbar(aes(ymin = lower, ymax = upper)) +
  geom_abline(intercept=0, slope=1))
