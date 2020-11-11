#pragma once

#include "VVX_random_placement.h"
#include "VVX_random_placement__Syms.h"
#include "verilated.h"

//#ifdef VCD_OUTPUT
#include <verilated_vcd_c.h>
//#endif

//#include <VX_config.h>
#include <ostream>
#include <vector>
#include <queue>
#include <bitset>

class RandomSim {
public:
  RandomSim();
  virtual ~RandomSim();

  void reset();
  void step();
  void reseed();
  uint64_t translate(uint64_t address);

  private:
  void eval();
  VVX_random_placement *random_;
  VerilatedVcdC *trace_;
};
