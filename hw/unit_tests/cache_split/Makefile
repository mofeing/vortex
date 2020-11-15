VPARAM = -GCACHE_SIZE=4096 -GWORD_SIZE=4 -GBANK_LINE_SIZE=16 -GNUM_BANKS=8 -GNUM_REQUESTS=4 -GCREQ_SIZE=4 -GMRVQ_SIZE=16 -GDFPQ_SIZE=16 -GSNRQ_SIZE=16 -GCWBQ_SIZE=4 -GDWBQ_SIZE=4 -GDFQQ_SIZE=4 -GSPLIT_CAPABLE=1
PARAM += -DCACHE_SIZE=4096 -DWORD_SIZE=4 -DBANK_LINE_SIZE=16 -DNUM_BANKS=8 -DNUM_REQUESTS=4 -DCREQ_SIZE=4 -DMRVQ_SIZE=16 -DDFPQ_SIZE=16 -DSNRQ_SIZE=16 -DCWBQ_SIZE=4 -DDWBQ_SIZE=4 -DDFQQ_SIZE=4 -DSPLIT_CAPABLE=1

# control RTL debug print states
DBG_PRINT_FLAGS = -DDBG_PRINT_CORE_ICACHE \
				  -DDBG_PRINT_CORE_DCACHE \
			      -DDBG_PRINT_CACHE_BANK  \
				  -DDBG_PRINT_CACHE_SNP   \
				  -DDBG_PRINT_CACHE_MSRQ  \
				  -DDBG_PRINT_DRAM        \
				  -DDBG_PRINT_OPAE

INCLUDE = -I../../rtl/ -I../../rtl/cache -I../../rtl/libs


SRCS = cachesim.cpp testbench.cpp

all: build

CF += -std=c++11 -fms-extensions -I../..

VF += --language 1800-2009 --assert -Wall --trace #-Wpedantic
VF += -Wno-DECLFILENAME
VF += --x-initial unique
VF += -exe $(SRCS) $(INCLUDE)

DBG += -DVCD_OUTPUT $(DBG_PRINT)


gen:
	verilator $(VF) -DNDEBUG -cc VX_cache.v $(VPARAM) $(PARAM) -CFLAGS '$(CF) -DNDEBUG $(PARAM)' --exe $(SRCS)

build: gen
	(cd obj_dir && make -j -f VVX_cache.mk)

run: build
	(cd obj_dir && ./VVX_cache && perl -pi -e 's/[^[:ascii:]]//g;' trace.vcd)

correct_trace: trace.vcd
	perl -pi -e 's/[^[:ascii:]]//g;' trace.vcd

clean:
	rm -rf obj_dir
