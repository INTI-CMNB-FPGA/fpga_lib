#!/usr/bin/make

TESTBENCHES = $(wildcard testbench/*)
TESTBENCHES:= $(filter-out README.md/,$(TESTBENCHES))

.PHONY : doc

all:
	make -C vhdl

test:
	@echo $(TESTBENCHES)
	make -C vhdl test
	@$(foreach TESTBENCH,$(TESTBENCHES),$(if $(wildcard $(TESTBENCH)/Makefile), make -C $(TESTBENCH);))

doc:
	@rm -fr doc/html/*
	bash ../fpga_helpers/docker/run.sh "doxygen doc/Doxyfile"

clean:
	make -C vhdl clean-all
	@$(foreach TESTBENCH,$(TESTBENCHES),$(if $(wildcard $(TESTBENCH)/Makefile), make -C $(TESTBENCH) clean;))

contributors:
	@git log --format='* %aN <%aE>' | LC_ALL=C.UTF-8 sort -uf > CONTRIBUTORS.md
