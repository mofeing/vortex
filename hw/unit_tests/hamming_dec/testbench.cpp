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

	std::vector<uint32_t> input(5);
	//100
	input[0] = 0xf687d0ab;
	input[1] = 0x00159154;
	input[2] = 0xdba39800;
	input[3] = 0x002b201b;
	input[4] = 0x00000100;

	std::vector<uint32_t> res = sim.calculate(input, s, d);
	std::cout << "Single: " << s << std::endl;
	std::cout << "Double: " << d << std::endl;

	for (int i = 3; i >= 0; --i)
		std::cout << std::hex << std::setw(8) << std::setfill('0') << res[i];

	std::cout << std::endl;
	return 0;
}
