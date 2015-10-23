importDemandData <- function() {
  
  dirPath = '../../../18_DataSets/ISSDA/data/CER_both/CER Electricity Revised March 2012/'
  fileNameList <- list.files(pattern = "*.txt", path = dirPath, full.names = TRUE)
  demandTable <- do.call("rbind", lapply(fileNameList, FUN=read.table, header=FALSE))
  uniqueMeters <- unique(demandTable$V1)
  nUniqueMeters <- length(uniqueMeters)
  nMeterReads <- vector("list", nUniqueMeters)
  
  # Find the number of meter reads for each unique meter
  for (meterIdx in 1:nUniqueMeters) {
    meter <- uniqueMeters[meterIdx]
    nMeterReads[meterIdx] <- length(demandTable[demandTable$V1==meter, 1])
  }
  
  # Find the most common no. of reads:
  commonReads <- as.numeric(names(table(as.numeric(nMeterReads))[
    table(as.numeric(nMeterReads)) == max(table(as.numeric(nMeterReads)))]))
  
  # Select only those meters with common no. of reads:
  metersWithCommonReads <- uniqueMeters[nMeterReads == commonReads]
  
  return(demandTable)
}

# Return an appropriately differenced TS
seasonalDiff <- function(x) {
  ns <- nsdiffs(x)
  if(ns > 0) {
    xstar <- diff(x,lag=frequency(x),differences=ns)
    print(paste0("No. seasonal differences removed: ", ns))
  } else {
    xstar <- x
  }
  nd <- ndiffs(xstar)
  if(nd > 0) {
    xstar <- diff(xstar,differences=nd)
    print(paste0("No. first differences removed: ", nd))
  }
  return(xstar)
}

# Plot histogram with Normal approximation
histWithNormal <- function(x) {
  h<-hist(x, breaks=10, col="red", xlab="Value",
          main="Histogram with Normal Curve")
  xfit<-seq(min(x),max(x),length=40)
  yfit<-dnorm(xfit,mean=mean(x),sd=sd(x))
  yfit <- yfit*diff(h$mids[1:2])*length(x)
  lines(xfit, yfit, col="blue", lwd=2) 
}

# Produce model on training data, and return RMSE on testing data:
getRMSE <- function(x, h, ...) {
  train.end <- time(x)[length(x)-h]
  test.start <- time(x)[length(x)-h+1]
  train <- window(x, end=train.end)
  test <- window(x, start = test.start)
  fit <- Arima(train, ...)
  fc <- forecast(fit, h=h)
  return(accuracy(fc, test)[2, "RMSE"])
}