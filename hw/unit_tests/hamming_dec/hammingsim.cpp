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

std::vector<uint32_t> ECCSim::calculate(std::vector<uint32_t> &input, bool &sing, bool &dbl) {
	std::copy(input.begin(), input.end(), &(ecc_->encoded[0]));
	// ecc_->data = input;
	this->eval();
	this->eval();
	std::vector<uint32_t> out(ecc_->data, ecc_->data + 4);
	sing = ecc_->corrected;
	dbl = ecc_->invalid;
	return out;
}

void ECCSim::eval() {
  ecc_->eval();
  trace_->dump(timestamp);
  ++timestamp;
}