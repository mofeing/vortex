#include "hammingsim.h"
#include <fstream>
#include <iomanip>
#include <iostream>
#include <vector>
#include <map>

uint64_t timestamp = 0;

double sc_time_stamp() {
  return timestamp;
}

ECCSim::ECCSim() {
  // force random values for uninitialized signals
  Verilated::randReset(2);

  ecc_ = new VVX_hamming_dec();

  Verilated::traceEverOn(true);
  trace_ = new VerilatedVcdC;
  ecc_->trace(trace_, 99);
  trace_->open("trace.vcd");
  this->eval();
}

ECCSim::~ECCSim() {
  trace_->close();
  delete ecc_;
}

uint32_t ECCSim::calculate(uint32_t input, bool &sing, bool &dbl) {
	ecc_->encoded = input;
	this->eval();
	this->eval();
	sing = ecc_->corrected;
	dbl = ecc_->invalid;
	return ecc_->data;
}

void ECCSim::eval() {
  ecc_->eval();
  trace_->dump(timestamp);
  ++timestamp;
}