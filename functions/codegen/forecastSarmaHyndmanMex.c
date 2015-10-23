/*
 * forecastSarmaHyndmanMex.c
 *
 * Code generation for function 'forecastSarmaHyndmanMex'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "forecastSarmaHyndmanMex.h"
#include "forecastSarmaHyndmanMex_emxutil.h"
#include "forecastSarmaHyndmanMex_data.h"

/* Variable Definitions */
static emlrtMCInfo emlrtMCI = { 10, 1, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m"
};

static emlrtRTEInfo emlrtRTEI = { 4, 21, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m"
};

static emlrtRTEInfo c_emlrtRTEI = { 15, 1, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m"
};

static emlrtBCInfo emlrtBCI = { -1, -1, 26, 41, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo b_emlrtBCI = { -1, -1, 26, 9, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo c_emlrtBCI = { -1, -1, 35, 41, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo d_emlrtBCI = { -1, -1, 36, 26, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo e_emlrtBCI = { -1, -1, 35, 9, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo emlrtDCI = { 13, 18, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtDCInfo b_emlrtDCI = { 13, 18, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  4 };

static emlrtBCInfo f_emlrtBCI = { -1, -1, 69, 9, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo g_emlrtBCI = { -1, -1, 69, 41, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo h_emlrtBCI = { -1, -1, 70, 26, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo i_emlrtBCI = { -1, -1, 71, 26, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo j_emlrtBCI = { -1, -1, 72, 23, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo c_emlrtDCI = { 72, 23, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo k_emlrtBCI = { -1, -1, 73, 36, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo d_emlrtDCI = { 73, 36, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo l_emlrtBCI = { -1, -1, 74, 36, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo e_emlrtDCI = { 74, 36, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo m_emlrtBCI = { -1, -1, 75, 36, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo f_emlrtDCI = { 75, 36, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo n_emlrtBCI = { -1, -1, 61, 9, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo o_emlrtBCI = { -1, -1, 61, 41, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo p_emlrtBCI = { -1, -1, 62, 26, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo q_emlrtBCI = { -1, -1, 63, 26, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo r_emlrtBCI = { -1, -1, 64, 23, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo g_emlrtDCI = { 64, 23, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo s_emlrtBCI = { -1, -1, 65, 36, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo h_emlrtDCI = { 65, 36, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo t_emlrtBCI = { -1, -1, 66, 36, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo i_emlrtDCI = { 66, 36, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo u_emlrtBCI = { -1, -1, 67, 36, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo j_emlrtDCI = { 67, 36, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo v_emlrtBCI = { -1, -1, 53, 9, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo w_emlrtBCI = { -1, -1, 53, 41, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo x_emlrtBCI = { -1, -1, 54, 26, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo y_emlrtBCI = { -1, -1, 55, 26, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo ab_emlrtBCI = { -1, -1, 56, 23, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo k_emlrtDCI = { 56, 23, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo bb_emlrtBCI = { -1, -1, 57, 36, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo l_emlrtDCI = { 57, 36, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo cb_emlrtBCI = { -1, -1, 58, 36, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo m_emlrtDCI = { 58, 36, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo db_emlrtBCI = { -1, -1, 59, 36, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo n_emlrtDCI = { 59, 36, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo eb_emlrtBCI = { -1, -1, 44, 9, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo fb_emlrtBCI = { -1, -1, 44, 41, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo gb_emlrtBCI = { -1, -1, 45, 26, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo hb_emlrtBCI = { -1, -1, 46, 26, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo ib_emlrtBCI = { -1, -1, 47, 23, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo o_emlrtDCI = { 47, 23, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo jb_emlrtBCI = { -1, -1, 48, 36, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo p_emlrtDCI = { 48, 36, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo kb_emlrtBCI = { -1, -1, 49, 36, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo q_emlrtDCI = { 49, 36, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo lb_emlrtBCI = { -1, -1, 50, 36, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo r_emlrtDCI = { 50, 36, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo mb_emlrtBCI = { -1, -1, 37, 26, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo nb_emlrtBCI = { -1, -1, 38, 23, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo s_emlrtDCI = { 38, 23, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo ob_emlrtBCI = { -1, -1, 39, 36, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo t_emlrtDCI = { 39, 36, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo pb_emlrtBCI = { -1, -1, 40, 36, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo u_emlrtDCI = { 40, 36, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo qb_emlrtBCI = { -1, -1, 41, 36, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo v_emlrtDCI = { 41, 36, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo rb_emlrtBCI = { -1, -1, 27, 26, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo sb_emlrtBCI = { -1, -1, 28, 26, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo tb_emlrtBCI = { -1, -1, 29, 23, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo w_emlrtDCI = { 29, 23, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo ub_emlrtBCI = { -1, -1, 30, 36, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo x_emlrtDCI = { 30, 36, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo vb_emlrtBCI = { -1, -1, 31, 36, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo y_emlrtDCI = { 31, 36, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo wb_emlrtBCI = { -1, -1, 32, 36, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo ab_emlrtDCI = { 32, 36, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo xb_emlrtBCI = { -1, -1, 17, 9, "forecast",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo yb_emlrtBCI = { -1, -1, 17, 41, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo ac_emlrtBCI = { -1, -1, 18, 26, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo bc_emlrtBCI = { -1, -1, 19, 26, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtBCInfo cc_emlrtBCI = { -1, -1, 20, 23, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo bb_emlrtDCI = { 20, 23, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo dc_emlrtBCI = { -1, -1, 21, 36, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo cb_emlrtDCI = { 21, 36, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo ec_emlrtBCI = { -1, -1, 22, 36, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo db_emlrtDCI = { 22, 36, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtBCInfo fc_emlrtBCI = { -1, -1, 23, 36, "demand",
  "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  0 };

static emlrtDCInfo eb_emlrtDCI = { 23, 36, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m",
  1 };

static emlrtRSInfo emlrtRSI = { 10, "forecastSarmaHyndmanMex",
  "C:\\Users\\Khalid Abdulla\\Documents\\PhD\\femc\\functions\\forecastingSARMA\\forecastSarmaHyndmanMex.m"
};

/* Function Declarations */
static void error(const emlrtStack *sp, const mxArray *b, emlrtMCInfo *location);

/* Function Definitions */
static void error(const emlrtStack *sp, const mxArray *b, emlrtMCInfo *location)
{
  const mxArray *pArray;
  pArray = b;
  emlrtCallMATLABR2012b(sp, 0, NULL, 1, &pArray, "error", true, location);
}

void forecastSarmaHyndmanMex(const emlrtStack *sp, const emxArray_real_T *demand,
  const real_T phiValues[3], real_T PhiValues, real_T k, emxArray_real_T
  *forecast)
{
  real_T b_k[2];
  boolean_T x[2];
  int32_T i0;
  boolean_T y;
  int32_T c_k;
  boolean_T exitg1;
  const mxArray *b_y;
  const mxArray *m0;
  real_T d_k[2];
  real_T d0;
  int32_T i1;
  int32_T i2;
  int32_T i3;
  int32_T i4;
  int32_T i5;
  int32_T i6;
  int32_T i7;
  int32_T i8;
  int32_T i9;
  int32_T i10;
  int32_T i11;
  int32_T i12;
  int32_T i13;
  int32_T i14;
  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;

  /* % SARMA forecast using method described by Hyndman in: */
  /*  https://www.otexts.org/fpp/8/8 */
  /*  Assert input types */
  /*  NB: need lags up to p + k*P, where p is AR order, P is seasonal AR order */
  /*  of model and k is the seasonal period */
  b_k[0] = k + 3.0;
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

  /*  Pre-allocate output forecast */
  d_k[0] = k;
  d_k[1] = 1.0;
  for (i0 = 0; i0 < 2; i0++) {
    d0 = emlrtNonNegativeCheckFastR2012b(d_k[i0], &b_emlrtDCI, sp);
    b_k[i0] = emlrtIntegerCheckFastR2012b(d0, &emlrtDCI, sp);
  }

  i0 = forecast->size[0];
  forecast->size[0] = (int32_T)b_k[0];
  emxEnsureCapacity(sp, (emxArray__common *)forecast, i0, (int32_T)sizeof(real_T),
                    &emlrtRTEI);
  c_k = (int32_T)b_k[0];
  for (i0 = 0; i0 < c_k; i0++) {
    forecast->data[i0] = 0.0;
  }

  emlrtForLoopVectorCheckR2012b(1.0, 1.0, k, mxDOUBLE_CLASS, (int32_T)k,
    &c_emlrtRTEI, sp);
  c_k = 0;
  while (c_k <= (int32_T)k - 1) {
    if (1.0 + (real_T)c_k <= 1.0) {
      i0 = forecast->size[0];
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
      i8 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &bb_emlrtDCI, sp);
      i9 = demand->size[0] * demand->size[1];
      d0 = (((real_T)(demand->size[0] * demand->size[1]) + (1.0 + (real_T)c_k))
            - k) - 1.0;
      i10 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &cb_emlrtDCI, sp);
      i11 = demand->size[0] * demand->size[1];
      d0 = (((real_T)(demand->size[0] * demand->size[1]) + (1.0 + (real_T)c_k))
            - k) - 2.0;
      i12 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &db_emlrtDCI, sp);
      i13 = demand->size[0] * demand->size[1];
      d0 = (((real_T)(demand->size[0] * demand->size[1]) + (1.0 + (real_T)c_k))
            - k) - 3.0;
      i14 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &eb_emlrtDCI, sp);
      forecast->data[emlrtDynamicBoundsCheckFastR2012b(c_k + 1, 1, i0,
        &xb_emlrtBCI, sp) - 1] = (((((phiValues[0] * demand->
        data[emlrtDynamicBoundsCheckFastR2012b(i2, 1, i1, &yb_emlrtBCI, sp) - 1]
        + phiValues[1] * demand->data[emlrtDynamicBoundsCheckFastR2012b(i4, 1,
        i3, &ac_emlrtBCI, sp) - 1]) + phiValues[2] * demand->
        data[emlrtDynamicBoundsCheckFastR2012b(i6, 1, i5, &bc_emlrtBCI, sp) - 1])
        + PhiValues * demand->data[emlrtDynamicBoundsCheckFastR2012b(i8, 1, i7,
        &cc_emlrtBCI, sp) - 1]) - phiValues[0] * PhiValues * demand->
        data[emlrtDynamicBoundsCheckFastR2012b(i10, 1, i9, &dc_emlrtBCI, sp) - 1])
        - phiValues[1] * PhiValues * demand->
        data[emlrtDynamicBoundsCheckFastR2012b(i12, 1, i11, &ec_emlrtBCI, sp) -
        1]) - phiValues[2] * PhiValues * demand->
        data[emlrtDynamicBoundsCheckFastR2012b(i14, 1, i13, &fc_emlrtBCI, sp) -
        1];
    } else if (1.0 + (real_T)c_k <= 2.0) {
      i0 = forecast->size[0];
      i1 = c_k + 1;
      emlrtDynamicBoundsCheckFastR2012b(i1, 1, i0, &b_emlrtBCI, sp);
      i0 = forecast->size[0];
      i1 = (int32_T)((1.0 + (real_T)c_k) - 1.0);
      emlrtDynamicBoundsCheckFastR2012b(i1, 1, i0, &emlrtBCI, sp);
      i0 = demand->size[0] * demand->size[1];
      i1 = (int32_T)(((real_T)(demand->size[0] * demand->size[1]) + 2.0) - 2.0);
      i2 = demand->size[0] * demand->size[1];
      i3 = (int32_T)(((real_T)(demand->size[0] * demand->size[1]) + 2.0) - 3.0);
      i4 = demand->size[0] * demand->size[1];
      d0 = ((real_T)(demand->size[0] * demand->size[1]) + 2.0) - k;
      i5 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &w_emlrtDCI, sp);
      i6 = demand->size[0] * demand->size[1];
      d0 = (((real_T)(demand->size[0] * demand->size[1]) + 2.0) - k) - 1.0;
      i7 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &x_emlrtDCI, sp);
      i8 = demand->size[0] * demand->size[1];
      d0 = (((real_T)(demand->size[0] * demand->size[1]) + 2.0) - k) - 2.0;
      i9 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &y_emlrtDCI, sp);
      i10 = demand->size[0] * demand->size[1];
      d0 = (((real_T)(demand->size[0] * demand->size[1]) + 2.0) - k) - 3.0;
      i11 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &ab_emlrtDCI, sp);
      forecast->data[1] = (((((phiValues[0] * forecast->data[0] + phiValues[1] *
        demand->data[emlrtDynamicBoundsCheckFastR2012b(i1, 1, i0, &rb_emlrtBCI,
        sp) - 1]) + phiValues[2] * demand->
        data[emlrtDynamicBoundsCheckFastR2012b(i3, 1, i2, &sb_emlrtBCI, sp) - 1])
        + PhiValues * demand->data[emlrtDynamicBoundsCheckFastR2012b(i5, 1, i4,
        &tb_emlrtBCI, sp) - 1]) - phiValues[0] * PhiValues * demand->
                            data[emlrtDynamicBoundsCheckFastR2012b(i7, 1, i6,
        &ub_emlrtBCI, sp) - 1]) - phiValues[1] * PhiValues * demand->
                           data[emlrtDynamicBoundsCheckFastR2012b(i9, 1, i8,
        &vb_emlrtBCI, sp) - 1]) - phiValues[2] * PhiValues * demand->
        data[emlrtDynamicBoundsCheckFastR2012b(i11, 1, i10, &wb_emlrtBCI, sp) -
        1];
    } else if (1.0 + (real_T)c_k <= 3.0) {
      i0 = forecast->size[0];
      i1 = c_k + 1;
      emlrtDynamicBoundsCheckFastR2012b(i1, 1, i0, &e_emlrtBCI, sp);
      i0 = forecast->size[0];
      i1 = (int32_T)((1.0 + (real_T)c_k) - 1.0);
      emlrtDynamicBoundsCheckFastR2012b(i1, 1, i0, &c_emlrtBCI, sp);
      i0 = forecast->size[0];
      i1 = (int32_T)((1.0 + (real_T)c_k) - 2.0);
      emlrtDynamicBoundsCheckFastR2012b(i1, 1, i0, &d_emlrtBCI, sp);
      i0 = demand->size[0] * demand->size[1];
      i1 = (int32_T)(((real_T)(demand->size[0] * demand->size[1]) + 3.0) - 3.0);
      i2 = demand->size[0] * demand->size[1];
      d0 = ((real_T)(demand->size[0] * demand->size[1]) + 3.0) - k;
      i3 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &s_emlrtDCI, sp);
      i4 = demand->size[0] * demand->size[1];
      d0 = (((real_T)(demand->size[0] * demand->size[1]) + 3.0) - k) - 1.0;
      i5 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &t_emlrtDCI, sp);
      i6 = demand->size[0] * demand->size[1];
      d0 = (((real_T)(demand->size[0] * demand->size[1]) + 3.0) - k) - 2.0;
      i7 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &u_emlrtDCI, sp);
      i8 = demand->size[0] * demand->size[1];
      d0 = (((real_T)(demand->size[0] * demand->size[1]) + 3.0) - k) - 3.0;
      i9 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &v_emlrtDCI, sp);
      forecast->data[2] = (((((phiValues[0] * forecast->data[1] + phiValues[1] *
        forecast->data[0]) + phiValues[2] * demand->
        data[emlrtDynamicBoundsCheckFastR2012b(i1, 1, i0, &mb_emlrtBCI, sp) - 1])
        + PhiValues * demand->data[emlrtDynamicBoundsCheckFastR2012b(i3, 1, i2,
        &nb_emlrtBCI, sp) - 1]) - phiValues[0] * PhiValues * demand->
                            data[emlrtDynamicBoundsCheckFastR2012b(i5, 1, i4,
        &ob_emlrtBCI, sp) - 1]) - phiValues[1] * PhiValues * demand->
                           data[emlrtDynamicBoundsCheckFastR2012b(i7, 1, i6,
        &pb_emlrtBCI, sp) - 1]) - phiValues[2] * PhiValues * demand->
        data[emlrtDynamicBoundsCheckFastR2012b(i9, 1, i8, &qb_emlrtBCI, sp) - 1];
    } else if (1.0 + (real_T)c_k <= k) {
      i0 = forecast->size[0];
      i1 = forecast->size[0];
      i2 = (int32_T)((1.0 + (real_T)c_k) - 1.0);
      i3 = forecast->size[0];
      i4 = (int32_T)((1.0 + (real_T)c_k) - 2.0);
      i5 = forecast->size[0];
      i6 = (int32_T)((1.0 + (real_T)c_k) - 3.0);
      i7 = demand->size[0] * demand->size[1];
      d0 = ((real_T)(demand->size[0] * demand->size[1]) + (1.0 + (real_T)c_k)) -
        k;
      i8 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &o_emlrtDCI, sp);
      i9 = demand->size[0] * demand->size[1];
      d0 = (((real_T)(demand->size[0] * demand->size[1]) + (1.0 + (real_T)c_k))
            - k) - 1.0;
      i10 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &p_emlrtDCI, sp);
      i11 = demand->size[0] * demand->size[1];
      d0 = (((real_T)(demand->size[0] * demand->size[1]) + (1.0 + (real_T)c_k))
            - k) - 2.0;
      i12 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &q_emlrtDCI, sp);
      i13 = demand->size[0] * demand->size[1];
      d0 = (((real_T)(demand->size[0] * demand->size[1]) + (1.0 + (real_T)c_k))
            - k) - 3.0;
      i14 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &r_emlrtDCI, sp);
      forecast->data[emlrtDynamicBoundsCheckFastR2012b(c_k + 1, 1, i0,
        &eb_emlrtBCI, sp) - 1] = (((((phiValues[0] * forecast->
        data[emlrtDynamicBoundsCheckFastR2012b(i2, 1, i1, &fb_emlrtBCI, sp) - 1]
        + phiValues[1] * forecast->data[emlrtDynamicBoundsCheckFastR2012b(i4, 1,
        i3, &gb_emlrtBCI, sp) - 1]) + phiValues[2] * forecast->
        data[emlrtDynamicBoundsCheckFastR2012b(i6, 1, i5, &hb_emlrtBCI, sp) - 1])
        + PhiValues * demand->data[emlrtDynamicBoundsCheckFastR2012b(i8, 1, i7,
        &ib_emlrtBCI, sp) - 1]) - phiValues[0] * PhiValues * demand->
        data[emlrtDynamicBoundsCheckFastR2012b(i10, 1, i9, &jb_emlrtBCI, sp) - 1])
        - phiValues[1] * PhiValues * demand->
        data[emlrtDynamicBoundsCheckFastR2012b(i12, 1, i11, &kb_emlrtBCI, sp) -
        1]) - phiValues[2] * PhiValues * demand->
        data[emlrtDynamicBoundsCheckFastR2012b(i14, 1, i13, &lb_emlrtBCI, sp) -
        1];
    } else if (1.0 + (real_T)c_k <= k + 1.0) {
      i0 = forecast->size[0];
      i1 = forecast->size[0];
      i2 = (int32_T)((1.0 + (real_T)c_k) - 1.0);
      i3 = forecast->size[0];
      i4 = (int32_T)((1.0 + (real_T)c_k) - 2.0);
      i5 = forecast->size[0];
      i6 = (int32_T)((1.0 + (real_T)c_k) - 3.0);
      i7 = forecast->size[0];
      d0 = (1.0 + (real_T)c_k) - k;
      i8 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &k_emlrtDCI, sp);
      i9 = forecast->size[0];
      d0 = (((real_T)forecast->size[0] + (1.0 + (real_T)c_k)) - k) - 1.0;
      i10 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &l_emlrtDCI, sp);
      i11 = demand->size[0] * demand->size[1];
      d0 = (((real_T)(demand->size[0] * demand->size[1]) + (1.0 + (real_T)c_k))
            - k) - 2.0;
      i12 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &m_emlrtDCI, sp);
      i13 = demand->size[0] * demand->size[1];
      d0 = (((real_T)(demand->size[0] * demand->size[1]) + (1.0 + (real_T)c_k))
            - k) - 3.0;
      i14 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &n_emlrtDCI, sp);
      forecast->data[emlrtDynamicBoundsCheckFastR2012b(c_k + 1, 1, i0,
        &v_emlrtBCI, sp) - 1] = (((((phiValues[0] * forecast->
        data[emlrtDynamicBoundsCheckFastR2012b(i2, 1, i1, &w_emlrtBCI, sp) - 1]
        + phiValues[1] * forecast->data[emlrtDynamicBoundsCheckFastR2012b(i4, 1,
        i3, &x_emlrtBCI, sp) - 1]) + phiValues[2] * forecast->
        data[emlrtDynamicBoundsCheckFastR2012b(i6, 1, i5, &y_emlrtBCI, sp) - 1])
        + PhiValues * forecast->data[emlrtDynamicBoundsCheckFastR2012b(i8, 1, i7,
        &ab_emlrtBCI, sp) - 1]) - phiValues[0] * PhiValues * forecast->
        data[emlrtDynamicBoundsCheckFastR2012b(i10, 1, i9, &bb_emlrtBCI, sp) - 1])
        - phiValues[1] * PhiValues * demand->
        data[emlrtDynamicBoundsCheckFastR2012b(i12, 1, i11, &cb_emlrtBCI, sp) -
        1]) - phiValues[2] * PhiValues * demand->
        data[emlrtDynamicBoundsCheckFastR2012b(i14, 1, i13, &db_emlrtBCI, sp) -
        1];
    } else if (1.0 + (real_T)c_k <= k + 2.0) {
      i0 = forecast->size[0];
      i1 = forecast->size[0];
      i2 = (int32_T)((1.0 + (real_T)c_k) - 1.0);
      i3 = forecast->size[0];
      i4 = (int32_T)((1.0 + (real_T)c_k) - 2.0);
      i5 = forecast->size[0];
      i6 = (int32_T)((1.0 + (real_T)c_k) - 3.0);
      i7 = forecast->size[0];
      d0 = (1.0 + (real_T)c_k) - k;
      i8 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &g_emlrtDCI, sp);
      i9 = forecast->size[0];
      d0 = (((real_T)forecast->size[0] + (1.0 + (real_T)c_k)) - k) - 1.0;
      i10 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &h_emlrtDCI, sp);
      i11 = forecast->size[0];
      d0 = (((real_T)forecast->size[0] + (1.0 + (real_T)c_k)) - k) - 2.0;
      i12 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &i_emlrtDCI, sp);
      i13 = demand->size[0] * demand->size[1];
      d0 = (((real_T)(demand->size[0] * demand->size[1]) + (1.0 + (real_T)c_k))
            - k) - 3.0;
      i14 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &j_emlrtDCI, sp);
      forecast->data[emlrtDynamicBoundsCheckFastR2012b(c_k + 1, 1, i0,
        &n_emlrtBCI, sp) - 1] = (((((phiValues[0] * forecast->
        data[emlrtDynamicBoundsCheckFastR2012b(i2, 1, i1, &o_emlrtBCI, sp) - 1]
        + phiValues[1] * forecast->data[emlrtDynamicBoundsCheckFastR2012b(i4, 1,
        i3, &p_emlrtBCI, sp) - 1]) + phiValues[2] * forecast->
        data[emlrtDynamicBoundsCheckFastR2012b(i6, 1, i5, &q_emlrtBCI, sp) - 1])
        + PhiValues * forecast->data[emlrtDynamicBoundsCheckFastR2012b(i8, 1, i7,
        &r_emlrtBCI, sp) - 1]) - phiValues[0] * PhiValues * forecast->
        data[emlrtDynamicBoundsCheckFastR2012b(i10, 1, i9, &s_emlrtBCI, sp) - 1])
        - phiValues[1] * PhiValues * forecast->
        data[emlrtDynamicBoundsCheckFastR2012b(i12, 1, i11, &t_emlrtBCI, sp) - 1])
        - phiValues[2] * PhiValues * demand->
        data[emlrtDynamicBoundsCheckFastR2012b(i14, 1, i13, &u_emlrtBCI, sp) - 1];
    } else {
      i0 = forecast->size[0];
      i1 = forecast->size[0];
      i2 = (int32_T)((1.0 + (real_T)c_k) - 1.0);
      i3 = forecast->size[0];
      i4 = (int32_T)((1.0 + (real_T)c_k) - 2.0);
      i5 = forecast->size[0];
      i6 = (int32_T)((1.0 + (real_T)c_k) - 3.0);
      i7 = forecast->size[0];
      d0 = (1.0 + (real_T)c_k) - k;
      i8 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &c_emlrtDCI, sp);
      i9 = forecast->size[0];
      d0 = (((real_T)forecast->size[0] + (1.0 + (real_T)c_k)) - k) - 1.0;
      i10 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &d_emlrtDCI, sp);
      i11 = forecast->size[0];
      d0 = (((real_T)forecast->size[0] + (1.0 + (real_T)c_k)) - k) - 2.0;
      i12 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &e_emlrtDCI, sp);
      i13 = forecast->size[0];
      d0 = (((real_T)forecast->size[0] + (1.0 + (real_T)c_k)) - k) - 3.0;
      i14 = (int32_T)emlrtIntegerCheckFastR2012b(d0, &f_emlrtDCI, sp);
      forecast->data[emlrtDynamicBoundsCheckFastR2012b(c_k + 1, 1, i0,
        &f_emlrtBCI, sp) - 1] = (((((phiValues[0] * forecast->
        data[emlrtDynamicBoundsCheckFastR2012b(i2, 1, i1, &g_emlrtBCI, sp) - 1]
        + phiValues[1] * forecast->data[emlrtDynamicBoundsCheckFastR2012b(i4, 1,
        i3, &h_emlrtBCI, sp) - 1]) + phiValues[2] * forecast->
        data[emlrtDynamicBoundsCheckFastR2012b(i6, 1, i5, &i_emlrtBCI, sp) - 1])
        + PhiValues * forecast->data[emlrtDynamicBoundsCheckFastR2012b(i8, 1, i7,
        &j_emlrtBCI, sp) - 1]) - phiValues[0] * PhiValues * forecast->
        data[emlrtDynamicBoundsCheckFastR2012b(i10, 1, i9, &k_emlrtBCI, sp) - 1])
        - phiValues[1] * PhiValues * forecast->
        data[emlrtDynamicBoundsCheckFastR2012b(i12, 1, i11, &l_emlrtBCI, sp) - 1])
        - phiValues[2] * PhiValues * forecast->
        data[emlrtDynamicBoundsCheckFastR2012b(i14, 1, i13, &m_emlrtBCI, sp) - 1];
    }

    c_k++;
    emlrtBreakCheckFastR2012b(emlrtBreakCheckR2012bFlagVar, sp);
  }
}

/* End of code generation (forecastSarmaHyndmanMex.c) */
