#pragma once

#include "VVX_hamming_enc.h"
#include "VVX_hamming_enc__Syms.h"
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

  std::vector<uint32_t> calculate(std::vector<uint32_t> &input);

  private:
  void eval();
  VVX_hamming_enc *ecc_;
  VerilatedVcdC *trace_;
};
