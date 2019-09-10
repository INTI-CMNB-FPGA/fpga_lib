#!/usr/bin/make

PATTERN = 00110000101001011001001101010110

VHDLS    = $(wildcard temp/*.vhdl)
VERILOGS = $(wildcard temp/*.v)

DOCKER   = bash ../../fpga_helpers/docker/run.sh
GHDL     = $(DOCKER) ghdl -s --warn-no-library --warn-no-hide --workdir=temp
IVERILOG = $(DOCKER) iverilog -t null

test: python2 python3
	@echo "* Checking differences between Python 2 and 3 versions"
	diff temp/rom_bin_python2.vhdl temp/rom_bin_python3.vhdl
	diff temp/rom_hex_python2.vhdl temp/rom_hex_python3.vhdl
	diff temp/rom_bin_python2.v    temp/rom_bin_python3.v
	diff temp/rom_hex_python2.v    temp/rom_hex_python3.v

python2 python3:
	@mkdir -p temp
	@echo "* Generating VHDL files with $@"
	echo $(PATTERN) | $@ text2rom.py -w 16 -n ROM > temp/rom_bin_$@.vhdl
	$(GHDL) temp/rom_bin_$@.vhdl
	echo $(PATTERN) | $@ bin2hex.py | $@ text2rom.py -w 16 -n ROM > temp/rom_hex_$@.vhdl
	$(GHDL) temp/rom_hex_$@.vhdl
	@echo "* Generating Verilog files with $@"
	echo $(PATTERN) | $@ text2rom.py -w 16 -n ROM -l verilog > temp/rom_bin_$@.v
	$(IVERILOG) temp/rom_bin_$@.v
	echo $(PATTERN) | $@ bin2hex.py | $@ text2rom.py -w 16 -n ROM -l verilog > temp/rom_hex_$@.v
	$(IVERILOG) temp/rom_hex_$@.v

clean:
	rm -fr temp
