#include <VX_config.h>

.section .text

.type vx_flush_l1, @function
.global vx_flush_l1
vx_flush_l1:
  li t0, DCACHE_SIZE
loop:
  addi t0, t0, -DBANK_LINE_SIZE; # t0 = t0 - DBANK_LINE_SIZE
  bnez t0, loop
  ret

.type vx_prng_reseed, @function
.global vx_prng_reseed
vx_prng_reseed:
  call vx_flush_l1
  csrrwi t0, CSR_PRNG_RESEED, 1
  ret

.type vx_set_cache_split, @function
.global vx_set_cache_split
vx_set_cache_split:
  csrrw t0, CSR_CACHE_SPLIT, a0
  ret