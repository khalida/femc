@echo off
set MATLAB=C:\PROGRA~1\MATLAB\R2014b
set MATLAB_ARCH=win64
set MATLAB_BIN="C:\Program Files\MATLAB\R2014b\bin"
set ENTRYPOINT=mexFunction
set OUTDIR=.\
set LIB_NAME=forecastSarmaHyndmanMex_mex
set MEX_NAME=forecastSarmaHyndmanMex_mex
set MEX_EXT=.mexw64
call setEnv.bat
echo # Make settings for forecastSarmaHyndmanMex > forecastSarmaHyndmanMex_mex.mki
echo COMPILER=%COMPILER%>> forecastSarmaHyndmanMex_mex.mki
echo COMPFLAGS=%COMPFLAGS%>> forecastSarmaHyndmanMex_mex.mki
echo OPTIMFLAGS=%OPTIMFLAGS%>> forecastSarmaHyndmanMex_mex.mki
echo DEBUGFLAGS=%DEBUGFLAGS%>> forecastSarmaHyndmanMex_mex.mki
echo LINKER=%LINKER%>> forecastSarmaHyndmanMex_mex.mki
echo LINKFLAGS=%LINKFLAGS%>> forecastSarmaHyndmanMex_mex.mki
echo LINKOPTIMFLAGS=%LINKOPTIMFLAGS%>> forecastSarmaHyndmanMex_mex.mki
echo LINKDEBUGFLAGS=%LINKDEBUGFLAGS%>> forecastSarmaHyndmanMex_mex.mki
echo MATLAB_ARCH=%MATLAB_ARCH%>> forecastSarmaHyndmanMex_mex.mki
echo BORLAND=%BORLAND%>> forecastSarmaHyndmanMex_mex.mki
echo OMPFLAGS= >> forecastSarmaHyndmanMex_mex.mki
echo OMPLINKFLAGS= >> forecastSarmaHyndmanMex_mex.mki
echo EMC_COMPILER=msvcsdk>> forecastSarmaHyndmanMex_mex.mki
echo EMC_CONFIG=optim>> forecastSarmaHyndmanMex_mex.mki
"C:\Program Files\MATLAB\R2014b\bin\win64\gmake" -B -f forecastSarmaHyndmanMex_mex.mk
