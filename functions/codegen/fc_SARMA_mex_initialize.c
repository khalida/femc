/*
 * fc_SARMA_mex_initialize.c
 *
 * Code generation for function 'fc_SARMA_mex_initialize'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "fc_SARMA_mex.h"
#include "fc_SARMA_mex_initialize.h"
#include "fc_SARMA_mex_data.h"

/* Function Definitions */
void fc_SARMA_mex_initialize(emlrtContext *aContext)
{
  emlrtStack st = { NULL, NULL, NULL };

  emlrtBreakCheckR2012bFlagVar = emlrtGetBreakCheckFlagAddressR2012b();
  emlrtCreateRootTLS(&emlrtRootTLSGlobal, aContext, NULL, 1);
  st.tls = emlrtRootTLSGlobal;
  emlrtClearAllocCountR2012b(&st, false, 0U, 0);
  emlrtEnterRtStackR2012b(&st);
  emlrtFirstTimeR2012b(emlrtRootTLSGlobal);
}

/* End of code generation (fc_SARMA_mex_initialize.c) */
