@echo off
set MATLAB=C:\PROGRA~1\MATLAB\R2014b
set MATLAB_ARCH=win64
set MATLAB_BIN="C:\Program Files\MATLAB\R2014b\bin"
set ENTRYPOINT=mexFunction
set OUTDIR=.\
set LIB_NAME=fc_SARMA_mex_mex
set MEX_NAME=fc_SARMA_mex_mex
set MEX_EXT=.mexw64
call setEnv.bat
echo # Make settings for fc_SARMA_mex > fc_SARMA_mex_mex.mki
echo COMPILER=%COMPILER%>> fc_SARMA_mex_mex.mki
echo COMPFLAGS=%COMPFLAGS%>> fc_SARMA_mex_mex.mki
echo OPTIMFLAGS=%OPTIMFLAGS%>> fc_SARMA_mex_mex.mki
echo DEBUGFLAGS=%DEBUGFLAGS%>> fc_SARMA_mex_mex.mki
echo LINKER=%LINKER%>> fc_SARMA_mex_mex.mki
echo LINKFLAGS=%LINKFLAGS%>> fc_SARMA_mex_mex.mki
echo LINKOPTIMFLAGS=%LINKOPTIMFLAGS%>> fc_SARMA_mex_mex.mki
echo LINKDEBUGFLAGS=%LINKDEBUGFLAGS%>> fc_SARMA_mex_mex.mki
echo MATLAB_ARCH=%MATLAB_ARCH%>> fc_SARMA_mex_mex.mki
echo BORLAND=%BORLAND%>> fc_SARMA_mex_mex.mki
echo OMPFLAGS= >> fc_SARMA_mex_mex.mki
echo OMPLINKFLAGS= >> fc_SARMA_mex_mex.mki
echo EMC_COMPILER=msvcsdk>> fc_SARMA_mex_mex.mki
echo EMC_CONFIG=optim>> fc_SARMA_mex_mex.mki
"C:\Program Files\MATLAB\R2014b\bin\win64\gmake" -B -f fc_SARMA_mex_mex.mk
