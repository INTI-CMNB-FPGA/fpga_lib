#!/usr/bin/make

syn: ise vivado quartus libero

TCLPATH = ../../../fpga_helpers/tcl
include $(TCLPATH)/Makefile

ise vivado quartus libero:
	@echo "##################################################################################"
	@echo "# Running $@"
	@echo "##################################################################################"
	$($@_TCL_SYN) -task syn -opt user $($@_END) > $@_report
	@rm -fr $($@_CLEAN_ALL)

clean-report:
	@rm -fr *_report
