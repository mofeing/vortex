#pragma once

#include "VVX_hamming_dec.h"
#include "VVX_hamming_dec__Syms.h"
#include "verilated.h"

//#ifdef VCD_OUTPUT
#include <verilated_vcd_c.h>
//#endif

//#include <VX_config.h>
#include <ostream>
#include <vector>
#include <queue>
#include <bitset>

class ECCSim {
public:
  ECCSim();
  virtual ~ECCSim();

  uint32_t calculate(uint32_t input, bool &sing, bool &dbl);

  private:
  void eval();
  VVX_hamming_dec *ecc_;
  VerilatedVcdC *trace_;
};
