#include "randomsim.h"
#include <iostream>
#include <fstream>
#include <iomanip>
#include <cassert>
#include <climits>

#define VCD_OUTPUT 1
#define NBUCKETS 16

#ifndef INDEXBITS
#define INDEXBITS 6
#endif

int main(int argc, char **argv) {
	//init
	RandomSim sim;
	sim.reset();
	sim.reseed();

	uint64_t unrepeatable = 1 << INDEXBITS;
	std::vector<int64_t> positions(unrepeatable, -1);

	int periodCollisions = 0;

	uint64_t i;
	for(i = 0; i < unrepeatable; ++i) {
		uint64_t pos = sim.translate(i);

		if (positions[pos] != -1) {
			std::cout << "Same-page collision" << std::endl;
		}

		positions[pos] = i;
	}

	for(i = 0; i < unrepeatable; ++i) {
		uint64_t pos = sim.translate(i+unrepeatable*9898);

		if (positions[pos] == i) {
			++periodCollisions;
		}
	}

	std::cout << "Period collisions: " << periodCollisions << std::endl;

	return 0;
}
