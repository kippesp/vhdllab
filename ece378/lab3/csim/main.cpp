#include <stdio.h>
#include <cstdlib>
#include <cassert>

#include "float.h"

// Implementation of a simulated floating point adder

// output a if s==0
uint32_t mux2(uint8_t s, uint32_t a, uint32_t b)
{
  if (s == 0)
    return a;
  else
    return b;
}

// output a if s==0
uint8_t mux2(uint8_t s, uint8_t a, uint8_t b)
{
  if (s == 0)
    return a;
  else
    return b;
}

// This component computes the absolute value of the difference of two unsigned
// numbers (e1 and e2). It also generates the signal sm.
uint8_t uAbsSign(uint8_t a, uint8_t b, uint8_t& sm)
{
  if (a >= b)
    sm = 0;
  else
    sm = 1;

  int32_t a32 = a;
  int32_t b32 = b;

  return static_cast<uint8_t>(abs(a32 - b32));
}

typedef enum {LEFT = 0, RIGHT = 1} bs_dir_t;
typedef enum {LOGICAL = 0, ARITHMETIC = 1} bs_mode_t;

uint32_t barrelShifter(uint32_t a, uint8_t dist, bs_dir_t dir, bs_mode_t mode)
{
  if (dir == LEFT)
  {
    return a << dist;
  }
  else
  {
    if (mode == ARITHMETIC)
    {
      union sa_t {
        uint32_t u;
        int32_t i;
      } sa;

      sa.u = a;

      return sa.i >> dist;
    }
    else
    {
      return a >> dist;
    }
  }
}

// convert magnitute, a, and sign, sg, into two complement number
int32_t smTo2c(uint32_t a, uint8_t sg)
{
  union sa_t {
    uint32_t u;
    int32_t i;
  } sa;

  assert(sg <= 1);
  assert(a <= 0x0FFFFFFF);

  sa.u = a;

  if (sg == 0)
  {
    return sa.i;
  }

  sa.i = 0 - sa.i;
  sa.i = sa.i;

  return sa.i;
}

typedef enum {ADD, SUBTRACT} operation_t;

// Count leading zeros plus first 1
uint8_t lzd(uint32_t a, bs_dir_t& sg)
{
  //uint32_t leading_one = 1 << (23 - 1 + 2);
  uint32_t output = 23;

  sg = LEFT;

  if      (a & 0x01000000) { output = 1; sg = RIGHT; }
  else if (a & 0x00800000) output =  0;
  else if (a & 0x00400000) output =  1;
  else if (a & 0x00200000) output =  2;
  else if (a & 0x00100000) output =  3;
  else if (a & 0x00080000) output =  4;
  else if (a & 0x00040000) output =  5;
  else if (a & 0x00020000) output =  6;
  else if (a & 0x00010000) output =  7;
  else if (a & 0x00008000) output =  8;
  else if (a & 0x00004000) output =  9;
  else if (a & 0x00002000) output = 10;
  else if (a & 0x00001000) output = 11;
  else if (a & 0x00000800) output = 12;
  else if (a & 0x00000400) output = 13;
  else if (a & 0x00000200) output = 14;
  else if (a & 0x00000100) output = 15;
  else if (a & 0x00000080) output = 16;
  else if (a & 0x00000040) output = 17;
  else if (a & 0x00000020) output = 18;
  else if (a & 0x00000010) output = 19;
  else if (a & 0x00000008) output = 20;
  else if (a & 0x00000004) output = 21;
  else if (a & 0x00000002) output = 22;
  else if (a & 0x00000001) output = 23;
  else assert(1); // don't support A+B == 0

  return output;
}

