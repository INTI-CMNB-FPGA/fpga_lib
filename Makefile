#!/usr/bin/make

all:
	make -C vhdl

test:
	make -C vhdl test

clean:
	make -C vhdl clean-all

contributors:
	@git log --format='* %aN <%aE>' | LC_ALL=C.UTF-8 sort -uf > CONTRIBUTORS.md
