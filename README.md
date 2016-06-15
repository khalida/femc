# femc
Last Updated: 15th June 2016

Repository for the MATLAB code for forecast error metric customization paper.

All of the main files are in the folder `./mainScripts` which contains the following scripts:

0) `Config.m`
This is a function which takes `pwd` as an argument, and sets up a `cfg` structure which controls settings of the optimization problem and the training of forecasts (and sets filenames for saving etc.)

1) `compareForecasts.m`
This runs training of multiple forecasts, and then plots the performance of the various methods as measured using the various metrics. This script produces the results plotted in Figures 4, 5, 6, 7 of the paper. Please note that for this script to work you must have R installed on your computer, and with your eviornment path set up so it can be run from the command line / terminal. It is also necessary to have a number of additional R libraries installed. Tar-balls for these libraries are included in the FEMC repo, but their installation is not automated.

2) `metricSelectMain.m`
Trains multiple forecasts (including multiple parameter values of PFEM and PEMD forecasts), tests these forecasts on a parameter selection dataset, chooses the parameter values for PFEM, PEMD forecasts, and then does a final test on an unseen test dataset. Used in producing Figure 8 in the paper.

3) `compileMexes.m`
This compiles the MEX files (required if running simulations on another platform).

4) `LoadFunctions.m`
This loads all of the required functions/scripts into the matlab PATH so that they can be called.

5) `runAllUnitTests.m`
This runs a series of unit tests on the various functions/utilities to confirm everything is installed corrected. It should take about 10 minutes or so to run on a modern desktop (Intel CORE i7). Again this script required R to be installed and have the relevant libraries loaded; if this is not the case the tests of the R forecasting scripts, `test_getAutomatedForecastR_simple`, `test_getAutomatedForecastR_onDemand` and `test_forecastSarma` can be commented out.

In addition to these main scripts there are many functions in the folder `./functions`; which are called from these scripts.

Whilst all the results presented in the paper are using FFNN forecasts for the parameterized forecasts, more recent testing has shown that this approach is effective even when using the 4-parameter SARMA forecast.

Note that the online repository does not include the data, partly because this is quite large 2.6GB in txt file format, and partly because access to this data needs to be requested from ISSDA. Requesting access is straight-forward, and is done by submitting a form via e-mail, [details here](http://www.ucd.ie/issda/data/commissionforenergyregulationcer). Assuming nothing has changed this data will be provided as 6 compressed text files. If they are labelled `File1.txt` to `File6.txt`, and placed in the `./data/` folder, the running `./data/importIssdaDataAll.m` should create a matlab data-file in the format and location needed to be called by the other scripts.

Because of the large number of forecasts which need to be trained, and the time-consuming process of training neural-network forecasts, especially for loss functions which don't have analytical gradients, running `compareForecasts.m` and `metricSelectMain.m` is time-consuming, and probably best done on a compute cluster. The code is configured to run different problem instances (aggregations of customers) in parrallel, the parameter `cfg.sim.nProc` set in `Config.m` sets the number of processors available.