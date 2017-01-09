#!/usr/bin/make

all:
	make -C vhdl

test:
	make -C vhdl test

clean:
	make -C vhdl clean-all
