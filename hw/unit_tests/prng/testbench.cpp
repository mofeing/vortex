#include "prngsim.h"
#include <iostream>
#include <fstream>
#include <iomanip>
#include <cassert>
#include <climits>

#define VCD_OUTPUT 1
#define NBUCKETS 16

int main(int argc, char **argv) {
	//init
	PRNGSim sim;
	sim.reset();
	sim.step();

	uint64_t result = 0;
	std::vector<int> buckets(NBUCKETS);
	for (int i = 0; i < NBUCKETS; ++i)
		buckets[i] = 0;

	uint64_t split = UINT16_MAX / NBUCKETS;

	for (int i = 0; i < 10000; ++i) {
		sim.step();
		sim.populateFromOutput(result);

		int bucketIndex = result / split;
		assert(bucketIndex < NBUCKETS);
		buckets[bucketIndex]++;
	}

	for (int i = 0; i < NBUCKETS; ++i)
		std::cout << buckets[i] << " | ";

	std::cout << std::endl;

	return 0;
}
