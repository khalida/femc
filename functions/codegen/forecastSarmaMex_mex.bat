@echo off
set MATLAB=C:\PROGRA~1\MATLAB\R2014b
set MATLAB_ARCH=win64
set MATLAB_BIN="C:\Program Files\MATLAB\R2014b\bin"
set ENTRYPOINT=mexFunction
set OUTDIR=.\
set LIB_NAME=forecastSarmaMex_mex
set MEX_NAME=forecastSarmaMex_mex
set MEX_EXT=.mexw64
call setEnv.bat
echo # Make settings for forecastSarmaMex > forecastSarmaMex_mex.mki
echo COMPILER=%COMPILER%>> forecastSarmaMex_mex.mki
echo COMPFLAGS=%COMPFLAGS%>> forecastSarmaMex_mex.mki
echo OPTIMFLAGS=%OPTIMFLAGS%>> forecastSarmaMex_mex.mki
echo DEBUGFLAGS=%DEBUGFLAGS%>> forecastSarmaMex_mex.mki
echo LINKER=%LINKER%>> forecastSarmaMex_mex.mki
echo LINKFLAGS=%LINKFLAGS%>> forecastSarmaMex_mex.mki
echo LINKOPTIMFLAGS=%LINKOPTIMFLAGS%>> forecastSarmaMex_mex.mki
echo LINKDEBUGFLAGS=%LINKDEBUGFLAGS%>> forecastSarmaMex_mex.mki
echo MATLAB_ARCH=%MATLAB_ARCH%>> forecastSarmaMex_mex.mki
echo BORLAND=%BORLAND%>> forecastSarmaMex_mex.mki
echo OMPFLAGS= >> forecastSarmaMex_mex.mki
echo OMPLINKFLAGS= >> forecastSarmaMex_mex.mki
echo EMC_COMPILER=msvcsdk>> forecastSarmaMex_mex.mki
echo EMC_CONFIG=optim>> forecastSarmaMex_mex.mki
"C:\Program Files\MATLAB\R2014b\bin\win64\gmake" -B -f forecastSarmaMex_mex.mk
