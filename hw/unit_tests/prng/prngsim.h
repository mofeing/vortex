#pragma once

#include "VVX_prng.h"
#include "VVX_prng__Syms.h"
#include "verilated.h"

//#ifdef VCD_OUTPUT
#include <verilated_vcd_c.h>
//#endif

//#include <VX_config.h>
#include <ostream>
#include <vector>
#include <queue>
#include <bitset>

#ifndef NNUM
#define NNUM 2
#endif

class PRNGSim {
public:
  PRNGSim();
  virtual ~PRNGSim();

  void reset();
  void step();
  void populateFromOutput(uint64_t &set);

  private:
  void eval();
  VVX_prng *prng_;
  VerilatedVcdC *trace_;
};
