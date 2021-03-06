#CFLAGS += -std=c++11 -O2 -DNDEBUG -Wall -Wextra -Wfatal-errors
CFLAGS += -std=c++11 -g -O0 -Wall -Wextra -Wfatal-errors

CFLAGS += -I../../include -I../../../hw/simulate -I../../../hw

# control RTL debug print states
DBG_PRINT_FLAGS += -DDBG_PRINT_CORE_ICACHE
DBG_PRINT_FLAGS += -DDBG_PRINT_CORE_DCACHE
DBG_PRINT_FLAGS += -DDBG_PRINT_CACHE_BANK 
DBG_PRINT_FLAGS += -DDBG_PRINT_CACHE_SNP 
DBG_PRINT_FLAGS += -DDBG_PRINT_CACHE_MSRQ
DBG_PRINT_FLAGS += -DDBG_PRINT_DRAM      
DBG_PRINT_FLAGS += -DDBG_PRINT_PIPELINE  
DBG_PRINT_FLAGS += -DDBG_PRINT_OPAE

DBG_FLAGS += $(DBG_PRINT_FLAGS)
DBG_FLAGS += -DDBG_CORE_REQ_INFO

#CONFIGS += -DNUM_CLUSTERS=2 -DNUM_CORES=4 -DL2_ENABLE=1
#CONFIGS += -DNUM_CLUSTERS=1 -DNUM_CORES=4 -DL2_ENABLE=1
CONFIGS += -DNUM_CLUSTERS=1 -DNUM_CORES=2 -DL2_ENABLE=0
#CONFIGS += -DNUM_CLUSTERS=1 -DNUM_CORES=1

#DEBUG=1

CFLAGS += -fPIC

CFLAGS += -DUSE_RTLSIM $(CONFIGS)

CFLAGS += -DDUMP_PERF_STATS

LDFLAGS += -shared -pthread
# LDFLAGS += -dynamiclib -pthread

TOP = Vortex

RTL_DIR = ../../hw/rtl

SRCS = vortex.cpp ../common/vx_utils.cpp ../../hw/simulate/simulator.cpp
SRCS += $(RTL_DIR)/fp_cores/svdpi/float_dpi.cpp

FPU_INCLUDE = -I$(RTL_DIR)/fp_cores -I$(RTL_DIR)/fp_cores/svdpi -I$(RTL_DIR)/fp_cores/fpnew/src/common_cells/include -I$(RTL_DIR)/fp_cores/fpnew/src/common_cells/src -I$(RTL_DIR)/fp_cores/fpnew/src/fpu_div_sqrt_mvp/hdl -I$(RTL_DIR)/fp_cores/fpnew/src 
RTL_INCLUDE = -I$(RTL_DIR) -I$(RTL_DIR)/libs -I$(RTL_DIR)/interfaces -I$(RTL_DIR)/cache $(FPU_INCLUDE)

VL_FLAGS += --language 1800-2009 --assert -Wall -Wpedantic $(CONFIGS)
VL_FLAGS += -Wno-DECLFILENAME
VL_FLAGS += --x-initial unique --x-assign unique
VL_FLAGS += verilator.vlt

# Enable Verilator multithreaded simulation
#THREADS ?= $(shell python3 -c 'import multiprocessing as mp; print(max(1, mp.cpu_count() // 2))')
#VL_FLAGS += --threads $(THREADS)

# Debugigng
ifdef DEBUG
	VL_FLAGS += -DVCD_OUTPUT --assert --trace $(DBG_FLAGS)
	CFLAGS   += -DVCD_OUTPUT $(DBG_FLAGS)
else    
	VL_FLAGS += -DNDEBUG
	CFLAGS   += -DNDEBUG
endif

PROJECT = libvortex.so
# PROJECT = libvortex.dylib

all: $(PROJECT)
	
$(PROJECT): $(SRCS)
	verilator --exe --cc $(TOP) --top-module $(TOP) $(RTL_INCLUDE) $(VL_FLAGS) $(SRCS) -CFLAGS '$(CFLAGS)' -LDFLAGS '$(LDFLAGS)' -o ../$(PROJECT)
	OPT_FAST="-O0 -g" make -j -C obj_dir -f V$(TOP).mk

clean:
	rm -rf $(PROJECT) obj_dir
