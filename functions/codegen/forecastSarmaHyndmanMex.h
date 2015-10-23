/*
 * forecastSarmaHyndmanMex.h
 *
 * Code generation for function 'forecastSarmaHyndmanMex'
 *
 */

#ifndef __FORECASTSARMAHYNDMANMEX_H__
#define __FORECASTSARMAHYNDMANMEX_H__

/* Include files */
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include "blas.h"
#include "rtwtypes.h"
#include "forecastSarmaHyndmanMex_types.h"

/* Function Declarations */
extern void forecastSarmaHyndmanMex(const emlrtStack *sp, const emxArray_real_T *
  demand, const real_T phiValues[3], real_T PhiValues, real_T k, emxArray_real_T
  *forecast);

#endif

/* End of code generation (forecastSarmaHyndmanMex.h) */
