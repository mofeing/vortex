#include "hammingsim.h"
#include <iostream>
#include <fstream>
#include <iomanip>
#include <cassert>
#include <climits>

#define VCD_OUTPUT 1
#define NBUCKETS 16

int main(int argc, char **argv) {
	//init
	ECCSim sim;
	// sim.step();
	for (int i = 0; i < 1; ++i)
		std::cout << std::bitset<32>(sim.calculate(0b001011001)) << std::endl;

	return 0;
}
