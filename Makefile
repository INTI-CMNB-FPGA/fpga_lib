#!/usr/bin/make

all:
	make -C vhdl

test:
	make -C vhdl test
	make -C testbench/FIFO

clean:
	make -C vhdl clean-all
	make -C testbench/FIFO clean

contributors:
	@git log --format='* %aN <%aE>' | LC_ALL=C.UTF-8 sort -uf > CONTRIBUTORS.md
