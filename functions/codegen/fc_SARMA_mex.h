/*
 * fc_SARMA_mex.h
 *
 * Code generation for function 'fc_SARMA_mex'
 *
 */

#ifndef __FC_SARMA_MEX_H__
#define __FC_SARMA_MEX_H__

/* Include files */
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include "blas.h"
#include "rtwtypes.h"
#include "fc_SARMA_mex_types.h"

/* Function Declarations */
extern void fc_SARMA_mex(const emlrtStack *sp, const emxArray_real_T *demand,
  const real_T theta[3], real_T phi, real_T k, emxArray_real_T *fc);

#endif

/* End of code generation (fc_SARMA_mex.h) */
