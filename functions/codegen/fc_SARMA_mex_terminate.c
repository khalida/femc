/*
 * fc_SARMA_mex_terminate.c
 *
 * Code generation for function 'fc_SARMA_mex_terminate'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "fc_SARMA_mex.h"
#include "fc_SARMA_mex_terminate.h"

/* Function Definitions */
void fc_SARMA_mex_atexit(void)
{
  emlrtStack st = { NULL, NULL, NULL };

  emlrtCreateRootTLS(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1);
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

void fc_SARMA_mex_terminate(void)
{
  emlrtStack st = { NULL, NULL, NULL };

  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/* End of code generation (fc_SARMA_mex_terminate.c) */
