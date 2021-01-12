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
	bool s, d;
	for (int i = 0; i < 1; ++i)
		std::cout << std::bitset<32>(sim.calculate(0b010101001110, s, d)) << std::endl;

	std::cout << "Single: " << s << std::endl;
	std::cout << "Double: " << d << std::endl;

	return 0;
}
