#include "randomsim.h"
#include <fstream>
#include <iomanip>
#include <iostream>
#include <vector>
#include <map>

uint64_t timestamp = 0;

double sc_time_stamp() {
  return timestamp;
}

RandomSim::RandomSim() {
  // force random values for uninitialized signals
  Verilated::randReset(2);

  random_ = new VVX_random_placement();

  Verilated::traceEverOn(true);
  trace_ = new VerilatedVcdC;
  random_->trace(trace_, 99);
  trace_->open("trace.vcd");
}

RandomSim::~RandomSim() {
  trace_->close();
  delete random_;
}

void RandomSim::reset() {
#ifndef NDEBUG
  std::cout << timestamp << ": [sim] reset()" << std::endl;
#endif

  random_->reset = 1;
  this->step();
  random_->reset = 0;
  this->step();
}

void RandomSim::reseed() {
	random_->reseed = 1;
	this->step();
	random_->reseed = 0;
	this->step();
}

void RandomSim::step() {
  //toggle clock
  random_->clk = 0;
  this->eval();

  random_->clk = 1;
  this->eval();
}

void RandomSim::eval() {
  random_->eval();
  trace_->dump(timestamp);
  ++timestamp;
}

uint64_t RandomSim::translate(uint64_t addr) {
	random_->raddress = addr;
	random_->waddress = addr;

	// No need to wait a clock cycle but that way we get a trace
	this->step();

	if (random_->rindex != random_->windex) {
		std::cerr << random_->rindex << " != " << random_->windex << std::endl;
	}

	return random_->rindex;
}