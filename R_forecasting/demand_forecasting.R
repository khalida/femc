# Train and test 'R forecast' and plot performance VS NP forecast

# Start the clock!
print(ptm <- proc.time())

# ==== RUNNING OPTIONS ==== #
nCustomers = c(1, 10, 100, 1000)
nAggregates = 2
dataFile = "../data/demand_3639.csv"
S = 48*1    # seasonality
h = 48      # forecast horizon
nIndTrain = 48*200
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
results_NP_df <- data.frame(matrix(ncol = nAggregates, nrow = length(nCustomers)))
results_automated_df <- data.frame(matrix(ncol = nAggregates, nrow = length(nCustomers)))

NP_MAPE <- data.frame(matrix(ncol = nAggregates, nrow = length(nCustomers)))
auto_MAPE <- data.frame(matrix(ncol = nAggregates, nrow = length(nCustomers)))

rownames(results_NP_df) <- nCustomers
rownames(results_automated_df) <- nCustomers

rownames(NP_MAPE) <- nCustomers
rownames(auto_MAPE) <- nCustomers

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
#     trainTS <- ts(demandSignalTrain, frequency=S)
    trainTS <- ts(demandSignalTrain)
    plot.ts(trainTS)
    
    # ==== Produce AUTO Forecast === #
    
    # Produce forecasts, one horizon at a time, add new data to time-series
    nFcasts <- nIndFcast - h + 1
    NP_RMSEs <- vector(length=(nFcasts))
    automated_RMSEs <- vector(length=(nFcasts))

    NP_MAPEs <- vector(length=(nFcasts))
    automated_MAPEs <- vector(length=(nFcasts))
    
    origin <- max(trainInd)
    dataSoFarTS <- trainTS
    
    for (eachHorizon in 1:nFcasts) {
      
      # fcastAutomated <- forecast(dataSoFarTS, h=h, find.frequency=TRUE, level=FALSE, robust=TRUE)
      fcastAutomated <- forecast(dataSoFarTS, h=h, level=FALSE, robust=TRUE)
      print(paste0("Forecast method: ", fcastAutomated$method))
      actual <- demandSignal_full[origin + 1:h]
      NP <- tail(dataSoFarTS, n=h)
      
      NP_RMSEs[eachHorizon] <- accuracy(NP, actual)[1, "RMSE"]
      automated_RMSEs[eachHorizon] <- accuracy(fcastAutomated$mean, actual)[1, "RMSE"]
      
      NP_MAPEs[eachHorizon] <- accuracy(NP, actual)[1, "MAPE"]
      automated_MAPEs[eachHorizon] <- accuracy(fcastAutomated$mean, actual)[1, "MAPE"]
      
     if (eachHorizon==1) {
        fcastVals <- data.frame(mean = as.numeric(fcastAutomated$mean), actual=actual)

        # ==== Plot forecast point VS actuals === #
        print(ggplot(fcastVals, aes(x = actual, y = mean)) +
                geom_point(size = 2) +
                geom_abline(intercept=0, slope=1))
        
        # ==== Plot the forecast to show how it looks compared to historic, actual, NP
        plot(1:h, NP, col="black", xlim=c(1, 2*h))
        lines((1:h)+h, actual, col="black")
        lines((1:h)+h, NP, col="red")
        lines((1:h)+h, fcastAutomated$mean, col="yellow")
 
        # ==== Also plot the forecast with confidence levels
        plot(fcastAutomated)
     }
      
      dataSoFarTS <- ts(c(dataSoFarTS, demandSignal_full[origin+1]))
#       dataSoFarTS <- ts(c(dataSoFarTS, demandSignal_full[origin+1]), frequency=S)
      origin <- origin + 1
    }
    
    results_NP_df[ii, eachAgg] <- mean(NP_RMSEs)
    results_automated_df[ii, eachAgg] <- mean(automated_RMSEs)
    
    NP_MAPE[ii, eachAgg] <- mean(NP_MAPEs)
    auto_MAPE[ii, eachAgg] <- mean(automated_MAPEs)
    
    plot(NP_RMSEs, type="l",col="red", ylim=c(min(c(NP_RMSEs, automated_RMSEs)),
                                             max(c(NP_RMSEs, automated_RMSEs))))
    lines(automated_RMSEs, col="yellow")
    print(paste0("nCust: ", nCust, ", eachAgg: ", eachAgg, ", DONE!"))
  }
}

print(results_NP_df)
print(results_automated_df)

print(NP_MAPE)
print(auto_MAPE)

# Print MAPE of automated forecast method and NP over aggregation level:
NP_MAPE <- transform(NP_MAPE, mean=apply(NP_MAPE,1,mean,na.rm=TRUE))
NP_MAPE <- transform(NP_MAPE, std=apply(subset(NP_MAPE, select=-mean),1,sd,na.rm=TRUE))

auto_MAPE <- transform(auto_MAPE, mean=apply(auto_MAPE,1,mean,na.rm=TRUE))
auto_MAPE <- transform(auto_MAPE, std=apply(subset(auto_MAPE, select=-mean),1,sd,na.rm=TRUE))

MAPEresults <- data.frame(nCustomers=nCustomers, NP_mean=NP_MAPE$mean, NP_std = NP_MAPE$std,
                         auto_mean=auto_MAPE$mean, auto_std=auto_MAPE$std)

print(ggplot(MAPEresults, aes(x = nCustomers)) +
        geom_line(aes(y=NP_mean, colour='NP')) +
        geom_errorbar(aes(ymin = NP_mean-NP_std, ymax = NP_mean+NP_std)) + 
        geom_line(aes(y=auto_mean, col='Auto')))


# Repeat for MSE: which is what auto-method most-likely seeks to minimise:
MSEresults <- data.frame(nCustomers=nCustomers, NP_mean=apply(results_NP_df,1,mean,na.rm=TRUE),
                         NP_std = apply(results_NP_df,1,sd,na.rm=TRUE),
                         auto_mean=apply(results_automated_df,1,mean,na.rm=TRUE),
                         auto_std=apply(results_automated_df,1,sd,na.rm=TRUE))

print(ggplot(MSEresults, aes(x = nCustomers)) +
        geom_line(aes(y=NP_mean, colour='NP')) +
        geom_errorbar(aes(ymin = NP_mean-NP_std, ymax = NP_mean+NP_std)) + 
        geom_line(aes(y=auto_mean, col='Auto')))

# Stop the clock
print(proc.time() - ptm)