# Train and test 'R forecast' and plot performance VS NP forecast

# Start the clock!
print(ptm <- proc.time())

# ==== RUNNING OPTIONS ==== #
nCustomers = c(1, 5, 25, 125)
nAggregates = 2
dataFile = "../data/demand_250.csv"
S = 48*1    # seasonality
h = 48      # forecast horizon
nIndTrain = 48*100
nIndFcast = 48*7*4

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

# ==== Train & Test Indexes ==== #
firstTrainIndex = nReads - nIndFcast - nIndTrain + 1
trainInd = firstTrainIndex + (0:(nIndTrain-1))
testInd = max(trainInd) + (1:nIndFcast)
if(max(testInd) > nReads) {
  stop('Test index out of bounds')
}

# Pre-allocate data-frames of results
# results_df <- data.frame(matrix(ncol = nAggregates, nrow = length(nCustomers)))
results_NP_df <- data.frame(matrix(ncol = nAggregates, nrow = length(nCustomers)))
results_man_df <- data.frame(matrix(ncol = nAggregates, nrow = length(nCustomers)))
results_automated_df <- data.frame(matrix(ncol = nAggregates, nrow = length(nCustomers)))

# rownames(results_df) <- nCustomers
rownames(results_NP_df) <- nCustomers
rownames(results_man_df) <- nCustomers
rownames(results_automated_df) <- nCustomers

# Loop through each aggregate, in each number of customers of interest:
for(ii in 1:length(nCustomers)) {
  nCust = nCustomers[ii]
  
  for(eachAgg in 1:nAggregates) {
    # ==== SELECT & SUM RANDOM SUBSET OF CUSTOMERS ==== #
    customerIndexes <- sample(1:nMeters, nCust, replace=F)
    if (nCust > 1) {
      demandSignal_full <- rowSums(demandData[, customerIndexes])  
    } else {
      demandSignal_full <- demandData[, customerIndexes] 
    }
    demandSignalTrain <- demandSignal_full[trainInd]
    
    # ==== ANALYSE SERIES ==== #
    trainTS <- ts(demandSignalTrain, frequency=S)
    # plot.ts(trainTS)
    # seasonplot(trainTS)
    # tsdisplay(trainTS)
    
    # ==== Produce AUTO ARIMA Forecast === #
    
    # Choose model order using AICc
    # fit <- auto.arima(trainTS)
    
    # Manually use model order I used in my work:
    #fitMan <- Arima(trainTS, order=c(3,0,0), seasonal=list(order=c(1,0,0),
    #                                                       period=S,
    #                                                       method="CSS")) 
    # print(fit)
    #print(fitMan)
    
    # produce forecasts, one horizon at a time, add new data to time-series
    nFcasts <- nIndFcast - h + 1
    # fcRMSEs <- vector(length=(nFcasts))
    #fcManRMSEs <- vector(length=(nFcasts))
    NP_RMSEs <- vector(length=(nFcasts))
    automated_RMSEs <- vector(length=(nFcasts))
    
    origin <- max(trainInd)
    dataSoFarTS <- trainTS
    
    for (eachHorizon in 1:nFcasts) {
      # fcast <- forecast(fit, h=h)
      #fcastMan <- forecast(fitMan, h=h)
      fcastAutomated <- forecast(dataSoFarTS, h=h)
      actual <- demandSignal_full[origin + 1:h]
      NP <- tail(dataSoFarTS, n=h)
      
      # fcRMSEs[eachHorizon] <- accuracy(fcast, actual)[2, "RMSE"]
      NP_RMSEs[eachHorizon] <- accuracy(NP, actual)[1, "RMSE"]
      #fcManRMSEs[eachHorizon] <- accuracy(fcastMan, actual)[2, "RMSE"]
      automated_RMSEs[eachHorizon] <- accuracy(fcastAutomated, actual)[2, "RMSE"]
      
      if (eachHorizon==1) {
        # plot(fcast)
        #plot(fcastMan)
        #fcastVals <- data.frame(mean = as.numeric(fcast$mean), upper = fcast$upper[, 2],
        #                        lower = fcast$lower[, 2], actual=actual)
        #fcastManVals <- data.frame(mean = as.numeric(fcastMan$mean), upper = fcastMan$upper[, 2],
        #                        lower = fcastMan$lower[, 2], actual=actual)
        
        # ==== Plot forecast point and range VS actuals === #
        #print(ggplot(fcastVals, aes(x = actual, y = mean)) +
        #        geom_point(size = 2) +
        #        geom_errorbar(aes(ymin = lower, ymax = upper)) +
        #        geom_abline(intercept=0, slope=1))
        
        # ==== Plot forecast point and range VS actuals === #
        #print(ggplot(fcastManVals, aes(x = actual, y = mean)) +
        #        geom_point(size = 2) +
        #        geom_errorbar(aes(ymin = lower, ymax = upper)) +
        #        geom_abline(intercept=0, slope=1))
      }
      
      dataSoFarTS <- ts(c(dataSoFarTS, demandSignal_full[origin+1]), frequency=S)
      # fit <- Arima(dataSoFarTS,model=fit)
      #fitMan <- Arima(dataSoFarTS,model=fitMan)
      origin <- origin + 1
    }
    
    # results_df[ii, eachAgg] <- mean(fcRMSEs)
    results_NP_df[ii, eachAgg] <- mean(NP_RMSEs)
    #results_man_df[ii, eachAgg] <- mean(fcManRMSEs)
    results_automated_df[ii, eachAgg] <- mean(automated_RMSEs)
    
    plot(NP_RMSEs, type="l",col="red", ylim=c(min(c(NP_RMSEs, automated_RMSEs)),
                                             max(c(NP_RMSEs, automated_RMSEs))))
    # lines(fcRMSEs, col="green")
    #lines(fcManRMSEs, col="blue")
    lines(automated_RMSEs, col="yellow")
    
    print(paste0("nCust: ", nCust, ", eachAgg: ", eachAgg, ", DONE!"))
  }
}

# print(results_df)
print(results_NP_df)
#print(results_man_df)
print(results_automated_df)

# Stop the clock
print(proc.time() - ptm)