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
	std::vector<uint32_t> input(4);
	input[0] = 0x53B43D04;
	input[1] = 0x00005645;
	input[2] = 0x37B74730;
	input[3] = 0x00005640;

	std::vector<uint32_t> res = sim.calculate(input);

	for (int i = 4; i >= 0; --i)
		std::cout << std::hex << std::setw(8) << std::setfill('0') << res[i];

	std::cout << std::endl;

	return 0;
}
