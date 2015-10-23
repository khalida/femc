/*
 * _coder_forecastSarmaHyndmanMex_mex.c
 *
 * Code generation for function 'forecastSarmaHyndmanMex'
 *
 */

/* Include files */
#include "mex.h"
#include "_coder_forecastSarmaHyndmanMex_api.h"
#include "forecastSarmaHyndmanMex_initialize.h"
#include "forecastSarmaHyndmanMex_terminate.h"

/* Function Declarations */
static void forecastSarmaHyndmanMex_mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);

/* Variable Definitions */
emlrtContext emlrtContextGlobal = { true, false, EMLRT_VERSION_INFO, NULL, "forecastSarmaHyndmanMex", NULL, false, {2045744189U,2170104910U,2743257031U,4284093946U}, NULL };
void *emlrtRootTLSGlobal = NULL;

/* Function Definitions */
static void forecastSarmaHyndmanMex_mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  const mxArray *outputs[1];
  const mxArray *inputs[4];
  int n = 0;
  int nOutputs = (nlhs < 1 ? 1 : nlhs);
  int nInputs = nrhs;
  emlrtStack st = { NULL, NULL, NULL };
  /* Module initialization. */
  forecastSarmaHyndmanMex_initialize(&emlrtContextGlobal);
  st.tls = emlrtRootTLSGlobal;
  /* Check for proper number of arguments. */
  if (nrhs != 4) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, mxINT32_CLASS, 4, mxCHAR_CLASS, 23, "forecastSarmaHyndmanMex");
  } else if (nlhs > 1) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, mxCHAR_CLASS, 23, "forecastSarmaHyndmanMex");
  }
  /* Temporary copy for mex inputs. */
  for (n = 0; n < nInputs; ++n) {
    inputs[n] = prhs[n];
  }
  /* Call the function. */
  forecastSarmaHyndmanMex_api(inputs, outputs);
  /* Copy over outputs to the caller. */
  for (n = 0; n < nOutputs; ++n) {
    plhs[n] = emlrtReturnArrayR2009a(outputs[n]);
  }
  /* Module finalization. */
  forecastSarmaHyndmanMex_terminate();
}

void forecastSarmaHyndmanMex_atexit_wrapper(void)
{
   forecastSarmaHyndmanMex_atexit();
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  /* Initialize the memory manager. */
  mexAtExit(forecastSarmaHyndmanMex_atexit_wrapper);
  /* Dispatch the entry-point. */
  forecastSarmaHyndmanMex_mexFunction(nlhs, plhs, nrhs, prhs);
}
/* End of code generation (_coder_forecastSarmaHyndmanMex_mex.c) */
