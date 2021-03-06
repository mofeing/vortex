`ifndef VX_CONFIG
`define VX_CONFIG

`include "VX_user_config.vh"

`ifndef NUM_CLUSTERS
`define NUM_CLUSTERS 1
`endif

`ifndef NUM_CORES
`define NUM_CORES 4
`endif

`ifndef NUM_WARPS
`define NUM_WARPS 4
`endif

`ifndef NUM_THREADS
`define NUM_THREADS 4
`endif

`ifndef NUM_BARRIERS
`define NUM_BARRIERS 4
`endif

`ifndef GLOBAL_BLOCK_SIZE
`define GLOBAL_BLOCK_SIZE 16
`endif

`ifndef STARTUP_ADDR
`define STARTUP_ADDR 32'h80000000
`endif

`ifndef SHARED_MEM_BASE_ADDR
`define SHARED_MEM_BASE_ADDR 32'h6FFFF000
`endif

`ifndef IO_BUS_BASE_ADDR
`define IO_BUS_BASE_ADDR 32'hFFFFFF00
`endif

`ifndef IO_BUS_ADDR_COUT
`define IO_BUS_ADDR_COUT 32'hFFFFFFFC
`endif

`ifndef L2_ENABLE
`define L2_ENABLE 0
`endif

`ifndef L3_ENABLE
`define L3_ENABLE (`NUM_CLUSTERS > 1)
`endif

`ifndef EXT_M_DISABLE
`define EXT_M_ENABLE
`endif

`ifndef EXT_F_DISABLE
`define EXT_F_ENABLE
`endif

`ifndef SPLIT_EN
`define SPLIT_EN 0
`endif

//`define FPU_FAST

// Device identification
`define VENDOR_ID           0
`define ARCHITECTURE_ID     0
`define IMPLEMENTATION_ID   0

///////////////////////////////////////////////////////////////////////////////

`ifndef LATENCY_IMUL
`define LATENCY_IMUL 3
`endif

`ifndef LATENCY_FNONCOMP
`define LATENCY_FNONCOMP 1
`endif

`ifndef LATENCY_FADDMUL
`define LATENCY_FADDMUL 3
`endif

`ifndef LATENCY_FMADD
`define LATENCY_FMADD 4
`endif

`ifndef LATENCY_FDIV
`define LATENCY_FDIV 15
`endif

`ifndef LATENCY_FSQRT
`define LATENCY_FSQRT 10
`endif

`ifndef LATENCY_ITOF
`define LATENCY_ITOF 7
`endif

`ifndef LATENCY_FTOI
`define LATENCY_FTOI 3
`endif

`ifndef LATENCY_FDIVSQRT
`define LATENCY_FDIVSQRT 10
`endif

`ifndef LATENCY_FCONV
`define LATENCY_FCONV 3
`endif

// CSR Addresses //////////////////////////////////////////////////////////////

`define CSR_FFLAGS      12'h001
`define CSR_FRM         12'h002
`define CSR_FCSR        12'h003

`define CSR_LTID        12'h020
`define CSR_LWID        12'h021
`define CSR_GTID        12'h022
`define CSR_GWID        12'h023
`define CSR_GCID        12'h024
`define CSR_NT          12'h025
`define CSR_NW          12'h026
`define CSR_NC          12'h027

`define CSR_SATP        12'h180

`define CSR_PMPCFG0     12'h3A0
`define CSR_PMPADDR0    12'h3B0

`define CSR_MSTATUS     12'h300
`define CSR_MISA        12'h301
`define CSR_MEDELEG     12'h302
`define CSR_MIDELEG     12'h303
`define CSR_MIE         12'h304
`define CSR_MTVEC       12'h305

`define CSR_MEPC        12'h341

`define CSR_CYCLE       12'hC00
`define CSR_CYCLE_H     12'hC80
`define CSR_INSTRET     12'hC02
`define CSR_INSTRET_H   12'hC82

`define CSR_MVENDORID   12'hF11
`define CSR_MARCHID     12'hF12
`define CSR_MIMPID      12'hF13
`define CSR_MHARTID     12'hF14

`define CSR_CACHE_SPLIT	12'hE00
`define CSR_PRNG_RESEED	12'hE01

// Pipeline Queues ============================================================

// Size of instruction queue
`ifndef IBUF_SIZE
`define IBUF_SIZE 8
`endif

// Size of LSU Request Queue
`ifndef LSUQ_SIZE
`define LSUQ_SIZE 8
`endif

// Size of MUL Request Queue
`ifndef MULQ_SIZE
`define MULQ_SIZE 8
`endif

// Size of FPU Request Queue
`ifndef FPUQ_SIZE
`define FPUQ_SIZE 8
`endif

// Dcache Configurable Knobs ==================================================

// Size of cache in bytes
`ifndef DCACHE_SIZE
`define DCACHE_SIZE 4096
`endif

// Size of line inside a bank in bytes
`ifndef DBANK_LINE_SIZE
`define DBANK_LINE_SIZE `GLOBAL_BLOCK_SIZE
`endif

// Number of banks {1, 2, 4, 8,...}
`ifndef DNUM_BANKS
`define DNUM_BANKS 4
`endif

// Size of a word in bytes
`ifndef DWORD_SIZE
`define DWORD_SIZE 4
`endif

// Core Request Queue Size
`ifndef DCREQ_SIZE
`define DCREQ_SIZE `NUM_WARPS
`endif

// Miss Reserv Queue Knob
`ifndef DMRVQ_SIZE
`define DMRVQ_SIZE `MAX(`NUM_WARPS*`NUM_THREADS, 8)
`endif

// Dram Fill Rsp Queue Size
`ifndef DDFPQ_SIZE
`define DDFPQ_SIZE 8
`endif

// Snoop Req Queue Size
`ifndef DSNRQ_SIZE
`define DSNRQ_SIZE 8
`endif

// Core Writeback Queue Size
`ifndef DCWBQ_SIZE
`define DCWBQ_SIZE `DCREQ_SIZE
`endif

// Dram Writeback Queue Size
`ifndef DDWBQ_SIZE
`define DDWBQ_SIZE 4
`endif

// Dram Fill Req Queue Size
`ifndef DDFQQ_SIZE
`define DDFQQ_SIZE `DCREQ_SIZE
`endif

// Icache Configurable Knobs ==================================================

// Size of cache in bytes
`ifndef ICACHE_SIZE
`define ICACHE_SIZE 2048
`endif

// Size of line inside a bank in bytes
`ifndef IBANK_LINE_SIZE
`define IBANK_LINE_SIZE `GLOBAL_BLOCK_SIZE
`endif

// Number of banks {1, 2, 4, 8,...}
`ifndef INUM_BANKS
`define INUM_BANKS 1
`endif

// Size of a word in bytes
`ifndef IWORD_SIZE
`define IWORD_SIZE 4
`endif

// Core Request Queue Size
`ifndef ICREQ_SIZE
`define ICREQ_SIZE `NUM_WARPS
`endif

// Miss Reserv Queue Knob
`ifndef IMRVQ_SIZE
`define IMRVQ_SIZE `MAX(`ICREQ_SIZE, 8)
`endif

// Dram Fill Rsp Queue Size
`ifndef IDFPQ_SIZE
`define IDFPQ_SIZE 8
`endif

// Core Writeback Queue Size
`ifndef ICWBQ_SIZE
`define ICWBQ_SIZE `ICREQ_SIZE
`endif

// Dram Writeback Queue Size
`ifndef IDWBQ_SIZE
`define IDWBQ_SIZE 8
`endif

// Dram Fill Req Queue Size
`ifndef IDFQQ_SIZE
`define IDFQQ_SIZE `ICREQ_SIZE
`endif

// SM Configurable Knobs ======================================================

// Size of cache in bytes
`ifndef SCACHE_SIZE
`define SCACHE_SIZE 1024
`endif

// Size of line inside a bank in bytes
`ifndef SBANK_LINE_SIZE
`define SBANK_LINE_SIZE `GLOBAL_BLOCK_SIZE
`endif

// Number of banks {1, 2, 4, 8,...}
`ifndef SNUM_BANKS
`define SNUM_BANKS 4
`endif

// Size of a word in bytes
`ifndef SWORD_SIZE
`define SWORD_SIZE 4
`endif

// Core Request Queue Size
`ifndef SCREQ_SIZE
`define SCREQ_SIZE `NUM_WARPS
`endif

// Core Writeback Queue Size
`ifndef SCWBQ_SIZE
`define SCWBQ_SIZE `SCREQ_SIZE
`endif

// L2cache Configurable Knobs =================================================

// Size of cache in bytes
`ifndef L2CACHE_SIZE
`define L2CACHE_SIZE 4096
`endif

// Size of line inside a bank in bytes
`ifndef L2BANK_LINE_SIZE
`define L2BANK_LINE_SIZE `GLOBAL_BLOCK_SIZE
`endif

// Number of banks {1, 2, 4, 8,...}
`ifndef L2NUM_BANKS
`define L2NUM_BANKS 4
`endif

// Size of a word in bytes
`ifndef L2WORD_SIZE
`define L2WORD_SIZE `L2BANK_LINE_SIZE
`endif

// Core Request Queue Size
`ifndef L2CREQ_SIZE
`define L2CREQ_SIZE 8
`endif

// Miss Reserv Queue Knob
`ifndef L2MRVQ_SIZE
`define L2MRVQ_SIZE `MAX(`L2CREQ_SIZE, 8)
`endif

// Dram Fill Rsp Queue Size
`ifndef L2DFPQ_SIZE
`define L2DFPQ_SIZE 8
`endif

// Snoop Req Queue Size
`ifndef L2SNRQ_SIZE
`define L2SNRQ_SIZE 8
`endif

// Core Writeback Queue Size
`ifndef L2CWBQ_SIZE
`define L2CWBQ_SIZE `L2CREQ_SIZE
`endif

// Dram Writeback Queue Size
`ifndef L2DWBQ_SIZE
`define L2DWBQ_SIZE 8
`endif

// Dram Fill Req Queue Size
`ifndef L2DFQQ_SIZE
`define L2DFQQ_SIZE `L2CREQ_SIZE
`endif

// L3cache Configurable Knobs =================================================

// Size of cache in bytes
`ifndef L3CACHE_SIZE
`define L3CACHE_SIZE 8192
`endif

// Size of line inside a bank in bytes
`ifndef L3BANK_LINE_SIZE
`define L3BANK_LINE_SIZE `GLOBAL_BLOCK_SIZE
`endif

// Number of banks {1, 2, 4, 8,...}
`ifndef L3NUM_BANKS
`define L3NUM_BANKS 4
`endif

// Size of a word in bytes
`ifndef L3WORD_SIZE
`define L3WORD_SIZE `L3BANK_LINE_SIZE
`endif

// Core Request Queue Size
`ifndef L3CREQ_SIZE
`define L3CREQ_SIZE 8
`endif

// Miss Reserv Queue Knob
`ifndef L3MRVQ_SIZE
`define L3MRVQ_SIZE `MAX(`L3CREQ_SIZE, 8)
`endif

// Dram Fill Rsp Queue Size
`ifndef L3DFPQ_SIZE
`define L3DFPQ_SIZE 8
`endif

// Snoop Req Queue Size
`ifndef L3SNRQ_SIZE
`define L3SNRQ_SIZE 8
`endif

// Core Writeback Queue Size
`ifndef L3CWBQ_SIZE
`define L3CWBQ_SIZE `L3CREQ_SIZE
`endif

// Dram Writeback Queue Size
`ifndef L3DWBQ_SIZE
`define L3DWBQ_SIZE 8
`endif

// Dram Fill Req Queue Size
`ifndef L3DFQQ_SIZE
`define L3DFQQ_SIZE `L3CREQ_SIZE
`endif

`endif
