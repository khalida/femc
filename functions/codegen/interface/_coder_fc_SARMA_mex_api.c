/*
 * _coder_fc_SARMA_mex_api.c
 *
 * Code generation for function '_coder_fc_SARMA_mex_api'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "fc_SARMA_mex.h"
#include "_coder_fc_SARMA_mex_api.h"
#include "fc_SARMA_mex_emxutil.h"

/* Variable Definitions */
static emlrtRTEInfo b_emlrtRTEI = { 1, 1, "_coder_fc_SARMA_mex_api", "" };

/* Function Declarations */
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, emxArray_real_T *y);
static real_T (*c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *theta,
  const char_T *identifier))[3];
static real_T (*d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId))[3];
static real_T e_emlrt_marshallIn(const emlrtStack *sp, const mxArray *phi, const
  char_T *identifier);
static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *demand, const
  char_T *identifier, emxArray_real_T *y);
static const mxArray *emlrt_marshallOut(const emxArray_real_T *u);
static real_T f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId);
static void g_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, emxArray_real_T *ret);
static real_T (*h_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
  const emlrtMsgIdentifier *msgId))[3];
static real_T i_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId);

/* Function Definitions */
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, emxArray_real_T *y)
{
  g_emlrt_marshallIn(sp, emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static real_T (*c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *theta,
  const char_T *identifier))[3]
{
  real_T (*y)[3];
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = identifier;
  thisId.fParent = NULL;
  y = d_emlrt_marshallIn(sp, emlrtAlias(theta), &thisId);
  emlrtDestroyArray(&theta);
  return y;
}
  static real_T (*d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
  const emlrtMsgIdentifier *parentId))[3]
{
  real_T (*y)[3];
  y = h_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static real_T e_emlrt_marshallIn(const emlrtStack *sp, const mxArray *phi, const
  char_T *identifier)
{
  real_T y;
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = identifier;
  thisId.fParent = NULL;
  y = f_emlrt_marshallIn(sp, emlrtAlias(phi), &thisId);
  emlrtDestroyArray(&phi);
  return y;
}

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *demand, const
  char_T *identifier, emxArray_real_T *y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = identifier;
  thisId.fParent = NULL;
  b_emlrt_marshallIn(sp, emlrtAlias(demand), &thisId, y);
  emlrtDestroyArray(&demand);
}

static const mxArray *emlrt_marshallOut(const emxArray_real_T *u)
{
  const mxArray *y;
  static const int32_T iv0[2] = { 0, 0 };

  const mxArray *m1;
  y = NULL;
  m1 = emlrtCreateNumericArray(2, iv0, mxDOUBLE_CLASS, mxREAL);
  mxSetData((mxArray *)m1, (void *)u->data);
  emlrtSetDimensions((mxArray *)m1, u->size, 2);
  emlrtAssign(&y, m1);
  return y;
}

static real_T f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId)
{
  real_T y;
  y = i_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static void g_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, emxArray_real_T *ret)
{
  int32_T iv1[2];
  boolean_T bv0[2];
  int32_T i;
  int32_T iv2[2];
  for (i = 0; i < 2; i++) {
    iv1[i] = -1;
    bv0[i] = true;
  }

  emlrtCheckVsBuiltInR2012b(sp, msgId, src, "double", false, 2U, iv1, bv0, iv2);
  ret->size[0] = iv2[0];
  ret->size[1] = iv2[1];
  ret->allocatedSize = ret->size[0] * ret->size[1];
  ret->data = (real_T *)mxGetData(src);
  ret->canFreeData = false;
  emlrtDestroyArray(&src);
}

static real_T (*h_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
  const emlrtMsgIdentifier *msgId))[3]
{
  real_T (*ret)[3];
  int32_T iv3[2];
  int32_T i9;
  for (i9 = 0; i9 < 2; i9++) {
    iv3[i9] = 1 + (i9 << 1);
  }

  emlrtCheckBuiltInR2012b(sp, msgId, src, "double", false, 2U, iv3);
  ret = (real_T (*)[3])mxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}
  static real_T i_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
  const emlrtMsgIdentifier *msgId)
{
  real_T ret;
  emlrtCheckBuiltInR2012b(sp, msgId, src, "double", false, 0U, 0);
  ret = *(real_T *)mxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

void fc_SARMA_mex_api(const mxArray * const prhs[4], const mxArray *plhs[1])
{
  emxArray_real_T *demand;
  emxArray_real_T *fc;
  real_T (*theta)[3];
  real_T phi;
  real_T k;
  emlrtStack st = { NULL, NULL, NULL };

  st.tls = emlrtRootTLSGlobal;
  emlrtHeapReferenceStackEnterFcnR2012b(&st);
  emxInit_real_T(&st, &demand, 2, &b_emlrtRTEI, true);
  emxInit_real_T(&st, &fc, 2, &b_emlrtRTEI, true);

  /* Marshall function inputs */
  emlrt_marshallIn(&st, emlrtAlias(prhs[0]), "demand", demand);
  theta = c_emlrt_marshallIn(&st, emlrtAlias(prhs[1]), "theta");
  phi = e_emlrt_marshallIn(&st, emlrtAliasP(prhs[2]), "phi");
  k = e_emlrt_marshallIn(&st, emlrtAliasP(prhs[3]), "k");

  /* Invoke the target function */
  fc_SARMA_mex(&st, demand, *theta, phi, k, fc);

  /* Marshall function outputs */
  plhs[0] = emlrt_marshallOut(fc);
  fc->canFreeData = false;
  emxFree_real_T(&fc);
  demand->canFreeData = false;
  emxFree_real_T(&demand);
  emlrtHeapReferenceStackLeaveFcnR2012b(&st);
}

/* End of code generation (_coder_fc_SARMA_mex_api.c) */
