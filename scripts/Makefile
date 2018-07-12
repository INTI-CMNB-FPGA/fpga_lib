#!/usr/bin/make

PATTERN = 00110000101001011001001101010110

test: python2 python3
	diff temp/rom_bin_python2.vhdl temp/rom_bin_python3.vhdl
	diff temp/rom_hex_python2.vhdl temp/rom_hex_python3.vhdl
	ghdl -a --workdir=temp temp/*.vhdl

python2 python3:
	@mkdir -p temp
	echo $(PATTERN) | $@ text2rom.py -w 16 -n ROM > temp/rom_bin_$@.vhdl
	echo $(PATTERN) | $@ bin2hex.py | $@ text2rom.py -w 16 -n ROM > temp/rom_hex_$@.vhdl

clean:
	rm -fr temp
