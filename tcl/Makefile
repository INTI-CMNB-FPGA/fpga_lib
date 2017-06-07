#!/usr/bin/make
#
# Makefile to run Tcl scripts for FPGAs
#
# Copyright (C) 2016-2017 INTI
# Copyright (C) 2016-2017 Rodrigo A. Melo <rmelo@inti.gob.ar>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

ifndef TOOL
   TOOL=vivado
endif

ifeq      ($(TOOL),ise)
else ifeq ($(TOOL),vivado)
else ifeq ($(TOOL),quartus)
else ifeq ($(TOOL),libero)
else
   $(error Unsupported TOOL [ise, vivado, quartus, libero])
endif

ifndef TASK
   TASK=bit
endif

ifeq      ($(TASK),syn)
else ifeq ($(TASK),imp)
else ifeq ($(TASK),bit)
else
   $(error Unsupported TASK [syn, imp, bit])
endif

ifndef OPT
   OPT=user
endif

ifeq      ($(OPT),user)
else ifeq ($(OPT),area)
else ifeq ($(OPT),power)
else ifeq ($(OPT),speed)
else
   $(error Unsupported OPT [user, area, power, speed])
endif

ifndef DEV
   DEV=fpga
endif

ifeq      ($(DEV),fpga)
else ifeq ($(DEV),spi)
else ifeq ($(DEV),bpi)
else ifeq ($(DEV),xcf)
else ifeq ($(DEV),detect)
else ifeq ($(DEV),unlock)
else
   $(error Unsupported DEV [fpga, spi, bpi, xcf])
endif

###############################################################################

ifndef TCLPATH
   TCLPATH=.
endif
SYN_FILE             = $(TCLPATH)/synthesis.tcl
PRG_FILE             = $(TCLPATH)/programming.tcl
BIT_FILE             = $(shell find -type f -name '*.bit' -o -name '*.sof' -o -name '*.pof' -o -name '*.ipd')

# ISE - Xilinx

ise_TCL_SYN          = xtclsh $(SYN_FILE)
ise_TCL_PRG          = xtclsh $(PRG_FILE)
ise_TCL_CON          = xtclsh
ise_GUI              = ise ise.xise
ise_CLEAN            = iseconfig _ngo xst xlnx_auto_0_xdb _xmsgs *.bgn *.bld  \
                       *.cmd_log *.csv *.drc *.gise *.html *.log *.lso *.map  \
                       *.mrp *.ncd *.ngc *.ngd *.ngm *.ngr *.pad *.par *.pcf  \
                       *.prj *.ptwx *.stx *.syr *.twr *.twx *.unroutes *.ut   \
                       *.txt *.xml *.xpi *.xrpt *.xst *.xwbt _impact* temp-ise
ise_CLEAN_ALL        = $(ise_CLEAN) ise.xise

# Vivado - Xilinx

vivado_TCL_SYN       = vivado -mode batch -notrace -quiet -source $(SYN_FILE) -tclargs
vivado_TCL_PRG       = vivado -mode batch -notrace -quiet -source $(PRG_FILE) -tclargs
vivado_TCL_CON       = vivado -mode tcl
vivado_GUI           = vivado vivado.xpr
vivado_CLEAN         = .Xil *.cache *.hw *.ip_user_files *.jou *.log *.rpt    \
                       *.runs *.sim *.srcs vivado_*.zip temp-vivado
vivado_CLEAN_ALL     = $(vivado_CLEAN) vivado.xpr

# Quartus 2/Prime - Intel (Altera)

quartus_TCL_SYN      = quartus_sh --script $(SYN_FILE)
quartus_TCL_PRG      = quartus_sh --script $(PRG_FILE)
quartus_TCL_CON      = quartus_sh -s
quartus_GUI          = quartus quartus.qpf
quartus_CLEAN        = db incremental_db output_files *.done *.jdi *.log *.pin\
                        *.qws *.rpt *.smsg *.sld *.sof *.sop *.summary *.txt  \
                       temp-quartus
quartus_CLEAN_ALL    = $(quartus_CLEAN) quartus.qpf quartus.qsf

# Libero-SoC - Microsemi (Actel)

libero_TCL_SYN       = libero SCRIPT:$(SYN_FILE) SCRIPT_ARGS:"
libero_TCL_PRG       = libero SCRIPT:$(PRG_FILE) SCRIPT_ARGS:"
libero_END           = "
libero_TCL_CON       = @echo console target not supported on Libero-SoC
libero_GUI           = libero temp-libero/libero.prjx
libero_CLEAN         = temp-libero
libero_CLEAN_ALL     = $(libero_CLEAN)

# Assignations according to the selected tool

TCL_SYN              = $($(TOOL)_TCL_SYN)
TCL_PRG              = $($(TOOL)_TCL_PRG)
TCL_END              = $($(TOOL)_END)
TCL_CON              = $($(TOOL)_TCL_CON)
GUI_CMD              = $($(TOOL)_GUI)
CLEAN                = $($(TOOL)_CLEAN)
CLEAN_ALL            = $($(TOOL)_CLEAN_ALL) $(BIT_FILE)
CLEAN_MULTI          = $(ise_CLEAN_ALL) $(vivado_CLEAN_ALL) \
                       $(quartus_CLEAN_ALL) $(libero_CLEAN_ALL)

###############################################################################

all help:
	@echo "Options:"
	@echo "* TOOL: ise , vivado, quartus, libero [default=vivado]"
	@echo "* TASK: syn, imp, bit, prog           [default=bit]"
	@echo "* OPT:  user ,area, power, speed      [default=user]"
	@echo "* DEV:  fpga, spi, bpi, xcf           [default=fpga]"
	@echo "Targets:"
	@echo "* run:         run TASK with the OPTimization using the selected TOOL."
	@echo "* clean:       to delete generated files (excluding project and bitstream files)."
	@echo "* clean-all:   to delete all the generated files."
	@echo "* clean-multi: to delete generated files for all the vendors."
	@echo "* console:     to lunch the Tcl Console of the vendor Tool."
	@echo "* gui:         to lunch the Gui of the vendor Tool."
	@echo "* prog         programming DEVice of the board using the selected TOOL."

run:
	$(TCL_SYN) -task $(TASK) -opt $(OPT) $(TCL_END)

clean:
	@rm -fr $(CLEAN)

clean-all:
	@rm -fr $(CLEAN_ALL)

clean-multi:
	@rm -fr $(CLEAN_MULTI)

console:
	$(TCL_CON)

gui:
	$(GUI_CMD)

###############################################################################

prog:
	$(TCL_PRG) -dev $(DEV) -bit $(BIT_FILE) $(TCL_END)

