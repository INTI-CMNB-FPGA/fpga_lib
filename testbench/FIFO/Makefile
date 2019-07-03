PWD=$(shell pwd)

export COCOTB_REDUCED_LOG_FMT=1

FPGALIB_SOURCES      = numeric/numeric_pkg.vhdl sync/sync_pkg.vhdl mems/mems_pkg.vhdl sync/ffchain.vhdl sync/gray_sync.vhdl mems/SimpleDualPortRAM.vhdl mems/FIFO.vhdl
VHDL_SOURCES_fpgalib = $(addprefix $(PWD)/../../vhdl/,$(FPGALIB_SOURCES))
VHDL_SOURCES         = $(PWD)/fifo_top.vhdl

TOPLEVEL  = fifo_top
MODULE    = fifo_tb

SIM       = ghdl
SIM_FILE  = fifo.ghw
SIM_ARGS  = --wave=$(SIM_FILE) --ieee-asserts=disable-at-0
SIM_BUILD = build

include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim

# The following is a workaround to support VHDL libraries

analyse: $(VHDL_SOURCES) $(SIM_BUILD)
	cd $(SIM_BUILD) && \
	$(foreach SOURCES_VAR, $(filter VHDL_SOURCES_%, $(.VARIABLES)), \
	$(CMD) -a $(GHDL_ARGS) $(COMPILE_ARGS) --work=$(SOURCES_VAR:VHDL_SOURCES_%=%) $($(SOURCES_VAR)) && ) \
	$(CMD) -a $(GHDL_ARGS) $(COMPILE_ARGS) --work=$(RTL_LIBRARY) $(VHDL_SOURCES) && \
	$(CMD) -e $(GHDL_ARGS) $(COMPILE_ARGS) --work=$(RTL_LIBRARY) $(TOPLEVEL)

view:
	gtkwave $(SIM_BUILD)/$(SIM_FILE)
