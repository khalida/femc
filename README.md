# femc 
Repository for the MATLAB code for forecast error
metric selection paper.

All of the main files are in the folder ./mainScripts which contains the
following scripts:

0) Config.m
This runs a simple script to set up several structures which control the
optimisation problem and the training of forecasts (and set filenames for
saving etc.)

1) compareForecasts.m
This runs training of multiple forecasts, and then plots the performance of
the various methods as measured using the various metrics. This script
produces the results plotted in Figures 6, 7, 8, 9

2) metricSelectMain.m
Trains multiple forecasts (including multiple parameter values of PFEM
and PEMD forecasts), tests these forecasts on a parameter selection dataset
chooses the parameter values for PFEM, PEMD forecasts, and then does a
final test on a test dataset. Used in producing Figure 10

3) metricSelectMainStochastic.m
Version of the above which attempt to avoid the need for training quite so
many different forecasts; by selected PFEM, PEMD parameters based on
randomised forecasts. Was never used to particularly good effect; further
work required.

4) compileMexes.m
This compiles the MEX files (required if running simulations on another
platform)

In addition to these main scripts there are many functions in the folder 
./functions; which are callled from these scripts.

NB: whilst all the results presented in the paper are using FFNN forecasts
for the parameterised forecasts, more recent testing has shown that this
approach is effective even when using the 4-parameter SARMA forecast.

There are other subtle differences between the results presented in the
paper and the Config.m set-up which has been left (to do with the billing
period simulated, whether margin from establishing a new peak is rewarded
etc.)
