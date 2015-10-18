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
  commonReads <- as.numeric(names(table(as.numeric(nMeterReads))[table(as.numeric(nMeterReads)) == max(table(as.numeric(nMeterReads)))]))

  # Select only those meters with common no. of reads:
  metersWithCommonReads <- uniqueMeters[nMeterReads == commonReads]
  
  return(demandTable)
}