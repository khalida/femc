# Generate ARIMA(3,0)x(1,0)[48] model validation data
# for testing MATLAB SARMA implementation

set.seed(42);

seasonality=48;
nPeriods=10;
noiseReductionFactor = 5;

t <- seq(0,nPeriods*2*pi,length=nPeriods*seasonality)
x <- sin(t) + rnorm(length(t))/noiseReductionFactor
plot(t, x, type='l');

xTS <- ts(x, frequency=seasonality)

fit <- Arima(x, order=c(3,0,0), seasonal=list(order=c(1,0,0), period=seasonality))
print(fit)
# Remove intercept; to allow comparison with Hyndman Matlab model
fit$coef[5] <- 0.0
fc <- forecast(fit, h=seasonality)
plot(fc, xlab='Arima() model forecast (with model order forced)')

# Using coefficients with zero AR component (to check Sevlian model)
fitMatlabZeroSAR <- fit
fitMatlabZeroSAR$coef[1:5] <- c(0.450261684019779, 0.28245660245168, 0.174661268582532,
                               0.0, 0.0)
fitMatlabZeroSAR <- Arima(x,model=fitMatlabZeroSAR)
fcMatlabZeroSAR <- forecast(fitMatlabZeroSAR, h=seasonality)
plot(fcMatlabZeroSAR, xlab='Matlab-fitted model forecast, zero SAR')

# Using coefficients with zero SAR component (to check Sevlian model)
fitMatlabZeroAR <- fit
fitMatlabZeroAR$coef[1:5] <- c(0.0, 0.0, 0.0, 0.394959662477209, 0.0)
fitMatlabZeroAR <- Arima(x,model=fitMatlabZeroAR)
fcMatlabZeroAR <- forecast(fitMatlabZeroAR, h=seasonality)
plot(fcMatlabZeroAR, xlab='Matlab-fitted model forecast, zero AR')

# Finally produce model with coefficients found from matlab model to see
# how it compares
fitMatlabCoeff <- fit
fitMatlabCoeff$coef[1:5] <- c(-0.0464890254206569, -0.0762745454752649, -0.00801495011260016,
                               0.999999998602471, 0)
fitMatlabCoeff <- Arima(x, model=fitMatlabCoeff)
print(fitMatlabCoeff)
fcMatlabCoeff <- forecast(fitMatlabCoeff, h=seasonality)
plot(fcMatlabCoeff, xlab='Matlab-fitted model forecast')

fitAuto <- auto.arima(x)
print(fitAuto)
fcAuto <- forecast(fitAuto, h=seasonality)
plot(fcAuto, xlab='auto.arima() model forecast')

# Completely automated forecast; should use this as my SOTA benchmark.
plot(forecast(xTS, h=seasonality), xlab='fully automated forecast')

# Check performance against the noise-free underlying model:
t_test <- seq(nPeriods*2*pi,(nPeriods+1)*2*pi,length=seasonality)
x_test <- sin(t)
rmse_fcAuto = accuracy(fcAuto, x_test)[2, "RMSE"]
rmse_fcMatlab = accuracy(fcMatlabCoeff, x_test)[2, "RMSE"]
rmse_fc_auto.arima = accuracy(fcAuto, x_test)[2, "RMSE"]

print(paste0("fcAuto RMSE: ", rmse_fcAuto, ", \nfcMatlab coefficient RMSE: ",
             rmse_fcMatlab, ", \nfc_auto.arima() RMSE: ", rmse_fc_auto.arima, "."))
