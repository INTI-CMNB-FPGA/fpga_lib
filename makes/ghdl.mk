# by RAM, 2015-2017
# Distributed under the BSD 3-Clause License

## Variables ##################################################################

UDIR=$(dir $(lastword $(MAKEFILE_LIST)))..

ifndef LIB
	LIB = work
endif

ifndef ODIR
	ODIR = temp
endif

ifndef TDIR
	TDIR = testbench
endif

PLIBS = $(addprefix -P,$(LIBS)) -P$(UDIR)/temp

FLAGS=$(PLIBS) --work=$(LIB) --workdir=$(ODIR) 
TFLAGS=--ieee-asserts=disable-at-0

## Rules and where to search ##################################################

vpath %.vhdl $(TDIR)
vpath %.o    $(ODIR)
vpath %      $(ODIR)
vpath %.ghw  $(ODIR)

# Analysis and elaboration

%.o: %.vhdl
	@mkdir -p $(ODIR)
	ghdl -a $(FLAGS) $<

%: %.o
	ghdl -e $(FLAGS) -o $(ODIR)/$(@F) $(@F)

# Running and visualization

run_%: %
	$(ODIR)/$(<F) $(TFLAGS)

vcd_% %.vcd: %
	$(ODIR)/$(<F) $(TFLAGS) --vcd=$(ODIR)/$(@F)
ghw_% %.ghw: %
	$(ODIR)/$(<F) $(TFLAGS) --wave=$(ODIR)/$(@F)

see_vcd_%: %.vcd
	gtkwave $(ODIR)/$(<F) &
see_ghw_% see_%: %.ghw
	gtkwave $(ODIR)/$(<F) &

## Common targets #############################################################

all: fpgalib bin

fpgalib:
ifndef STANDALONE
	make -C $(UDIR)/vhdl
endif

clean-all:
	@rm -rf $(ODIR)

help:
	@echo "Being TESTBENCH the name of the entity:"
	@echo "$$ make run_TESTBENCH        Run the testbench"
	@echo "$$ make vcd_TESTBENCH        Run the testbench and generates VCD waveforms"
	@echo "$$ make ghw_TESTBENCH        Run the testbench and generates GHW waveforms"
	@echo "$$ make see_vcd_TESTBENCH    Open GtkWave with the VCD waveform"
	@echo "$$ make see_ghw_TESTBENCH    Open GtkWave with the GHW waveform"
	@echo "$$ make see_TESTBENCH        Open GtkWave with the GHW waveform"
	@echo "Being FILE the basename of a vhdl file:"
	@echo "$$ make FILE.o               Analize FILE.vhdl"
	@echo "Others"
	@echo "$$ make clean-all            Remove Output directory"
