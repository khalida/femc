/*
 * forecastSarmaHyndmanMex_terminate.c
 *
 * Code generation for function 'forecastSarmaHyndmanMex_terminate'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "forecastSarmaHyndmanMex.h"
#include "forecastSarmaHyndmanMex_terminate.h"

/* Function Definitions */
void forecastSarmaHyndmanMex_atexit(void)
{
  emlrtStack st = { NULL, NULL, NULL };

  emlrtCreateRootTLS(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1);
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

void forecastSarmaHyndmanMex_terminate(void)
{
  emlrtStack st = { NULL, NULL, NULL };

  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/* End of code generation (forecastSarmaHyndmanMex_terminate.c) */