int main()
{
  operation_t operation = SUBTRACT;

  hwfloat_t A = 0x60a10000u;
  hwfloat_t B = 0xc2f97000u;

  //hwfloat_t A = 97982074617856.0f;
  //hwfloat_t B = -130.71875f;

  hwfloat_t C;
  if (operation == SUBTRACT)
    C.f = A.f + B.f;
  else
    C.f = A.f - B.f;

  printf("(A) x %08x = %a\n", A.u, A.f);
  printf("(A) E 0x%02x = %d\n", A.r.e, A.r.e);
  printf("(A) p 0x%02x\n", A.r.p);

  printf("(B) x %08x = %a\n", B.u, B.f);
  printf("(B) E 0x%02x = %d\n", B.r.e, B.r.e);
  printf("(B) p 0x%02x\n", B.r.p);

  printf("\n(C) x %08x = %a\n", C.u, C.f);
  printf("(C) E 0x%02x = %d\n", C.r.e, C.r.e);
  printf("(C) p 0x%02x\n", C.r.p);

  /*
  printf("x %08x\n", barrelShifter(A.u, 0, LEFT, LOGICAL));
  printf("x %08x\n", barrelShifter(A.u, 1, LEFT, LOGICAL));
  printf("x %08x\n", barrelShifter(A.u, 2, LEFT, LOGICAL));
  printf("x %08x\n", barrelShifter(A.u, 3, LEFT, LOGICAL));
  printf("x %08x\n", barrelShifter(A.u, 4, LEFT, LOGICAL));
  */

  /*
  printf("s 0x%01x\n", C.r.s);
  printf("E 0x%02x = %d\n", C.r.e, C.r.e);
  printf("p 0x%06x\n", C.r.p);
  printf("x 0x%08x\n", C.u);

  printf("x %08x\n", C.u);
  printf("f %f\n", C.f);

  printf("e: %d\n", C.r.e - BIAS);
  */

  uint8_t sm; // 0 if A.r.e is larger, 1 otherwise
  uint8_t uAbsSign_out = uAbsSign(A.r.e, B.r.e, sm);

  // Choose the greater exponent
  uint32_t ep = mux2(sm, A.r.e, B.r.e);

  // Of the greater exponent, choose its significand, f
  uint32_t fy = mux2(sm, A.r.p, B.r.p);

  // Of the lesser exponent, choose its significand, f
  uint32_t fx = mux2(sm, B.r.p, A.r.p);

  // restore the implicit 1
  uint32_t sy = fy | (1 << PSIZE);
  uint32_t sx = fx | (1 << PSIZE);

  // normalize to the larger exponent (i.e. shift right the smaller mantissa)
  uint32_t sx_normalized = barrelShifter(sx, uAbsSign_out, RIGHT, ARITHMETIC);

  // t1 <-- sy if A.r.e is larger
  // t1 <-- sx_normalized otherwise
  uint32_t t1 = mux2(sm, sy, sx_normalized);

  // t2 <-- sx_normalized if A.r.e is larger
  // t2 <-- sy otherwise
  uint32_t t2 = mux2(sm, sx_normalized, sy);

  // Convert t1 and t2 into 2s complement form
  int32_t t1_smTo2c = smTo2c(t1, A.r.s);
  int32_t t2_smTo2c = smTo2c(t2, B.r.s);

  hwfloat_t t1_oper_t2;

  // Perform the operation on the mantissa bits
  if (operation == ADD)
    t1_oper_t2.i = t1_smTo2c + t2_smTo2c;
  else
    t1_oper_t2.i = t1_smTo2c - t2_smTo2c;

  // Save the new sign bit
  uint8_t sg = t1_oper_t2.r.s;

  // Convert to magnitude representation
  uint32_t t1_oper_t2_uAbs = abs(t1_oper_t2.i);

  // Identify number of leading zeros plus implicit 1
  bs_dir_t dir;
  uint8_t shift = lzd(t1_oper_t2_uAbs, dir);

  // Shift magnitude to 01.bbbb bbbb bbbb bbbb bbbb bbb form
  uint32_t t1_oper_t2_shifted = barrelShifter(t1_oper_t2_uAbs, shift, dir, LOGICAL);

  // Mask off 01. bits
  hwfloat_t f = t1_oper_t2_shifted & PMASK;

  // Include the shifting of the barrel shifter
  if (dir == LEFT)
    f.r.e = ep - shift;
  else
    f.r.e = ep + shift;

  f.r.s = sg;

  printf("\n(f) x %08x = %a\n", f.u, f.f);
  printf("(f) E 0x%02x = %d\n", f.r.e, f.r.e);
  printf("(f) p 0x%02x\n", f.r.p);
}
