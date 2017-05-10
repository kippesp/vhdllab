#include <cstdint>

const uint32_t PSIZE = 23;
const uint32_t ESIZE = 8;

//   s[  e     ][             p             ]
//   .... .... .... ....  .... .... .... ....
//  / |        | \
// 31 30      23  22                        0
typedef union HardwareFloat
{
  float f;
  uint32_t u;
  int32_t i;
  struct decomposed_float {
    uint32_t p : 23;
    uint32_t e : 8;
    uint32_t s : 1;
  } r;

  HardwareFloat(void) : u(0u) { }

  HardwareFloat(uint32_t v) { u = v; }

  HardwareFloat(int32_t v) { i = v; }

  HardwareFloat(float v) { f = v; }

} hwfloat_t;

const uint32_t BIAS = (1 << (8 - 1)) - 1;

const uint32_t PMASK  = 0x07fffff;
const uint32_t P1MASK = 0x0ffffff;
const uint32_t P2MASK = 0x1ffffff;
const uint32_t P3MASK = 0x3ffffff;
const uint32_t EMASK = 0xff;
