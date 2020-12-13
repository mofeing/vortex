#ifndef VX_FLUSH_H
#define VX_FLUSH_H

#ifdef __cplusplus
extern "C" {
#endif

// Flush all L1-Dcaches
void vx_flush_l1();

// Send reseed trigger to L1 Dcache
void vx_prng_reseed();

#ifdef __cplusplus
}
#endif

#endif