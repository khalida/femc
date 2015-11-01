data <- read.table('data.csv', header=FALSE, sep=',')
results <- shapiro.test(data$V1)
results2 <- c(results$statistic[['W']], results$p.value)
write.table(results2, file='testResults.csv', sep=',', col.names=FALSE,
                row.names=FALSE, qmethod='double')
