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