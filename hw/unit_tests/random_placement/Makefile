PARAM += -DINDEXBITS=6 -DADDRESSBITS=24 -DCONTROLBITS=12

# control RTL debug print states
DBG_PRINT_FLAGS = -DDBG_PRINT_CORE_ICACHE \
				  -DDBG_PRINT_CORE_DCACHE \
			      -DDBG_PRINT_CACHE_BANK  \
				  -DDBG_PRINT_CACHE_SNP   \
				  -DDBG_PRINT_CACHE_MSRQ  \
				  -DDBG_PRINT_DRAM        \
				  -DDBG_PRINT_OPAE

#DBG_PRINT=$(DBG_PRINT_FLAGS)

INCLUDE = -I../../rtl/ -I../../rtl/cache -I../../rtl/libs


SRCS = randomsim.cpp testbench.cpp

all: build

CF += -std=c++11 -fms-extensions -I../..

VF += --language 1800-2009 --assert -Wall --trace #-Wpedantic
VF += -Wno-DECLFILENAME
VF += --x-initial unique
VF += -exe $(SRCS) $(INCLUDE)

DBG += -DVCD_OUTPUT $(DBG_PRINT)


gen:
	verilator $(VF) -DNDEBUG -cc VX_random_placement.v $(PARAM) -CFLAGS '$(CF) -DNDEBUG $(PARAM)' --exe $(SRCS)

build: gen
	(cd obj_dir && make -j -f VVX_random_placement.mk)

run: build
	(cd obj_dir && ./VVX_random_placement)

clean:
	rm -rf obj_dir
