/*
 * fc_SARMA_mex.c
 *
 * Code generation for function 'fc_SARMA_mex'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "fc_SARMA_mex.h"
#include "fc_SARMA_mex_emxutil.h"
#include "fc_SARMA_mex_data.h"

/* Variable Definitions */
static emlrtMCInfo emlrtMCI = { 4, 1, "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m" };

static emlrtRTEInfo emlrtRTEI = { 1, 15, "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m" };

static emlrtRTEInfo c_emlrtRTEI = { 8, 1, "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m" };

static emlrtBCInfo emlrtBCI = { -1, -1, 14, 32, "fc", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtBCInfo b_emlrtBCI = { -1, -1, 14, 9, "fc", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtBCInfo c_emlrtBCI = { -1, -1, 18, 32, "fc", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtBCInfo d_emlrtBCI = { -1, -1, 18, 58, "fc", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtBCInfo e_emlrtBCI = { -1, -1, 18, 9, "fc", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtBCInfo f_emlrtBCI = { -1, -1, 26, 9, "fc", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtBCInfo g_emlrtBCI = { -1, -1, 26, 32, "fc", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtBCInfo h_emlrtBCI = { -1, -1, 26, 58, "fc", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtBCInfo i_emlrtBCI = { -1, -1, 27, 22, "fc", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtBCInfo j_emlrtBCI = { -1, -1, 27, 43, "fc", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtDCInfo emlrtDCI = { 27, 43, "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 1 };

static emlrtBCInfo k_emlrtBCI = { -1, -1, 22, 9, "fc", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtBCInfo l_emlrtBCI = { -1, -1, 22, 32, "fc", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtBCInfo m_emlrtBCI = { -1, -1, 22, 58, "fc", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtBCInfo n_emlrtBCI = { -1, -1, 23, 22, "fc", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtBCInfo o_emlrtBCI = { -1, -1, 23, 43, "demand", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtDCInfo b_emlrtDCI = { 23, 43, "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 1 };

static emlrtBCInfo p_emlrtBCI = { -1, -1, 19, 22, "demand", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtBCInfo q_emlrtBCI = { -1, -1, 19, 53, "demand", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtDCInfo c_emlrtDCI = { 19, 53, "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 1 };

static emlrtBCInfo r_emlrtBCI = { -1, -1, 14, 58, "demand", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtBCInfo s_emlrtBCI = { -1, -1, 15, 22, "demand", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtBCInfo t_emlrtBCI = { -1, -1, 15, 53, "demand", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtDCInfo d_emlrtDCI = { 15, 53, "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 1 };

static emlrtBCInfo u_emlrtBCI = { -1, -1, 10, 9, "fc", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtBCInfo v_emlrtBCI = { -1, -1, 10, 32, "demand", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtBCInfo w_emlrtBCI = { -1, -1, 10, 68, "demand", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtBCInfo x_emlrtBCI = { -1, -1, 11, 22, "demand", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtBCInfo y_emlrtBCI = { -1, -1, 11, 53, "demand", "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 0 };

static emlrtDCInfo e_emlrtDCI = { 11, 53, "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m", 1 };

static emlrtRSInfo emlrtRSI = { 4, "fc_SARMA_mex",
  "C:\\LocalData\\Documents\\Documents\\PhD\\13_Software\\05_Simulink\\microGrid_MPC\\minimise_max_power_drawn\\models\\commonFunctions\\fc_SA"
  "RMA_mex.m" };

/* Function Declarations */
static void error(const emlrtStack *sp, const mxArray *b, emlrtMCInfo *location);

/* Function Definitions */
static void error(const emlrtStack *sp, const mxArray *b, emlrtMCInfo *location)
{
  const mxArray *pArray;
  pArray = b;
  emlrtCallMATLABR2012b(sp, 0, NULL, 1, &pArray, "error", true, location);
}

void fc_SARMA_mex(const emlrtStack *sp, const emxArray_real_T *demand, const
                  real_T theta[3], real_T phi, real_T k, emxArray_real_T *fc)
{
  real_T b_k[2];
  boolean_T x[2];
  int32_T i0;
  boolean_T y;
  int32_T c_k;
  boolean_T exitg1;
  const mxArray *b_y;
  const mxArray *m0;
  uint32_T uv0[2];
  int32_T i1;
  int32_T i2;
  int32_T i3;
  int32_T i4;
  int32_T i5;
  int32_T i6;
  int32_T i7;
  real_T d0;
  int32_T i8;
  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;

  /*  Assert input types */
  b_k[0] = k;
  b_k[1] = 1.0;
  for (i0 = 0; i0 < 2; i0++) {
    x[i0] = (demand->size[i0] == b_k[i0]);
  }

  y = true;
  c_k = 0;
  exitg1 = false;
  while ((!exitg1) && (c_k < 2)) {
    if (x[c_k] == 0) {
      y = false;
      exitg1 = true;
    } else {
      c_k++;
    }
  }

  if (y) {
  } else {
    b_y = NULL;
    m0 = emlrtCreateString("Assertion failed.");
    emlrtAssign(&b_y, m0);
    st.site = &emlrtRSI;
    error(&st, b_y, &emlrtMCI);
  }

  for (i0 = 0; i0 < 2; i0++) {
    uv0[i0] = (uint32_T)demand->size[i0];
  }

  i0 = fc->size[0] * fc->size[1];
  fc->size[0] = (int32_T)uv0[0];
  emxEnsureCapacity(sp, (emxArray__common *)fc, i0, (int32_T)sizeof(real_T),
                    &emlrtRTEI);
  i0 = fc->size[0] * fc->size[1];
  fc->size[1] = (int32_T)uv0[1];
  emxEnsureCapacity(sp, (emxArray__common *)fc, i0, (int32_T)sizeof(real_T),
                    &emlrtRTEI);
  c_k = (int32_T)uv0[0] * (int32_T)uv0[1];
  for (i0 = 0; i0 < c_k; i0++) {
    fc->data[i0] = 0.0;
  }

  emlrtForLoopVectorCheckR2012b(1.0, 1.0, k, mxDOUBLE_CLASS, (int32_T)k,
    &c_emlrtRTEI, sp);
  c_k = 0;
  while (c_k <= (int32_T)k - 1) {
    if (1.0 + (real_T)c_k <= 1.0) {
      i0 = fc->size[0] * fc->size[1];
      i1 = demand->size[0] * demand->size[1];
      i2 = (int32_T)(((real_T)(demand->size[0] * demand->size[1]) + (1.0 +
        (real_T)c_k)) - 1.0);
      i3 = demand->size[0] * demand->size[1];
      i4 = (int32_T)(((real_T)(demand->size[0] * demand->size[1]) + (1.0 +
        (real_T)c_k)) - 2.0);
      i5 = demand->size[0] * demand->size[1];
      i6 = (int32_T)(((real_T)(demand->size[0] * demand->size[1]) + (1.0 +
        (real_T)c_k)) - 3.0);
      i7 = demand->size[0] * demand->size[1];
      d0 = ((real_T)(demand->size[0] * demand->size[1]) + (1.0 + (real_T)c_k)) -
        k;
      i8 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &e_emlrtDCI, sp);
      fc->data[emlrtDynamicBoundsCheckFastR2012b(c_k + 1, 1, i0, &u_emlrtBCI, sp)
        - 1] = ((theta[0] * demand->data[emlrtDynamicBoundsCheckFastR2012b(i2, 1,
                  i1, &v_emlrtBCI, sp) - 1] + theta[1] * demand->
                 data[emlrtDynamicBoundsCheckFastR2012b(i4, 1, i3, &w_emlrtBCI,
                  sp) - 1]) + theta[2] * demand->
                data[emlrtDynamicBoundsCheckFastR2012b(i6, 1, i5, &x_emlrtBCI,
                 sp) - 1]) + phi * demand->
        data[emlrtDynamicBoundsCheckFastR2012b(i8, 1, i7, &y_emlrtBCI, sp) - 1];
    } else if (1.0 + (real_T)c_k <= 2.0) {
      i0 = fc->size[0] * fc->size[1];
      i1 = c_k + 1;
      emlrtDynamicBoundsCheckFastR2012b(i1, 1, i0, &b_emlrtBCI, sp);
      i0 = fc->size[0] * fc->size[1];
      i1 = (int32_T)((1.0 + (real_T)c_k) - 1.0);
      emlrtDynamicBoundsCheckFastR2012b(i1, 1, i0, &emlrtBCI, sp);
      i0 = demand->size[0] * demand->size[1];
      i1 = (int32_T)(((real_T)(demand->size[0] * demand->size[1]) + 2.0) - 2.0);
      i2 = demand->size[0] * demand->size[1];
      i3 = (int32_T)(((real_T)(demand->size[0] * demand->size[1]) + 2.0) - 3.0);
      i4 = demand->size[0] * demand->size[1];
      d0 = ((real_T)(demand->size[0] * demand->size[1]) + 2.0) - k;
      i5 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &d_emlrtDCI, sp);
      fc->data[1] = ((theta[0] * fc->data[0] + theta[1] * demand->
                      data[emlrtDynamicBoundsCheckFastR2012b(i1, 1, i0,
        &r_emlrtBCI, sp) - 1]) + theta[2] * demand->
                     data[emlrtDynamicBoundsCheckFastR2012b(i3, 1, i2,
        &s_emlrtBCI, sp) - 1]) + phi * demand->
        data[emlrtDynamicBoundsCheckFastR2012b(i5, 1, i4, &t_emlrtBCI, sp) - 1];
    } else if (1.0 + (real_T)c_k <= 3.0) {
      i0 = fc->size[0] * fc->size[1];
      i1 = c_k + 1;
      emlrtDynamicBoundsCheckFastR2012b(i1, 1, i0, &e_emlrtBCI, sp);
      i0 = fc->size[0] * fc->size[1];
      i1 = (int32_T)((1.0 + (real_T)c_k) - 1.0);
      emlrtDynamicBoundsCheckFastR2012b(i1, 1, i0, &c_emlrtBCI, sp);
      i0 = fc->size[0] * fc->size[1];
      i1 = (int32_T)((1.0 + (real_T)c_k) - 2.0);
      emlrtDynamicBoundsCheckFastR2012b(i1, 1, i0, &d_emlrtBCI, sp);
      i0 = demand->size[0] * demand->size[1];
      i1 = (int32_T)(((real_T)(demand->size[0] * demand->size[1]) + 3.0) - 3.0);
      i2 = demand->size[0] * demand->size[1];
      d0 = ((real_T)(demand->size[0] * demand->size[1]) + 3.0) - k;
      i3 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &c_emlrtDCI, sp);
      fc->data[2] = ((theta[0] * fc->data[1] + theta[1] * fc->data[0]) + theta[2]
                     * demand->data[emlrtDynamicBoundsCheckFastR2012b(i1, 1, i0,
        &p_emlrtBCI, sp) - 1]) + phi * demand->
        data[emlrtDynamicBoundsCheckFastR2012b(i3, 1, i2, &q_emlrtBCI, sp) - 1];
    } else if (1.0 + (real_T)c_k <= k) {
      i0 = fc->size[0] * fc->size[1];
      i1 = fc->size[0] * fc->size[1];
      i2 = (int32_T)((1.0 + (real_T)c_k) - 1.0);
      i3 = fc->size[0] * fc->size[1];
      i4 = (int32_T)((1.0 + (real_T)c_k) - 2.0);
      i5 = fc->size[0] * fc->size[1];
      i6 = (int32_T)((1.0 + (real_T)c_k) - 3.0);
      i7 = demand->size[0] * demand->size[1];
      d0 = ((real_T)(demand->size[0] * demand->size[1]) + (1.0 + (real_T)c_k)) -
        k;
      i8 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &b_emlrtDCI, sp);
      fc->data[emlrtDynamicBoundsCheckFastR2012b(c_k + 1, 1, i0, &k_emlrtBCI, sp)
        - 1] = ((theta[0] * fc->data[emlrtDynamicBoundsCheckFastR2012b(i2, 1, i1,
                  &l_emlrtBCI, sp) - 1] + theta[1] * fc->
                 data[emlrtDynamicBoundsCheckFastR2012b(i4, 1, i3, &m_emlrtBCI,
                  sp) - 1]) + theta[2] * fc->
                data[emlrtDynamicBoundsCheckFastR2012b(i6, 1, i5, &n_emlrtBCI,
                 sp) - 1]) + phi * demand->
        data[emlrtDynamicBoundsCheckFastR2012b(i8, 1, i7, &o_emlrtBCI, sp) - 1];
    } else {
      i0 = fc->size[0] * fc->size[1];
      i1 = fc->size[0] * fc->size[1];
      i2 = (int32_T)((1.0 + (real_T)c_k) - 1.0);
      i3 = fc->size[0] * fc->size[1];
      i4 = (int32_T)((1.0 + (real_T)c_k) - 2.0);
      i5 = fc->size[0] * fc->size[1];
      i6 = (int32_T)((1.0 + (real_T)c_k) - 3.0);
      i7 = fc->size[0] * fc->size[1];
      d0 = (1.0 + (real_T)c_k) - k;
      i8 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &emlrtDCI, sp);
      fc->data[emlrtDynamicBoundsCheckFastR2012b(c_k + 1, 1, i0, &f_emlrtBCI, sp)
        - 1] = ((theta[0] * fc->data[emlrtDynamicBoundsCheckFastR2012b(i2, 1, i1,
                  &g_emlrtBCI, sp) - 1] + theta[1] * fc->
                 data[emlrtDynamicBoundsCheckFastR2012b(i4, 1, i3, &h_emlrtBCI,
                  sp) - 1]) + theta[2] * fc->
                data[emlrtDynamicBoundsCheckFastR2012b(i6, 1, i5, &i_emlrtBCI,
                 sp) - 1]) + phi * fc->data[emlrtDynamicBoundsCheckFastR2012b(i8,
        1, i7, &j_emlrtBCI, sp) - 1];
    }

    c_k++;
    emlrtBreakCheckFastR2012b(emlrtBreakCheckR2012bFlagVar, sp);
  }
}

/* End of code generation (fc_SARMA_mex.c) */
