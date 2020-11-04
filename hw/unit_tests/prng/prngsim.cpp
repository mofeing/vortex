#include "prngsim.h"
#include <fstream>
#include <iomanip>
#include <iostream>
#include <vector>
#include <map>

uint64_t timestamp = 0;

double sc_time_stamp() {
  return timestamp;
}

PRNGSim::PRNGSim() {
  // force random values for uninitialized signals
  Verilated::randReset(2);

  prng_ = new VVX_prng();

  Verilated::traceEverOn(true);
  trace_ = new VerilatedVcdC;
  prng_->trace(trace_, 99);
  trace_->open("trace.vcd");
}

PRNGSim::~PRNGSim() {
  trace_->close();
  delete prng_;
}

void PRNGSim::reset() {
#ifndef NDEBUG
  std::cout << timestamp << ": [sim] reset()" << std::endl;
#endif

  prng_->reset = 1;
  this->step();
  prng_->reset = 0;
  this->step();
}

void PRNGSim::step() {
  //toggle clock
  prng_->clk = 0;
  this->eval();

  prng_->clk = 1;
  this->eval();
}

void PRNGSim::populateFromOutput(uint64_t &set) {
	set = prng_->rnd;
}

void PRNGSim::eval() {
  prng_->eval();
  trace_->dump(timestamp);
  ++timestamp;
}