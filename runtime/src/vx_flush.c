#ifndef VX_FLUSH_H
#define VX_FLUSH_H

#include <vx_flush.h>

#ifdef __cplusplus
extern "C" {
#endif

// Flushes L1 first and then sends the reseed signals
// Only to be called by the master thread; UB otherwise
void vx_prng_reseed() {
	vx_flush_l1();
	
	//  L1 intercepts the request and interprets it as reseed trigger
  	asm("csrrsi t1,CSR_PRNG_RESEED,1");
}

#ifdef __cplusplus
}
#endif

#endif